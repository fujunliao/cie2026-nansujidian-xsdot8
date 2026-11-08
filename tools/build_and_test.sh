#!/usr/bin/env bash
set -euo pipefail
PKG=$(cd "$(dirname "$0")/.." && pwd)
ROOT=${1:?Usage: bash tools/build_and_test.sh /absolute/path/to/prepared-root}
export XSDOT8_ROOT="$ROOT" NOOP_HOME="$ROOT/XiangShan" NEMU_HOME="$ROOT/NEMU" AM_HOME="$ROOT/nexus-am"
export JAVA_HOME=${JAVA_HOME:-/opt/graalvm-jdk-21}
export PATH="$JAVA_HOME/bin:/usr/local/llvm/bin:$PATH"
mkdir -p "$ROOT/logs" "$ROOT/work"
make -C "$NEMU_HOME" xsdot8-test_defconfig > "$ROOT/logs/nemu-config.log" 2>&1
make -C "$NEMU_HOME" -j2 > "$ROOT/logs/nemu-build.log" 2>&1
make -C "$NOOP_HOME" emu CONFIG=KunminghuV2MinimalConfig JVM_XMX=12G EMU_THREADS=1 EMU_TRACE=fst -j4 > "$ROOT/logs/v2-build.log" 2>&1
for mode in 1 2 3 4 6; do
  make -C "$PKG/software" -f Makefile.regression ARCH=riscv64-xs LINUX_GNU_TOOLCHAIN=1 MARCH=rv64gcv MODE="$mode"
  cp "$PKG/software/build/regression$mode-riscv64-xs.bin" "$ROOT/work/mode$mode.bin"
  cp "$PKG/software/build/regression$mode-riscv64-xs.elf" "$ROOT/work/mode$mode.elf"
done
make -C "$PKG/software" ARCH=riscv64-xs LINUX_GNU_TOOLCHAIN=1 MARCH=rv64gcv
cp "$PKG/software/build/xsdot8-riscv64-xs.bin" "$ROOT/work/full.bin"
cp "$PKG/software/build/xsdot8-riscv64-xs.elf" "$ROOT/work/full.elf"
bash "$PKG/tools/run_existing.sh" all
