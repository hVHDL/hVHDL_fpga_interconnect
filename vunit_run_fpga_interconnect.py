#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()

lib = VU.add_library("lib");

lib.add_source_files(ROOT / "interconnect_configuration" / "*.vhd")
lib.add_source_files(ROOT / "*.vhd")
lib.add_source_files(ROOT / "bus_controller" / "*.vhd")
lib.add_source_files(ROOT / "fpga_interconnect_simulation" / "*.vhd")

VU.main()
