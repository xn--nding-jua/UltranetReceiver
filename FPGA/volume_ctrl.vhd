library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; --This allows the use of the signed variable types. The complete model using this approach is much more compact and is shown below:

entity volume_ctrl is
	generic(top : natural := 23);
port (
	signal_in 	: in std_logic_vector (top downto 0);
	volume 		: in std_logic_vector (top downto 0); -- value is between 0 and 256
	signal_out 	: out std_logic_vector (top downto 0)
	);
end entity volume_ctrl;

architecture behavior of volume_ctrl is
	signal signal_out_tmp : std_logic_vector ((2*top)+1 downto 0);
begin
	volume_control : process (signal_in, volume)
	begin
		signal_out_tmp <= std_logic_vector(unsigned(signal_in) * unsigned(volume)); -- do multiplication signal x volume[0-256]
	end process volume_control;
	
	signal_out <= signal_out_tmp(top+8 downto 8); -- take only 24 bits of the result and shift it 8 bits to the right, to divide by 256
end architecture behavior;
