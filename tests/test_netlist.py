import sys,json,random,time,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT))
from model.reference import execute,pack
from tools.netlist_sim import Netlist
r=random.Random(20261007);start=time.time()
core=Netlist(ROOT/'results/core_netlist.json','VDotCore')
serial=Netlist(ROOT/'results/serial_netlist.json','VDotSerial')
pipe=Netlist(ROOT/'results/pipe_netlist.json','VDotPipe')
counts={'required':0,'exhaustive_single_lane':0,'random_full_sources':0,'pipeline_cycles':0}
def check(a,b):
    ref=execute(a,b)
    assert core.outputs(dict(a=a,b=b,active=1))['result']==ref
    assert serial.outputs(dict(a=a,b=b))['result']==ref
    assert core.outputs(dict(a=a,b=b,active=0))['result']==0
for x in (0,1,-1,127,-128):
    for y in (0,1,-1,127,-128):
        check(pack([x]*8),pack([y]*8));counts['required']+=1
# Exhaust all signed int8 pairs; rotate the active lane, testing packing too.
for x in range(-128,128):
    for y in range(-128,128):
        lane=(x+y)&7
        check((x&255)<<(lane*8),(y&255)<<(lane*8));counts['exhaustive_single_lane']+=1
for _ in range(4096):
    check(r.getrandbits(128),r.getrandbits(128));counts['random_full_sources']+=1
# Exercise independent enables, consecutive captures, gaps and output holding.
prev_products=0;prev_result=0
for i in range(4096):
    a,b=r.getrandbits(128),r.getrandbits(128)
    e1,e2=r.randrange(2),r.randrange(2)
    if i<2:e1=e2=1;a=b=0
    want=prev_products if e2 else prev_result
    got=pipe.tick(dict(a=a,b=b,en1=e1,en2=e2,clock=0))['result']
    if i>=2:assert got==want,(i,got,want)
    if e1:prev_products=execute(a,b)
    prev_result=got;counts['pipeline_cycles']+=1
summary={'status':'PASS','method':'Yosys-elaborated word-level netlist, two-state simulation',
 'seed':20261007,'counts':counts,'elapsed_seconds':round(time.time()-start,3),
 'rtl_sha256':hashlib.sha256((ROOT/'rtl/VDot.sv').read_bytes()).hexdigest(),
 'not_verified':['Chisel whole-chip compilation','NEMU binary','XiangShan Difftest','flush/ROB integration','physical timing/area/power']}
(ROOT/'results/netlist_tests.json').write_text(json.dumps(summary,indent=2))
print(json.dumps(summary,indent=2))
