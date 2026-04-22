`include "define.v"

module execute_M_pipe_reg(
input wire clk_i,
input wire M_stall_i,
input wire M_bubble_i,

input wire [2 : 0] e_stat_i,
input wire [63 : 0] e_pc_i,
input wire [3 : 0] e_icode_i,
input wire [3 : 0] e_ifun_i,
input wire         e_Cnd_i,
input wire [63 : 0]e_valE_i,
input wire [63 : 0]e_valA_i,
input wire [3 : 0] e_dstE_i,
input wire [3 : 0] e_dstM_i,

output wire [2 : 0] M_stat_o,
output wire [63 : 0] M_pc_o,
output wire [3 : 0] M_icode_o,
output wire [3 : 0] M_ifun_o,
output wire         M_Cnd_o,
output wire [63 : 0]M_valE_o,
output wire [63 : 0]M_valA_o,
output wire [3 : 0] M_dstE_o,
output wire [3 : 0] M_dstM_o

);

reg [2 : 0] M_stat_tp;
reg [63 : 0] M_pc_tp;
reg [3 : 0] M_icode_tp;
reg [3 : 0] M_ifun_tp;
reg         M_Cnd_tp;
reg [63 : 0]M_valE_tp;
reg [63 : 0]M_valA_tp;
reg [3 : 0] M_dstE_tp;
reg [3 : 0] M_dstM_tp;

initial begin
          M_stat_tp = 3'h0;
          M_pc_tp = 64'd0;
          M_icode_tp = `INOP;
          M_ifun_tp = 4'b0;
          M_Cnd_tp = 1'b0;
          M_valE_tp = 64'b0;
          M_valA_tp = 64'b0;
          M_dstE_tp = `RNONE;
          M_dstM_tp = `RNONE;
end

always @(posedge clk_i) begin
    if(M_bubble_i)begin
          M_stat_tp <= e_stat_i;
          M_pc_tp <= 64'd0;
          M_icode_tp <= `INOP;
          M_ifun_tp <= 4'b0;
          M_Cnd_tp <= 1'b0;
          M_valE_tp <= 64'b0;
          M_valA_tp <= 64'b0;
          M_dstE_tp <= `RNONE;
          M_dstM_tp <= `RNONE;
    end
    else if(~M_stall_i)begin
          M_stat_tp <= e_stat_i;
          M_pc_tp <= e_pc_i;
          M_icode_tp <= e_icode_i;
          M_ifun_tp <= e_ifun_i;
          M_Cnd_tp <= e_Cnd_i;
          M_valE_tp <= e_valE_i;
          M_valA_tp <= e_valA_i;
          M_dstE_tp <= e_dstE_i;
          M_dstM_tp <= e_dstM_i;
    end
end

assign  M_stat_o = M_stat_tp;
assign  M_pc_o = M_pc_tp;
assign  M_icode_o = M_icode_tp;
assign  M_ifun_o = M_ifun_tp;
assign  M_Cnd_o = M_Cnd_tp;
assign  M_valE_o = M_valE_tp;
assign  M_valA_o = M_valA_tp;
assign  M_dstE_o = M_dstE_tp;
assign  M_dstM_o = M_dstM_tp;

endmodule