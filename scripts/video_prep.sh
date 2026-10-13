#!/bin/bash
# Usage: video_prep.sh <url-or-file> <project_dir> <start_s> <end_s>
# Downloads (if URL), cuts the exact range, makes a 1 fps contact sheet,
# a few larger crop frames, and lists scene cuts inside the range.
set -e
SRC="$1"; P="$2"; START="$3"; END="$4"
YTDLP=~/.browser-use-env/bin/yt-dlp; FF=/opt/homebrew/bin/ffmpeg; FP=/opt/homebrew/bin/ffprobe
D="$P/01_source"; mkdir -p "$D/download" "$D/frames"
if [[ "$SRC" == http* ]]; then
  [ -f "$D/download/source_full.mp4" ] || "$YTDLP" -q -f "bv*+ba/b" --merge-output-format mp4 -o "$D/download/source_full.mp4" "$SRC"
else
  cp "$SRC" "$D/download/source_full.mp4"
fi
echo "== full source"; "$FP" -v error -show_entries format=duration:stream=codec_type,width,height,r_frame_rate -of compact "$D/download/source_full.mp4"
LEN=$(echo "$END - $START" | bc)
CLIP="$D/clip_${START}-${END}s.mp4"
"$FF" -v error -y -ss "$START" -i "$D/download/source_full.mp4" -t "$LEN" -c:v libx264 -crf 16 -preset slow -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart "$CLIP"
echo "== clip: $CLIP"; "$FP" -v error -show_entries format=duration -of compact "$CLIP"
N=$(printf "%.0f" "$LEN"); COLS=7; ROWS=$(( (N + COLS - 1) / COLS )); [ $ROWS -lt 1 ] && ROWS=1
"$FF" -v error -y -i "$CLIP" -vf "fps=1,scale=240:-1,tile=${COLS}x${ROWS}" -frames:v 1 "$D/frames/contact_sheet.png"
echo "== contact sheet: $D/frames/contact_sheet.png (1 frame per second, left to right)"
for f in 0.25 0.5 0.75; do t=$(printf "%.2f" "$(echo "$LEN * $f" | bc)"); "$FF" -v error -y -ss "$t" -i "$CLIP" -frames:v 1 -vf "scale=540:-1" "$D/frames/crop_${t}s.png"; done
echo "== larger frames: $D/frames/crop_*.png"
echo "== scene cuts (seconds inside the clip; may miss handheld cuts - check the sheet):"
"$FF" -v error -i "$CLIP" -vf "select='gt(scene,0.3)',showinfo" -f null - 2>&1 | grep -o "pts_time:[0-9.]*" || echo "none detected"
