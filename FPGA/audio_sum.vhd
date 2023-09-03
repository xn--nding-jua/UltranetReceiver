library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; --This allows the use of the signed variable types. The complete model using this approach is much more compact and is shown below:

entity audio_sum is
	generic(top : natural := 23);
port (
	ch1_in : in signed(top downto 0);
	ch2_in : in signed(top downto 0);
	ch3_in : in signed(top downto 0);
	ch4_in : in signed(top downto 0);
	ch5_in : in signed(top downto 0);
	ch6_in : in signed(top downto 0);
	ch7_in : in signed(top downto 0);
	ch8_in : in signed(top downto 0);
	ch9_in : in signed(top downto 0);
	ch10_in : in signed(top downto 0);
	ch11_in : in signed(top downto 0);
	ch12_in : in signed(top downto 0);
	ch13_in : in signed(top downto 0);
	ch14_in : in signed(top downto 0);
	ch15_in : in signed(top downto 0);
	ch16_in : in signed(top downto 0);
	sum_out : out signed(top downto 0)
	);
end entity audio_sum;

architecture behavior of audio_sum is
begin
	s1 : process (ch1_in, ch2_in, ch3_in, ch4_in, ch5_in, ch6_in, ch7_in, ch8_in, ch9_in, ch10_in, ch11_in, ch12_in, ch13_in, ch14_in, ch15_in, ch16_in)
	begin
		sum_out <= ch1_in + ch2_in + ch3_in + ch4_in + ch5_in + ch6_in + ch7_in + ch8_in + ch9_in + ch10_in + ch11_in + ch12_in + ch13_in + ch14_in + ch15_in + ch16_in;
	end process s1;
end architecture behavior;
