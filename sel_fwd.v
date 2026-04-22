`include "define.v"

module sel_fwd(
input wire [3 : 0] D_icode_i,
input wire [63 : 0] D_valP_i,
input wire [3 : 0] d_srcA_i,

input wire [3 : 0] e_dstE_i,
input wire [63 : 0] e_valE_i,

input wire [3 : 0] M_dstM_i,
input wire [63 : 0] m_valM_i,

input wire [3 : 0] M_dstE_i,
input wire [63 : 0] M_valE_i,

input wire [3 : 0] W_dstM_i,
input wire [63 : 0] W_valM_i,

input wire [3: 0] W_dstE_i,
input wire [63 : 0] W_valE_i,

input wire [63 : 0] d_rvalA_i,

output wire [63 : 0] fwdA_valA_o


);


assign fwdA_valA_o = ((D_icode_i == `IJXX || D_icode_i == `ICALL) ? D_valP_i :
                      (d_srcA_i == e_dstE_i) ? e_valE_i : 
                      (d_srcA_i == M_dstM_i) ? m_valM_i :
                      (d_srcA_i == M_dstE_i) ? M_valE_i : 
                      (d_srcA_i == W_dstM_i) ? W_valM_i : 
                      (d_srcA_i == W_dstE_i) ? W_valE_i : d_rvalA_i );

endmodule



module fwd(

input wire [3 : 0] d_srcB_i,

input wire [3 : 0] e_dstE_i,
input wire [63 : 0] e_valE_i,

input wire [3 : 0] M_dstM_i,
input wire [63 : 0] m_valM_i,

input wire [3 : 0] M_dstE_i,
input wire [63 : 0] M_valE_i,

input wire [3 : 0] W_dstM_i,
input wire [63 : 0] W_valM_i,

input wire [3: 0] W_dstE_i,
input wire [63 : 0] W_valE_i,

input wire [63 : 0] d_rvalB_i,

output wire [63 : 0] fwdB_valB_o


);


assign fwdB_valB_o =( (d_srcB_i == e_dstE_i) ? e_valE_i : 
                      (d_srcB_i == M_dstM_i) ? m_valM_i :
                      (d_srcB_i == M_dstE_i) ? M_valE_i : 
                      (d_srcB_i == W_dstM_i) ? W_valM_i : 
                      (d_srcB_i == W_dstE_i) ? W_valE_i : d_rvalB_i ); 
                      

endmodule