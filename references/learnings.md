# Learnings (append after every run - short, general lessons)

## Swap
- 2026-10-12 | Photos beat text: a kippah, an AirPod and a blue t-shirt in the user's selfies all appeared in the video although the prompt said NO kippah / same shirt. Clean and crop the refs before upload.
- 2026-10-12 | Earrings from the original person disappeared when the refs had none. Mention items to keep explicitly; consider adding them to cleaned refs if they matter.
- 2026-10-12 | Real phone photos of a real person gave a very real face. A generated character image (extreme cartoonish features) came out mask-like.
- 2026-10-12 | Tattoo sleeves and a gold watch from the original were kept well. Motion copy and other people stayed untouched.
- 2026-10-12 | 14 s at 1080p = 165 credits, ~10 min render. 5.7 s = 66 credits. Output 24 fps, can be a few frames short.
- 2026-10-12 | A short third shot at the end of the range also got swapped - check for scene cuts in the chosen range.
- 2026-10-12 | Generating right after "let's go" without a price stop burned 165 credits on a flawed run. The price gate is not optional.
- 2026-10-13 | Clips under 4 s get a 422 on get_cost (no message). Fix: pad to >=4 s (ffmpeg tpad clone last frame) before upload.
- 2026-10-13 | Celebrity face (Elon Musk) refs -> job status `ip_detected` within ~30 s, credits refunded. Higgsfield blocks famous faces; flag this at intake and don't try to get around it.
- 2026-10-13 | Polished AI-edited portraits of a non-famous woman (user said she approved) still got `ip_detected` (refunded, ~1 min). The filter can flag faces that only resemble a known person. Ask for raw phone selfies up front; never try to trick the filter.

- 2026-10-13 | Hair-edited AI portraits (short bob, cropped head+neck) passed the ip filter on the same barber clip that was blocked before. Face/expressions/cape came out great.
- 2026-10-13 | Swap ERASED the other people standing close behind the main person (barber's face+body, background guy) - only the barber's hand stayed. When others are close/overlapping, warn the user in step 1 and check them first in QA.

- 2026-10-13 | Never write 'mouth in sync with the audio' when the main person is silent - the model made her lip-sync an off-camera voice. A prompt with 'NOT talking, mouth mostly closed' + 'barber's face/body must stay visible, do not remove any person' fixed both: barber came back fully, background guy only partly.

## Motion
- (no runs yet)
