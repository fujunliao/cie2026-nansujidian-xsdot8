`timescale 1ns/1ps
module datapath_tb;
reg clock=0,en1=0,en2=0,active=0;
reg [127:0] a=0,b=0;
wire [127:0] result,iso,raw;
VDotPipe dut(clock,en1,en2,a,b,result);
VDotProducts #(.ISOLATE(1)) gate_mul(a,b,active,iso);
VDotProducts #(.ISOLATE(0)) raw_mul(a,b,active,raw);
reg [127:0] prev_iso=0,prev_raw=0;
reg signed [31:0] pending=0,expected=0,sum;
reg signed [7:0] x,y;
integer i,j,seed=20261008,iso_flips=0,raw_flips=0,checks=0;
function integer pop;
input [127:0] v;
integer k;begin pop=0;for(k=0;k<128;k=k+1)pop=pop+v[k];end
endfunction
initial begin
  $dumpfile("datapath.vcd");$dumpvars(0,datapath_tb);
  // Defined initialization through legal enables, no claimed reset on data registers.
  en1=1;#5;clock=1;#5;clock=0;en2=1;#5;clock=1;#5;clock=0;
  for(i=0;i<4096;i=i+1)begin
    a={$random(seed),$random(seed),$random(seed),$random(seed)};
    b={$random(seed),$random(seed),$random(seed),$random(seed)};
    en1=($random(seed)&3)!=0;en2=($random(seed)&3)!=0;
    active=(i%32)<16;
    sum=0;
    for(j=0;j<8;j=j+1)begin x=a[8*j+:8];y=b[8*j+:8];sum=sum+x*y;end
    if(en2)expected=pending;
    if(en1)pending=sum;
    #4;
    iso_flips=iso_flips+pop(iso^prev_iso);raw_flips=raw_flips+pop(raw^prev_raw);
    prev_iso=iso;prev_raw=raw;
    if(active && iso!==raw)$fatal(1,"isolation active mismatch");
    if(!active && iso!==128'b0)$fatal(1,"isolation idle mismatch");
    clock=1;#1;
    if(result!=={96'b0,expected})$fatal(1,"pipeline mismatch cycle=%0d actual=%h expect=%h",i,result,expected);
    checks=checks+1;#5;clock=0;
  end
  $display("DATAPATH cycles=%0d randomized_enables PASS",checks);
  $display("ISOLATION samples=4096 duty=50%% gated_product_bit_flips=%0d ungated_product_bit_flips=%0d",iso_flips,raw_flips);
  $finish;
end
endmodule
