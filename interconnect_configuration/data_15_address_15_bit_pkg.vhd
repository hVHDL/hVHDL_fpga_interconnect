library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package fpga_interconnect_definitions is

    subtype data_type    is std_logic_vector(15 downto 0);
    subtype address_type is std_logic_vector(15 downto 0);

end package fpga_interconnect_definitions;
