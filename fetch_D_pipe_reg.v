`include "define.v"

module fetch_D_pipe_reg(
input wire clk_i,

input wire D_stall_i,
input wire D_bubble_i,

input wire [2 : 0] f_stat_i,
input wire [63 : 0] f_pc_i,
input wire [3 : 0] f_icode_i,
input wire [3 : 0] f_ifun_i,
input wire [3 : 0] f_rA_i,
input wire [3 : 0] f_rB_i,
input wire [63 : 0] f_valC_i,
input wire [63 : 0] f_valP_i,

output wire [2 : 0] D_stat_o,
output wire [63 : 0] D_pc_o,
output wire [3 : 0] D_icode_o,
output wire [3 : 0] D_ifun_o,
output wire [3 : 0] D_rA_o,
output wire [3 : 0] D_rB_o,
output wire [63 : 0] D_valC_o,
output wire [63 : 0] D_valP_o

);

reg [2 : 0] D_stat_tp;
reg [63 : 0] D_pc_tp;
reg [3 : 0] D_icode_tp;
reg [3 : 0] D_ifun_tp;
reg [3 : 0] D_rA_tp;
reg [3 : 0] D_rB_tp;
reg [63 : 0] D_valC_tp;
reg [63 : 0] D_valP_tp;

initial begin
         D_stat_tp = 3'h0;
         D_pc_tp = 64'h0;
         D_icode_tp = `INOP;
         D_ifun_tp = 4'h0;
         D_rA_tp = `RNONE;
         D_rB_tp = `RNONE;
         D_valC_tp = 64'h0;
         D_valP_tp = 64'h0;
end


always @(posedge clk_i) begin
    if(D_bubble_i) begin
         D_stat_tp <= 3'h0;
         D_pc_tp <= 64'h0;
         D_icode_tp <= `INOP;
         D_ifun_tp <= 4'h0;
         D_rA_tp <= `RNONE;
         D_rB_tp <= `RNONE;
         D_valC_tp <= 64'h0;
         D_valP_tp <= 64'h0;
    end
    else if(~D_stall_i) begin
         D_stat_tp <= f_stat_i;
         D_pc_tp <= f_pc_i;
         D_icode_tp <= f_icode_i;
         D_ifun_tp <= f_ifun_i;
         D_rA_tp <= f_rA_i;
         D_rB_tp <= f_rB_i;
         D_valC_tp <= f_valC_i;
         D_valP_tp <= f_valP_i;
    end
end


assign D_stat_o = D_stat_tp;
assign D_pc_o = D_pc_tp;
assign D_icode_o = D_icode_tp;
assign D_ifun_o = D_ifun_tp;
assign D_rA_o = D_rA_tp;
assign D_rB_o = D_rB_tp;
assign D_valC_o = D_valC_tp;
assign D_valP_o = D_valP_tp;



endmodule