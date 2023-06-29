echo off

ghdl -a --ieee=synopsys --std=08 %1/interconnect_configuration/data_15_address_15_bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %1/fpga_interconnect_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %1/bus_controller/bus_controller_pkg.vhd
