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
# Log an error message (Red) to stderr
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2; }
# Log a debug message (Magenta) - uncomment the echo line to enable
log_debug() {
    echo -e "${COLOR_MAGENTA}[DEBUG]${COLOR_RESET} $*"
    # : # Do nothing by default if debug is off
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
    check_dependency "mkvextract" # For extracting PGS tracks
    check_dependency "jq"         # For parsing mkvmerge JSON output
    check_dependency "sup2srt"    # For OCR (PGS to SRT conversion)
    log_info "All required tools found."
}

# Determine if a file/path should be excluded based on EXCLUDE_FILE
should_exclude() {
    local full_path="$1"
    [[ -f "$EXCLUDE_FILE" ]] || return 1 # No exclude file, so nothing is excluded

    # Read each exclusion pattern from the file
    while IFS= read -r exclude_pattern; do
        # Skip empty lines or lines starting with '#' (comments)
        [[ -z "$exclude_pattern" || "${exclude_pattern:0:1}" == "#" ]] && continue

        # Trim leading/trailing whitespace from the pattern
        exclude_pattern="$(echo "$exclude_pattern" | xargs)"

        # Check if the exclude_pattern is a substring of the full_path
        # This allows excluding based on folder names like "Featurettes", "Specials",
        # or full directory paths.
        if [[ "$full_path" == *"$exclude_pattern"* ]]; then
            return 0 # Exclude (return 0 for true in bash)
        fi
    done < "$EXCLUDE_FILE" # Redirect EXCLUDE_FILE into the while loop

    return 1 # Do not exclude (return 1 for false in bash)
}

# --- Main Script Logic ---

check_dependencies # Call the dependency check function first

log_info "Starting PGS to SRT OCR process. Working directory: '$WORKDIR'"
# Create the temporary working directory; exit if it fails
mkdir -p "$WORKDIR" || { log_error "Failed to create working directory: $WORKDIR"; exit 1; }

# ---------- OCR Phase ----------
# Find all MKV files, print their paths null-separated, and process them one by one
find "$ROOT" -type f -name "*.mkv" -print0 | while IFS= read -r -d $'\0' FILE; do
    BASENAME="$(basename "$FILE" .mkv)" # Extract filename without extension
    SRT_PATH="$(dirname "$FILE")/${BASENAME}.eng.srt" # Define the output SRT path (original behavior)

    # Check if the file (or its path) should be excluded
    if should_exclude "$FILE"; then
        log_skip "OCR excluded (matches exclude pattern) → $BASENAME"
        continue # Skip this file and move to the next if excluded
    fi

    # Check if an SRT file already exists and contains the signature
    # If it does, it means this script already processed it, so skip
    if [[ -f "$SRT_PATH" ]]; then
        if tail -n 10 "$SRT_PATH" | grep -qF "$STATIC_SIGNATURE_PREFIX"; then
            log_skip "Already processed (signature found) → $SRT_PATH"
            continue # Skip this file entirely if already processed and tagged
        fi
        # If an SRT file exists but *doesn't* have our signature, it's considered an external/orphan.
        # The script will proceed to overwrite it with the new OCR'd one.
        log_info "Existing untagged SRT found for $BASENAME. Will overwrite with OCR'd version."
    fi

    log_info "Scanning → $BASENAME"

    # Get MKV track information in JSON format
    MKV_INFO_JSON=$(mkvmerge -J "$FILE" 2>/dev/null)
    # Check if mkvmerge failed or returned empty JSON
    if [[ $? -ne 0 || -z "$MKV_INFO_JSON" ]]; then
        log_error "Failed to get mkvmerge JSON info for $FILE. Skipping."
        continue
    fi

    BEST_ID="" # Initialize best track ID
    MAX_COUNT=-1 # Initialize max element count to -1, so any valid count (>=0) is considered

    # Use jq to extract PGS subtitle track details: ID|Language|num_index_entries
    mapfile -t PGS_TRACK_DETAILS < <(
        echo "$MKV_INFO_JSON" | jq -r '
            .tracks[] |
            select(
                .type == "subtitles" and
                .properties.codec_id == "S_HDMV/PGS"
            ) |
            "\(.id)|\(.properties.language // "und")|\(.properties.num_index_entries // 0)"
        '
    )

    # If no PGS tracks are found for this file, skip it
    if [[ ${#PGS_TRACK_DETAILS[@]} -eq 0 ]]; then
        log_skip "No PGS tracks found for: $BASENAME"
        continue
    fi

    log_debug "Available PGS tracks for: $FILE (Raw details: ${PGS_TRACK_DETAILS[*]})"

    # Iterate through found PGS tracks to select the best English one
    for DETAIL_STRING in "${PGS_TRACK_DETAILS[@]}"; do
        # Parse the pipe-separated string into individual variables
        IFS='|' read -r current_id lang current_count_str <<< "$DETAIL_STRING"
        lang="${lang,,}" # Convert language to lowercase for consistent comparison
        current_count=$((current_count_str)) # Explicitly convert string count to integer

        log_debug " ↳ Candidate PGS: mkvextract ID=$current_id Lang=$lang Count=$current_count"

        # Prioritize English language tracks, then choose by maximum element count
        if [[ "$lang" == "eng" ]]; then
            # If this is the first English track found OR
            # if this English track has a higher element count than the current best
            if [[ -z "$BEST_ID" || "$current_count" -gt "$MAX_COUNT" ]]; then
                BEST_ID="$current_id"
                MAX_COUNT="$current_count"
            fi
        fi
    done

    # Final check: if no suitable English PGS track was found
    if [[ -z "$BEST_ID" ]]; then
        log_error "No suitable English PGS track found with sufficient elements for: $BASENAME. Review debug logs above."
        continue
    fi

    # Define the path for the temporary SUP file
    SUP_FILE="$WORKDIR/${BASENAME}_track${BEST_ID}.sup"
    log_info "Extracting Track $BEST_ID (PGS) to: $SUP_FILE"

    # Extract the chosen PGS track to the temporary SUP file
    if ! mkvextract tracks "$FILE" "${BEST_ID}:${SUP_FILE}"; then
        log_error "Extraction failed for $BASENAME (Track $BEST_ID). Removing temporary SUP file."
        rm -f "$SUP_FILE" # Clean up partially created SUP file on failure
        continue
    fi

    log_info "Performing OCR to SRT for: $BASENAME"
    # Perform OCR using sup2srt; exit code indicates success/failure
    if ! sup2srt -l eng -o "$SRT_PATH" "$SUP_FILE"; then
        log_error "OCR failed for $BASENAME. Removing temporary SUP file."
        rm -f "$SUP_FILE" # Clean up on OCR failure
        continue
    fi

    # Append the unique signature to the generated SRT file
    echo "$SIGNATURE" >> "$SRT_PATH"
    log_success "OCR completed and saved → $SRT_PATH"

    # Remove the temporary SUP file after successful processing
    rm -f "$SUP_FILE"
done

log_info "OCR phase complete. Cleaning up working directory: '$WORKDIR'"
# Remove the entire temporary directory
rm -rf "$WORKDIR" || log_error "Failed to remove working directory: '$WORKDIR'"

### Cleanup Phase (Controlled by Exclusion List)

log_info "Checking for orphaned SRT subtitles..."

# Find all SRT files (regardless of origin)
find "$ROOT" -type f -name "*.srt" -print0 | while IFS= read -r -d $'\0' SRT_FILE; do
    # First, check if the SRT file (or its path) should be excluded.
    # If it is, we explicitly keep it, assuming it's torrent-managed.
    if should_exclude "$SRT_FILE"; then
        log_success "Keeping SRT (matches exclude pattern) → $SRT_FILE"
        continue # Skip to the next SRT
    fi

    # If not excluded, then apply the signature-based logic:
    # If the SRT file contains the static signature prefix, keep it (it's ours).
    if tail -n 10 "$SRT_FILE" | grep -qF "$STATIC_SIGNATURE_PREFIX"; then
        log_success "Keeping tagged SRT (created by this script) → $SRT_FILE"
    else
        # Otherwise, it's an "orphaned" SRT (not created or tagged by this script, AND not excluded), so delete it.
        log_error "Deleting orphaned SRT (not created by this script and not excluded) → $SRT_FILE"
        rm -f "$SRT_FILE"
    fi
done

log_success "Subtitle processing complete."
