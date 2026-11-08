#ifndef XSDOT8_H
#define XSDOT8_H
#include <stdint.h>
#include <stddef.h>
int32_t xs_vdot8(const int8_t *a, const int8_t *b);
int32_t xs_baseline8(const int8_t *a, const int8_t *b);
int32_t xs_ref8(const int8_t *a, const int8_t *b);
int64_t xs_gemv_row(const int8_t *a,const int8_t *b,size_t n,int use_vdot);
void xs_vdot_full(const int8_t *a,const int8_t *b,uint8_t *out);
#endif
