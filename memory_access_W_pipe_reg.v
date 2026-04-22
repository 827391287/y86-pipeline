`include "define.v"

module memory_access_W_pipe_reg(

input wire clk_i,
input wire W_stall_i,
input wire W_bubble_i,

input wire  [2:0]  m_stat_i,
input wire  [63:0] m_pc_i,
input wire  [3:0]  m_icode_i,
input wire  [63:0] M_valE_i,
input wire  [63:0] m_valM_i,
input wire  [3:0]  M_dstE_i,
input wire  [3:0]  M_dstM_i,

output wire  [2:0]  W_stat_o,
output wire  [63:0] W_pc_o,
output wire  [3:0]  W_icode_o,
output wire  [63:0] W_valE_o,
output wire  [63:0] W_valM_o,
output wire  [3:0]  W_dstE_o,
output wire  [3:0]  W_dstM_o
);

reg  [2:0]  W_stat_tp;
reg  [63:0] W_pc_tp;
reg  [3:0]  W_icode_tp;
reg  [63:0] W_valE_tp;
reg  [63:0] W_valM_tp;
reg  [3:0]  W_dstE_tp;
reg  [3:0]  W_dstM_tp;


initial begin
            W_stat_tp  = 3'b0;
            W_pc_tp    = 64'h0;
            W_icode_tp = `INOP;
            W_valE_tp  = 64'h0;
            W_valM_tp  = 64'h0;
            W_dstE_tp  = 4'h0;
            W_dstM_tp  = 4'h0;
end

always@(posedge clk_i) begin
     if(W_bubble_i) begin
            W_stat_tp  <= 3'b0;
            W_pc_tp    <= 64'h0;
            W_icode_tp <= `INOP;
            W_valE_tp  <= 64'h0;
            W_valM_tp  <= 64'h0;
            W_dstE_tp  <= 4'h0;
            W_dstM_tp  <= 4'h0;
     end
     else if(~W_stall_i) begin
            W_stat_tp  <= m_stat_i;
            W_pc_tp    <= m_pc_i;
            W_icode_tp <= m_icode_i;
            W_valE_tp  <= M_valE_i;
            W_valM_tp  <= m_valM_i;
            W_dstE_tp  <= M_dstE_i;
            W_dstM_tp  <= M_dstM_i;
      end
end


assign       W_stat_o  = W_stat_tp;
assign       W_pc_o    = W_pc_tp ;
assign       W_icode_o = W_icode_tp;
assign       W_valE_o  = W_valE_tp;
assign       W_valM_o  = W_valM_tp;
assign       W_dstE_o  = W_dstE_tp;
assign       W_dstM_o  = W_dstM_tp;


endmodule