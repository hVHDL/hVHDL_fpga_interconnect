library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package bus_control_functions_pkg is

    function write_connection_is_established
    (
        can_connect : boolean
    )
    return boolean;

end package bus_control_functions_pkg;

package body bus_control_functions_pkg is
------------------------------------------------------------------------
    function write_connection_is_established
    (
        can_connect : boolean
    )
    return boolean
    is
    begin
        return false;
    end write_connection_is_established;
------------------------------------------------------------------------

end package body bus_control_functions_pkg;

