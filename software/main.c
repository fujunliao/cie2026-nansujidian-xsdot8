#include <stdint.h>
#include <klib.h>
#include "vdot.h"
extern int32_t xs_alias_vs1(const int8_t*,const int8_t*);
extern int32_t xs_alias_vs2(const int8_t*,const int8_t*);
static uint32_t rng=20261007;
static uint32_t next(void){ rng^=rng<<13; rng^=rng>>17; rng^=rng<<5; return rng; }
static inline uint64_t cycle(void){uint64_t x; asm volatile("rdcycle %0":"=r"(x)::"memory");return x;}
#ifndef XSDOT8_CASES
#define XSDOT8_CASES 1025
#endif
#ifndef XSDOT8_RUNS
#define XSDOT8_RUNS 9
#endif
#ifndef XSDOT8_REPEATS
#define XSDOT8_REPEATS 256
#endif
int main(void){
  /* AM startup initializes FS but leaves VS off; enable vector state. */
  asm volatile("csrs mstatus, %0" :: "r"(0x200UL) : "memory");
  int8_t a[16],b[16]; uint8_t out[16];
  const int8_t values[]={0,1,-1,127,-128};
  unsigned cases=0;
  for(unsigned k=0;k<XSDOT8_CASES;k++){
    for(unsigned i=0;i<16;i++){
      a[i]=k<25?values[k/5]:(int8_t)next();
      b[i]=k<25?values[k%5]:(int8_t)next();
    }
    int32_t ref=xs_ref8(a,b);
    int32_t actual[4]={xs_vdot8(a,b),xs_baseline8(a,b),xs_alias_vs1(a,b),xs_alias_vs2(a,b)};
    for(unsigned f=0;f<4;f++) if(actual[f]!=ref){
      printf("FAIL case=%u kernel=%u expected=%d actual=%d\n", k,f,ref,actual[f]);
      return 1;
    }
    xs_vdot_full(a,b,out);
    for(unsigned i=0;i<16;i++) {
      uint8_t expected=i<4?((uint32_t)ref>>(i*8))&255:0;
      if(out[i]!=expected){
        printf("FAIL full-register case=%u byte=%u expected=%u actual=%u\n",k,i,expected,out[i]);
        return 2;
      }
    }
    cases++;
  }
  printf("XSDot8 functional cases=%u PASS\n",cases);
  /* End-to-end callable-kernel cycles, NOT isolated FU latency. */
  volatile int64_t checksum=0;
  for(unsigned mode=0;mode<2;mode++){
    for(unsigned warm=0;warm<16;warm++) checksum+=mode?xs_vdot8(a,b):xs_baseline8(a,b);
    for(unsigned run=0;run<XSDOT8_RUNS;run++){
      uint64_t begin=cycle();
      for(unsigned i=0;i<XSDOT8_REPEATS;i++) checksum+=mode?xs_vdot8(a,b):xs_baseline8(a,b);
      uint64_t elapsed=cycle()-begin;
      printf("BENCH,%s,%u,%lu,%u\n",mode?"vdot":"baseline",run,(unsigned long)elapsed,XSDOT8_REPEATS);
    }
  }
  printf("checksum=%ld\n",(long)checksum);
  return 0;
}
