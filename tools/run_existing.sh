#!/usr/bin/env bash
set -euo pipefail
ROOT="${XSDOT8_ROOT:-$HOME/projects/xsdot8-award}"
export NOOP_HOME="$ROOT/XiangShan"
MODE=${1:-smoke}
STAMP=$(date +%Y%m%d-%H%M%S)
mkdir -p "$ROOT/logs/recheck-$STAMP"
case "$MODE" in smoke) jobs="1";; all) jobs="1 2 3 4 6 full";; 1|2|3|4|6|full) jobs="$MODE";; *) echo 'Use smoke, all, 1, 2, 3, 4, 6, or full'; exit 2;; esac
for job in $jobs; do
  image="$ROOT/work/mode$job.bin"
  if [ "$job" = full ]; then image="$ROOT/work/full.bin"; fi
  log="$ROOT/logs/recheck-$STAMP/$job.log"
  "$NOOP_HOME/build/emu" -b 0 -e 0 -C 2000000 -i "$image" --diff "$ROOT/NEMU/build/riscv64-nemu-interpreter-so" 2>&1 | tee "$log"
  grep -q 'HIT GOOD TRAP' "$log"
done
echo "PASS: logs at $ROOT/logs/recheck-$STAMP"
