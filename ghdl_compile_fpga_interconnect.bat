echo off

ghdl -a --ieee=synopsys --std=08 interconnect_configuration/data_15_address_15_bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 fpga_interconnect_pkg.vhd
ghdl -a --ieee=synopsys --std=08 bus_controller/bus_controller_pkg.vhd
