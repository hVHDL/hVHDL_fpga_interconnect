library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;

package bus_controller_pkg is
------------------------------------------------------------------------
    type list_of_connection_states is (idle, wait_for_connection, connected);

    type list_of_actions is (idle, connect, transmit_data, end_connection);
------------------------------------------------------------------------
    type bus_controller_record is record
        connection_states : list_of_connection_states;
        bus_controller_is_requested  : boolean;
        bus_controller_is_done : boolean;
    end record;

    constant init_bus_controller : bus_controller_record := (idle, false, false);
------------------------------------------------------------------------
    procedure create_bus_controller (
        signal bus_controller_object : inout bus_controller_record;
        signal received_actions : in list_of_actions;
        signal sent_actions : out list_of_actions);
------------------------------------------------------------------------
end package bus_controller_pkg;

package body bus_controller_pkg is
------------------------------------------------------------------------
    procedure create_bus_controller 
    (
        signal bus_controller_object : inout bus_controller_record;
        signal received_actions      : in list_of_actions;
        signal sent_actions          : out list_of_actions
    ) 
    is
        alias connection_state is bus_controller_object.connection_states;
    begin
        CASE connection_state is 
            WHEN idle =>
                sent_actions <= idle;
                if received_actions = connect then
                    connection_state <= wait_for_connection;
                end if;

            WHEN wait_for_connection =>
                if received_actions = connect then
                    connection_state <= connected;
                end if;
                sent_actions <= connect;

            WHEN connected =>
                sent_actions <= transmit_data;
        end CASE;

    end procedure;

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
end package body bus_controller_pkg;
