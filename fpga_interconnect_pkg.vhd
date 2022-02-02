library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package fpga_interconnect_pkg is
------------------------------------------------------------------------
    type fpga_interconnect_record is record
        address                   : std_logic_vector(15 downto 0);
        data                      : std_logic_vector(15 downto 0);
        read_is_requested_when_0  : std_logic;
        write_is_requested_when_0 : std_logic;
    end record;

    constant init_fpga_interconnect : fpga_interconnect_record := ((others => '1'), (others => '1'), '1', '1');
------------------------------------------------------------------------
    procedure init_bus_out (
        signal bus_out : out fpga_interconnect_record);
------------------------------------------------------------------------
    procedure request_data_read_from_address (
        signal bus_out : out fpga_interconnect_record;
        address : in std_logic_vector(15 downto 0));
------------------------------------------------------------------------
    function read_is_requested_from_address (
        bus_in : fpga_interconnect_record;
        address : std_logic_vector(15 downto 0))
    return boolean;
------------------------------------------------------------------------
    procedure write_data_to_address (
        signal bus_out : out fpga_interconnect_record;
        address : std_logic_vector(15 downto 0);
        data_to_be_written : std_logic_vector(15 downto 0));
------------------------------------------------------------------------
    function write_is_requested_to_address (
        bus_in : fpga_interconnect_record;
        address : std_logic_vector(15 downto 0))
    return boolean;
------------------------------------------------------------------------
    function get_bus_data (
        bus_in : fpga_interconnect_record)
    return std_logic_vector ;
------------------------------------------------------------------------
    procedure assign_register_read_address (
        bus_in                 : in fpga_interconnect_record;
        signal bus_out         : out fpga_interconnect_record;
        address                : in std_logic_vector(15 downto 0);
        signal data_to_be_read : inout std_logic_vector(15 downto 0));
------------------------------------------------------------------------
    procedure assign_register_read_and_write (
        bus_in         : in fpga_interconnect_record;
        signal bus_out : out fpga_interconnect_record;
        address : in std_logic_vector(15 downto 0);
        signal data_to_be_read : inout std_logic_vector(15 downto 0));
------------------------------------------------------------------------
    function "and" (
        left, right : fpga_interconnect_record)
    return fpga_interconnect_record;
------------------------------------------------------------------------
end package fpga_interconnect_pkg;

package body fpga_interconnect_pkg is
------------------------------------------------------------------------
    procedure init_bus_out
    (
        signal bus_out : out fpga_interconnect_record
    ) is
    begin
        bus_out.address <= (others => '1');
        bus_out.data    <= (others => '1');

        bus_out.read_is_requested_when_0  <= '1';
        bus_out.write_is_requested_when_0 <= '1';
    end init_bus_out;
------------------------------------------------------------------------
    procedure request_data_read_from_address
    (
        signal bus_out : out fpga_interconnect_record;
        address : in std_logic_vector(15 downto 0)
    ) is
    begin

        bus_out.address <= address;
        bus_out.read_is_requested_when_0 <= '0';
        
    end request_data_read_from_address;
------------------------------------------------------------------------
    function read_is_requested_from_address
    (
        bus_in : fpga_interconnect_record;
        address : std_logic_vector(15 downto 0)
    )
    return boolean
    is
    begin
        if bus_in.address = address and bus_in.read_is_requested_when_0 = '0' then
            return true;
        else
            return false;
        end if;
        
    end read_is_requested_from_address;
------------------------------------------------------------------------
    procedure write_data_to_address
    (
        signal bus_out : out fpga_interconnect_record;
        address : std_logic_vector(15 downto 0);
        data_to_be_written : std_logic_vector(15 downto 0)
    ) is
    begin
        bus_out.write_is_requested_when_0 <= '0';
        bus_out.address                   <= address;
        bus_out.data                      <= data_to_be_written;
    end write_data_to_address;
------------------------------------------------------------------------
    function write_is_requested_to_address
    (
        bus_in : fpga_interconnect_record;
        address : std_logic_vector(15 downto 0)
    )
    return boolean
    is
    begin
        if bus_in.address = address and bus_in.write_is_requested_when_0 = '0' then
            return true;
        else
            return false;
        end if;
        
    end write_is_requested_to_address;
------------------------------------------------------------------------
    function get_bus_data
    (
        bus_in : fpga_interconnect_record
    )
    return std_logic_vector 
    is
    begin
        return bus_in.data;
    end get_bus_data;
------------------------------------------------------------------------
------------------------------------------------------------------------
    procedure assign_register_read_address
    (
        bus_in         : in fpga_interconnect_record;
        signal bus_out : out fpga_interconnect_record;
        address : in std_logic_vector(15 downto 0);
        signal data_to_be_read : inout std_logic_vector(15 downto 0)
    ) is
    begin
        if read_is_requested_from_address(bus_in, address) then
            write_data_to_address(bus_out, x"0000", data_to_be_read);
        end if;
    end assign_register_read_address;

------------------------------------------------------------------------
    procedure assign_register_read_and_write
    (
        bus_in         : in fpga_interconnect_record;
        signal bus_out : out fpga_interconnect_record;
        address : in std_logic_vector(15 downto 0);
        signal data_to_be_read : inout std_logic_vector(15 downto 0)
    ) is
    begin
       assign_register_read_address(bus_in, bus_out, address, data_to_be_read);

       if write_is_requested_to_address(bus_in, address) then
           data_to_be_read <= get_bus_data(bus_in);
       end if;

        
    end assign_register_read_and_write;
------------------------------------------------------------------------
    function "and"
    (
        left, right : fpga_interconnect_record
    )
    return fpga_interconnect_record
    is
        variable combined_bus : fpga_interconnect_record;
    begin
        combined_bus := (
                          left.address                   and  right.address                  ,
                          left.data                      and  right.data                     ,
                          left.read_is_requested_when_0  and  right.read_is_requested_when_0 ,
                          left.write_is_requested_when_0 and  right.write_is_requested_when_0);

        return combined_bus;
        
    end "and";
------------------------------------------------------------------------
end package body fpga_interconnect_pkg;
