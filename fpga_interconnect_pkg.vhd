library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package fpga_interconnect_pkg is
------------------------------------------------------------------------
    type fpga_interconnect_record is record
        fpga_interconnect_is_done : boolean;
        fpga_interconnect_is_requested : boolean;
    end record;

    constant init_fpga_interconnect : fpga_interconnect_record := (false, false);
------------------------------------------------------------------------
    procedure create_fpga_interconnect (
        signal fpga_interconnect_object : inout fpga_interconnect_record);
------------------------------------------------------------------------
    procedure request_fpga_interconnect (
        signal fpga_interconnect_object : out fpga_interconnect_record);
------------------------------------------------------------------------
    function fpga_interconnect_is_ready (fpga_interconnect_object : fpga_interconnect_record)
        return boolean;
------------------------------------------------------------------------
end package fpga_interconnect_pkg;

package body fpga_interconnect_pkg is
------------------------------------------------------------------------
    procedure create_fpga_interconnect 
    (
        signal fpga_interconnect_object : inout fpga_interconnect_record
    ) 
    is
        alias fpga_interconnect_is_requested is fpga_interconnect_object.fpga_interconnect_is_requested;
        alias fpga_interconnect_is_done is fpga_interconnect_object.fpga_interconnect_is_done;
    begin
        fpga_interconnect_is_requested <= false;
        if fpga_interconnect_is_requested then
            fpga_interconnect_is_done <= true;
        else
            fpga_interconnect_is_done <= false;
        end if;
    end procedure;

------------------------------------------------------------------------
    procedure request_fpga_interconnect
    (
        signal fpga_interconnect_object : out fpga_interconnect_record
    ) is
    begin
        fpga_interconnect_object.fpga_interconnect_is_requested <= true;
        
    end request_fpga_interconnect;

------------------------------------------------------------------------
    function fpga_interconnect_is_ready
    (
        fpga_interconnect_object : fpga_interconnect_record
    )
    return boolean
    is
    begin
        return fpga_interconnect_object.fpga_interconnect_is_done;
    end fpga_interconnect_is_ready;

------------------------------------------------------------------------
end package body fpga_interconnect_pkg;
