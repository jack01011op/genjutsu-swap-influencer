# Swap path (hf_mult_replace_object)

The model keeps every pixel of the original video except the main person, and repaints that person from the reference photos. Moves, camera, crowd, lighting and audio stay. Mouth movement follows the original person, so lip sync comes "for free" from the source, but it is the hardest part to look perfect.

## Keep/remove table - rows to cover

Build it from what you actually see. Two sources: **O** = original person in the video, **R** = reference photos. For each row the user picks: from O / from R / remove / change (describe).

| Element | Typical question |
|---|---|
| Face / identity | From R (almost always) |
| Skin tone | From R? Note the scene lighting will tint it (e.g. red club light) |
| Hair | From R? Original may be bald / different |
| Beard / facial hair | From R or from O? |
| Head items (hat, kippah, cap, headband) | List each one seen in O and in R separately |
| Glasses / sunglasses | From O, remove, or from R? (no glasses = eyes visible, can look less stable) |
| Earrings / piercings | From O or remove? |
| Earbuds / AirPods | Usually remove - they are in many selfies |
| Clothes (top, bottom) | Same as O, O changed a little (be creative), from R, or new? |
| Tattoos | List each one you see on O (arm sleeves, hands, neck, face, chest). Keep all / some / none? |
| Jewelry (watch, chain, bracelet, rings) | From O? |
| Body type | From O (the model follows O's body anyway) |
| Other people | Stay unchanged (confirm the main person is the only swap) |
| Audio | Keep original / mute |
| Lip sync | Follows original mouth - set expectation |
| Resolution | 1080p / 720p / 480p |
| Clip range | Seconds, plus warn about seconds where the main person is hidden |

## Making the photos match the table

Only if the user picks cleaning in step 3. Because photos beat text, these are the options to offer:
- Crop each photo to head + neck (shoulders at most) when clothes come from O. A t-shirt visible in R replaced the original shirt last time.
- Edit out every "remove" item visible in R (hat/kippah, earbuds, glasses) before upload.
- If one photo is already clean (e.g. a front selfie without the hat), it can be kept as the main reference; edited side views add angles.
- Keep 2-4 photos covering front + both sides. More angles = steadier face.

## Prompt notes

`scripts/build_prompt.py` builds the prompt from spec.json. It states: who to replace (describe O's position, clothes, action), identity from R, explicit NO list, everything kept from O, copy motion and mouth frame by frame, and keep everyone else and the original sound unchanged. The prompt helps, but if something is in the photos, the prompt will not reliably beat it.

## Known failure modes

- Items in R leak into the video even when the prompt says NO (kippah, AirPod, t-shirt). Fix: clean the photos.
- Items on O disappear (earrings) when R shows none. Fix: mention them in the prompt; if they matter, consider adding them to the cleaned photos.
- Face can look mask-like or stylized on non-photo references. Real photos gave a much more real face.
- Output is 24 fps and may be a few frames shorter than the source.
- Scene cuts: the model swaps in every shot, including short shots at the end of the range - check the range for cuts in step 1.
