---
name: genjutsu-swap-influencer
description: Put a person or character into a real video with Higgsfield Genjutsu, either by swapping the main person in a video (replace_object, keeps the original scene) or by motion transfer (copies a video's moves onto a reference photo). Runs a gated, credit-safe flow - video cut, main-person check, a keep/remove table for every element (face, hair, beard, skin, clothes, tattoos, jewelry, glasses, hats, earbuds, audio, lip sync), reference photo cleaning, optional cheap 480p test, exact price, then generate and QA. Use this whenever the user wants to swap themselves, a friend, an AI influencer or a custom character into a YouTube/TikTok/Instagram clip, "put me in this video", "replace the guy in this video", "make my character do this dance", or mentions Genjutsu, Higgsfield swap, face swap video, or character replacement - even if they don't name the skill.
---

# Genjutsu Swap Influencer

Turns "put this character into that video" into a finished video without wasting credits or guessing.
Two paths, picked with one question at the start:

| Path | What it does | Background comes from | Model | Status |
|---|---|---|---|---|
| **Swap** | Repaints only the main person in the original video | The original video | `hf_mult_replace_object` | Tested |
| **Motion** | Animates the reference photo with the video's moves | The reference photo | `hf_mult_motion_control` | Not tested yet - extra careful |

Easy way to explain the difference to the user: **Swap puts you into their world. Motion brings their moves into your world.**

## The golden rules (why they exist)

The user has been burned before by an agent that acted ahead, guessed, and spent credits. These rules are the whole point of the skill:

1. **One step, then stop.** Every gate below ends the turn and waits for the user. A "let's go" counts only for the step that was just proposed - it is never approval to also generate. The one time this was skipped, 165 credits were spent on a video that ignored three of the user's instructions.
2. **Answer the question first.** If the user asks something, answer it and stop. Don't start uploading or generating in the same turn.
3. **Ask every question, guess nothing.** Each element in the keep/remove table gets an explicit answer. Then repeat back "exactly what I understood" before moving on.
4. **Money gate.** Before any credit-spending call: run `get_cost`, show the exact price + current balance, and wait for an explicit yes ("yes", "generate", "go" said *after* seeing the price). Image edits for reference cleaning are cheap but still get mentioned before running.
5. **Photos beat text.** Genjutsu copies what is in the reference photos far more than what the prompt says. A kippah, an AirPod and a t-shirt in the photos all appeared in the video even though the prompt said "NO kippah". So when photos show something the user wants removed, tell them and offer to clean the photos (step 3) - their choice.
6. **Photoreal by default.** Real humans, real skin, unless the user asks for a style.
7. **Short, simple messages.** The user prefers plain words and simple analogies. Tables and short lists, no jargon. Honest about failures.
8. **Consent.** If a real person's face is used, ask once whether that person agreed (the user saying "it's me" is enough).

## Project folder

Every job gets a numbered folder so nothing gets lost:

```
~/higgsfield-mcp/output/genjutsu-projects/NN_<short-slug>/
  spec.json             # single source of truth: every answer the user gave
  01_source/            # download/, cut clip, frames/
  02_refs_original/     # user's photos, untouched copies
  03_refs_clean/        # cleaned/cropped photos actually uploaded
  04_test/              # optional cheap test run
  05_final/             # final video + review_sheet.png + qa.md
```

`NN` = next number after the highest existing folder. Open the relevant folder for the user (`open <dir>` or `open -R <file>`) whenever there is something to look at. Credit history goes in `~/higgsfield-mcp/output/genjutsu-projects/credit_log.csv` (see `scripts/credit_log.sh`).

## The flow

Each **[STOP]** means: send the short message, end the turn, wait.

### Step 0 - Path + intake
Ask (one message): video link/file, which seconds, swap or motion (explain with the one-line analogy if unsure), and the character (new photos or an existing character). Read `references/learnings.md` now - it holds lessons from earlier runs. **[STOP]**

### Step 1 - Video check
Download and prep with `scripts/video_prep.sh <url-or-file> <project_dir> <start> <end>`. It downloads, cuts the exact range, makes a contact sheet (1 fps) and lists scene cuts. Look at the contact sheet.
Tell the user, exactly: who the main person is (clothes, position, what they do), who stays the same, scene cuts inside the range, and any seconds where the main person is small or hidden (they will pay for those seconds). For motion: describe the moves that will be copied. **[STOP]**

### Step 2 - Keep/remove table
Read the path file now: `references/swap.md` or `references/motion.md`. Look closely at the original person (crop frames - `video_prep.sh` writes `frames/crop_*.png`) and at the reference photos. Build the table from what you actually see, one row per element. Fill `spec.json` from `assets/spec_template.json` as answers come in.
Repeat back "exactly what I understood" as a short list. **[STOP]** until the user confirms every row.

### Step 3 - Clean the reference photos (only if the user picks it)
Cleaning is an option, never automatic. Look at the photos against the table and, if a "remove" item (hat/kippah, earbuds, glasses) or unwanted clothes are visible, offer it in one short message:
"Your photos show <items>. Genjutsu copies photos more than text, so they may show up in the video. Want me to clean the photos first (edit out <items>, crop to head + neck)? It costs about X credits per photo. Or we upload them as they are."
- If the user says no: upload the originals, keep the items in the prompt's NO list, and remind them once of the risk. Don't push again.
- If yes: edit with an identity-keeping model (see `references/higgsfield-api.md` - reference cleaning), save to `03_refs_clean/`, open the folder, check the face is still the same person, and show the user. **[STOP]** until approved.
If nothing in the photos conflicts with the table, say so and skip the offer.

### Step 4 - Cheap test (ask, never automatic)
Offer: "Want a cheap test first? I swap only ~3-4 seconds at 480p to check the face, kippah, clothes etc. Costs about X credits instead of Y." Get both prices with `get_cost`. Only run it if the user says yes. After it finishes, run the QA check (step 6) on it and report. **[STOP]**

### Step 5 - Exact price, then generate
Upload, confirm, `get_cost` with the exact final params (see `references/higgsfield-api.md`). Show: price, balance before, balance after. **[STOP]** - wait for an explicit yes after the price.
Then build the prompt with `python3 scripts/build_prompt.py <project_dir>/spec.json`, submit, log the cost, poll with `jobs_wait` (give the user a one-line update every few minutes - long jobs run ~10 min for 14 s).

### Step 6 - QA + report
Download to `05_final/`, run `scripts/review_sheet.sh <video> <out_dir>` and look at the sheet (plus zoomed frames where needed). Check every row of the keep/remove table: pass / fail + the seconds where it fails. Write `05_final/qa.md`. Open the video.
Report: specs (resolution, length, fps, audio), credits spent + left, what worked, what failed and why, the fix and its price. **[STOP]**

### Step 7 - Learn
Append one or two lines to `references/learnings.md` under the right path: what worked, what failed, the cause if known. Keep it short and general (a lesson, not a diary). This is how the skill gets better every video.

## Files

- `references/swap.md` - swap-specific table rows, prompt notes, known failure modes. Read in step 2 for swap.
- `references/motion.md` - motion-specific questions and cautions. Read in step 2 for motion.
- `references/higgsfield-api.md` - exact tool calls, upload recipe, media roles, price check, polling, gotchas. Read before the first Higgsfield call.
- `references/learnings.md` - living lessons. Read in step 0, append in step 7.
- `assets/spec_template.json` - spec skeleton.
- `scripts/video_prep.sh`, `scripts/review_sheet.sh`, `scripts/build_prompt.py`, `scripts/credit_log.sh`.
