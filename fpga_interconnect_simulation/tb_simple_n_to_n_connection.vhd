LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

    use work.fpga_interconnect_pkg.all;

library vunit_lib;
    use vunit_lib.run_pkg.all;

entity simple_n_to_n_connection_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of simple_n_to_n_connection_tb is

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;

    signal simulation_counter : natural := 0;
    -----------------------------------
    -- simulation specific signals ----
    signal bus_1 : fpga_interconnect_record := init_fpga_interconnect;
    signal data_in_1 : integer range 0 to 2**16-1 := 1;

    signal bus_2 : fpga_interconnect_record := init_fpga_interconnect;
    signal data_in_2 : integer range 0 to 2**16-1 := 2;

    signal bus_3 : fpga_interconnect_record := init_fpga_interconnect;
    signal data_in_3 : integer range 0 to 2**16-1 := 3;

    signal combined_bus : fpga_interconnect_record := init_fpga_interconnect;

------------------------------------------------------------------------
begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        simulation_running <= true;
        wait for simtime_in_clocks*clock_per;
        simulation_running <= false;
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

------------------------------------------------------------------------
    sim_clock_gen : process
    begin
        simulator_clock <= '0';
        wait for clock_half_per;
        while simulation_running loop
            wait for clock_half_per;
                simulator_clock <= not simulator_clock;
            end loop;
        wait;
    end process;
------------------------------------------------------------------------
    combine_buses : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            create_bus(combined_bus, (bus_1, bus_2, bus_3));

        end if; -- rising_edge
    end process combine_buses;	

------------------------------------------------------------------------

    test1 : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            init_bus(bus_1);

            connect_data_to_address(combined_bus, bus_1, 1, data_in_1);
            CASE simulation_counter is
                WHEN 1 => write_data_to_address(bus_1, 2, data_in_1);
                WHEN others => -- do nothing
            end CASE;


        end if; -- rising_edge
    end process test1;	
------------------------------------------------------------------------
    test2 : process(simulator_clock)
        
    begin
        if rising_edge(simulator_clock) then
            init_bus(bus_2);
            connect_data_to_address(combined_bus, bus_2, 2, data_in_2);
            CASE simulation_counter is
                WHEN 4 => write_data_to_address(bus_2, 3, data_in_2);
                WHEN others => -- do nothing
            end CASE;

        end if; --rising_edge
    end process test2;	
------------------------------------------------------------------------
    test3 : process(simulator_clock)
        
    begin
        if rising_edge(simulator_clock) then
            init_bus(bus_3);
            connect_data_to_address(combined_bus, bus_3, 3, data_in_3);

        end if; --rising_edge
    end process test3;	
------------------------------------------------------------------------
------------------------------------------------------------------------
end vunit_simulation;
