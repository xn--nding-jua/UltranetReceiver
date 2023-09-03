library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; --This allows the use of the signed variable types. The complete model using this approach is much more compact and is shown below:

entity volume_ctrl is
	generic(top : natural := 23);
port (
	signal_in 	: in signed(top downto 0);
	volume 		: in signed(top downto 0); -- value is between 0 and 256
	signal_out 	: out std_logic_vector(top downto 0)
	);
end entity volume_ctrl;

architecture behavior of volume_ctrl is
	signal signal_x_volume : signed((2*top)+1 downto 0); -- we need double the bits for the multiplication
begin
	volume_control : process (signal_in, volume)
	begin
		signal_x_volume <= signal_in * volume; -- do multiplication signal x volume[0-256]
	end process volume_control;
	
	-- now we have to divide the multiplicated signal by 256.
	-- We can bitshift this by 8 to the right, but we have
	-- to take care of the sign-bit as we have signed-integers here!
	signal_out <= std_logic_vector(signal_x_volume)((2*top)+1) & std_logic_vector(signal_x_volume)(top+7 downto 8); -- signed-bit & 23 audio-sample-bits
end architecture behavior;
