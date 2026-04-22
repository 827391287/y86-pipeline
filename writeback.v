`include "define.v"
module writeback(
input wire[3 : 0] icode_i,
input wire[63 : 0] valE_i,
input wire[63 : 0] valB_i,
input wire[63 : 0] valM_i,
input wire         Cnd_i,


output wire[63 : 0] valE_o,
output wire[63 : 0] valM_o,

output wire stat_o

);

assign valE_o = valE_i;
assign valM_o = valM_i;



endmodule