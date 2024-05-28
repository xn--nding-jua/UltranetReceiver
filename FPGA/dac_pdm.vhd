-- This file contains a second-order sigma-delta-converter
-- Original source by Mike Field, 06.07.2020, New Zealand (https://github.com/hamsternz/second_order_sigma_delta_DAC/blob/master/sigma_delta_second.vhd)
-- General information about delta-sigma-converters can be found here: https://www.beis.de/Elektronik/DeltaSigma/DeltaSigma.html

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dac_pdm is
	generic(
		bit_width	: natural range 16 to 32 := 24
	);
	port(
		clk			: in  STD_LOGIC;
		sample_in	: in  STD_LOGIC_VECTOR (bit_width - 1 downto 0);
		output		: out STD_LOGIC
	);
end dac_pdm;

architecture Behavioral of dac_pdm is
    signal dac_out          : std_logic := '0';
    signal dac_accum1       : signed(bit_width + 3 downto 0) := (others => '0');
    signal dac_accum2       : signed(bit_width + 3 downto 0) := (others => '0');
    signal dac_feedback     : signed(bit_width + 3 downto 0) := (others => '0');
begin
	output <= dac_out;
	
	with dac_out select dac_feedback <= to_signed(-2**(bit_width - 1), bit_width + 4) when '1',
                                        to_signed( 2**(bit_width - 1), bit_width + 4) when others;     
	dac2_proc: process(clk)
		variable new_val1 : signed(bit_width + 3 downto 0);
		variable new_val2 : signed(bit_width + 3 downto 0);
	begin
		if rising_edge(clk) then 
			new_val1 := dac_accum1 + signed(sample_in) + dac_feedback;
			new_val2 := dac_accum2 + new_val1 + dac_feedback;
			if new_val2 < 0 then
				dac_out <= '0';
			else
				dac_out <= '1';
			end if;
			dac_accum1 <= new_val1;
			dac_accum2 <= new_val2;
       end if;
		end process;
end Behavioral;