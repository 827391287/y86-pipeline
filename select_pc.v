`include "define.v"

module select_pc(
input wire [63:0] F_predPC_i,
input wire [3 :0] M_icode_i,
input wire [3 :0] W_icode_i,
input wire [63:0] M_valA_i,
input wire [63:0] W_valM_i,
input wire        M_Cnd_i,

output reg [63 :0] f_pc_o
);

always @(*) begin
    if(M_icode_i == `IJXX && !M_Cnd_i)
        f_pc_o = M_valA_i;
    else if(W_icode_i == `IRET)
        f_pc_o = W_valM_i;
    else 
        f_pc_o = F_predPC_i;

end


endmodule