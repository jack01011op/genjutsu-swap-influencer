#!/bin/bash
# Usage: review_sheet.sh <video.mp4> <out_dir>
# Prints specs and writes review_sheet.png (1 frame per second) for QA.
set -e
V="$1"; O="$2"; FF=/opt/homebrew/bin/ffmpeg; FP=/opt/homebrew/bin/ffprobe; mkdir -p "$O"
"$FP" -v error -show_entries format=duration:stream=codec_type,width,height,r_frame_rate -of compact "$V"
LEN=$("$FP" -v error -show_entries format=duration -of csv=p=0 "$V"); N=$(printf "%.0f" "$LEN")
COLS=7; ROWS=$(( (N + COLS - 1) / COLS )); [ $ROWS -lt 1 ] && ROWS=1
"$FF" -v error -y -i "$V" -vf "fps=1,scale=270:-1,tile=${COLS}x${ROWS}" -frames:v 1 "$O/review_sheet.png"
echo "review sheet: $O/review_sheet.png"
