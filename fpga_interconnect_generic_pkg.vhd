
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package fpga_interconnect_generic_pkg is
    generic(number_of_data_bits : natural;
            number_of_address_bits : natural);

    subtype data_type    is std_logic_vector(number_of_data_bits-1 downto 0);
    subtype address_type is std_logic_vector(number_of_address_bits-1 downto 0);

    type fpga_interconnect_record is record
        data                           : data_type;
        address                        : address_type;
        data_write_is_requested_with_0 : std_logic;
        data_read_is_requested_with_0  : std_logic;
    end record;

    constant init_fpga_interconnect : fpga_interconnect_record := ((others => '1'), (others => '1'), '1', '1');
    type bus_array is array (integer range <>) of fpga_interconnect_record;

------------------------------------------------------------------------
    function "and" ( left, right : fpga_interconnect_record)
        return fpga_interconnect_record;
------------------------------------------------------------------------
    procedure init_bus (
        signal bus_out : out fpga_interconnect_record);
------------------------------------------------------------------------
    procedure write_data_to_address (
        signal bus_out : out fpga_interconnect_record;
        address : integer;
        data : integer);

    procedure write_data_to_address (
        signal bus_out : out fpga_interconnect_record;
        address : integer;
        data : std_logic_vector);
------------------------------------------------------------------------
    function write_to_address_is_requested (
        bus_in : fpga_interconnect_record;
        address : integer)
    return boolean;
------------------------------------------------------------------------
    function read_is_requested ( bus_in : fpga_interconnect_record)
        return boolean;
------------------------------------------------------------------------
    function get_data ( bus_in : fpga_interconnect_record)
        return integer;

    function get_address ( bus_in : fpga_interconnect_record)
        return integer;
------------------------------------------------------------------------
    procedure request_data_from_address (
        signal bus_out : out fpga_interconnect_record;
        address : integer);
------------------------------------------------------------------------
    function data_is_requested_from_address (
        bus_in : fpga_interconnect_record;
        address : integer)
        return boolean;

    function data_is_requested_from_address_range (
        bus_in : in fpga_interconnect_record;
        greater_or_equal_to : integer;
        less_than : integer)
    return boolean;

    function write_is_requested_to_address (
        bus_in : fpga_interconnect_record;
        address : natural)
    return boolean;

    function write_is_requested_to_address_range (
        bus_in : in fpga_interconnect_record;
        greater_or_equal_to : integer;
        less_than : integer)
    return boolean;
------------------------------------------------------------------------
    procedure connect_data_to_address (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        signal data    : inout integer);

    procedure connect_data_to_address (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        signal data    : inout std_logic_vector);
------------------------------------------------------------------------
    procedure connect_read_only_data_to_address (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        data           : in integer);

    procedure connect_read_only_data_to_address (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        data           : in std_logic_vector);
------------------------------------------------------------------------
    procedure create_bus (
        signal com_bus : out fpga_interconnect_record;
        input_buses : in bus_array );
------------------------------------------------------------------------
    function write_from_bus_is_requested ( bus_in : fpga_interconnect_record)
        return boolean;

end package fpga_interconnect_generic_pkg;

package body fpga_interconnect_generic_pkg is

------------------------------------------------------------------------
    function "and"
    (
        left, right : fpga_interconnect_record
    )
    return fpga_interconnect_record
    is
    begin
    return (left.data                           and right.data                          ,
            left.address                        and right.address                       ,
            left.data_write_is_requested_with_0 and right.data_write_is_requested_with_0,
            left.data_read_is_requested_with_0  and right.data_read_is_requested_with_0 );
        
    end "and";
------------------------------------------------------------------------
    function to_integer
    (
        data : std_logic_vector 
    )
    return integer
    is
    begin
        return to_integer(unsigned(data));
    end to_integer;
------------------------------------------------------------------------
    function to_std_logic_vector
    (
        data : integer
    )
    return std_logic_vector
    is
    begin
        return std_logic_vector(to_unsigned(data, 16));
        
    end to_std_logic_vector;
------------------------------------------------------------------------
    procedure init_bus
    (
        signal bus_out : out fpga_interconnect_record
    ) is
    begin
        bus_out <= init_fpga_interconnect;
    end init_bus;
------------------------------------------------------------------------
    procedure write_data_to_address
    (
        signal bus_out : out fpga_interconnect_record;
        address : integer;
        data : integer
    ) is
    begin
        bus_out.address <= to_std_logic_vector(address);
        bus_out.data    <= to_std_logic_vector(data);
        bus_out.data_write_is_requested_with_0 <= '0';
    end write_data_to_address;

    procedure write_data_to_address
    (
        signal bus_out : out fpga_interconnect_record;
        address : integer;
        data : std_logic_vector
    ) is
    begin
        bus_out.address <= to_std_logic_vector(address);
        bus_out.data    <= data;
        bus_out.data_write_is_requested_with_0 <= '0';
    end write_data_to_address;
------------------------------------------------------------------------
------------------------------------------------------------------------
    function write_from_bus_is_requested
    (
        bus_in : fpga_interconnect_record
    )
    return boolean
    is
    begin
        
        return bus_in.data_write_is_requested_with_0 = '0';
    end write_from_bus_is_requested;
------------------------------------------------------------------------
    function write_to_address_is_requested
    (
        bus_in : fpga_interconnect_record;
        address : integer
    )
    return boolean
    is
    begin
        
        return bus_in.data_write_is_requested_with_0 = '0' and
            to_integer(bus_in.address) = address;
    end write_to_address_is_requested;
------------------------------------------------------------------------
    function get_data
    (
        bus_in : fpga_interconnect_record
    )
    return integer
    is
    begin
        return to_integer(bus_in.data);
    end get_data;
------------------------------------------------------------------------
    procedure request_data_from_address
    (
        signal bus_out : out fpga_interconnect_record;
        address : integer
    ) is
    begin
        bus_out.data_read_is_requested_with_0 <= '0';
        bus_out.address <= to_std_logic_vector(address);
    end request_data_from_address;
------------------------------------------------------------------------
    function read_is_requested
    (
        bus_in : fpga_interconnect_record
    )
    return boolean
    is
    begin
        return bus_in.data_read_is_requested_with_0 = '1';
    end read_is_requested;
------------------------------------------------------------------------
    function data_is_requested_from_address
    (
        bus_in : fpga_interconnect_record;
        address : integer
    )
    return boolean
    is
    begin
        return bus_in.data_read_is_requested_with_0 = '0' and
            to_integer(bus_in.address) = address;
    end data_is_requested_from_address;

    function data_is_requested_from_address_range
    (
        bus_in : in fpga_interconnect_record;
        greater_or_equal_to : integer;
        less_than : integer
    )
    return boolean
    is
        variable is_requested : boolean;
    begin
        is_requested := bus_in.data_read_is_requested_with_0 = '0';
        is_requested := is_requested and get_address(bus_in) >= greater_or_equal_to;
        is_requested := is_requested and get_address(bus_in) < less_than;

        return is_requested;
        
    end data_is_requested_from_address_range;

    function write_is_requested_to_address_range
    (
        bus_in : in fpga_interconnect_record;
        greater_or_equal_to : integer;
        less_than : integer
    )
    return boolean
    is
        variable is_requested : boolean;
    begin
        is_requested := bus_in.data_write_is_requested_with_0 = '0';
        is_requested := is_requested and get_address(bus_in) >= greater_or_equal_to;
        is_requested := is_requested and get_address(bus_in) < less_than;
        return is_requested;
        
    end write_is_requested_to_address_range;
------------------------------------------------------------------------
    procedure connect_data_to_address
    (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        signal data    : inout integer
    ) is
    begin
        if write_to_address_is_requested(bus_in, address) then
            data <= get_data(bus_in);
        end if;

        if data_is_requested_from_address(bus_in, address) then
            write_data_to_address(bus_out, 0, data);
        end if;
        
    end connect_data_to_address;

    procedure connect_data_to_address
    (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        signal data    : inout std_logic_vector
    ) is
    begin
        if write_to_address_is_requested(bus_in, address) then
            data <= bus_in.data;
        end if;

        if data_is_requested_from_address(bus_in, address) then
            write_data_to_address(bus_out, 0, data);
        end if;
        
    end connect_data_to_address;
------------------------------------------------------------------------
------------------------------------------------------------------------
    procedure connect_read_only_data_to_address
    (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        data           : in integer
    ) is
    begin
        if data_is_requested_from_address(bus_in, address) then
            write_data_to_address(bus_out, 0, data);
        end if;
        
    end connect_read_only_data_to_address;

    procedure connect_read_only_data_to_address
    (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        data           : in std_logic_vector
    ) is
    begin
        if data_is_requested_from_address(bus_in, address) then
            write_data_to_address(bus_out, 0, to_integer(unsigned(data)));
        end if;
        
    end connect_read_only_data_to_address;
------------------------------------------------------------------------
------------------------------------------------------------------------
    procedure create_bus
    (
        signal com_bus : out fpga_interconnect_record;
        input_buses : in bus_array 
    ) is
        variable combined_bus : fpga_interconnect_record := init_fpga_interconnect;
    begin
        for i in input_buses'range loop
            combined_bus := combined_bus and input_buses(i);
        end loop;

        com_bus <= combined_bus;
        
    end create_bus;
------------------------------------------------------------------------
    function get_address
    (
        bus_in : fpga_interconnect_record
    )
    return integer
    is
    begin
        return to_integer(unsigned(bus_in.address));
        
    end get_address;
------------------------------------------------------------------------
    function write_is_requested_to_address
    (
        bus_in : fpga_interconnect_record;
        address : natural
    )
    return boolean
    is
    begin
        return (bus_in.data_write_is_requested_with_0 = '0') and 
               (get_address(bus_in) = address);

    end write_is_requested_to_address;
------------------------------------------------------------------------

end package body fpga_interconnect_generic_pkg;
