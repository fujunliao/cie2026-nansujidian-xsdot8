"""Capture a real process with PTY timing as an asciicast, without invented output."""
import os,pty,subprocess,time,json,sys,select,codecs,hashlib
from pathlib import Path
dest=Path(sys.argv[1]); command=sys.argv[2:]
dest.parent.mkdir(parents=True,exist_ok=True)
inputs={}
for opt in ['-i','--diff']:
    if opt in command:
        fp=Path(command[command.index(opt)+1]);inputs[str(fp)]=hashlib.sha256(fp.read_bytes()).hexdigest()
dest.with_suffix('.inputs.json').write_text(json.dumps({'command':command,'sha256':inputs},indent=2))
master,slave=pty.openpty();start=time.monotonic()
proc=subprocess.Popen(command,stdin=subprocess.DEVNULL,stdout=slave,stderr=slave,close_fds=True)
os.close(slave);dec=codecs.getincrementaldecoder('utf-8')('replace')
with dest.with_suffix('.cast').open('w') as cast,dest.with_suffix('.log').open('w') as log:
    cast.write(json.dumps({'version':2,'width':110,'height':32,'timestamp':int(time.time()),'title':'XSDot8 actual verification execution','command':command},ensure_ascii=False)+'\n')
    while True:
        try:data=os.read(master,16384)
        except OSError:break
        if not data:break
        s=dec.decode(data); log.write(s);log.flush()
        cast.write(json.dumps([round(time.monotonic()-start,4),'o',s],ensure_ascii=False)+'\n');cast.flush()
    rc=proc.wait()
dest.with_suffix('.exit').write_text(str(rc)+'\n')
print(f'{dest.name}: exit={rc}, wall_seconds={time.monotonic()-start:.1f}')
sys.exit(rc)
