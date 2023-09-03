library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; --This allows the use of the signed variable types. The complete model using this approach is much more compact and is shown below:

entity volume_ctrl_stereo is
	generic(top : natural := 23);
port (
	signal_in 		: in signed(top downto 0);
	volume_l			: in signed(top downto 0); -- value is between 0 and 256
	volume_r			: in signed(top downto 0); -- value is between 0 and 256
	signal_out_l	: out std_logic_vector(top downto 0);
	signal_out_r	: out std_logic_vector(top downto 0)
	);
end entity volume_ctrl_stereo;

architecture behavior of volume_ctrl_stereo is
	signal signal_x_volume_l : signed((2*top)+1 downto 0); -- we need double the bits for the multiplication
	signal signal_x_volume_r : signed((2*top)+1 downto 0); -- we need double the bits for the multiplication
begin
	volume_control_l : process (signal_in, volume_l)
	begin
		signal_x_volume_l <= signal_in * volume_l; -- do multiplication signal x volume[0-256]
	end process volume_control_l;
	
	volume_control_r : process (signal_in, volume_r)
	begin
		signal_x_volume_r <= signal_in * volume_r; -- do multiplication signal x volume[0-256]
	end process volume_control_r;

	-- now we have to divide the multiplicated signal by 256.
	-- We can bitshift this by 8 to the right, but we have
	-- to take care of the sign-bit as we have signed-integers here!
	signal_out_l <= std_logic_vector(signal_x_volume_l)((2*top)+1) & std_logic_vector(signal_x_volume_l)(top+7 downto 8); -- signed-bit & 23 audio-sample-bits
	signal_out_r <= std_logic_vector(signal_x_volume_r)((2*top)+1) & std_logic_vector(signal_x_volume_r)(top+7 downto 8); -- signed-bit & 23 audio-sample-bits
end architecture behavior;
