#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()
# VU = VUnit.from_argv(vhdl_standard="93")

lib = VU.add_library("lib");

lib.add_source_files(ROOT / "fpga_interconnect_simulation" / "*.vhd")
lib.add_source_files(ROOT / "*.vhd")

VU.main()
