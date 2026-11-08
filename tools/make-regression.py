from pathlib import Path
P=Path(__file__).resolve().parents[1]
D=P/'software'; D.mkdir(exist_ok=True)
def ins(rd,s1,s2): return (1<<25)|(s2<<20)|(s1<<15)|(rd<<7)|11
lines=['.option arch, rv64gcv','.text','.align 2']
def fn(name,body): lines.extend([f'.global {name}',f'{name}:']+['  '+x for x in body]+['  ret'])
fn('xs_trap_entry',[
'addi sp,sp,-16','sd t0,0(sp)','sd t1,8(sp)','la t0,trap_cause','csrr t1,mcause','sd t1,0(t0)',
'la t0,trap_count','ld t1,0(t0)','addi t1,t1,1','sd t1,0(t0)',
'la t0,trap_pc','csrr t1,mepc','sd t1,0(t0)','addi t1,t1,4','csrw mepc,t1',
'ld t0,0(sp)','ld t1,8(sp)','addi sp,sp,16','mret'])
# mtvec handler has an unreachable ret after mret; use direct mode, 4-byte aligned.
profiles={
'sew16':['vsetivli zero,8,e16,m1,tu,mu'],
'lmul2':['vsetivli zero,8,e8,m2,tu,mu'],
'lmulf2':['vsetivli zero,8,e8,mf2,tu,mu'],
'vl0':['vsetivli zero,0,e8,m1,tu,mu'],
'vl1':['vsetivli zero,1,e8,m1,tu,mu'],
'vl7':['vsetivli zero,7,e8,m1,tu,mu'],
'vl16':['vsetivli zero,16,e8,m1,tu,mu'],
'vstart':['csrwi vstart,1'],
'vill':['li t0,0x20','li t1,8','vsetvl zero,t1,t0'],
'vm0':[],
'vsoff':['li t0,0x600','csrc mstatus,t0'],
}
for name,profile in profiles.items():
    body=['vsetivli zero,16,e8,m1,tu,mu','vle8.v v8,(a0)','vle8.v v9,(a1)','vmv.v.i v10,-1',
          'vsetivli zero,8,e8,m1,tu,mu']+profile
    body += [f'.word 0x{(ins(10,8,9) if name!="vm0" else ins(10,8,9)&~(1<<25)):08x}']
    if name=='vsoff':body+=['li t0,0x200','csrs mstatus,t0']
    body+=['csrwi vstart,0','vsetivli zero,16,e8,m1,tu,mu','vse8.v v10,(a2)']
    fn('xs_bad_'+name,body)
for r in range(32):
    s1=(r+1)%32;s2=(r+2)%32
    fn('xs_reg_'+str(r),['vsetivli zero,16,e8,m1,tu,mu',f'vle8.v v{s1},(a0)',f'vle8.v v{s2},(a1)',
       'vsetivli zero,8,e8,m1,tu,mu',f'.word 0x{ins(r,s1,s2):08x}',
       'vsetivli zero,16,e8,m1,tu,mu',f'vse8.v v{r},(a2)'])
fn('xs_vector_add',['vsetivli zero,16,e8,m1,tu,mu','vle8.v v8,(a0)','vle8.v v9,(a1)',
                    'vadd.vv v10,v8,v9','vse8.v v10,(a2)'])
# Architectural branch recovery workload. Waveform inspection is needed to claim actual squashing.
fn('xs_branch_recovery',['vsetivli zero,8,e8,m1,tu,mu','vle8.v v8,(a0)','vle8.v v9,(a1)',
  'vmv.v.i v10,3','ld t0,0(a2)','beqz t0,1f',f'.word 0x{ins(10,8,9):08x}',
  '1:','vsetivli zero,1,e32,m1,tu,mu','vmv.x.s a0,v10'])
fn('xs_issue8',['vsetivli zero,8,e8,m1,tu,mu','vle8.v v8,(a0)','vle8.v v9,(a1)']+
   [f'.word 0x{ins(16+j,8,9):08x}' for j in range(8)]+
   ['vsetivli zero,1,e32,m1,tu,mu','li a0,0']+
   [x for j in range(8) for x in [f'vmv.x.s t0,v{16+j}','add a0,a0,t0']])
fn('xs_chain16',['vsetivli zero,8,e8,m1,tu,mu','vle8.v v8,(a0)','vle8.v v9,(a1)']+
   [f'.word 0x{ins(8,8,9):08x}' for j in range(16)]+
   ['vsetivli zero,1,e32,m1,tu,mu','vmv.x.s a0,v8'])
# 64-element blocked kernels, same 64 input bytes, exact 64-bit accumulation.
for mode in ['vdot','rvv']:
    b=[]
    if mode=='rvv':b+=['vsetivli zero,1,e32,m1,tu,mu','vmv.s.x v0,zero']
    b+=[f'vsetivli zero,8,e8,{"m1" if mode=="vdot" else "mf2"},tu,mu']
    for j in range(8):
        b+=['vle8.v v2,(a0)','vle8.v v3,(a1)','addi a0,a0,8','addi a1,a1,8']
        b+=[f'.word 0x{ins(8+j,2,3):08x}' if mode=='vdot' else f'vwmul.vv v{16+j},v2,v3']
    if mode=='rvv':
        b+=['vsetivli zero,8,e16,m1,tu,mu']
        b += [f'vwredsum.vs v{8+j},v{16+j},v0' for j in range(8)]
    b+=['vsetivli zero,1,e32,m1,tu,mu','li a0,0']
    for j in range(8):b+=[f'vmv.x.s t0,v{8+j}','add a0,a0,t0']
    fn('xs_'+mode+'64',b)
(D/'regression_asm.S').write_text('\n'.join(lines)+'\n')
(D/'Makefile.regression').write_text('''NAME = regression$(MODE)
SRCS = regression.c reference.c kernels.S regression_asm.S
DST_DIR = $(CURDIR)/build/mode$(MODE)/
CFLAGS += -O2 -fno-tree-vectorize -march=rv64gcv -mabi=lp64d
CPPFLAGS += -DTEST_MODE=$(MODE)
include $(AM_HOME)/Makefile.app
''')
declarations='\n'.join(f'extern void xs_bad_{n}(const int8_t*,const int8_t*,uint8_t*);' for n in profiles)
declarations+='\n'+'\n'.join(f'extern void xs_reg_{r}(const int8_t*,const int8_t*,uint8_t*);' for r in range(32))
declarations+='\nstatic regfn regs[]={'+','.join('xs_reg_'+str(r) for r in range(32))+'};\n'
declarations+='static regfn bad[]={'+','.join('xs_bad_'+n for n in profiles)+'};\n'
declarations+='static const char *names[]={'+','.join('"'+n+'"' for n in profiles)+'};\n'
(D/'regression_decl.h').write_text(declarations)
print('Generated regression assembly: 32 register positions, 11 illegal profiles, branch and GEMV kernels')
