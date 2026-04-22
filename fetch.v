`include "define.v"module fetch(
    input wire [63 : 0] PC_i,
    output wire [3 : 0] icode_o,
    output wire[3 : 0] ifun_o,
    output wire[3 : 0] rA_o,
    output wire[3 : 0] rB_o,
    output wire[63 : 0] valC_o,
    output wire[63 : 0] valP_o,
    output wire [63 : 0] predPC_o,
    output wire [2 : 0] stat_o
);reg  [7 : 0]   instr_mem[0:1023];wire [79 : 0]  instr;wire           need_regids;wire           need_valC;
wire   instr_valid;
wire   imem_error;

initial begin
    instr_mem[0] = 8'h60;
    instr_mem[1] = 8'h23;

/*
//                            | # Execution begins at address 0
//0x000:                      |     .pos 0
//0x000: 30f40002000000000000 |     irmovq stack, %rsp      # Set up stack pointer
    instr_mem[0] = 8'h30;
    instr_mem[1] = 8'hf4;
    instr_mem[2] = 8'h00;
    instr_mem[3] = 8'h02;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;
//0x00a: 804800000000000000   |     call main       # Execute main program
    instr_mem[10] = 8'h80;
    instr_mem[11] = 8'h48;
    instr_mem[12] = 8'h00;
    instr_mem[13] = 8'h00;
    instr_mem[14] = 8'h00;
    instr_mem[15] = 8'h00;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;
//0x013: 00                   |     halt            # Terminate program
    instr_mem[19] = 8'h00;

//                            | 
//0x048:                      | main:
//0x048: 30f70000000000000000 |     irmovq Array?0?,%rdi?7?
    instr_mem[72] = 8'h30;
    instr_mem[73] = 8'hf7;
    instr_mem[74] = 8'h00;
    instr_mem[75] = 8'h00;
    instr_mem[76] = 8'h00;
    instr_mem[77] = 8'h00;
    instr_mem[78] = 8'h00;
    instr_mem[79] = 8'h00;
    instr_mem[80] = 8'h00;
    instr_mem[81] = 8'h00;
//0x052: 30f60600000000000000 |     irmovq $6,%rsi?6?
    instr_mem[82] = 8'h30;
    instr_mem[83] = 8'hf6;
    instr_mem[84] = 8'h06;
    instr_mem[85] = 8'h00;
    instr_mem[86] = 8'h00;
    instr_mem[87] = 8'h00;
    instr_mem[88] = 8'h00;
    instr_mem[89] = 8'h00;
    instr_mem[90] = 8'h00;
    instr_mem[91] = 8'h00;
//0x05c: 806600000000000000   |     call bubble_sort
    instr_mem[92] = 8'h80;
    instr_mem[93] = 8'h66;
    instr_mem[94] = 8'h00;
    instr_mem[95] = 8'h00;
    instr_mem[96] = 8'h00;
    instr_mem[97] = 8'h00;
    instr_mem[98] = 8'h00;
    instr_mem[99] = 8'h00;
    instr_mem[100] = 8'h00;
//0x065: 90                   |     ret
    instr_mem[101] = 8'h90;
//                            | 
//                            | # void bubble_sort(long *data, long count)
//                            | # data in %rdi, count in %rsi
//0x066:                      | bubble_sort:
//0x066: a08f                 |     pushq %r8
    instr_mem[102] = 8'ha0;
    instr_mem[103] = 8'h8f;
//0x068: a09f                 |     pushq %r9
    instr_mem[104] = 8'ha0;
    instr_mem[105] = 8'h9f;
//0x06a: a0af                 |     pushq %r10
    instr_mem[106] = 8'ha0;
    instr_mem[107] = 8'haf;
//0x06c: a0bf                 |     pushq %r11
    instr_mem[108] = 8'ha0;
    instr_mem[109] = 8'hbf;
//0x06e: a0cf                 |     pushq %r12
    instr_mem[110] = 8'ha0;
    instr_mem[111] = 8'hcf;
//0x070: a0df                 |     pushq %r13
    instr_mem[112] = 8'ha0;
    instr_mem[113] = 8'hdf;
//0x072: a0ef                 |     pushq %r14
    instr_mem[114] = 8'ha0;
    instr_mem[115] = 8'hef;
//0x074: 30f80800000000000000 |     irmovq $8,%r8      # Constant 8
    instr_mem[116] = 8'h30;
    instr_mem[117] = 8'hf8;
    instr_mem[118] = 8'h08;
    instr_mem[119] = 8'h00;
    instr_mem[120] = 8'h00;
    instr_mem[121] = 8'h00;
    instr_mem[122] = 8'h00;
    instr_mem[123] = 8'h00;
    instr_mem[124] = 8'h00;
    instr_mem[125] = 8'h00;
//0x07e: 2079                 |     rrmovq %rdi?7?,%r9    # last in %r9
    instr_mem[126] = 8'h20;
    instr_mem[127] = 8'h79;
//0x080: 6066                 |     addq %rsi,%rsi?6?
    instr_mem[128] = 8'h60;
    instr_mem[129] = 8'h66;
//0x082: 6066                 |     addq %rsi,%rsi
    instr_mem[130] = 8'h60;
    instr_mem[131] = 8'h66;
//0x084: 6066                 |     addq %rsi,%rsi
    instr_mem[132] = 8'h60;
    instr_mem[133] = 8'h66;
//0x086: 6186                 |     subq %r8,%rsi?6?
    instr_mem[134] = 8'h61;
    instr_mem[135] = 8'h86;
//0x088: 6069                 |     addq %rsi,%r9      # last = data + count - 1
    instr_mem[136] = 8'h60;
    instr_mem[137] = 8'h69;
//0x08a:                      | L1:
//0x08a: 209a                 |     rrmovq %r9,%r10
    instr_mem[138] = 8'h20;
    instr_mem[139] = 8'h9a;
//0x08c: 617a                 |     subq %rdi?7?,%r10
    instr_mem[140] = 8'h61;
    instr_mem[141] = 8'h7a;
//0x08e: 71f300000000000000   |     jle L2
    instr_mem[142] = 8'h71;
    instr_mem[143] = 8'hf3;
    instr_mem[144] = 8'h00;
    instr_mem[145] = 8'h00;
    instr_mem[146] = 8'h00;
    instr_mem[147] = 8'h00;
    instr_mem[148] = 8'h00;
    instr_mem[149] = 8'h00;
    instr_mem[150] = 8'h00;
//0x097: 207b                 |     rrmovq %rdi?7?,%r11   # i in %r11
    instr_mem[151] = 8'h20;
    instr_mem[152] = 8'h7b;
//0x099:                      | L3:
//0x099: 209c                 |     rrmovq %r9,%r12
    instr_mem[153] = 8'h20;
    instr_mem[154] = 8'h9c;
//0x09b: 61bc                 |     subq %r11,%r12
    instr_mem[155] = 8'h61;
    instr_mem[156] = 8'hbc;
//0x09d: 71e800000000000000   |     jle L4
    instr_mem[157] = 8'h71;
    instr_mem[158] = 8'he8;
    instr_mem[159] = 8'h00;
    instr_mem[160] = 8'h00;
    instr_mem[161] = 8'h00;
    instr_mem[162] = 8'h00;
    instr_mem[163] = 8'h00;
    instr_mem[164] = 8'h00;
    instr_mem[165] = 8'h00;
//0x0a6: 50cb0000000000000000 |     mrmovq (%r11),%r12     # *i
    instr_mem[166] = 8'h50;
    instr_mem[167] = 8'hcb;
    instr_mem[168] = 8'h00;
    instr_mem[169] = 8'h00;
    instr_mem[170] = 8'h00;
    instr_mem[171] = 8'h00;
    instr_mem[172] = 8'h00;
    instr_mem[173] = 8'h00;
    instr_mem[174] = 8'h00;
    instr_mem[175] = 8'h00;
//0x0b0: 50db0800000000000000 |     mrmovq 8(%r11),%r13    # *(i+1)
    instr_mem[176] = 8'h50;
    instr_mem[177] = 8'hdb;
    instr_mem[178] = 8'h08;
    instr_mem[179] = 8'h00;
    instr_mem[180] = 8'h00;
    instr_mem[181] = 8'h00;
    instr_mem[182] = 8'h00;
    instr_mem[183] = 8'h00;
    instr_mem[184] = 8'h00;
    instr_mem[185] = 8'h00;
//0x0ba: 20ce                 |     rrmovq %r12,%r14
    instr_mem[186] = 8'h20;
    instr_mem[187] = 8'hce;
//0x0bc: 61de                 |     subq %r13,%r14
    instr_mem[188] = 8'h61;
    instr_mem[189] = 8'hde;
//0x0be: 71dd00000000000000   |     jle L5
    instr_mem[190] = 8'h71;
    instr_mem[191] = 8'hdd;
    instr_mem[192] = 8'h00;
    instr_mem[193] = 8'h00;
    instr_mem[194] = 8'h00;
    instr_mem[195] = 8'h00;
    instr_mem[196] = 8'h00;
    instr_mem[197] = 8'h00;
    instr_mem[198] = 8'h00;
//0x0c7: 20de                 |     rrmovq %r13,%r14
    instr_mem[199] = 8'h20;
    instr_mem[200] = 8'hde;
//0x0c9: 40cb0800000000000000 |     rmmovq %r12,8(%r11)
    instr_mem[201] = 8'h40;
    instr_mem[202] = 8'hcb;
    instr_mem[203] = 8'h08;
    instr_mem[204] = 8'h00;
    instr_mem[205] = 8'h00;
    instr_mem[206] = 8'h00;
    instr_mem[207] = 8'h00;
    instr_mem[208] = 8'h00;
    instr_mem[209] = 8'h00;
    instr_mem[210] = 8'h00;
//0x0d3: 40eb0000000000000000 |     rmmovq %r14,(%r11)
    instr_mem[211] = 8'h40;
    instr_mem[212] = 8'heb;
    instr_mem[213] = 8'h00;
    instr_mem[214] = 8'h00;
    instr_mem[215] = 8'h00;
    instr_mem[216] = 8'h00;
    instr_mem[217] = 8'h00;
    instr_mem[218] = 8'h00;
    instr_mem[219] = 8'h00;
    instr_mem[220] = 8'h00;
//0x0dd:                      | L5:
//0x0dd: 608b                 |     addq %r8,%r11   # i++
    instr_mem[221] = 8'h60;
    instr_mem[222] = 8'h8b;
//0x0df: 709900000000000000   |     jmp L3
    instr_mem[223] = 8'h70;
    instr_mem[224] = 8'h99;
    instr_mem[225] = 8'h00;
    instr_mem[226] = 8'h00;
    instr_mem[227] = 8'h00;
    instr_mem[228] = 8'h00;
    instr_mem[229] = 8'h00;
    instr_mem[230] = 8'h00;
    instr_mem[231] = 8'h00;
//0x0e8:                      | L4:
//0x0e8: 6189                 |     subq %r8,%r9    # last--
    instr_mem[232] = 8'h61;
    instr_mem[233] = 8'h89;
//0x0ea: 708a00000000000000   |     jmp L1
    instr_mem[234] = 8'h70;
    instr_mem[235] = 8'h8a;
    instr_mem[236] = 8'h00;
    instr_mem[237] = 8'h00;
    instr_mem[238] = 8'h00;
    instr_mem[239] = 8'h00;
    instr_mem[240] = 8'h00;
    instr_mem[241] = 8'h00;
    instr_mem[242] = 8'h00;
//0x0f3:                      | L2:
//0x0f3: b0ef                 |     popq %r14
    instr_mem[243] = 8'hb0;
    instr_mem[244] = 8'hef;
//0x0f5: b0df                 |     popq %r13
    instr_mem[245] = 8'hb0;
    instr_mem[246] = 8'hdf;
//0x0f7: b0cf                 |     popq %r12
    instr_mem[247] = 8'hb0;
    instr_mem[248] = 8'hcf;
//0x0f9: b0bf                 |     popq %r11
    instr_mem[249] = 8'hb0;
    instr_mem[250] = 8'hbf;
//0x0fb: b0af                 |     popq %r10
    instr_mem[251] = 8'hb0;
    instr_mem[252] = 8'haf;
//0x0fd: b09f                 |     popq %r9
    instr_mem[253] = 8'hb0;
    instr_mem[254] = 8'h9f;
//0x0ff: b08f                 |     popq %r8
    instr_mem[255] = 8'hb0;
    instr_mem[256] = 8'h8f;
//0x101: 90                   |     ret
    instr_mem[257] = 8'h90;

*/
/*
    instr_mem[0] = 8'h50;
    instr_mem[1] = 8'h20;
    instr_mem[2] = 8'h00;
    instr_mem[3] = 8'h00;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;

    instr_mem[10] = 8'h60;
    instr_mem[11] = 8'h23;
*/

/*
//ret
    instr_mem[0] = 8'h30;
    instr_mem[1] = 8'hf4;
    instr_mem[2] = 8'h00;
    instr_mem[3] = 8'h01;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;

    instr_mem[10] = 8'h80;
    instr_mem[11] = 8'd30;
    instr_mem[12] = 8'h00;
    instr_mem[13] = 8'h00;
    instr_mem[14] = 8'h00;
    instr_mem[15] = 8'h00;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;

    instr_mem[19] = 8'h30;
    instr_mem[20] = 8'hf1;
    instr_mem[21] = 8'h0a;
    instr_mem[22] = 8'h00;
    instr_mem[23] = 8'h00;
    instr_mem[24] = 8'h00;
    instr_mem[25] = 8'h00;
    instr_mem[26] = 8'h00;
    instr_mem[27] = 8'h00;
    instr_mem[28] = 8'h00;

    instr_mem[29] = 8'h00;

    instr_mem[30] = 8'h90;

    instr_mem[31] = 8'h20;  
    instr_mem[32] = 8'h12;
*/

/*
//jne
    instr_mem[0] = 8'h63;
    instr_mem[1] = 8'h11;

    instr_mem[2] = 8'h74;
    instr_mem[3] = 8'd22;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;
    instr_mem[10] = 8'h00;

    instr_mem[11] = 8'h30;
    instr_mem[12] = 8'hf1;
    instr_mem[13] = 8'h01;
    instr_mem[14] = 8'h00;
    instr_mem[15] = 8'h00;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;
    instr_mem[19] = 8'h00;
    instr_mem[20] = 8'h00;

    instr_mem[21] = 8'h00;

    instr_mem[22] = 8'h30;
    instr_mem[23] = 8'hf6;
    instr_mem[24] = 8'h02;
    instr_mem[25] = 8'h00;
    instr_mem[26] = 8'h00;
    instr_mem[27] = 8'h00;
    instr_mem[28] = 8'h00;
    instr_mem[29] = 8'h00;
    instr_mem[30] = 8'h00;
    instr_mem[31] = 8'h00; 
 
    instr_mem[32] = 8'h30;
    instr_mem[33] = 8'hf7;
    instr_mem[34] = 8'h03;
    instr_mem[35] = 8'h00;
    instr_mem[36] = 8'h00;
    instr_mem[37] = 8'h00;
    instr_mem[38] = 8'h00;
    instr_mem[39] = 8'h00;
    instr_mem[40] = 8'h00;
    instr_mem[41] = 8'h00; 

    instr_mem[42] = 8'h00;
*/
/*
//combination A
    instr_mem[0] = 8'h63;
    instr_mem[1] = 8'h11;

    instr_mem[2] = 8'h74;
    instr_mem[3] = 8'd22;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;
    instr_mem[10] = 8'h00;

    instr_mem[11] = 8'h30;
    instr_mem[12] = 8'hf1;
    instr_mem[13] = 8'h01;
    instr_mem[14] = 8'h00;
    instr_mem[15] = 8'h00;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;
    instr_mem[19] = 8'h00;
    instr_mem[20] = 8'h00;

    instr_mem[21] = 8'h00;

    instr_mem[22] = 8'h90;
*/
/*
//combination B 
    instr_mem[0] = 8'h50;
    instr_mem[1] = 8'h41;
    instr_mem[2] = 8'h00;
    instr_mem[3] = 8'h00;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;

    instr_mem[10] = 8'h90;

    instr_mem[11] = 8'h60;
    instr_mem[12] = 8'h23;

*/
/*
    instr_mem[0] = 8'h30;
    instr_mem[1] = 8'hf1;
    instr_mem[2] = 8'h0a;
    instr_mem[3] = 8'h00;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;

    instr_mem[10] = 8'h30;
    instr_mem[11] = 8'hf2;
    instr_mem[12] = 8'h03;
    instr_mem[13] = 8'h00;
    instr_mem[14] = 8'h00;
    instr_mem[15] = 8'h00;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;
    instr_mem[19] = 8'h00;

    instr_mem[20] = 8'h60;
    instr_mem[21] = 8'h12;
*/


/*
    instr_mem[0] = 8'h00;

    instr_mem[1] = 8'h10;

    instr_mem[2] = 8'h30;
    instr_mem[3] = 8'hf2;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;
    instr_mem[10] = 8'h00;
    instr_mem[11] = 8'h00;

    instr_mem[12] = 8'ha0;
    instr_mem[13] = 8'haf;

    instr_mem[14] = 8'h40;
    instr_mem[15] = 8'h30;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;
    instr_mem[19] = 8'h00;
    instr_mem[20] = 8'h00;
    instr_mem[21] = 8'd00;
    instr_mem[22] = 8'h00;
    instr_mem[23] = 8'h00;

    instr_mem[24] = 8'h50;
    instr_mem[25] = 8'h58;
    instr_mem[26] = 8'h00;
    instr_mem[27] = 8'h00;
    instr_mem[28] = 8'h00;
    instr_mem[29] = 8'h00;
    instr_mem[30] = 8'h00;
    instr_mem[31] = 8'h00;
    instr_mem[32] = 8'h00;
    instr_mem[33] = 8'h00;

    instr_mem[34] = 8'h60;
    instr_mem[35] = 8'h67;

    instr_mem[36] = 8'h60;
    instr_mem[37] = 8'he3;

    //instr_mem[38] = 8'h22;
    //instr_mem[39] = 8'h89;


    instr_mem[38] = 8'h20;
    instr_mem[39] = 8'h01;

    instr_mem[40] = 8'hb0;
    instr_mem[41] = 8'hbf;
*/
/*
    instr_mem[0] = 8'h30;
    instr_mem[1] = 8'hf7;
    instr_mem[2] = 8'h00;
    instr_mem[3] = 8'h00;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;

    instr_mem[10] = 8'h30;
    instr_mem[11] = 8'hf6;
    instr_mem[12] = 8'h04;
    instr_mem[13] = 8'h00;
    instr_mem[14] = 8'h00;
    instr_mem[15] = 8'h00;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;
    instr_mem[19] = 8'h00;

    instr_mem[20] = 8'h80;
    instr_mem[21] = 8'd30;
    instr_mem[22] = 8'h00;
    instr_mem[23] = 8'h00;
    instr_mem[24] = 8'h00;
    instr_mem[25] = 8'h00;
    instr_mem[26] = 8'h00;
    instr_mem[27] = 8'h00;
    instr_mem[28] = 8'h00;

    instr_mem[29] = 8'h00;

    instr_mem[30] = 8'h30;
    instr_mem[31] = 8'hf8;
    instr_mem[32] = 8'h08;
    instr_mem[33] = 8'h00;
    instr_mem[34] = 8'h00;
    instr_mem[35] = 8'h00;
    instr_mem[36] = 8'h00;
    instr_mem[37] = 8'h00;
    instr_mem[38] = 8'h00;
    instr_mem[39] = 8'h00;

    instr_mem[40] = 8'h30;
    instr_mem[41] = 8'hf9;
    instr_mem[42] = 8'h01;
    instr_mem[43] = 8'h00;
    instr_mem[44] = 8'h00;
    instr_mem[45] = 8'h00;
    instr_mem[46] = 8'h00;
    instr_mem[47] = 8'h00;
    instr_mem[48] = 8'h00;
    instr_mem[49] = 8'h00;

    instr_mem[50] = 8'h63;
    instr_mem[51] = 8'h00;

    instr_mem[52] = 8'h62;
    instr_mem[53] = 8'h66;

    instr_mem[54] = 8'h70;
    instr_mem[55] = 8'd79;
    instr_mem[56] = 8'h00;
    instr_mem[57] = 8'h00;
    instr_mem[58] = 8'h00;
    instr_mem[59] = 8'h00;
    instr_mem[60] = 8'h00;
    instr_mem[61] = 8'h00;
    instr_mem[62] = 8'h00;

    instr_mem[63] = 8'h50;
    instr_mem[64] = 8'ha7;
    instr_mem[65] = 8'h00;
    instr_mem[66] = 8'h00;
    instr_mem[67] = 8'h00;
    instr_mem[68] = 8'h00;
    instr_mem[69] = 8'h00;
    instr_mem[70] = 8'h00;
    instr_mem[71] = 8'h00;
    instr_mem[72] = 8'h00; 

    instr_mem[73] = 8'h60;
    instr_mem[74] = 8'ha0;  

    instr_mem[75] = 8'h60;
    instr_mem[76] = 8'h87; 

    instr_mem[77] = 8'h61;
    instr_mem[78] = 8'h96;

    instr_mem[79] = 8'h74;
    instr_mem[80] = 8'd63;
    instr_mem[81] = 8'h00;
    instr_mem[82] = 8'h00;
    instr_mem[83] = 8'h00;
    instr_mem[84] = 8'h00;
    instr_mem[85] = 8'h00;
    instr_mem[86] = 8'h00;
    instr_mem[87] = 8'h00;

    instr_mem[88] = 8'h90;
*/


endassign  imem_error = (PC_i > 1023);
assign instr = {instr_mem[PC_i + 9] , instr_mem[PC_i + 8] ,instr_mem[PC_i + 7] ,instr_mem[PC_i + 6] ,instr_mem[PC_i + 5] ,instr_mem[PC_i + 4] ,instr_mem[PC_i + 3] ,instr_mem[PC_i + 2] ,instr_mem[PC_i + 1] ,instr_mem[PC_i + 0] };
assign icode_o = instr[7 : 4];assign  ifun_o = instr[3 : 0];assign instr_valid = (icode_o < 4'hC);assign need_regids = (icode_o == `ICMOVQ) ||(icode_o == `IIRMOVQ) ||(icode_o == `IRMMOVQ) ||(icode_o == `IMRMOVQ) ||(icode_o == `IOPQ) ||(icode_o == `IPUSHQ) ||(icode_o == `IPOPQ) ;assign need_valC = (icode_o == `IIRMOVQ) ||(icode_o == `IRMMOVQ) ||(icode_o == `IMRMOVQ) ||(icode_o == `IJXX) ||(icode_o == `ICALL) ;assign rA_o = need_regids ? instr[15 : 12] : 4'hF;assign rB_o = need_regids ? instr[11 : 8]  : 4'hF;assign valC_o = need_regids ? instr[79 : 16] : instr[71 : 8] ;
assign valP_o = PC_i + 1 + 8* need_valC + need_regids ; 

assign stat_o = imem_error ? `SADR : (!instr_valid) ? `SINS : (icode_o == `IHALT) ? `SHLT : `SAOK;

assign predPC_o = (icode_o == `IJXX || icode_o == `ICALL)? valC_o : valP_o;
endmodule