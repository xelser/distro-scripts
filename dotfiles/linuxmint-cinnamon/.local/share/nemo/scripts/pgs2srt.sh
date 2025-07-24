#!/bin/bash

ROOT="${1:-$PWD}"
LOG="$ROOT/pgs_recursive_pipeline.log"
COMMENT="[OCR] Extracted & converted directly from MKV via sup2srt"
orphan_log="$ROOT/orphaned_srt_audit.log"

GREEN='\033[0;32m' ; YELLOW='\033[1;33m' ; BLUE='\033[1;34m'
RED='\033[0;31m'   ; PURPLE='\033[0;35m' ; TEAL='\033[0;36m'
ORANGE='\033[38;5;208m' ; NC='\033[0m'

function notify() {
  if command -v notify-send &>/dev/null && [[ -n "$DISPLAY" ]]; then
    notify-send "PGS OCR Pipeline" "$1"
  fi
  echo -e "${BLUE}[🔔] $1${NC}" | tee -a "$LOG"
}

EXCLUDE_FILE="/mnt/Media/srt_exclude_dirs.txt"
excluded=()
[[ -f "$EXCLUDE_FILE" ]] && mapfile -t excluded < "$EXCLUDE_FILE"

CLI_DEPS=(mkvtoolnix jq tesseract-ocr libnotify-bin)
DEV_DEPS=(libtiff-dev libleptonica-dev libtesseract-dev libavcodec-dev libavformat-dev libavutil-dev libavdevice-dev cmake build-essential git)

missing=()
for pkg in "${CLI_DEPS[@]}"; do
  dpkg -s "$pkg" &>/dev/null || missing+=("$pkg")
done

if (( ${#missing[@]} )); then
  echo -e "${YELLOW}[ + ] Installing: ${missing[*]}${NC}" | tee -a "$LOG"
  sudo apt install -y "${missing[@]}" >> "$LOG" 2>&1
else
  echo -e "${GREEN}[ ✓ ] All dependencies present${NC}" | tee -a "$LOG"
fi

if ! command -v sup2srt &>/dev/null; then
  echo -e "${RED}[!] sup2srt not found. Building...${NC}" | tee -a "$LOG"
  for dep in "${DEV_DEPS[@]}"; do
    dpkg -s "$dep" &>/dev/null || sudo apt install -y "$dep" >> "$LOG" 2>&1
  done
  git clone https://github.com/retrontology/sup2srt.git /tmp/sup2srt >> "$LOG" 2>&1
  mkdir -p /tmp/sup2srt/build && cd /tmp/sup2srt/build
  cmake .. && make -j"$(nproc)" && sudo make install
  cd "$ROOT"
fi

mapfile -t mkv_list < <(find "$ROOT" -iname "*.mkv")
total_mkvs=${#mkv_list[@]}
processed=0
for mkvfile in "${mkv_list[@]}"; do
  ((processed++))
  progress_percent=$(( processed * 100 / total_mkvs ))

  echo ""
  echo -e "${BLUE}➤ Processing... [$processed/$total_mkvs] $progress_percent% done${NC}"
  echo -e "${PURPLE} • $(basename "$mkvfile")${NC}"

  dir="$(dirname "$mkvfile")"
  base="$(basename "$mkvfile" .mkv)"
  parent_dir="$(basename "$dir")"

  if printf '%s\n' "${excluded[@]}" | grep -qxF "$parent_dir"; then
    echo -e "${YELLOW} ↪ Directory excluded → Skipping $base.mkv${NC}" | tee -a "$LOG"
    echo "[SUMMARY][SKIPPED]   $base.mkv → Directory excluded ($parent_dir)" >> "$LOG"
    continue
  fi

  track_json=$(mkvmerge -J "$mkvfile")
  has_srt=$(echo "$track_json" | jq -e '.tracks[] | select(.codec=="SubRip/SRT")')

  [[ -n "$has_srt" ]] && {
    echo -e "${YELLOW} ↪ Skipped: Embedded SRT track${NC}" | tee -a "$LOG"
    echo "[SUMMARY][SKIPPED]   $base.mkv → Embedded SRT present" >> "$LOG"
    continue
  }

  pgs_tracks=$(echo "$track_json" | jq -c '[.tracks[] | select(.type=="subtitles" and .codec=="HDMV PGS" and (.properties.language == "eng" or .properties.language == null))]')
  [[ "$pgs_tracks" == "[]" ]] && {
    echo -e "${YELLOW} ↪ Skipped: No English PGS track${NC}" | tee -a "$LOG"
    echo "[SUMMARY][SKIPPED]   $base.mkv → No English PGS" >> "$LOG"
    continue
  }

  mapfile -t track_lines < <(jq -c '.[]' <<< "$pgs_tracks")
  created_subs=()
  declare -A locked_suffixes

  for srtfile in "$dir/$base".en*.srt; do
    [[ -f "$srtfile" ]] || continue
    footer=$(tail -n 1 "$srtfile" 2>/dev/null)
    [[ "$footer" == *"$COMMENT"* && "$footer" == *"Track "* ]] || continue
    suffix_part="${srtfile#$dir/$base.}"
    suffix_part="${suffix_part%.srt}"
    locked_suffixes["$suffix_part"]=1
  done

  for track in "${track_lines[@]}"; do
    id=$(echo "$track" | jq '.id')
    forced=$(echo "$track" | jq '.properties.forced_track // false')
    sdh=$(echo "$track" | jq '.properties.hearing_impaired // false')
    title=$(echo "$track" | jq -r '.properties.track_name // ""')

    suffix=".en"
    [[ "$forced" == "true" || "$title" =~ [Ff]orced ]] && suffix=".en.forced"
    [[ "$sdh" == "true" || "$title" =~ (SDH|HI|Hearing Impaired) ]] && suffix=".en.sdh"

    suffix_key="${suffix#.}"
    srt_path="$dir/$base.$suffix_key.srt"

    if [[ -f "$srt_path" ]]; then
      footer=$(tail -n 1 "$srt_path" 2>/dev/null)
      if [[ "$footer" == *"$COMMENT"* && "$footer" == *"(Track $id)"* ]]; then
        echo -e "${YELLOW} ↪ Valid OCR already exists → $(basename "$srt_path")${NC}" | tee -a "$LOG"
        created_subs+=("Skipped: $(basename "$srt_path")")
        continue
      elif grep -qxF "$parent_dir" "$EXCLUDE_FILE"; then
        echo -e "${YELLOW} ↪ Unknown .srt in excluded directory → Skipping: $(basename "$srt_path")${NC}" | tee -a "$LOG"
        continue
      else
        echo -e "${RED} ✗ Invalid or mismatched SRT → Removing: $(basename "$srt_path")${NC}" | tee -a "$LOG"
        echo "[ORPHANED-SRT] Removed: $srt_path (Suffix: .$suffix_key)" >> "$orphan_log"
        rm -f "$srt_path"
      fi
    fi

    if [[ -n "${locked_suffixes["$suffix_key"]}" ]]; then
      if [[ "$title" =~ [Ff]orced ]]; then
        suffix_key="en.forced"
      elif [[ "$title" =~ (SDH|HI|Hearing Impaired) ]]; then
        suffix_key="en.sdh"
      else
        index=2
        while [[ -n "${locked_suffixes["en.$index"]}" ]]; do
          ((index++))
        done
        suffix_key="en.$index"
        echo -e "${ORANGE} ↪ Suffix conflict → Reassigned to .$suffix_key${NC}" | tee -a "$LOG"
      fi
      srt_path="$dir/$base.$suffix_key.srt"
    fi

    locked_suffixes["$suffix_key"]=1
    sup="${srt_path%.srt}.sup"

    echo -e "${TEAL}  — Extracting track $id${NC} from .mkv"
    mkvextract tracks "$mkvfile" "$id:$sup" >> "$LOG" 2>&1
    echo -e "${GREEN}  ✓ Created:${NC} $(basename "$sup")"

    echo -e "${TEAL}  — Converting track $id${NC} from .sup (PGS) to .srt (SubRip)"
    sup2srt -l eng "$sup" -o "$srt_path" >> "$LOG" 2>&1
    echo -e "${GREEN}  ✓ Created:${NC} $(basename "$srt_path")"

    if [[ -s "$srt_path" && $(wc -l < "$srt_path") -gt 5 ]]; then
      echo -e "\n9999\n99:59:59,999 --> 99:59:59,999\n$COMMENT (Track $id)" >> "$srt_path"
      sudo chown "$USER:mediaaccess" "$srt_path"
      sudo chmod 664 "$srt_path"
      rm -f "$sup"
      created_subs+=("$(basename "$srt_path")")
    else
      echo -e "${RED} ✗ OCR failed for track $id${NC}" | tee -a "$LOG"
    fi
  done

  mapfile -t unique_subs < <(printf "%s\n" "${created_subs[@]}" | awk '!seen[$0]++')
  new_files=()
  for sub in "${unique_subs[@]}"; do
    [[ "$sub" != Skipped:* ]] && new_files+=("$sub")
  done

  if [[ ${#new_files[@]} -gt 0 ]]; then
    joined=$(IFS=, ; echo "${new_files[*]}")
    echo "[SUMMARY][OCR]       $base.mkv → Created: $joined" >> "$LOG"
  elif [[ ${#unique_subs[@]} -gt 0 ]]; then
    joined=$(IFS=, ; echo "${unique_subs[*]}")
    echo "[SUMMARY][SKIPPED]   $base.mkv → $joined" >> "$LOG"
  else
    echo "[SUMMARY][FAILED]    $base.mkv → No usable English PGS" >> "$LOG"
    echo -e "${RED} ✗ No usable output${NC}"
  fi
done

# ── Cleanup ─────────────────────────────────────────
echo -e "${BLUE} 🧹 Removing untagged SRTs (excluding filtered directories)${NC}"
cleaned=0

while read -r subdir; do
  [[ -d "$ROOT/$subdir" ]] || continue
  find "$ROOT/$subdir" -type f -iname "*.srt" -exec bash -c '
    for srt; do
      if ! tail -n 1 "$srt" | grep -qF "'"$COMMENT"'"; then
        rm -f "$srt"
        ((cleaned++))
      fi
    done
  ' bash {} +
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -vxFf "$EXCLUDE_FILE")

(( cleaned > 0 )) && echo -e "${RED}✗ Removed $cleaned untagged SRTs${NC}"

# ── Completion ──────────────────────────────────────
notify "Processing complete in $(basename "$ROOT")"
echo -e "${GREEN}✓ All tasks finished. Log saved to:${NC} $LOG"
