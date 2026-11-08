// SPDX-License-Identifier: MIT
package xiangshan.backend.fu.wrapper
import chisel3._
import chisel3.util.HasBlackBoxResource
class VDotPipe extends BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val clock = Input(Clock())
    val en1 = Input(Bool())
    val en2 = Input(Bool())
    val a = Input(UInt(128.W))
    val b = Input(UInt(128.W))
    val result = Output(UInt(128.W))
  })
  addResource("/xsdot8/VDotPipe.sv")
}
