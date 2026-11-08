#!/usr/bin/env bash
set -euo pipefail
PKG=$(cd "$(dirname "$0")/.." && pwd)
ROOT=${1:?Usage: bash tools/prepare_sources.sh /new/absolute/root}
if [ -e "$ROOT" ]; then echo 'STOP: target already exists; choose a new directory.'; exit 2; fi
mkdir -p "$ROOT"
getsha() { python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))[sys.argv[2]])' "$PKG/upstream-lock.json" "$1"; }
git clone --filter=blob:none --no-checkout https://github.com/OpenXiangShan/XiangShan.git "$ROOT/XiangShan"
git -C "$ROOT/XiangShan" checkout --detach "$(getsha xiangshan)"
git -C "$ROOT/XiangShan" submodule update --init --recursive
git clone --filter=blob:none --no-checkout https://github.com/OpenXiangShan/NEMU.git "$ROOT/NEMU"
git -C "$ROOT/NEMU" checkout --detach "$(getsha nemu)"
git -C "$ROOT/NEMU" submodule update --init --recursive
git clone --filter=blob:none --no-checkout https://github.com/OpenXiangShan/nexus-am.git "$ROOT/nexus-am"
git -C "$ROOT/nexus-am" checkout --detach "$(getsha nexus_am)"
git -C "$ROOT/nexus-am" submodule update --init --recursive
python3 "$PKG/tools/apply_overlay.py" xiangshan "$ROOT/XiangShan" --apply
python3 "$PKG/tools/apply_overlay.py" nemu "$ROOT/NEMU" --apply
echo "Sources prepared. Build with: bash tools/build_and_test.sh '$ROOT'"
