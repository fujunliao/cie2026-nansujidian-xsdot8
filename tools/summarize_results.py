"""Recompute reported medians from the delivered actual system logs."""
from pathlib import Path
import json,re,statistics
p=Path(__file__).resolve().parents[1]
out={}
for section,name,pattern,modes in [
 ('callable','v2-full',r'BENCH,(baseline|vdot),(\d+),(\d+),(\d+)',['baseline','vdot']),
 ('gemv','v2-mode4',r'GEMVBENCH,(rvv|vdot),(\d+),(\d+),(\d+),(\d+),(\d+)',['rvv','vdot'])]:
 text=(p/'results/system'/(name+'.log')).read_text(encoding='utf-8')
 assert 'HIT GOOD TRAP' in text
 groups={m:[] for m in modes}
 for row in re.findall(pattern,text):
  n=int(row[3] if section=='callable' else row[4]);groups[row[0]].append(int(row[2])/n)
 assert all(len(v)==9 for v in groups.values())
 med={m:statistics.median(v) for m,v in groups.items()}
 out[section]={'median_cycles':med,'speedup':med[modes[0]]/med['vdot']}
print(json.dumps(out,indent=2))
