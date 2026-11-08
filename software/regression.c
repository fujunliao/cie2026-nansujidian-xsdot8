#include <stdint.h>
#include <stddef.h>
#include <klib.h>
#include "vdot.h"
typedef void (*regfn)(const int8_t*,const int8_t*,uint8_t*);
volatile uint64_t trap_cause,trap_count,trap_pc;
extern void xs_trap_entry(void);
extern void xs_vector_add(const int8_t*,const int8_t*,uint8_t*);
extern int32_t xs_branch_recovery(const int8_t*,const int8_t*,const uint64_t*);
extern int64_t xs_vdot64(const int8_t*,const int8_t*),xs_rvv64(const int8_t*,const int8_t*);
extern int32_t xs_issue8(const int8_t*,const int8_t*),xs_chain16(const int8_t*,const int8_t*);
#include "regression_decl.h"
static uint32_t seed=0x20261008;
static uint32_t rng(void){seed^=seed<<13;seed^=seed>>17;seed^=seed<<5;return seed;}
static inline uint64_t cyc(void){uint64_t x;asm volatile("rdcycle %0":"=r"(x)::"memory");return x;}
static inline uint64_t inst(void){uint64_t x;asm volatile("rdinstret %0":"=r"(x)::"memory");return x;}
static int full(const uint8_t*out,int32_t ref){for(unsigned i=0;i<16;i++)if(out[i]!=(i<4?((uint32_t)ref>>(8*i))&255:0))return 0;return 1;}
static int64_t scalar(const int8_t*a,const int8_t*b,unsigned n){int64_t s=0;for(unsigned i=0;i<n;i++)s+=(int32_t)a[i]*b[i];return s;}
static int64_t blocked(const int8_t*a,const int8_t*b,unsigned n,int mode){int64_t s=0;unsigned i=0;for(;i+64<=n;i+=64)s+=mode?xs_vdot64(a+i,b+i):xs_rvv64(a+i,b+i);for(;i+8<=n;i+=8)s+=mode?xs_vdot8(a+i,b+i):xs_baseline8(a+i,b+i);for(;i<n;i++)s+=(int32_t)a[i]*b[i];return s;}
#ifndef TEST_MODE
#define TEST_MODE 0
#endif
int main(void){
  asm volatile("csrs mstatus,%0"::"r"(0x200UL):"memory");
  static int8_t a[264],b[264];uint8_t out[16];
  for(unsigned i=0;i<264;i++){a[i]=(int8_t)rng();b[i]=(int8_t)rng();}
  printf("XSDot8 V2 regression mode=%d seed=0x20261008\n",TEST_MODE);
  if(TEST_MODE==6){
    for(unsigned i=0;i<16;i++){a[i]=(int8_t)i;b[i]=2;}
    int32_t many=xs_issue8(a,b);
    int32_t chain=xs_chain16(a,b),ref=0;
    for(unsigned j=0;j<16;j++){ref=xs_ref8(a,b);for(unsigned k=0;k<8;k++)a[k]=k<4?(int8_t)((uint32_t)ref>>(8*k)):0;}
    printf("PIPELINE independent8=%d expected=448 chain16=%d expected=%d\n",many,chain,ref);
    if(many!=448||chain!=ref)return 61;
    printf("PIPELINE II_and_dependency PASS\n");return 0;
  }
  if(TEST_MODE==1){
    for(unsigned i=0;i<16;i++){a[i]=(int8_t)i;b[i]=2;}
    xs_vector_add(a,b,out);
    for(unsigned i=0;i<16;i++)if(out[i]!=i+2)return 31;
    printf("VECTOR_ADD bytes=16 PASS\n");
    for(unsigned j=0;j<8;j++)regs[j](a,b,out);
    if(!full(out,56))return 32;
    printf("VDOT_WAVE expected=56 PASS\n");return 0;
  }
  if(TEST_MODE==0||TEST_MODE==2){
    /* This upstream supports Smrnmi/Smdbltrp. Initialize the bare-metal
       exception environment explicitly before installing a normal M trap. */
    asm volatile("csrs 0x744,%0\n\tcsrc mstatus,%1"::"r"(8UL),"r"(1UL<<42):"memory");
    uint64_t oldvec;asm volatile("csrrw %0,mtvec,%1":"=r"(oldvec):"r"(xs_trap_entry):"memory");
    for(unsigned k=0;k<sizeof(bad)/sizeof(bad[0]);k++){
      trap_cause=~0UL;trap_count=0;trap_pc=0;
      bad[k](a,b,out);
      int intact=1;for(unsigned j=0;j<16;j++)if(out[j]!=255)intact=0;
      printf("ILLEGAL,%s,cause=%lu,count=%lu,pc=%lx,unchanged=%d\n",names[k],(unsigned long)trap_cause,(unsigned long)trap_count,(unsigned long)trap_pc,intact);
      if(trap_count!=1||trap_cause!=2||!intact)return 10+k;
    }
    asm volatile("csrw mtvec,%0"::"r"(oldvec):"memory");
    printf("ILLEGAL profiles=11 PASS\n");if(TEST_MODE==2)return 0;
  }
  if(TEST_MODE==0||TEST_MODE==3){
    for(unsigned k=0;k<128;k++){
      for(unsigned i=0;i<16;i++){a[i]=(int8_t)rng();b[i]=(int8_t)rng();}
      for(unsigned r=0;r<32;r++){regs[r](a,b,out);if(!full(out,xs_ref8(a,b))){printf("REG_FAIL k=%u r=%u\n",k,r);return 40;}}
    }
    printf("REGFILE cases=4096 incl_v0_v31_full128 PASS\n");
    volatile uint64_t taken=0;
    for(unsigned k=0;k<512;k++){
      taken=(rng()&3)==0;
      int32_t v=xs_branch_recovery(a,b,(const uint64_t*)&taken);
      int32_t ref=taken?xs_ref8(a,b):0x03030303;
      if(v!=ref){printf("BRANCH_FAIL k=%u expected=%d actual=%d\n",k,ref,v);return 41;}
    }
    printf("BRANCH recovery_cases=512 PASS\n");if(TEST_MODE==3)return 0;
  }
  if(TEST_MODE==0||TEST_MODE==4){
    unsigned lengths[]={0,1,7,8,9,15,31,63,64,65,127,128,129,255,256,263};
    for(unsigned k=0;k<16;k++)for(unsigned mode=0;mode<2;mode++)if(blocked(a,b,lengths[k],mode)!=scalar(a,b,lengths[k])){printf("GEMV_FAIL n=%u mode=%u\n",lengths[k],mode);return 50;}
    printf("GEMV tails_lengths=16 modes=2 PASS\n");
    volatile int64_t checksum=0;
    for(unsigned mode=0;mode<2;mode++){
      for(unsigned warm=0;warm<8;warm++)checksum+=blocked(a,b,256,mode);
      for(unsigned run=0;run<9;run++){
        uint64_t i0=inst(),c0=cyc();
        for(unsigned rep=0;rep<32;rep++)checksum+=blocked(a,b,256,mode);
        uint64_t c1=cyc(),i1=inst();
        printf("GEMVBENCH,%s,%u,%lu,%lu,32,256\n",mode?"vdot":"rvv",run,(unsigned long)(c1-c0),(unsigned long)(i1-i0));
      }
    }
    printf("GEMV checksum=%ld PASS\n",(long)checksum);
  }
  return 0;
}
