`include "define.v"

module decode_E_pipe_reg(

input wire clk_i,
input wire E_stall_i,
input wire E_bubble_i,

input wire [2:0] d_stat_i,
input wire [63 : 0] d_pc_i,
input wire [3 : 0] d_icode_i,
input wire [3 : 0] d_ifun_i,
input wire [63 : 0] d_valC_i,
input wire [63 : 0] d_valA_i,
input wire [63 : 0] d_valB_i,
input wire [3 : 0] d_dstE_i,
input wire [3 : 0] d_dstM_i,
input wire [3 : 0] d_srcA_i,
input wire [3 : 0] d_srcB_i,

output wire [2:0] E_stat_o,
output wire [63 : 0] E_pc_o,
output wire [3 : 0] E_icode_o,
output wire [3 : 0] E_ifun_o,
output wire [63 : 0] E_valC_o,
output wire [63 : 0] E_valA_o,
output wire [63 : 0] E_valB_o,
output wire [3 : 0] E_dstE_o,
output wire [3 : 0] E_dstM_o,
output wire [3 : 0] E_srcA_o,
output wire [3 : 0] E_srcB_o


);
reg [2:0] E_stat_tp;
reg [63 : 0] E_pc_tp;
reg [3 : 0] E_icode_tp;
reg [3 : 0] E_ifun_tp;
reg [63 : 0] E_valC_tp;
reg [63 : 0] E_valA_tp;
reg [63 : 0] E_valB_tp;
reg [3 : 0] E_dstE_tp;
reg [3 : 0] E_dstM_tp;
reg [3 : 0] E_srcA_tp;
reg [3 : 0] E_srcB_tp;

initial begin
         E_stat_tp = 3'h0;
         E_pc_tp = 64'b0;
         E_icode_tp = `INOP;
         E_ifun_tp = 4'b0;
         E_valC_tp = 64'b0;
         E_valA_tp = 64'b0;
         E_valB_tp = 64'b0;
         E_dstE_tp = `RNONE;
         E_dstM_tp = `RNONE;
         E_srcA_tp = `RNONE;
         E_srcB_tp = `RNONE;

end
always@(posedge clk_i) begin
    if(E_bubble_i) begin
         E_stat_tp <= d_stat_i;
         E_pc_tp <= 64'b0;
         E_icode_tp <= `INOP;
         E_ifun_tp <= 4'b0;
         E_valC_tp <= 64'b0;
         E_valA_tp <= 64'b0;
         E_valB_tp <= 64'b0;
         E_dstE_tp <= `RNONE;
         E_dstM_tp <= `RNONE;
         E_srcA_tp <= `RNONE;
         E_srcB_tp <= `RNONE;
     end
    else if(~E_stall_i) begin
         E_stat_tp <= d_stat_i;
         E_pc_tp <= d_pc_i;
         E_icode_tp <= d_icode_i;
         E_ifun_tp <= d_ifun_i;
         E_valC_tp <= d_valC_i;
         E_valA_tp <= d_valA_i;
         E_valB_tp <= d_valB_i;
         E_dstE_tp <= d_dstE_i;
         E_dstM_tp <= d_dstM_i;
         E_srcA_tp <= d_srcA_i;
         E_srcB_tp <= d_srcB_i;
     end
end

assign   E_stat_o = E_stat_tp;
assign   E_pc_o = E_pc_tp ;
assign   E_icode_o = E_icode_tp ;
assign   E_ifun_o = E_ifun_tp ;
assign   E_valC_o = E_valC_tp ;
assign   E_valA_o = E_valA_tp ;
assign   E_valB_o = E_valB_tp ;
assign   E_dstE_o = E_dstE_tp ;
assign   E_dstM_o = E_dstM_tp ;
assign   E_srcA_o = E_srcA_tp ;
assign   E_srcB_o = E_srcB_tp ;

endmodule
