"""Run on the ACTUAL XiangShan host. This alone is not proof of a working emu."""
import argparse,socket,platform,subprocess,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--team',required=True);p.add_argument('--xs',type=Path,required=True);a=p.parse_args()
try: ip=socket.gethostbyname(socket.gethostname())
except OSError: ip='UNRESOLVED'
print(f'hello xiangshan, I am {a.team}, IP address {ip}')
print(platform.platform())
subprocess.run(['git','-C',str(a.xs),'rev-parse','HEAD'],check=True)
subprocess.run([str(a.xs.resolve()/'build'/'emu'),'--help'],check=True)
