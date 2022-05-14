library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;

package bus_controller_pkg is
------------------------------------------------------------------------
    type list_of_connection_states is (idle, wait_for_connection, connected, end_connection);

    type list_of_actions is (idle, connect, transmit_data, end_connection);
------------------------------------------------------------------------
    type bus_controller_record is record
        connection_states : list_of_connection_states;
        i_requested_connection  : boolean;
        bus_controller_is_done : boolean;
    end record;

    constant init_bus_controller : bus_controller_record := (idle, false, false);
------------------------------------------------------------------------
    procedure create_bus_controller (
        signal bus_controller_object : inout bus_controller_record;
        signal received_actions : in list_of_actions;
        signal sent_actions : out list_of_actions);
------------------------------------------------------------------------
    procedure request_connection (
        signal bus_controller_object : out bus_controller_record);
------------------------------------------------------------------------
    procedure end_connection (
        signal bus_controller_object : out bus_controller_record);
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
        alias i_requested_connection is bus_controller_object.i_requested_connection;
    begin
        CASE connection_state is 
            WHEN idle =>
                sent_actions <= idle;
                if received_actions = connect then
                    connection_state <= wait_for_connection;
                    i_requested_connection <= false;
                end if;

            WHEN wait_for_connection =>
                if received_actions = connect then
                    connection_state <= connected;
                end if;

                if i_requested_connection then
                    sent_actions <= connect;
                end if;

            WHEN connected =>
                sent_actions <= transmit_data;
                if received_actions = idle then
                    i_requested_connection <= false;
                end if;
            WHEN end_connection =>
                sent_actions <= idle;
                connection_state <= idle;
        end CASE;

    end procedure;

------------------------------------------------------------------------
    procedure request_connection
    (
        signal bus_controller_object : out bus_controller_record
    ) is
    begin
        bus_controller_object.connection_states <= wait_for_connection;
        bus_controller_object.i_requested_connection <= true;
         
    end request_connection;
------------------------------------------------------------------------
    procedure end_connection
    (
        signal bus_controller_object : out bus_controller_record
    ) is
    begin
        bus_controller_object.connection_states <= idle;
        
    end end_connection;
------------------------------------------------------------------------
end package body bus_controller_pkg;
