#!/usr/bin/env python3
"""Build the Genjutsu prompt from spec.json so every user answer ends up in it.

Usage: python3 build_prompt.py <spec.json>
Element "source" values: "R" (from reference photos), "O" (keep from original
person), "remove", or any other text = describe the change.
"""
import json, sys

spec = json.load(open(sys.argv[1]))
els = spec.get("elements", [])
from_r = [e["element"] for e in els if e.get("source") == "R"]
from_o = [e["element"] + (f" ({e['notes']})" if e.get("notes") else "") for e in els if e.get("source") == "O"]
remove = [e["element"] for e in els if e.get("source") == "remove"]
change = [f"{e['element']}: {e['source']}" for e in els if e.get("source") not in ("R", "O", "remove")]
ch = spec.get("character", {})
parts = []

if spec.get("path", "swap") == "swap":
    parts.append(f"Replace ONLY {spec.get('main_person', 'the main person')} with the person from the reference photos.")
    parts.append(f"Use his exact real face and identity: {ch.get('identity_desc', '')}.")
    if from_r:
        parts.append("From the reference photos take: " + ", ".join(from_r) + ".")
    parts.append("100% photorealistic real human skin with natural pores and texture, not a mask, not CGI.")
    if remove:
        parts.append("Do NOT show: " + ", ".join(remove) + ".")
    if from_o:
        parts.append("Keep exactly as in the original video: " + ", ".join(from_o) + ".")
    if change:
        parts.append("Changes: " + "; ".join(change) + ".")
    parts.append("Copy the original person's motion exactly frame by frame: every gesture, head turn and expression.")
    if spec.get("lip_sync"):
        parts.append("The mouth must match the original mouth movements exactly, in sync with the audio.")
    keep = spec.get("keep_unchanged", [])
    if keep:
        parts.append("Keep unchanged: " + ", ".join(keep) + ".")
else:
    parts.append(f"Animate the person in the reference image to perform exactly the movements of {spec.get('main_person', 'the person in the video')}.")
    parts.append(f"Keep the identity, face, clothes and background from the reference image: {ch.get('identity_desc', '')}.")
    if remove:
        parts.append("Do NOT show: " + ", ".join(remove) + ".")
    if change:
        parts.append("Changes: " + "; ".join(change) + ".")
    parts.append("Photorealistic, natural motion, stable face.")

if spec.get("extra_prompt"):
    parts.append(spec["extra_prompt"])
print(" ".join(p for p in parts if p.strip()))
