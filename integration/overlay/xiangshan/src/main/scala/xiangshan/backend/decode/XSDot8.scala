// SPDX-License-Identifier: MIT
package xiangshan.backend.decode
import chisel3._
import chisel3.util._
object XSDot8 {
  // Reserved custom-0 major opcode. Vector register indices retain OP-V positions.
  val instruction = BitPat("b0000001??????????000?????0001011")
  def fuOp = "hfe".U(xiangshan.FuOpTypeWidth.W) // unused in pinned VipuType; ff is dummy
}
