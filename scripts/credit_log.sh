#!/bin/bash
# Usage: credit_log.sh <project> <step> <model> <resolution> <seconds> <credits> <balance_after> [job_id]
L=~/higgsfield-mcp/output/genjutsu-projects/credit_log.csv; mkdir -p "$(dirname "$L")"
[ -f "$L" ] || echo "date,project,step,model,resolution,seconds,credits,balance_after,job_id" > "$L"
echo "$(date +%F_%H:%M),$1,$2,$3,$4,$5,$6,$7,${8:-}" >> "$L"; tail -3 "$L"
