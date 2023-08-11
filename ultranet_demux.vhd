library ieee;
use ieee.std_logic_1164.all;

entity ultranet_demux is
	port
	(
		clk				: in std_logic;
		sample_data		: in std_logic_vector(23 downto 0);
		frame_data		: in std_logic_vector(7 downto 0);
		process_data	: in std_logic;
		
		ch1_out 			: out std_logic_vector(23 downto 0);
		ch2_out 			: out std_logic_vector(23 downto 0);
		ch3_out 			: out std_logic_vector(23 downto 0);
		ch4_out 			: out std_logic_vector(23 downto 0);
		ch5_out 			: out std_logic_vector(23 downto 0);
		ch6_out 			: out std_logic_vector(23 downto 0);
		ch7_out 			: out std_logic_vector(23 downto 0);
		ch8_out 			: out std_logic_vector(23 downto 0)
	);
end entity;

architecture rtl of ultranet_demux is
	signal channel					: integer range 1 to 8 := 1; -- channel-counter
begin
	process(clk)
		constant multiframe_sync	: std_logic_vector(7 downto 0):= "00001001"; -- this will mark channel 1
		constant midframe 			: std_logic_vector(7 downto 0):= "00000001"; -- this will mark channel 2 to 8
	begin
		if (rising_edge(clk)) then
			if process_data = '1' then
				if frame_data = multiframe_sync then -- receive channel 1
					channel <= 1;
				else -- receive channel 2..8
					channel <= channel + 1;
				end if;
				
				-- store individual channels to output-vectors
				if channel = 1 then
					ch1_out <= sample_data;
				elsif channel = 2 then
					ch2_out <= sample_data;
				elsif channel = 3 then
					ch3_out <= sample_data;
				elsif channel = 4 then
					ch4_out <= sample_data;
				elsif channel = 5 then
					ch5_out <= sample_data;
				elsif channel = 6 then
					ch6_out <= sample_data;
				elsif channel = 7 then
					ch7_out <= sample_data;
				elsif channel = 8 then
					ch8_out <= sample_data;
				end if;
			end if;
		end if;
	end process;
end rtl;