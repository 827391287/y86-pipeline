`include "define.v"

module execute(
input wire clk_i,
input wire rst_n_i,
input wire[3 : 0] E_icode_i,
input wire[3 : 0] E_ifun_i,
input wire[3 : 0] E_dstE_i,

input wire signed[63 : 0]E_valA_i,
input wire signed[63 : 0]E_valB_i,
input wire signed[63 : 0]E_valC_i,

input wire  [2 : 0] m_stat_i,
input wire  [2 : 0] W_stat_i,

output wire signed[63 : 0] e_valE_o,
output wire       [3 : 0]  e_dstE_o,
output wire                e_Cnd_o,
output wire                zf_o,
output wire                sf_o,
output wire                of_o
);

wire [63 : 0] aluA;
wire [63 : 0] aluB;
wire [3 : 0]  alu_fun;

reg [2:0] new_cc;
reg [2:0] cc;
wire set_cc;

assign aluA = (E_icode_i == `ICMOVQ || E_icode_i == `IOPQ) ? E_valA_i : (E_icode_i == `IMRMOVQ ||E_icode_i == `IRMMOVQ || E_icode_i == `IIRMOVQ) ? E_valC_i : (E_icode_i == `ICALL || E_icode_i == `IPUSHQ) ? -8 : (E_icode_i == `IPOPQ || E_icode_i == `IRET) ? 8 : 0;

assign aluB = (E_icode_i == `IRMMOVQ || E_icode_i == `IMRMOVQ || E_icode_i == `IOPQ || E_icode_i ==`ICALL ||E_icode_i == `IPUSHQ || E_icode_i == `IPOPQ || E_icode_i == `IRET) ? E_valB_i : (E_icode_i == `IRRMOVQ || E_icode_i == `IIRMOVQ) ? 0 : 0;

assign alu_fun = (E_icode_i == `IOPQ) ? E_ifun_i : `ALUADD;

assign e_valE_o = (alu_fun == `ALUSUB) ? (aluB - aluA) : (alu_fun == `ALUAND) ? (aluA & aluB) : (alu_fun == `ALUXOR) ? (aluA ^ aluB) : (aluA + aluB) ;



always@(*) begin
   if(~rst_n_i ) begin
      new_cc[2] = 1;
      new_cc[1] = 0;
      new_cc[0] = 0;
   end
   else if(E_icode_i == `IOPQ) begin
      new_cc[2] = (e_valE_o == 0) ? 1 : 0 ;
      new_cc[1] = e_valE_o[63] ;
      new_cc[0] = (alu_fun == `ALUADD) ? (aluA[63] == aluB[63]) & (aluA[63] != e_valE_o[63] ) :
                  (alu_fun == `ALUSUB) ? (~aluA[63] == aluB[63]) & (aluB[63] != e_valE_o[63]) : 0;
   end
end


assign set_cc = (E_icode_i == `IOPQ) ? 1 : 0;

always@(posedge clk_i) begin
   if(~rst_n_i)
      cc <= 3'b100;
   else if(set_cc)
      cc <= new_cc;
end

wire zf ,sf , of;
assign zf = cc[2];
assign sf = cc[1];
assign of = cc[0];

assign e_Cnd_o = (E_ifun_i == `C_YES) | (E_ifun_i == `C_LE & ((sf ^of) | zf)) | (E_ifun_i == `C_L & (sf ^ of)) | (E_ifun_i == `C_E & zf) | 
(E_ifun_i == `C_NE & ~zf) |(E_ifun_i == `C_GE & ~(sf ^of)) | (E_ifun_i == `C_G & (~(sf ^of) & ~zf ));

assign e_dstE_o = ((E_icode_i == `ICMOVQ) && !e_Cnd_o) ? `RNONE : E_dstE_i;

assign zf_o = zf;
assign sf_o = sf;
assign of_o = of;
endmodule
