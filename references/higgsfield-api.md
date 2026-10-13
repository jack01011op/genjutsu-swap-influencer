# Higgsfield calls - exact recipe and gotchas

Two connectors exist. Use the **claude.ai Higgsfield** connector (`mcp__claude_ai_Higgsfield__*`) for Genjutsu - it is what has worked. The local `higgsfield` MCP (`mcp__higgsfield__*`) is handy for image edits. Load deferred tools with ToolSearch `select:` in one call.

## Upload (local file -> media_id)

1. `media_upload` with `files: [{filename, content_type}, ...]` (batch all files in one call). Returns `upload_url` + `media_id` per file.
2. PUT each file with curl from Bash, paste the full upload_url exactly:
   `curl -s -o /dev/null -w "%{http_code}\n" -X PUT -H "Content-Type: video/mp4" --data-binary @file.mp4 '<upload_url>'` - expect `200`.
3. `media_confirm` - one call for the video (`type: video`, `media_id`), one for the images (`type: image`, `media_ids: [...]`).

## Genjutsu params

```json
{
  "model": "hf_mult_replace_object",          // swap; motion = "hf_mult_motion_control"
  "resolution": "1080p",                       // 480p / 720p / 1080p
  "count": 1,
  "use_unlim": false,
  "declined_preset_id": "24bae836-2c4a-48e0-89b6-49fcc0b21612",
  "medias": [
    {"value": "<video media_id>", "role": "video_references"},
    {"value": "<image media_id>", "role": "image_references"}
  ],
  "prompt": "<from build_prompt.py>"
}
```

- Exactly one video, 1+ images. Roles must be `video_references` / `image_references` (plain `video`/`image` get auto-coerced, but use the real names).
- `declined_preset_id` stops the server from suggesting an unrelated preset ("IN THE DARK") instead of generating. If a different preset id comes back, pass that id instead and resubmit.
- `use_unlim: false` - pay with credits; omitting it may return an `unlim_choice` question.

## Price check

Same params + `"get_cost": true`. Returns `cost.credits` and submits nothing. Needs the real uploaded media - price depends on the clip length, not on a `duration` param. It can time out on fake/old ids; retry with the real ones.
Rough guide seen so far: swap at 1080p is about 11.5-12 credits per second (5.7 s = 66, 14 s = 165). Always confirm with get_cost - don't quote the rough guide as the price.
Balance: `balance` tool.

## Polling

`jobs_wait` with `[{index: 0, job_id}]`, timeout 15. Status goes queued -> in_progress -> completed. A 14 s clip took ~10 min. The tool may label the job type as "image" while running - ignore it. Result: `result_url` (mp4) - download with curl.
Never resubmit after a transport timeout without checking the first job's status first.

## Reference cleaning (image edits)

Goal: same person, same face, the "remove" items gone, cropped to head + neck.
- Crop first locally with `sips`/ffmpeg if cropping alone fixes it (free).
- For removing items: local MCP `mcp__higgsfield__hf_upload_file` then `mcp__higgsfield__alibaba_qwen_image_3_edit` (check params with `hf_describe_model`). Prompt pattern: "Same exact person, same face, same identity, photoreal. Remove the <item>; show his natural <hair/ear> there. Change nothing else." Qwen sometimes says "temporarily unavailable" - retry.
- Alternative: `xai_grok_imagine_image_2_0` with the photo as reference.
- Always compare the edited face with the original before showing the user; if identity drifted, retry or keep the uncropped original and tell the user.

## Local tools

- yt-dlp: `~/.browser-use-env/bin/yt-dlp`
- ffmpeg/ffprobe: `/opt/homebrew/bin/` (no drawtext filter - don't use text overlays)
- ffmpeg scene detection misses cuts in handheld clips; look at the contact sheet too.
