`include "define.v"

module F_pipe_reg(
input wire    clk_i,
input wire    F_stall_i,
input wire    F_bubble_i,

input wire [63:0] f_predPC_i,

output reg [63:0] F_predPC_o
   
);

always @(posedge clk_i)begin
   if(F_bubble_i)
      F_predPC_o <= 64'h0;
   else if(~F_stall_i)
      F_predPC_o <= f_predPC_i;
end

initial begin
     F_predPC_o <= 64'h0;
end
/*
initial begin
   F_stall_i = 1'b0;
   F_bubble_i = 1'b0;
end

*/
endmodule