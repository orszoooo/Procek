`timescale 1ns/100ps

module rom # (
    parameter WIDTH = 8
)(
    addr,
    instr,
    arg
);
input [WIDTH-1:0] addr;
output [WIDTH-1:0] instr;
output [WIDTH-1:0] arg;

reg [(WIDTH*2)-1:0] mem [0:WIDTH-1];

initial begin
  $readmemh("rom_init.hex", mem);
end

assign instr = mem[addr][2*WIDTH-1:WIDTH];
assign arg = mem[addr][WIDTH-1:0];

endmodule