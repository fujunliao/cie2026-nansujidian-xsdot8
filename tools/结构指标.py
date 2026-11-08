"""Read elaborated RTL structure; do not claim physical area or speedup."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
result={}
for file,top in [('core','VDotCore'),('serial','VDotSerial')]:
    cells=json.loads((root/f'results/{file}_netlist.json').read_text())['modules'][top]['cells'].values()
    widths=[(int(c['parameters']['Y_WIDTH'],2) if isinstance(c['parameters']['Y_WIDTH'],str) else int(c['parameters']['Y_WIDTH'])) for c in cells if c['type']=='$add']
    result[file]={'adder_output_widths':sorted(widths),'sum_adder_output_bits':sum(widths)}
result['proxy_reduction']=1-result['core']['sum_adder_output_bits']/result['serial']['sum_adder_output_bits']
result['meaning']='RTL adder output-width sum ONLY. Not physical area, timing, power or measured speedup.'
print(json.dumps(result,indent=2))
