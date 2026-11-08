"""Apply only to exact pinned upstream files. All checks occur before writes."""
import argparse,json,hashlib,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('repo',choices=['xiangshan','nemu']);p.add_argument('path',type=Path);p.add_argument('--apply',action='store_true');a=p.parse_args()
root=Path(__file__).resolve().parents[1]
target=a.path.resolve();lock=json.loads((root/'upstream-lock.json').read_text())
sha=subprocess.check_output(['git','-C',str(target),'rev-parse','HEAD'],text=True).strip()
if sha!=lock[a.repo]:raise SystemExit('STOP: upstream commit differs from upstream-lock.json')
records=json.loads((root/'integration/manifest.json').read_text())[a.repo]
todo=[]
for rec in records:
    dest=(target/rec['path']).resolve()
    if not dest.is_relative_to(target):raise SystemExit('unsafe path')
    actual=hashlib.sha256(dest.read_bytes()).hexdigest() if dest.exists() else None
    if actual!=rec['before_sha256']:raise SystemExit('STOP: modified or unexpected file: '+str(dest))
    content=(root/'integration/overlay'/a.repo/rec['path']).read_bytes()
    if hashlib.sha256(content).hexdigest()!=rec['after_sha256']:raise SystemExit('overlay checksum mismatch')
    todo.append((dest,content))
print('Verified',sha,'files:',len(todo))
if not a.apply:print('Dry run only. Use --apply to copy reviewed overlay.')
else:
    for dest,content in todo:
        dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(content)
    print('Applied. Inspect git diff. This does NOT certify compilation or simulation.')
