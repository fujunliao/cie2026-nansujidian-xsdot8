"""Independent architectural oracle. Project profile: e8,m1,vl8,vm1,vstart0."""
MATCH = 0x0200000B
MASK = 0xFE00707F
def signed8(value):
    value &= 255
    return value if value < 128 else value - 256
def dot(a, b):
    if not (0 <= a < 1 << 128 and 0 <= b < 1 << 128):
        raise ValueError('sources must be 128-bit unsigned integers')
    return sum(signed8(a >> (8*i)) * signed8(b >> (8*i)) for i in range(8))
def execute(a, b, *, sew=8, lmul=1, vl=8, vm=1, vstart=0, vill=False):
    if (sew,lmul,vl,vm,vstart,vill) != (8,1,8,1,0,False):
        raise ValueError('illegal XSDot8 project profile')
    return dot(a,b) & 0xffffffff
def pack(values):
    if len(values)>16 or any(not -128 <= x <= 127 for x in values):
        raise ValueError('at most 16 signed bytes required')
    return sum((x & 255) << (i*8) for i,x in enumerate(values))
def encode(vd, vs1, vs2):
    if any(not 0 <= x < 32 for x in (vd,vs1,vs2)):
        raise ValueError('vector register index')
    return MATCH | vd << 7 | vs1 << 15 | vs2 << 20
def decode(word):
    if word & MASK != MATCH:
        raise ValueError('not vdot.vv')
    return (word >> 7 & 31, word >> 15 & 31, word >> 20 & 31)
