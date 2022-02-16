LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

    use work.fpga_interconnect_pkg.all;

library vunit_lib;
    use vunit_lib.run_pkg.all;

entity tb_fpga_interconnect is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of tb_fpga_interconnect is

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;

    signal simulation_counter : natural := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal bus_from_stimulus : fpga_interconnect_record := init_fpga_interconnect;
    signal data_in_stimulus : integer := 0;

    signal bus_from_endpoint_1 : fpga_interconnect_record := init_fpga_interconnect;
    signal data_in_endpoint_1 : integer := 0;

    signal bus_from_endpoint_2 : fpga_interconnect_record := init_fpga_interconnect;
    signal data_in_endpoint_2 : integer := 0;

    signal combined_bus : fpga_interconnect_record := init_fpga_interconnect;
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

    stimulus : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            init_bus(bus_from_stimulus);

            CASE simulation_counter is
                WHEN 5 =>  write_data_to_address(bus_from_stimulus      , 1             , 35   );
                WHEN 6 =>  write_data_to_address(bus_from_stimulus      , 1             , 46   );
                WHEN 7 =>  write_data_to_address(bus_from_stimulus      , 1             , 25   );
                WHEN 8 =>  write_data_to_address(bus_from_stimulus      , 2             , 5895 );
                WHEN 9 =>  request_data_from_address(bus_from_stimulus  , 1                    );
                WHEN 10 =>  request_data_from_address(bus_from_stimulus , 2                    );
                WHEN 11 =>  request_data_from_address(bus_from_stimulus , 3                    );
                WHEN 12 =>  write_data_to_address(bus_from_stimulus     , 3             , 0    );
                WHEN 13 =>  request_data_from_address(bus_from_stimulus , 3                    );
                WHEN others => --do nothing
            end CASE; --simulation_counter

            connect_data_to_address(combined_bus, bus_from_stimulus, 0, data_in_stimulus);

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
    combine_buses : process(simulator_clock)
        
    begin
        if rising_edge(simulator_clock) then
            combined_bus <= bus_from_endpoint_2 and bus_from_endpoint_1;

        end if; --rising_edge
    end process combine_buses;	
------------------------------------------------------------------------
    endpoint_1 : process(simulator_clock)
        
    begin
        if rising_edge(simulator_clock) then

            init_bus(bus_from_endpoint_1);
            connect_data_to_address(bus_from_stimulus, bus_from_endpoint_1, 1 , data_in_endpoint_1);

        end if; --rising_edge
    end process endpoint_1;	
------------------------------------------------------------------------
    endpoint_2 : process(simulator_clock)
        
    begin
        if rising_edge(simulator_clock) then

            init_bus(bus_from_endpoint_2);
            connect_data_to_address(bus_from_stimulus, bus_from_endpoint_2, 2 , data_in_endpoint_2);
            connect_read_only_data_to_address(bus_from_stimulus, bus_from_endpoint_2, 3 , 35896);

        end if; --rising_edge
    end process endpoint_2;	
------------------------------------------------------------------------
end vunit_simulation;
