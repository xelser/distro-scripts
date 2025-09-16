#!/usr/bin/env bash
# set -euo pipefail # Uncomment this line once debugging is complete and the script works reliably

# --- Configuration ---
ROOT="${1:-.}" # Root directory to start scanning from, defaults to current directory
EXCLUDE_FILE="/mnt/Media/srt_exclude_dirs.txt" # Path to your exclusion file
WORKDIR="./_subs_temp" # Temporary working directory is not needed for extraction, but kept for consistency

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
log_info() { echo -e "${COLOR_CYAN}[INFO]${COLOR_RESET} $*"; }
log_skip() { echo -e "${COLOR_YELLOW}[SKIP]${COLOR_RESET} $*"; }
log_success() { echo -e "${COLOR_GREEN}[DONE]${COLOR_RESET} $*"; }
log_extract() { echo -e "${COLOR_BLUE}[EXTRACT]${COLOR_RESET} $*"; }
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2; }
log_debug() { :; }

check_dependency() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Dependency missing: '$cmd'. Please install it to proceed."
        exit 1
    fi
    log_debug "Dependency found: '$cmd'"
}

check_dependencies() {
    log_info "Checking required command-line tools..."
    check_dependency "mkvmerge"
    check_dependency "mkvextract"
    check_dependency "jq"
    check_dependency "stat"
    log_info "All required tools found."
}

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
log_info "Starting text-based subtitle extraction process."

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
    
    mapfile -t SUB_TRACKS < <(
        echo "$MKV_INFO_JSON" | jq -r '
            .tracks[] |
            select(
                .type == "subtitles" and
                .properties.language == "eng" and
                (.properties.codec_id | test("^(S_TEXT/UTF8|S_TEXT/ASS)$"))
            ) |
            "\(.id)|\(.properties.codec_id)|\(.properties.num_index_entries // 0)|\(.properties.track_name // "")|\(.properties.forced_track)|\(.properties.default_track)|\(.properties.hearing_impaired)"
        '
    )
    
    if [[ ${#SUB_TRACKS[@]} -eq 0 ]]; then
        log_skip "No suitable text-based subtitle tracks found for: $BASENAME."
        continue
    fi
    
    BEST_TEXT_ID=""
    BEST_TEXT_COUNT=-1
    BEST_TEXT_CODEC=""
    BEST_TEXT_NAME=""
    TEXT_IS_FORCED=false
    TEXT_IS_DEFAULT=false
    TEXT_IS_HI=false
    
    for DETAIL_STRING in "${SUB_TRACKS[@]}"; do
        IFS='|' read -r current_id codec_id current_count track_name forced_track default_track hearing_impaired <<< "$DETAIL_STRING"
        if [[ "$current_count" -gt "$BEST_TEXT_COUNT" ]]; then
            BEST_TEXT_ID="$current_id"
            BEST_TEXT_COUNT="$current_count"
            BEST_TEXT_CODEC="$codec_id"
            BEST_TEXT_NAME="$track_name"
            [[ "$forced_track" == "true" ]] && TEXT_IS_FORCED=true || TEXT_IS_FORCED=false
            [[ "$default_track" == "true" ]] && TEXT_IS_DEFAULT=true || TEXT_IS_DEFAULT=false
            [[ "$hearing_impaired" == "true" || "${track_name^^}" == *"SDH"* || "${track_name^^}" == *"HI"* ]] && TEXT_IS_HI=true || TEXT_IS_HI=false
        fi
    done
    
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
done

### Cleanup Phase
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

log_success "Text-based subtitle processing complete."
