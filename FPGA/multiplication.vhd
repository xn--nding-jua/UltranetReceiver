library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; --This allows the use of the signed variable types. The complete model using this approach is much more compact and is shown below:

entity multiplication is
	generic(top : natural := 23);
port (
	clk : in std_logic;
	a : in std_logic_vector (top downto 0);
	b : in std_logic_vector (top downto 0);
	product : out std_logic_vector (2*top+1 downto 0)
	);
end entity multiplication;

architecture behavior of multiplication is
begin
	p1 : process (a,b)
	begin
		product <= std_logic_vector(unsigned(a) * unsigned(b));
	end process p1;
end architecture behavior;
