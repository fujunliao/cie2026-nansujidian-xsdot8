/* Stage-one observation target: inspect real instruction PC in disassembly. */
.option arch, rv64gcv
.text
.global xs_vector_add
xs_vector_add:
  vsetivli zero, 8, e8, m1, tu, mu
  vle8.v v8, (a0)
  vle8.v v9, (a1)
  vadd.vv v10, v8, v9
  vse8.v v10, (a2)
  ret
