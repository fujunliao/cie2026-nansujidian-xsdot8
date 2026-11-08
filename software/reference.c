#include "vdot.h"
int32_t xs_ref8(const int8_t *a,const int8_t *b) {
  int32_t s=0;
  for(unsigned i=0;i<8;i++) s += (int32_t)a[i]*(int32_t)b[i];
  return s;
}
int64_t xs_gemv_row(const int8_t *a,const int8_t *b,size_t n,int use_vdot) {
  int64_t s=0;
  size_t i=0;
  for(;i+8<=n;i+=8) s += use_vdot ? xs_vdot8(a+i,b+i) : xs_baseline8(a+i,b+i);
  for(;i<n;i++) s += (int32_t)a[i]*(int32_t)b[i];
  return s;
}
