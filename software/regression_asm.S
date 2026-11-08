.option arch, rv64gcv
.text
.align 2
.global xs_trap_entry
xs_trap_entry:
  addi sp,sp,-16
  sd t0,0(sp)
  sd t1,8(sp)
  la t0,trap_cause
  csrr t1,mcause
  sd t1,0(t0)
  la t0,trap_count
  ld t1,0(t0)
  addi t1,t1,1
  sd t1,0(t0)
  la t0,trap_pc
  csrr t1,mepc
  sd t1,0(t0)
  addi t1,t1,4
  csrw mepc,t1
  ld t0,0(sp)
  ld t1,8(sp)
  addi sp,sp,16
  mret
  ret
.global xs_bad_sew16
xs_bad_sew16:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  vsetivli zero,8,e16,m1,tu,mu
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_lmul2
xs_bad_lmul2:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  vsetivli zero,8,e8,m2,tu,mu
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_lmulf2
xs_bad_lmulf2:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  vsetivli zero,8,e8,mf2,tu,mu
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_vl0
xs_bad_vl0:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  vsetivli zero,0,e8,m1,tu,mu
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_vl1
xs_bad_vl1:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  vsetivli zero,1,e8,m1,tu,mu
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_vl7
xs_bad_vl7:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  vsetivli zero,7,e8,m1,tu,mu
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_vl16
xs_bad_vl16:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  vsetivli zero,16,e8,m1,tu,mu
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_vstart
xs_bad_vstart:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  csrwi vstart,1
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_vill
xs_bad_vill:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  li t0,0x20
  li t1,8
  vsetvl zero,t1,t0
  .word 0x0294050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_vm0
xs_bad_vm0:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0094050b
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_bad_vsoff
xs_bad_vsoff:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,-1
  vsetivli zero,8,e8,m1,tu,mu
  li t0,0x600
  csrc mstatus,t0
  .word 0x0294050b
  li t0,0x200
  csrs mstatus,t0
  csrwi vstart,0
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_reg_0
xs_reg_0:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v1,(a0)
  vle8.v v2,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0220800b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v0,(a2)
  ret
.global xs_reg_1
xs_reg_1:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0231008b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v1,(a2)
  ret
.global xs_reg_2
xs_reg_2:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v3,(a0)
  vle8.v v4,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0241810b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v2,(a2)
  ret
.global xs_reg_3
xs_reg_3:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v4,(a0)
  vle8.v v5,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0252018b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v3,(a2)
  ret
.global xs_reg_4
xs_reg_4:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v5,(a0)
  vle8.v v6,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0262820b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v4,(a2)
  ret
.global xs_reg_5
xs_reg_5:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v6,(a0)
  vle8.v v7,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0273028b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v5,(a2)
  ret
.global xs_reg_6
xs_reg_6:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v7,(a0)
  vle8.v v8,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0283830b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v6,(a2)
  ret
.global xs_reg_7
xs_reg_7:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0294038b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v7,(a2)
  ret
.global xs_reg_8
xs_reg_8:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v9,(a0)
  vle8.v v10,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x02a4840b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v8,(a2)
  ret
.global xs_reg_9
xs_reg_9:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v10,(a0)
  vle8.v v11,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x02b5048b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v9,(a2)
  ret
.global xs_reg_10
xs_reg_10:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v11,(a0)
  vle8.v v12,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x02c5850b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v10,(a2)
  ret
.global xs_reg_11
xs_reg_11:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v12,(a0)
  vle8.v v13,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x02d6058b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v11,(a2)
  ret
.global xs_reg_12
xs_reg_12:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v13,(a0)
  vle8.v v14,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x02e6860b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v12,(a2)
  ret
.global xs_reg_13
xs_reg_13:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v14,(a0)
  vle8.v v15,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x02f7068b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v13,(a2)
  ret
.global xs_reg_14
xs_reg_14:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v15,(a0)
  vle8.v v16,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0307870b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v14,(a2)
  ret
.global xs_reg_15
xs_reg_15:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v16,(a0)
  vle8.v v17,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0318078b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v15,(a2)
  ret
.global xs_reg_16
xs_reg_16:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v17,(a0)
  vle8.v v18,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0328880b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v16,(a2)
  ret
.global xs_reg_17
xs_reg_17:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v18,(a0)
  vle8.v v19,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0339088b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v17,(a2)
  ret
.global xs_reg_18
xs_reg_18:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v19,(a0)
  vle8.v v20,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x0349890b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v18,(a2)
  ret
.global xs_reg_19
xs_reg_19:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v20,(a0)
  vle8.v v21,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x035a098b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v19,(a2)
  ret
.global xs_reg_20
xs_reg_20:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v21,(a0)
  vle8.v v22,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x036a8a0b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v20,(a2)
  ret
.global xs_reg_21
xs_reg_21:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v22,(a0)
  vle8.v v23,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x037b0a8b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v21,(a2)
  ret
.global xs_reg_22
xs_reg_22:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v23,(a0)
  vle8.v v24,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x038b8b0b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v22,(a2)
  ret
.global xs_reg_23
xs_reg_23:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v24,(a0)
  vle8.v v25,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x039c0b8b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v23,(a2)
  ret
.global xs_reg_24
xs_reg_24:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v25,(a0)
  vle8.v v26,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x03ac8c0b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v24,(a2)
  ret
.global xs_reg_25
xs_reg_25:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v26,(a0)
  vle8.v v27,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x03bd0c8b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v25,(a2)
  ret
.global xs_reg_26
xs_reg_26:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v27,(a0)
  vle8.v v28,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x03cd8d0b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v26,(a2)
  ret
.global xs_reg_27
xs_reg_27:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v28,(a0)
  vle8.v v29,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x03de0d8b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v27,(a2)
  ret
.global xs_reg_28
xs_reg_28:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v29,(a0)
  vle8.v v30,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x03ee8e0b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v28,(a2)
  ret
.global xs_reg_29
xs_reg_29:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v30,(a0)
  vle8.v v31,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x03ff0e8b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v29,(a2)
  ret
.global xs_reg_30
xs_reg_30:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v31,(a0)
  vle8.v v0,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x020f8f0b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v30,(a2)
  ret
.global xs_reg_31
xs_reg_31:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v0,(a0)
  vle8.v v1,(a1)
  vsetivli zero,8,e8,m1,tu,mu
  .word 0x02100f8b
  vsetivli zero,16,e8,m1,tu,mu
  vse8.v v31,(a2)
  ret
.global xs_vector_add
xs_vector_add:
  vsetivli zero,16,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vadd.vv v10,v8,v9
  vse8.v v10,(a2)
  ret
.global xs_branch_recovery
xs_branch_recovery:
  vsetivli zero,8,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  vmv.v.i v10,3
  ld t0,0(a2)
  beqz t0,1f
  .word 0x0294050b
  1:
  vsetivli zero,1,e32,m1,tu,mu
  vmv.x.s a0,v10
  ret
.global xs_issue8
xs_issue8:
  vsetivli zero,8,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  .word 0x0294080b
  .word 0x0294088b
  .word 0x0294090b
  .word 0x0294098b
  .word 0x02940a0b
  .word 0x02940a8b
  .word 0x02940b0b
  .word 0x02940b8b
  vsetivli zero,1,e32,m1,tu,mu
  li a0,0
  vmv.x.s t0,v16
  add a0,a0,t0
  vmv.x.s t0,v17
  add a0,a0,t0
  vmv.x.s t0,v18
  add a0,a0,t0
  vmv.x.s t0,v19
  add a0,a0,t0
  vmv.x.s t0,v20
  add a0,a0,t0
  vmv.x.s t0,v21
  add a0,a0,t0
  vmv.x.s t0,v22
  add a0,a0,t0
  vmv.x.s t0,v23
  add a0,a0,t0
  ret
.global xs_chain16
xs_chain16:
  vsetivli zero,8,e8,m1,tu,mu
  vle8.v v8,(a0)
  vle8.v v9,(a1)
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  .word 0x0294040b
  vsetivli zero,1,e32,m1,tu,mu
  vmv.x.s a0,v8
  ret
.global xs_vdot64
xs_vdot64:
  vsetivli zero,8,e8,m1,tu,mu
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  .word 0x0231040b
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  .word 0x0231048b
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  .word 0x0231050b
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  .word 0x0231058b
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  .word 0x0231060b
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  .word 0x0231068b
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  .word 0x0231070b
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  .word 0x0231078b
  vsetivli zero,1,e32,m1,tu,mu
  li a0,0
  vmv.x.s t0,v8
  add a0,a0,t0
  vmv.x.s t0,v9
  add a0,a0,t0
  vmv.x.s t0,v10
  add a0,a0,t0
  vmv.x.s t0,v11
  add a0,a0,t0
  vmv.x.s t0,v12
  add a0,a0,t0
  vmv.x.s t0,v13
  add a0,a0,t0
  vmv.x.s t0,v14
  add a0,a0,t0
  vmv.x.s t0,v15
  add a0,a0,t0
  ret
.global xs_rvv64
xs_rvv64:
  vsetivli zero,1,e32,m1,tu,mu
  vmv.s.x v0,zero
  vsetivli zero,8,e8,mf2,tu,mu
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  vwmul.vv v16,v2,v3
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  vwmul.vv v17,v2,v3
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  vwmul.vv v18,v2,v3
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  vwmul.vv v19,v2,v3
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  vwmul.vv v20,v2,v3
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  vwmul.vv v21,v2,v3
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  vwmul.vv v22,v2,v3
  vle8.v v2,(a0)
  vle8.v v3,(a1)
  addi a0,a0,8
  addi a1,a1,8
  vwmul.vv v23,v2,v3
  vsetivli zero,8,e16,m1,tu,mu
  vwredsum.vs v8,v16,v0
  vwredsum.vs v9,v17,v0
  vwredsum.vs v10,v18,v0
  vwredsum.vs v11,v19,v0
  vwredsum.vs v12,v20,v0
  vwredsum.vs v13,v21,v0
  vwredsum.vs v14,v22,v0
  vwredsum.vs v15,v23,v0
  vsetivli zero,1,e32,m1,tu,mu
  li a0,0
  vmv.x.s t0,v8
  add a0,a0,t0
  vmv.x.s t0,v9
  add a0,a0,t0
  vmv.x.s t0,v10
  add a0,a0,t0
  vmv.x.s t0,v11
  add a0,a0,t0
  vmv.x.s t0,v12
  add a0,a0,t0
  vmv.x.s t0,v13
  add a0,a0,t0
  vmv.x.s t0,v14
  add a0,a0,t0
  vmv.x.s t0,v15
  add a0,a0,t0
  ret
