LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library work;
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
    signal data_in_stimulus : std_logic_vector(15 downto 0) := x"1234"; 

    signal bus_from_node_1 : fpga_interconnect_record := init_fpga_interconnect;
    signal data_in_node_1 : std_logic_vector(15 downto 0) := x"0001"; 

    signal bus_from_node_2 : fpga_interconnect_record := init_fpga_interconnect;
    signal data_in_node_2 : std_logic_vector(15 downto 0) := x"0002"; 
    signal another_data_in_node_2 : std_logic_vector(15 downto 0) := x"0003"; 

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

            init_bus_out(bus_from_stimulus);

            CASE simulation_counter is
                WHEN 5 => write_data_to_address(bus_from_stimulus, x"0001", x"abba");
                WHEN 6 => write_data_to_address(bus_from_stimulus, x"0001", x"acdc");
                WHEN 7 => write_data_to_address(bus_from_stimulus, x"0001", x"acab");
                WHEN 8 => write_data_to_address(bus_from_stimulus, x"0002", x"0557");
                WHEN 9 => request_data_read_from_address(bus_from_stimulus, x"0001");
                WHEN 10 => request_data_read_from_address(bus_from_stimulus, x"0002");
                WHEN 11 => request_data_read_from_address(bus_from_stimulus, x"0003");
                            write_data_to_address(bus_from_stimulus, x"0003", x"0557");
                WHEN others => -- do nothing
            end CASE; --simulation_counter

            if write_is_requested_to_address(combined_bus, x"0000") then
                data_in_stimulus <= get_bus_data(combined_bus);
            end if;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
    combine_buses : process(simulator_clock)
    begin
        if rising_edge(simulator_clock) then
            combined_bus <= bus_from_node_1 and bus_from_node_2;
        end if; --rising_edge
    end process combine_buses;	
------------------------------------------------------------------------
    node_1 : process(simulator_clock)
        
    begin
        if rising_edge(simulator_clock) then
            init_bus_out(bus_from_node_1);

           assign_register_read_and_write(bus_from_stimulus, bus_from_node_1, x"0001", data_in_node_1);

        end if; --rising_edge
    end process node_1;	
------------------------------------------------------------------------
    node_2 : process(simulator_clock)
        
    begin
        if rising_edge(simulator_clock) then
           init_bus_out(bus_from_node_2);

           assign_register_read_address(bus_from_stimulus, bus_from_node_2, x"0002", data_in_node_2);
           assign_register_read_and_write(bus_from_stimulus, bus_from_node_2, x"0003", another_data_in_node_2);

        end if; --rising_edge
    end process node_2;	
------------------------------------------------------------------------
end vunit_simulation;
