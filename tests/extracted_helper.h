def_EHelper(xsdot8) {
  require_vector(true);
  if (VLEN != 128 || vtype->vsew != 0 || vtype->vlmul != 0 ||
      !s->vm || vstart->val != 0) longjmp_exception(EX_II);
  if (vl->val != 8) {
    // This profile check occurs in XiangShan's execution stage. Its ROB
    // carries no original instruction for a late illegal-instruction trap,
    // so mtval is zero (an ISA-permitted value). Match that platform contract.
    // cpu_exec copies this field on longjmp and flushes the decode cache.
    IFDEF(CONFIG_TVAL_EX_II, s->isa.instr.val = 0);
    longjmp_exception(EX_II);
  }
  int32_t sum = 0;
  for (int i = 0; i < 8; ++i) {
    // Explicit conversion from unsigned byte avoids implementation-defined narrowing.
    uint32_t ua = vreg_b(id_src1->reg, i);
    uint32_t ub = vreg_b(id_src2->reg, i);
    int32_t a = ua < 128 ? (int32_t)ua : (int32_t)ua - 256;
    int32_t b = ub < 128 ? (int32_t)ub : (int32_t)ub - 256;
    sum += a * b;
  }
  for (int i = 0; i < 16; ++i) vreg_b(id_dest->reg, i) = 0;
  uint32_t bits = (uint32_t)sum;
  for (int i = 0; i < 4; ++i) vreg_b(id_dest->reg, i) = (bits >> (i*8)) & 255;
  vstart->val = 0;
  vp_set_dirty();
}
