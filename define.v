//Operation codes
`define     IHALT           4'H0 
`define     INOP            4'H1
`define     ICMOVQ          4'H2
`define     IRRMOVQ         4'H2
`define     IIRMOVQ         4'H3
`define     IRMMOVQ         4'H4
`define     IMRMOVQ         4'H5
`define     IOPQ            4'H6
`define     IJXX            4'H7
`define     ICALL           4'H8
`define     IRET            4'H9
`define     IPUSHQ          4'HA
`define     IPOPQ           4'HB
//Function codes
`define     FADDL           4'H0
`define     FSUBL           4'H1
`define     FANDL           4'H2
`define     FXORL           4'H3
//Jump & move conditions function code.
`define     C_YES           4'h0
`define     C_LE            4'h1
`define     C_L             4'h2
`define     C_E             4'h3
`define     C_NE            4'h4
`define     C_GE            4'h5
`define     C_G             4'h6

//Register Codes
`define     RRSP            4'H4
`define     RNONE           4'HF

//Status Codes
`define     SAOK            3'H1
`define     SHLT            3'H2
`define     SADR            3'H3
`define     SINS            3'H4

//
`define     ALUADD          4'H0
`define     ALUSUB          4'H1
`define     ALUAND          4'H2
`define     ALUXOR          4'H3

//Size Codes
`define     NIBBLE          3:0
`define     ZERONIBBLE      4'h0
`define     BYTE            7:0
`define     BYTE0           79:72
`define     BYTE1           71:64
`define     BYTE2           63:56
`define     BYTE3           55:48
`define     BYTE4           47:40
`define     BYTE5           39:32
`define     BYTE6           31:24
`define     BYTE7           23:16
`define     BYTE8           15:8
`define     BYTE9           7:0
`define     WORD            31:0
// write or read
`define     ENABLE          1'b1
`define     DISABLE         1'b0

