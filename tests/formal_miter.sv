module VDotMiter(input [127:0] a,b, output ok);
 wire [127:0] tree,serial;
 VDotCore core(a,b,1'b1,tree);
 VDotSerial refimpl(a,b,serial);
 assign ok=(tree==serial);
endmodule
