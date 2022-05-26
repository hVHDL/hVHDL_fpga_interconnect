LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

    use work.bus_controller_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity bus_controller_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of bus_controller_tb is

    constant clock_per : time := 1 ns;
    constant simtime_in_clocks : integer := 50;

    signal simulator_clock    : std_logic := '0';
    signal simulation_counter : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----
    signal bus_controller_1 : bus_controller_record := init_bus_controller;
    signal bus_controller_2 : bus_controller_record := init_bus_controller;

    signal sent_actions_1 : list_of_actions;
    signal sent_actions_2 : list_of_actions;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_per;

        check(bus_controller_1.connection_states = idle and bus_controller_2.connection_states = idle
            , "Communication did not end");

        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	


    simulator_clock <= not simulator_clock after clock_per/2.0;

------------------------------------------------------------------------
------------------------------------------------------------------------

    stimulus : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_bus_controller(bus_controller_1, sent_actions_2, sent_actions_1);

            CASE simulation_counter is
                WHEN 2  => request_connection(bus_controller_1);
                WHEN 10 => end_connection(bus_controller_1);
                WHEN 32 => request_connection(bus_controller_1);

                WHEN others => -- do nothing
            end CASE;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
    process2 : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            create_bus_controller(bus_controller_2, sent_actions_1, sent_actions_2);

        end if; -- rising_edge
    end process process2;	

------------------------------------------------------------------------
end vunit_simulation;
