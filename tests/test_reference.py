import unittest,random,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from model.reference import *
class OracleTests(unittest.TestCase):
  def test_required(self):
    for a,b,want in [([1]*8,[2]*8,16),([-1]*8,[2]*8,-16),([-128]*8,[-128]*8,131072),([-128]*8,[127]*8,-130048),([127]*8,[127]*8,129032),([0]*8,[127]*8,0)]:
      self.assertEqual(dot(pack(a),pack(b)),want)
      self.assertEqual(execute(pack(a),pack(b)),want&0xffffffff)
  def test_upper_half_ignored(self):
    r=random.Random(91)
    for _ in range(1000):
      a,b=r.getrandbits(64),r.getrandbits(64)
      self.assertEqual(execute(a,b),execute(a|(r.getrandbits(64)<<64),b|(r.getrandbits(64)<<64)))
  def test_encoding_all_registers(self):
    for d in range(32):
      for a in range(32):
        for b in range(32): self.assertEqual(decode(encode(d,a,b)),(d,a,b))
    self.assertEqual(encode(10,8,9),0x0294050b)
  def test_reject(self):
    for kwargs in [dict(sew=16),dict(vl=0),dict(vl=16),dict(lmul=2),dict(vm=0),dict(vstart=1),dict(vill=True)]:
      with self.assertRaises(ValueError): execute(0,0,**kwargs)
    for bit in range(32):
      if MASK>>bit&1:
        with self.assertRaises(ValueError):decode(MATCH^(1<<bit))
if __name__=='__main__': unittest.main()
