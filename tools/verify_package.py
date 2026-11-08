from pathlib import Path
import hashlib,json,sys
p=Path(__file__).resolve().parents[1]
checks=json.loads((p/'SHA256SUMS.json').read_text(encoding='utf-8'))
bad=[]
for n,sha in checks.items():
    f=p/n
    if not f.is_file() or hashlib.sha256(f.read_bytes()).hexdigest()!=sha:bad.append(n)
if bad:print('FAILED',*bad,sep='\n');sys.exit(1)
print('PASS',len(checks),'file hashes')
