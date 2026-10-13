# Motion path (hf_mult_motion_control) - NOT TESTED YET

Status: never run in this workflow yet. Be extra careful: always offer the cheap 480p test, always show the exact price, and write what you learn to learnings.md after the first runs. When the user asks how it works, say plainly that this path is new.

## What it does

The model reads only the movement from the driving video (like a stick figure) and animates the subject in the reference image(s) to follow it. Background, clothes and look come from the reference image. The original scene, other people and the camera from the video are NOT kept.

Analogy for the user: the video is the puppeteer's hands, the photo is the puppet.

## Questions to ask (the table for this path)

| Element | Question |
|---|---|
| Driving video | Which seconds? Who in the video is the "dancer" whose moves we copy? (if several people, which one) |
| Subject image | Which photo is the scene? Is that background OK, since it becomes the video's background? |
| Full body vs half body | The moves in the video vs what's visible in the photo: if the video shows legs dancing but the photo is a selfie from the chest up, the result will be cropped or invent legs. Warn and ask for a full-body photo if needed. |
| Clothes / items | Everything comes from the photo - anything to remove (hat, earbuds) must be edited out of the photo first. |
| Face / identity | From the photo |
| Audio | Keep the driving video's audio, or mute? (Check whether the model output includes audio; if not, offer to add it back with ffmpeg.) |
| Lip sync | Only if the driving person speaks/raps - expectations: mouth may not match. |
| Resolution | 1080p / 720p / 480p |

## Notes to verify on the first runs

- Does the output keep the driving audio? (unknown)
- How does it handle a selfie (half body) vs full-body driving video? (unknown)
- Price per second vs swap? (check with get_cost)
- Does camera motion from the video carry over? (unknown)

Record answers in learnings.md under "Motion".
