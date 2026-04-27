#!/usr/bin/env python3
"""
bin2mem.py — Convert RISC-V binary/ELF to $readmemh hex file.

Usage:
  # From ELF (recommended):
  riscv-none-elf-objcopy -O binary prog.elf prog.bin
  python tools/bin2mem.py prog.bin cpu/tb/tests/test_xxx.mem

  # From raw binary directly:
  python tools/bin2mem.py prog.bin cpu/tb/tests/test_xxx.mem

The output is one byte per line in hex, suitable for Verilog $readmemh.
Also prints a disassembly-like word listing for quick inspection.
"""

import sys
import struct

def bin_to_mem(bin_path: str, mem_path: str) -> None:
    with open(bin_path, "rb") as f:
        data = f.read()

    with open(mem_path, "w") as f:
        f.write(f"// Generated from {bin_path}\n")
        f.write(f"// {len(data)} bytes = {len(data)//4} instructions\n")

        for i, byte in enumerate(data):
            if i % 4 == 0:
                # Show word value as comment
                word = struct.unpack_from("<I", data, i)[0] if i + 4 <= len(data) else 0
                f.write(f"\n// @{i:04x}  word=0x{word:08x}\n")
            f.write(f"{byte:02x}\n")

    print(f"[bin2mem] {len(data)} bytes → {mem_path}")
    print(f"[bin2mem] {len(data)//4} words (instructions)")

    # Quick word dump to stdout
    print("\nWord listing:")
    for i in range(0, len(data), 4):
        if i + 4 <= len(data):
            word = struct.unpack_from("<I", data, i)[0]
            print(f"  [{i:04x}] 0x{word:08x}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    bin_to_mem(sys.argv[1], sys.argv[2])
