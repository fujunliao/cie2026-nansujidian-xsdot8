/* SPDX-License-Identifier: MIT
 * Project result interpretation: vd[31:0]=signed full sum; vd[127:32]=0.
 * Leaf routines clobber vector registers and vl/vtype per vector calling convention.
 */
.option arch, rv64gcv
.text
.align 2
.global xs_vdot8
xs_vdot8:
  vsetivli zero, 8, e8, m1, tu, mu
  vle8.v v8, (a0)
  vle8.v v9, (a1)
  .word 0x0294050b /* vdot.vv v10,v8,v9 ; custom-0, funct7=1, funct3=0 */
  vsetivli zero, 1, e32, m1, tu, mu
  vmv.x.s a0, v10
  ret

.global xs_baseline8
xs_baseline8:
  /* e8,mf2 -> widening multiply e16,m1 -> widening reduction e32.
     vmul.e8 + vredsum.e8 is NOT a full-precision baseline. */
  vsetivli zero, 8, e8, mf2, tu, mu
  vle8.v v8, (a0)
  vle8.v v9, (a1)
  vwmul.vv v12, v8, v9
  vsetivli zero, 4, e32, m1, tu, mu
  vmv.v.i v14, 0
  vsetivli zero, 8, e16, m1, tu, mu
  vwredsum.vs v10, v12, v14
  vsetivli zero, 1, e32, m1, tu, mu
  vmv.x.s a0, v10
  ret

.global xs_vdot_full
xs_vdot_full:
  vsetivli zero, 16, e8, m1, tu, mu
  vle8.v v8, (a0)
  vle8.v v9, (a1)
  vmv.v.i v10, -1
  vsetivli zero, 8, e8, m1, tu, mu
  .word 0x0294050b
  vsetivli zero, 16, e8, m1, tu, mu
  vse8.v v10, (a2)
  ret

.global xs_alias_vs1
xs_alias_vs1:
  vsetivli zero, 8, e8, m1, tu, mu
  vle8.v v8, (a0)
  vle8.v v9, (a1)
  .word 0x0294040b /* vd=vs1=v8 */
  vsetivli zero, 1, e32, m1, tu, mu
  vmv.x.s a0, v8
  ret

.global xs_alias_vs2
xs_alias_vs2:
  vsetivli zero, 8, e8, m1, tu, mu
  vle8.v v8, (a0)
  vle8.v v9, (a1)
  .word 0x0294048b /* vd=vs2=v9 */
  vsetivli zero, 1, e32, m1, tu, mu
  vmv.x.s a0, v9
  ret
