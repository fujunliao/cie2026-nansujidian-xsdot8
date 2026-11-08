#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results
python3 -m unittest discover -s tests -p test_reference.py -v 2>&1 | tee results/reference-tests.log
YOSYS="${YOSYS:-yosys}"
for spec in 'VDotCore core' 'VDotSerial serial' 'VDotPipe pipe'; do
  read -r top name <<< "$spec"
  "$YOSYS" -Q -T -p "read_verilog -sv rtl/VDot.sv; hierarchy -top $top; proc; flatten; opt; check; write_json results/${name}_netlist.json" > "results/${name}-yosys.log"
done
python3 tests/test_netlist.py
"$YOSYS" -Q -T -p 'read_verilog -sv rtl/VDot.sv tests/formal_miter.sv; hierarchy -top VDotMiter; proc; flatten; opt; sat -timeout 60 -verify -prove ok 1 -show-inputs' > results/formal.log
