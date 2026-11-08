/* Host unit harness for the exact helper extracted from the NEMU overlay.
 * Stubbed CSR/VRF access; not a NEMU executable or Difftest result.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <setjmp.h>
#include <stdlib.h>
#define VLEN 128
#define EX_II 2
typedef struct { unsigned reg; } Operand;
typedef struct { bool vm; } Decode;
static Operand sa,sb,sd;
#define id_src1 (&sa)
#define id_src2 (&sb)
#define id_dest (&sd)
static uint8_t vr[32][16];
#define vreg_b(r,i) vr[(r)][(i)]
static struct {unsigned vsew,vlmul;} vt;
static struct {uint64_t val;} length,start;
#define vtype (&vt)
#define vl (&length)
#define vstart (&start)
static jmp_buf trap;
static bool dirty;
static void longjmp_exception(int cause){longjmp(trap,cause);}
static void require_vector(bool check){(void)check;}
static void vp_set_dirty(void){dirty=true;}
#define IFDEF(config, ...) /* host harness does not model mtval */
#define def_EHelper(name) static void helper_##name(Decode *s)
#include "extracted_helper.h"
static uint32_t rng=20261007;
static uint32_t next(void){rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;return rng;}
static int invoke_helper(Decode *s){
  int cause=setjmp(trap);
  if(!cause) helper_xsdot8(s);
  return cause;
}
int main(void){
  Decode s={true};length.val=8;
  unsigned cases=0;
  for(unsigned d=0;d<32;d++)for(unsigned a=0;a<32;a++)for(unsigned b=0;b<32;b++){
    for(unsigned r=0;r<32;r++)for(unsigned i=0;i<16;i++)vr[r][i]=(uint8_t)next();
    int32_t ref=0;
    for(unsigned i=0;i<8;i++){
      int32_t x=vr[a][i],y=vr[b][i];if(x>=128)x-=256;if(y>=128)y-=256;ref+=x*y;
    }
    uint8_t before[32][16];memcpy(before,vr,sizeof vr);
    sa.reg=a;sb.reg=b;sd.reg=d;dirty=false;
    if(invoke_helper(&s)){fputs("unexpected trap\n",stderr);return 1;}
    for(unsigned r=0;r<32;r++)for(unsigned i=0;i<16;i++){
      unsigned expected=r!=d?before[r][i]:(i<4?((uint32_t)ref>>(8*i))&255:0);
      if(vr[r][i]!=expected)return 2;
    }
    if(!dirty || start.val!=0)return 3;
    cases++;
  }
  for(unsigned bad=0;bad<5;bad++){
    vt.vsew=vt.vlmul=0;length.val=8;start.val=0;s.vm=true;
    if(bad==0)vt.vsew=1;
    if(bad==1)vt.vlmul=1;
    if(bad==2)length.val=0;
    if(bad==3)start.val=1;
    if(bad==4)s.vm=false;
    uint8_t before[32][16];memcpy(before,vr,sizeof vr);dirty=false;
    if(!invoke_helper(&s))return 4;
    if(memcmp(before,vr,sizeof vr)||dirty)return 5;
  }
  printf("PASS: exact NEMU helper host harness; %u register-alias cases, 5 illegal-profile cases. NOT Difftest.\n",cases);
  return 0;
}
