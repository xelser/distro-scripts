#!/bin/bash

ROOT="${1:-$PWD}"
LOG="$ROOT/pgs_recursive_pipeline.log"
COMMENT="[OCR] Extracted & converted directly from MKV via sup2srt"

CLI_DEPS=(mkvtoolnix jq tesseract-ocr)
SUP2SRT_DEPS=(libtiff-dev libleptonica-dev libtesseract-dev libavcodec-dev libavformat-dev libavutil-dev libavdevice-dev cmake build-essential git)

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[1;34m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${BLUE}[*] Starting recursive scan in: $ROOT${NC}" | tee "$LOG"

# ── Ensure Dependencies ──────────────────────────────
for pkg in "${CLI_DEPS[@]}"; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    echo -e "${YELLOW}[+] Installing: $pkg${NC}" | tee -a "$LOG"
    sudo apt install -y "$pkg" >> "$LOG" 2>&1
  else
    echo -e "${GREEN}[~] Already installed: $pkg${NC}" | tee -a "$LOG"
  fi
done

# ── Build sup2srt if missing ─────────────────────────
if ! command -v sup2srt &>/dev/null; then
  echo -e "${RED}[!] sup2srt not found. Building...${NC}" | tee -a "$LOG"
  for dep in "${SUP2SRT_DEPS[@]}"; do
    if ! dpkg -s "$dep" &>/dev/null; then
      sudo apt install -y "$dep" >> "$LOG" 2>&1
    fi
  done
  git clone https://github.com/retrontology/sup2srt.git /tmp/sup2srt >> "$LOG" 2>&1
  mkdir -p /tmp/sup2srt/build && cd /tmp/sup2srt/build
  cmake .. >> "$LOG" 2>&1 && make -j"$(nproc)" >> "$LOG" 2>&1 && sudo make install >> "$LOG" 2>&1
  cd "$ROOT"
fi

# ── Process MKV Files ─────────────────────────────────
find "$ROOT" -type f -iname "*.mkv" | while read -r mkvfile; do
  dir="$(dirname "$mkvfile")"
  base="$(basename "$mkvfile" .mkv)"
  echo -e "${BLUE}[→] Scanning: $base.mkv${NC}" | tee -a "$LOG"
  created_subs=()

  track_json=$(mkvmerge -J "$mkvfile")

  if echo "$track_json" | jq -e '.tracks[] | select(.codec=="SubRip/SRT")' >/dev/null; then
    echo -e "${YELLOW}[⏭] Embedded SRT detected — skipping${NC}" | tee -a "$LOG"
    echo -e "${YELLOW}[SUMMARY] $base.mkv → Skipped (embedded SRT present)${NC}" | tee -a "$LOG"
    continue
  fi

  pgstracks=$(echo "$track_json" | jq -c '.tracks[] | select(.type=="subtitles") | select(.codec=="HDMV PGS") | select(.properties.language == "eng" or .properties.language == null)')
  [[ -z "$pgstracks" ]] && echo -e "${YELLOW}[⏭] No English PGS tracks found${NC}" | tee -a "$LOG" && echo -e "${YELLOW}[SUMMARY] $base.mkv → Skipped (no English PGS)" | tee -a "$LOG" && continue

  mapfile -t track_lines < <(echo "$pgstracks")

  for track in "${track_lines[@]}"; do
    id=$(echo "$track" | jq '.id')
    forced=$(echo "$track" | jq '.properties.forced_track // false')
    sdh=$(echo "$track" | jq '.properties.hearing_impaired // false')

    suffix=".en"
    [[ "$sdh" == "true" ]] && suffix+=".sdh"
    [[ "$forced" == "true" ]] && suffix+=".forced"

    base_srt="$dir/$base${suffix}.srt"
    index=2
    while [[ -f "$base_srt" ]]; do
      if tail -n 1 "$base_srt" | grep -qF "$COMMENT"; then
        echo -e "${GREEN}[~] Valid OCR SRT exists → $(basename "$base_srt")${NC}" | tee -a "$LOG"
        created_subs+=("Skipped: $(basename "$base_srt")")
        continue 2
      fi
      base_srt="$dir/$base${suffix}.${index}.srt"
      ((index++))
    done

    srt="$base_srt"
    sup="${srt%.srt}.sup"

    echo -e "${YELLOW}[+] Extracting track $id → $sup${NC}" | tee -a "$LOG"
    mkvextract tracks "$mkvfile" "$id:$sup" >> "$LOG" 2>&1

    echo -e "${BLUE}[✎] OCR: $sup → $srt${NC}" | tee -a "$LOG"
    sup2srt -l eng "$sup" -o "$srt" >> "$LOG" 2>&1

    if [[ -f "$srt" ]]; then
      echo -e "\n9999\n99:59:59,999 --> 99:59:59,999\n$COMMENT" >> "$srt"
      echo -e "${GREEN}[✓] Created & tagged: $(basename "$srt")${NC}" | tee -a "$LOG"
      created_subs+=("$(basename "$srt")")
      sudo chown "$USER:mediaaccess" "$srt"; sudo chmod 664 "$srt"
      rm -f "$sup"; echo -e "${BLUE}[🧹] Removed: $sup${NC}" | tee -a "$LOG"
    else
      echo -e "${RED}[!] OCR failed: $sup${NC}" | tee -a "$LOG"
    fi
  done

  expected_count=$(echo "$pgstracks" | jq -c '.' | wc -l)
  actual_srt=()
  for srt in "$dir/$base".en*.srt; do
    [[ -f "$srt" ]] || continue
    if tail -n 1 "$srt" | grep -qF "$COMMENT"; then
      actual_srt+=("$srt")
    fi
  done

  if (( ${#actual_srt[@]} > expected_count )); then
    to_remove_count=$(( ${#actual_srt[@]} - expected_count ))
    echo -e "${YELLOW}[🧹] Removing $to_remove_count excess .srt files${NC}" | tee -a "$LOG"
    IFS=$'\n' sorted=($(printf '%s\n' "${actual_srt[@]}" | sort -r))
    for i in $(seq 0 $((to_remove_count - 1))); do
      rm -f "${sorted[$i]}"
      echo -e "${RED}[✗] Removed: $(basename "${sorted[$i]}")${NC}" | tee -a "$LOG"
    done
  fi

  if [[ ${#created_subs[@]} -gt 0 ]]; then
  joined=$(IFS=, ; echo "${created_subs[*]}")
  
    if echo "$joined" | grep -q "Skipped:"; then
      echo -e "${YELLOW}[SUMMARY] $base.mkv → OCR complete: $joined${NC}" | tee -a "$LOG"
    else
      echo -e "${GREEN}[SUMMARY] $base.mkv → OCR complete: $joined${NC}" | tee -a "$LOG"
    fi
  else
    echo -e "${RED}[SUMMARY] $base.mkv → No usable English PGS${NC}" | tee -a "$LOG"
  fi
done

# ── Final Sweep: Remove Untagged SRTs ─────────────────
echo -e "\n${BLUE}===== CLEANING UNTAGGED SRT FILES =====${NC}"
find "$ROOT" -type f -iname "*.srt" | while read -r srt; do
  if ! tail -n 1 "$srt" | grep -qF "$COMMENT"; then
    echo -e "${RED}[✗] Removing untagged SRT: $(basename "$srt")${NC}" | tee -a "$LOG"
    rm -f "$srt"
  fi
done

# ── Final Summary View ───────────────────────────────
echo -e "\n${BLUE}===== FINAL SUMMARY =====${NC}"
grep -F "[SUMMARY]" "$LOG" | while read -r line; do
  case "$line" in
    *"Skipped"*) echo -e "${YELLOW}$line${NC}" ;;
    *"OCR complete"*) echo -e "${GREEN}$line${NC}" ;;
    *) echo -e "${RED}$line${NC}" ;;
  esac
done
