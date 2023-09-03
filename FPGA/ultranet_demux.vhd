-------------------------------------------------------------------------------
-- Distributor for received Ultranet-Samples
-- https://github.com/xn--nding-jua/UltranetReceiver
------------------------------------------------------------------------------- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; -- lib for unsigned and signed

entity ultranet_demux is
	port
	(
		clk				: in std_logic;
		sample_in		: in std_logic_vector(23 downto 0); -- swap endianness of sample-data
		channel			: in unsigned(2 downto 0);
		new_data			: in std_logic;
		
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
	signal pos_edge		: std_logic;
	signal znew_data		: std_logic;
begin
	detect_edge : process(clk)
	begin
		if rising_edge(clk) then
			znew_data <= new_data;
			if new_data = '1' and znew_data = '0' then
				pos_edge <= '1';
			else
				pos_edge <= '0';
			end if;
		end if;
	end process;

	process(clk)
	begin
		if (rising_edge(clk)) then
			if pos_edge = '1' then
				-- store individual channels to output-vectors
				
				if channel = 0 then
					ch1_out <= sample_in;
				elsif channel = 1 then
					ch2_out <= sample_in;
				elsif channel = 2 then
					ch3_out <= sample_in;
				elsif channel = 3 then
					ch4_out <= sample_in;
				elsif channel = 4 then
					ch5_out <= sample_in;
				elsif channel = 5 then
					ch6_out <= sample_in;
				elsif channel = 6 then
					ch7_out <= sample_in;
				elsif channel = 7 then
					ch8_out <= sample_in;
				end if;
			end if;
		end if;
	end process;
end rtl;