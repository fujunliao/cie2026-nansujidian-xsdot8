"""Consume measured log lines; never substitutes guessed XiangShan cycles."""
import sys,json,statistics
from pathlib import Path
groups={'baseline':[],'vdot':[]}
for line in Path(sys.argv[1]).read_text().splitlines():
  if not line.startswith('BENCH,'):continue
  _,kind,run,cycles,iters=line.split(',')
  cycles,iters=int(cycles),int(iters)
  if cycles<=0 or iters<=0: raise ValueError('invalid measurement')
  groups[kind].append(cycles/iters)
if any(len(x)<3 for x in groups.values()):raise SystemExit('Need >=3 measured runs of EACH variant')
med={k:statistics.median(v) for k,v in groups.items()}
print(json.dumps({'metric':'callable_kernel_cycles_per_call','samples':groups,'median':med,
  'speedup':med['baseline']/med['vdot'],'warning':'NOT isolated FU latency; report waveform issue-to-result latency separately'},indent=2))
