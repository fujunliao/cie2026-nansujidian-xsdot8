from pathlib import Path
root=Path(__file__).resolve().parents[1]
source=(root/'integration/overlay/nemu/src/isa/riscv64/instr/rvv/vcompute.h').read_text()
start=source.index('def_EHelper(xsdot8) {')
end=source.index('\ndef_EHelper(vadd)',start)
(root/'tests/extracted_helper.h').write_text(source[start:end])
print('Extracted helper from actual version-locked overlay')
