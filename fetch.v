`include "define.v"

module fetch(
    input  wire [63:0] PC_i,
    output wire [3:0]  icode_o,
    output wire [3:0]  ifun_o,
    output wire [3:0]  rA_o,
    output wire [3:0]  rB_o,
    output wire [63:0] valC_o,
    output wire [63:0] valP_o,
    output wire [63:0] predPC_o,
    output wire [2:0]  stat_o
);

    reg  [7:0]  instr_mem[0:1023];
    wire [79:0] instr;
    wire        need_regids;
    wire        need_valC;
    wire        instr_valid;
    wire        imem_error;

    initial begin
        $readmemh("prog.mem", instr_mem);
    end

    assign imem_error  = (PC_i > 1023);

    assign instr = {instr_mem[PC_i+9], instr_mem[PC_i+8], instr_mem[PC_i+7],
                    instr_mem[PC_i+6], instr_mem[PC_i+5], instr_mem[PC_i+4],
                    instr_mem[PC_i+3], instr_mem[PC_i+2], instr_mem[PC_i+1],
                    instr_mem[PC_i+0]};

    assign icode_o     = instr[7:4];
    assign ifun_o      = instr[3:0];
    assign instr_valid = (icode_o < 4'hC);

    assign need_regids = (icode_o == `ICMOVQ)  || (icode_o == `IIRMOVQ) ||
                         (icode_o == `IRMMOVQ) || (icode_o == `IMRMOVQ) ||
                         (icode_o == `IOPQ)    || (icode_o == `IPUSHQ)  ||
                         (icode_o == `IPOPQ);

    assign need_valC   = (icode_o == `IIRMOVQ) || (icode_o == `IRMMOVQ) ||
                         (icode_o == `IMRMOVQ) || (icode_o == `IJXX)    ||
                         (icode_o == `ICALL);

    assign rA_o     = need_regids ? instr[15:12] : 4'hF;
    assign rB_o     = need_regids ? instr[11:8]  : 4'hF;
    assign valC_o   = need_regids ? instr[79:16] : instr[71:8];
    assign valP_o   = PC_i + 1 + 8*need_valC + need_regids;

    assign stat_o   = imem_error          ? `SADR :
                      !instr_valid         ? `SINS :
                      (icode_o == `IHALT)  ? `SHLT : `SAOK;

    assign predPC_o = (icode_o == `IJXX || icode_o == `ICALL) ? valC_o : valP_o;

endmodule
