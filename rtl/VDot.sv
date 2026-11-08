// SPDX-License-Identifier: MIT
// XSDot8: eight signed byte products, exact 19-bit reduction, 32-bit result.
// Low 64 source bits participate. Output placement is a project interpretation.
module VDotProducts #(parameter ISOLATE = 1)(
  input [127:0] a, b, input active, output [127:0] products
);
  genvar i;
  generate for (i=0; i<8; i=i+1) begin: lane
    wire signed [7:0] x = (!ISOLATE || active) ? a[8*i +: 8] : 8'sd0;
    wire signed [7:0] y = (!ISOLATE || active) ? b[8*i +: 8] : 8'sd0;
    wire signed [15:0] product = x * y;
    assign products[16*i +: 16] = product;
  end endgenerate
endmodule

module VDotReduce(input [127:0] products, output [127:0] result);
  wire signed [15:0] p [0:7];
  wire signed [16:0] s [0:3];
  wire signed [17:0] t [0:1];
  wire signed [18:0] sum;
  genvar i;
  generate for(i=0;i<8;i=i+1) begin: unpack
    assign p[i] = products[16*i +: 16];
  end
  for(i=0;i<4;i=i+1) begin: level1
    assign s[i] = $signed({p[2*i][15],p[2*i]}) + $signed({p[2*i+1][15],p[2*i+1]});
  end
  for(i=0;i<2;i=i+1) begin: level2
    assign t[i] = $signed({s[2*i][16],s[2*i]}) + $signed({s[2*i+1][16],s[2*i+1]});
  end endgenerate
  assign sum = $signed({t[0][17],t[0]}) + $signed({t[1][17],t[1]});
  assign result = {96'b0, {13{sum[18]}}, sum};
endmodule

module VDotCore #(parameter ISOLATE = 1)(
  input [127:0] a,b, input active, output [127:0] result
);
  wire [127:0] products;
  VDotProducts #(.ISOLATE(ISOLATE)) mul(a,b,active,products);
  VDotReduce reduce(products,result);
endmodule

// Datapath only. Parent XiangShan FU owns valid, ROB tags, flush and writeback.
// en1 captures products; en2 captures their reduction one cycle later.
module VDotPipe(input clock, input en1,en2,
  input [127:0] a,b, output reg [127:0] result);
  wire [127:0] products, reduced;
  reg [127:0] products_q;
  VDotProducts mul(a,b,en1,products);
  VDotReduce reduce(products_q,reduced);
  always @(posedge clock) begin
    if(en1) products_q <= products;
    if(en2) result <= reduced;
  end
endmodule

// Area/logic-depth ablation: intentionally serial 32-bit accumulation.
module VDotSerial(input [127:0] a,b, output [127:0] result);
  wire signed [31:0] sums [0:8];
  assign sums[0]=0;
  genvar i;
  generate for(i=0;i<8;i=i+1) begin: lane
    wire signed [7:0] x=a[i*8 +: 8], y=b[i*8 +: 8];
    wire signed [15:0] product=x*y;
    assign sums[i+1] = sums[i] + {{16{product[15]}},product};
  end endgenerate
  assign result={96'b0,sums[8]};
endmodule
