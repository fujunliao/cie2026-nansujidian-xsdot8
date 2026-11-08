from pathlib import Path
import subprocess,json,re,sys
r=Path(__file__).resolve().parents[1]/'results';out=r/'waves'
source=out/'vector-add-vdot.fst'
if len(sys.argv)>1:source=out/sys.argv[1];out=out/'throughput';out.mkdir(exist_ok=True)
proc=subprocess.Popen(['fst2vcd',str(source)],stdout=subprocess.PIPE,text=True,bufsize=1024*1024)
scope=[];sel=[];commits=[]
for line in proc.stdout:
    t=line.split()
    if not t:continue
    if t[0]=='$scope':scope.append(t[2])
    elif t[0]=='$upscope':scope.pop()
    elif t[0]=='$var':
        name='.'.join(scope+[t[4]])
        keep=any(('.'+unit+'.') in name and '.' not in name.split('.'+unit+'.',1)[1]
                 and (t[4].startswith('io_') or t[4].startswith('xsdot8_')) for unit in ['Vipu','VialuFix'])
        keep|= '.Vipu.dot.' in name and '.' not in name.split('.Vipu.dot.',1)[1]
        keep|= name=='TOP.SimTop.clock'
        keep|= '.inner_ctrlBlock.rob.io_commits_' in name and any(x in t[4] for x in ['debug_pc','debug_instr','isCommit','commitValid','robIdx'])
        keep|= '.inner_ctrlBlock.rob.io_flushOut_' in name
        if ('commit' in name.lower() and any(t[4].endswith(s) for s in ['_pc','_instr','_valid','_robIdx','_robIdx_value'])):
            commits.append({'path':name,'id':t[3],'width':int(t[2])})
            if 'difftest' in name.lower():keep=True
        if keep:sel.append({'path':name,'id':t[3],'width':int(t[2])})
    elif t[0]=='$enddefinitions':break
(out/'commit-signals.json').write_text(json.dumps(commits,indent=2))
# Stable short identifiers in compact VCD, one variable for every original alias.
selected={s['id'] for s in sel}; values={}; rows=[];tm=0;changed=False
def snapshot():
    if changed:rows.append([tm,values.copy()])
with (out/'selected.vcd').open('w') as f:
    f.write('$timescale 1ns $end\n$scope module captured $end\n')
    for i,s in enumerate(sel):f.write(f'$var wire {s["width"]} {s["id"]} s{i} $end\n')
    f.write('$upscope $end\n$enddefinitions $end\n')
    for line in proc.stdout:
        if line.startswith('#'):
            snapshot();tm=int(line[1:]);changed=False
            f.write(line)
        elif line[0:1] in '01xz' and line[1:].strip() in selected:
            ident=line[1:].strip();values[ident]=line[0];changed=True;f.write(line)
        elif line.startswith('b'):
            t=line.split()
            if len(t)==2 and t[1] in selected:values[t[1]]=t[0][1:];changed=True;f.write(line)
    snapshot()
assert proc.wait()==0
(out/'selected-signals.json').write_text(json.dumps(sel,indent=2))
(out/'selected-rows.json').write_text(json.dumps(rows,separators=(',',':')))
print('signals',len(sel),'event_rows',len(rows),'commit_candidates',len(commits),'last_timestamp',tm)
def event_rows(suffix):
    sig=next(s for s in sel if s['path'].endswith(suffix));ident=sig['id'];last='0';ev=[]
    for t,v in rows:
        x=v.get(ident,'0')
        if x=='1' and last!='1':ev.append(t)
        last=x
    return ev
issue=event_rows('.Vipu.xsdot8_issue');wb=event_rows('.Vipu.xsdot8_writeback')
print('vdot_issue_times',issue);print('vdot_writeback_times',wb)
(out/'event-summary.json').write_text(json.dumps({'vdot_issue_times':issue,'vdot_writeback_times':wb},indent=2))
