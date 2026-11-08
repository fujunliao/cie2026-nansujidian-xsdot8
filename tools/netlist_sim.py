"""Small fail-closed interpreter for Yosys word-level JSON cells used by VDot.
This executes the elaborated RTL netlist, not a rewritten dot-product model.
Only 2-state behavior is modeled. Uninitialized storage is deliberately seeded 0;
tests never claim a valid output before two qualified pipeline captures.
"""
import json
def param_int(value):
    return int(value,2) if isinstance(value,str) else int(value)
class Netlist:
    def __init__(self,path,top):
        self.m=json.loads(path.read_text())['modules'][top]
        self.cells=[c for c in self.m['cells'].values() if c['type']!='$scopeinfo'];self.reg={}
        self.seq=[c for c in self.cells if c['type'] in ('$dff','$dffe')]
        self.comb=[c for c in self.cells if c not in self.seq]
        for c in self.seq:
            self.reg.update({b:0 for b in c['connections']['Q']})
        known=set(self.reg)|{'0','1'}
        for p in self.m['ports'].values():
            if p['direction']=='input':known.update(p['bits'])
        self.order=[];pending=self.comb[:]
        while pending:
            moved=False
            for c in pending[:]:
                ins=[b for p,bits in c['connections'].items() if c['port_directions'][p]=='input' for b in bits]
                if all(b in known for b in ins):
                    self.order.append(c);pending.remove(c);moved=True
                    for p,bits in c['connections'].items():
                        if c['port_directions'][p]=='output':known.update(bits)
            if not moved:raise ValueError('combinational cycle, unknown bit, or unsupported structure')
    @staticmethod
    def number(bits,vals,signed=False):
        n=sum(vals[b]<<i for i,b in enumerate(bits))
        return n-(1<<len(bits)) if signed and n>>(len(bits)-1) else n
    @staticmethod
    def assign(bits,value,vals):
        for i,b in enumerate(bits):
            if isinstance(b,str):
                if b not in ('0','1'):raise ValueError('unknown constant')
                if int(b)!=(value>>i&1):raise ValueError('constant conflict')
            else: vals[b]=value>>i&1
    def settle(self,inputs):
        vals={'0':0,'1':1,**self.reg}
        for k,p in self.m['ports'].items():
            if p['direction']=='input':self.assign(p['bits'],inputs[k],vals)
        for c in self.order:
            conn=c['connections'];par=c['parameters'];t=c['type']
            def get(p):return self.number(conn[p],vals, bool(param_int(par.get(p+'_SIGNED','0'))))
            if t=='$mul':y=get('A')*get('B')
            elif t=='$add':y=get('A')+get('B')
            elif t=='$mux':y=get('B') if get('S') else get('A')
            elif t=='$logic_not':y=int(not get('A'))
            elif t=='$logic_and':y=int(bool(get('A')) and bool(get('B')))
            elif t=='$and':y=get('A')&get('B')
            elif t=='$eq':y=int(get('A')==get('B'))
            else:raise ValueError('unsupported cell '+t)
            self.assign(conn['Y'],y,vals)
        return vals
    def outputs(self,inputs):
        vals=self.settle(inputs)
        return {k:self.number(p['bits'],vals) for k,p in self.m['ports'].items() if p['direction']=='output'}
    def tick(self,inputs):
        vals=self.settle(inputs);new=dict(self.reg)
        for c in self.seq:
            conn=c['connections'];par=c['parameters']
            if param_int(par['CLK_POLARITY'])!=1:raise ValueError('only positive edge supported')
            enable=True
            if c['type']=='$dffe':enable=self.number(conn['EN'],vals)==param_int(par['EN_POLARITY'])
            if enable:self.assign(conn['Q'],self.number(conn['D'],vals),new)
        self.reg=new
        return self.outputs(inputs)
