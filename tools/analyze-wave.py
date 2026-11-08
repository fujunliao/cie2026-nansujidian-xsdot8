from pathlib import Path
import json,sys
from functools import lru_cache
root=Path(__file__).resolve().parents[1]/'results/waves'
if len(sys.argv)>1:root=root/'throughput'
sig=json.loads((root/'selected-signals.json').read_text());rows=json.loads((root/'selected-rows.json').read_text())
@lru_cache(None)
def sid(suffix):return next(s['id'] for s in sig if s['path'].endswith(suffix))
def val(v,suffix):return int(v.get(sid(suffix),'0'),2)
ids={s['path']:s['id'] for s in sig}
va_units=[s['path'].removesuffix('io_in_valid') for s in sig if s['path'].endswith('.VialuFix.io_in_valid')]
issue=[];wb=[];vadd=[];commits=[];cur={};j=0
# FST default dump is indexed directly by DiffTrapEvent.cycleCnt, once/cycle.
for t in range(rows[0][0],rows[-1][0]+1):
    while j<len(rows) and rows[j][0]<=t:cur=rows[j][1];j+=1
    if val(cur,'.Vipu.xsdot8_issue'):
        issue.append({'cycle':t,'a':hex(val(cur,'.Vipu.dot.a')),'b':hex(val(cur,'.Vipu.dot.b'))})
    if val(cur,'.Vipu.xsdot8_writeback'):
        wb.append({'cycle':t,'result':hex(val(cur,'.Vipu.dot.result')),'rob_index':val(cur,'.Vipu.io_out_bits_ctrl_robIdx_value')})
    for u in va_units:
        if val(cur,u+'io_in_valid'):
            vadd.append({'unit':u,'event':'issue','cycle':t,'op':val(cur,u+'io_in_bits_ctrl_fuOpType'),'a':hex(val(cur,u+'io_in_bits_data_src_0')),'b':hex(val(cur,u+'io_in_bits_data_src_1'))})
        if val(cur,u+'io_out_valid'):
            vadd.append({'unit':u,'event':'writeback','cycle':t,'result':hex(val(cur,u+'io_out_bits_res_data'))})
    if val(cur,'.rob.io_commits_isCommit'):
        for k in range(8):
            if val(cur,f'.rob.io_commits_commitValid_{k}'):
                instr=val(cur,f'.rob.io_commits_info_{k}_debug_instr')
                if instr&127==11 or (instr&127==87 and (instr>>26)==0 and ((instr>>12)&7)==0):
                    commits.append({'cycle':t,'slot':k,'pc':hex(val(cur,f'.rob.io_commits_info_{k}_debug_pc')),'instr':hex(instr)})
assert len(issue)==len(wb),(len(issue),len(wb))
lat=[b['cycle']-a['cycle'] for a,b in zip(issue,wb)]
report={'source':'actual full-chip FST','timestamp_unit':'guest cycle (default emu --dump-wave)','issues':issue,'writebacks':wb,'latencies_cycles':lat,'vadd_events':vadd,'relevant_commits':commits}
if len(issue)==24:
    report['independent_issue_intervals']=[issue[i+1]['cycle']-issue[i]['cycle'] for i in range(7)]
    report['dependent_issue_intervals']=[issue[i+1]['cycle']-issue[i]['cycle'] for i in range(8,23)]
(root/'analysis.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
