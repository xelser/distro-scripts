#!/usr/bin/env bash
# set -euo pipefail # Uncomment this line once debugging is complete and the script works reliably

# --- Configuration ---
ROOT="${1:-.}" # Root directory to start scanning from, defaults to current directory
EXCLUDE_FILE="/mnt/Media/srt_exclude_dirs.txt" # Path to your exclusion file
WORKDIR="./_subs_temp" # Temporary working directory for SUP files

# Define the static part of the signature for checking (without the date)
STATIC_SIGNATURE_PREFIX="[PGS→OCR] Processed on"
# Define the full dynamic signature for writing (includes the current date)
SIGNATURE="${STATIC_SIGNATURE_PREFIX} $(date '+%Y-%m-%d %H:%M')"

# --- Colors for Output ---
COLOR_RESET='\e[0m'
COLOR_RED='\e[31m'
COLOR_GREEN='\e[32m'
COLOR_YELLOW='\e[33m'
COLOR_BLUE='\e[34m'
COLOR_MAGENTA='\e[35m'
COLOR_CYAN='\e[36m'

# --- Functions ---

# Log an informational message (Cyan)
log_info() { echo -e "${COLOR_CYAN}[INFO]${COLOR_RESET} $*"; }
# Log a skip message (Yellow)
log_skip() { echo -e "${COLOR_YELLOW}[SKIP]${COLOR_RESET} $*"; }
# Log a success message (Green)
log_success() { echo -e "${COLOR_GREEN}[DONE]${COLOR_RESET} $*"; }
# Log an extract message (Blue)
log_extract() { echo -e "${COLOR_BLUE}[EXTRACT]${COLOR_RESET} $*"; }
# Log an error message (Red) to stderr
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2; }
# Log a debug message (Magenta) - uncomment the echo line to enable
log_debug() {
    # echo -e "${COLOR_MAGENTA}[DEBUG]${COLOR_RESET} $*" # Uncomment to enable debug logging
    : # Do nothing by default if debug is off
}

# Check if a required command-line tool is installed
check_dependency() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Dependency missing: '$cmd'. Please install it to proceed."
        exit 1
    fi
    log_debug "Dependency found: '$cmd'"
}

# Check all necessary dependencies
check_dependencies() {
    log_info "Checking required command-line tools..."
    check_dependency "mkvmerge"    # For getting MKV info and creating JSON
    check_dependency "mkvextract" # For extracting subtitle tracks
    check_dependency "jq"         # For parsing mkvmerge JSON output
    check_dependency "sup2srt"    # For OCR (PGS to SRT conversion)
    check_dependency "stat"       # For checking file ownership
    log_info "All required tools found."
}

# Determine if a file/path should be excluded based on EXCLUDE_FILE or owner
should_exclude() {
    local full_path="$1"
    local file_owner=""

    file_owner=$(stat -c %U "$full_path" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        log_error "Failed to get owner for '$full_path'. Treating as excluded for safety."
        return 0
    fi

    if [[ "$file_owner" == "jellyfin" ]]; then
        log_skip "Excluding '$full_path': Owned by 'jellyfin'."
        return 0
    fi

    [[ -f "$EXCLUDE_FILE" ]] || return 1

    while IFS= read -r exclude_pattern; do
        [[ -z "$exclude_pattern" || "${exclude_pattern:0:1}" == "#" ]] && continue
        exclude_pattern="$(echo "$exclude_pattern" | xargs)"
        if [[ "$full_path" == *"$exclude_pattern"* ]]; then
            log_skip "Excluding '$full_path': Matches pattern '$exclude_pattern' in '$EXCLUDE_FILE'."
            return 0
        fi
    done < "$EXCLUDE_FILE"

    return 1
}

# --- Main Script Logic ---

check_dependencies

log_info "Starting subtitle processing. Working directory: '$WORKDIR'"
mkdir -p "$WORKDIR" || { log_error "Failed to create working directory: $WORKDIR"; exit 1; }

# ---------- Processing Phase (Priority: Text > PGS) ----------
find "$ROOT" -type f -name "*.mkv" -print0 | while IFS= read -r -d $'\0' FILE; do
    BASENAME="$(basename "$FILE" .mkv)"
    DIRNAME="$(dirname "$FILE")"

    if should_exclude "$FILE"; then
        continue
    fi

    log_info "Scanning → $BASENAME"

    MKV_INFO_JSON=$(mkvmerge -J "$FILE" 2>/dev/null)
    if [[ $? -ne 0 || -z "$MKV_INFO_JSON" ]]; then
        log_error "Failed to get mkvmerge JSON info for $FILE. Skipping."
        continue
    fi
    
    # Use jq to get all suitable English subtitle tracks with all relevant properties
    mapfile -t SUB_TRACKS < <(
        echo "$MKV_INFO_JSON" | jq -r '
            .tracks[] |
            select(
                .type == "subtitles" and
                .properties.language == "eng" and
                (.properties.codec_id | test("^(S_TEXT/UTF8|S_TEXT/ASS|S_HDMV/PGS)$"))
            ) |
            "\(.id)|\(.properties.codec_id)|\(.properties.language)|\(.properties.num_index_entries // 0)|\(.properties.track_name // "")|\(.properties.forced_track)|\(.properties.default_track)|\(.properties.hearing_impaired)"
        '
    )
    
    if [[ ${#SUB_TRACKS[@]} -eq 0 ]]; then
        log_skip "No suitable English subtitle tracks found for: $BASENAME."
        continue
    fi
    
    log_info "Found ${#SUB_TRACKS[@]} suitable English tracks to process."
    
    # --- Priority 1: Check for text-based tracks (SRT or ASS) ---
    BEST_TEXT_ID=""
    BEST_TEXT_COUNT=-1
    BEST_TEXT_CODEC=""
    BEST_TEXT_NAME=""
    TEXT_IS_FORCED=false
    TEXT_IS_DEFAULT=false
    TEXT_IS_HI=false
    for DETAIL_STRING in "${SUB_TRACKS[@]}"; do
        IFS='|' read -r current_id codec_id lang current_count track_name forced_track default_track hearing_impaired <<< "$DETAIL_STRING"
        if [[ ("$codec_id" == "S_TEXT/UTF8" || "$codec_id" == "S_TEXT/ASS") && "$current_count" -gt "$BEST_TEXT_COUNT" ]]; then
            BEST_TEXT_ID="$current_id"
            BEST_TEXT_COUNT="$current_count"
            BEST_TEXT_CODEC="$codec_id"
            BEST_TEXT_NAME="$track_name"
            # Set boolean flags
            [[ "$forced_track" == "true" ]] && TEXT_IS_FORCED=true || TEXT_IS_FORCED=false
            [[ "$default_track" == "true" ]] && TEXT_IS_DEFAULT=true || TEXT_IS_DEFAULT=false
            [[ "$hearing_impaired" == "true" || "${track_name^^}" == *"SDH"* || "${track_name^^}" == *"HI"* ]] && TEXT_IS_HI=true || TEXT_IS_HI=false
        fi
    done
    
    if [[ -n "$BEST_TEXT_ID" ]]; then
        OUTPUT_EXT=""
        case "$BEST_TEXT_CODEC" in
            "S_TEXT/UTF8") OUTPUT_EXT="srt";;
            "S_TEXT/ASS")  OUTPUT_EXT="ass";;
        esac
        
        FILENAME_SUFFIX=""
        $TEXT_IS_FORCED && FILENAME_SUFFIX="${FILENAME_SUFFIX}.forced"
        $TEXT_IS_DEFAULT && FILENAME_SUFFIX="${FILENAME_SUFFIX}.default"
        $TEXT_IS_HI && FILENAME_SUFFIX="${FILENAME_SUFFIX}.sdh"

        OUTPUT_PATH="${DIRNAME}/${BASENAME}.eng${FILENAME_SUFFIX}.${OUTPUT_EXT}"
        
        if [[ -f "$OUTPUT_PATH" ]]; then
            if tail -n 10 "$OUTPUT_PATH" | grep -qF "$STATIC_SIGNATURE_PREFIX"; then
                log_skip "Already processed (signature found) → $OUTPUT_PATH"
                continue
            fi
            local existing_owner=$(stat -c %U "$OUTPUT_PATH" 2>/dev/null)
            if [[ "$existing_owner" == "jellyfin" ]]; then
                log_skip "Skipping processing for '$BASENAME': Existing file is untagged and owned by 'jellyfin'."
                continue
            fi
            log_info "Existing untagged file found for $BASENAME. Will overwrite with new version."
        fi
        
        log_extract "Extracting text-based subtitle track $BEST_TEXT_ID with tags '${FILENAME_SUFFIX}' to: $OUTPUT_PATH"
        if ! mkvextract tracks "$FILE" "${BEST_TEXT_ID}:${OUTPUT_PATH}"; then
            log_error "Extraction failed for $BASENAME (Track $BEST_TEXT_ID)."
            rm -f "$OUTPUT_PATH"
        else
            echo "$SIGNATURE" >> "$OUTPUT_PATH"
            log_success "Extraction completed and saved → $OUTPUT_PATH"
        fi
        continue # Processing for this movie is complete, move to the next
    fi

    # --- Priority 2: Fallback to PGS OCR if no text-based tracks were found ---
    BEST_PGS_ID=""
    BEST_PGS_COUNT=-1
    BEST_PGS_NAME=""
    PGS_IS_FORCED=false
    PGS_IS_DEFAULT=false
    PGS_IS_HI=false
    for DETAIL_STRING in "${SUB_TRACKS[@]}"; do
        IFS='|' read -r current_id codec_id lang current_count track_name forced_track default_track hearing_impaired <<< "$DETAIL_STRING"
        if [[ "$codec_id" == "S_HDMV/PGS" && "$current_count" -gt "$BEST_PGS_COUNT" ]]; then
            BEST_PGS_ID="$current_id"
            BEST_PGS_COUNT="$current_count"
            BEST_PGS_NAME="$track_name"
            [[ "$forced_track" == "true" ]] && PGS_IS_FORCED=true || PGS_IS_FORCED=false
            [[ "$default_track" == "true" ]] && PGS_IS_DEFAULT=true || PGS_IS_DEFAULT=false
            [[ "$hearing_impaired" == "true" || "${track_name^^}" == *"SDH"* || "${track_name^^}" == *"HI"* ]] && PGS_IS_HI=true || PGS_IS_HI=false
        fi
    done
    
    if [[ -n "$BEST_PGS_ID" ]]; then
        FILENAME_SUFFIX=""
        $PGS_IS_FORCED && FILENAME_SUFFIX="${FILENAME_SUFFIX}.forced"
        $PGS_IS_DEFAULT && FILENAME_SUFFIX="${FILENAME_SUFFIX}.default"
        $PGS_IS_HI && FILENAME_SUFFIX="${FILENAME_SUFFIX}.sdh"

        OUTPUT_PATH="${DIRNAME}/${BASENAME}.eng${FILENAME_SUFFIX}.srt"
        
        if [[ -f "$OUTPUT_PATH" ]]; then
            if tail -n 10 "$OUTPUT_PATH" | grep -qF "$STATIC_SIGNATURE_PREFIX"; then
                log_skip "Already processed (signature found) → $OUTPUT_PATH"
                continue
            fi
            local existing_owner=$(stat -c %U "$OUTPUT_PATH" 2>/dev/null)
            if [[ "$existing_owner" == "jellyfin" ]]; then
                log_skip "Skipping processing for '$BASENAME': Existing file is untagged and owned by 'jellyfin'."
                continue
            fi
            log_info "Existing untagged file found for $BASENAME. Will overwrite with new version."
        fi
        
        SUP_FILE="$WORKDIR/${BASENAME}_track${BEST_PGS_ID}.sup"
        log_info "Extracting PGS to temporary SUP file: $SUP_FILE"
        if ! mkvextract tracks "$FILE" "${BEST_PGS_ID}:${SUP_FILE}"; then
            log_error "Extraction failed for $BASENAME (Track $BEST_PGS_ID). Removing temporary SUP file."
            rm -f "$SUP_FILE"
        else
            log_info "Performing OCR to SRT for: $BASENAME with tags '${FILENAME_SUFFIX}'"
            if ! sup2srt -l eng -o "$OUTPUT_PATH" "$SUP_FILE"; then
                log_error "OCR failed for $BASENAME. Removing temporary SUP file."
                rm -f "$SUP_FILE"
            else
                echo "$SIGNATURE" >> "$OUTPUT_PATH"
                log_success "OCR completed and saved → $OUTPUT_PATH"
            fi
            rm -f "$SUP_FILE"
        fi
    fi
done

log_info "Processing phase complete. Cleaning up working directory: '$WORKDIR'"
rm -rf "$WORKDIR" || log_error "Failed to remove working directory: '$WORKDIR'"

### Cleanup Phase (Controlled by Exclusion List)

log_info "Checking for orphaned SRT/ASS subtitles..."

find "$ROOT" -type f -name "*.srt" -o -name "*.ass" -print0 | while IFS= read -r -d $'\0' SUB_FILE; do
    if should_exclude "$SUB_FILE"; then
        log_success "Keeping subtitle (matches exclude pattern or owned by 'jellyfin') → $SUB_FILE"
        continue
    fi

    if tail -n 10 "$SUB_FILE" | grep -qF "$STATIC_SIGNATURE_PREFIX"; then
        log_success "Keeping tagged subtitle (created by this script) → $SUB_FILE"
    else
        log_error "Deleting orphaned subtitle (not created by this script and not excluded) → $SUB_FILE"
        rm -f "$SUB_FILE"
    fi
done

log_success "Subtitle processing complete."
