# crt0.s — minimal bare-metal startup for RV32I simulation
# Placed at address 0x00000000 (entry point)

    .section .text.init
    .globl _start
_start:
    li   sp, 0xEFF0         # stack top: near end of 64KB dmem
    call main               # call C main()
    ebreak                  # SHLT — tells pipeline_top to stop
