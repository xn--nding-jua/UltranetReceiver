library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; -- lib for unsigned and signed

entity ultranet_demux is
	port
	(
		sample_in		: in std_logic_vector(23 downto 0);
		channel			: in unsigned(7 downto 0);
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
begin
	process(process_data)
	begin
		if (rising_edge(process_data)) then
			-- store individual channels to output-vectors
			if channel = 1 then
				ch1_out <= sample_in;
			elsif channel = 2 then
				ch2_out <= sample_in;
			elsif channel = 3 then
				ch3_out <= sample_in;
			elsif channel = 4 then
				ch4_out <= sample_in;
			elsif channel = 5 then
				ch5_out <= sample_in;
			elsif channel = 6 then
				ch6_out <= sample_in;
			elsif channel = 7 then
				ch7_out <= sample_in;
			elsif channel = 8 then
				ch8_out <= sample_in;
			end if;
		end if;
	end process;
end rtl;