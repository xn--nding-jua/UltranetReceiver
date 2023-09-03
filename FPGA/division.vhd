library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; --This allows the use of the signed variable types. The complete model using this approach is much more compact and is shown below:

entity division is
	generic(top : natural := 23);
port (
	clk : in std_logic;
	a : in std_logic_vector (2*top+1 downto 0);
	b : in std_logic_vector (2*top+1 downto 0);
	result : out std_logic_vector (2*top+1 downto 0)
	);
end entity division;

architecture behavior of division is
begin
	d1 : process (a,b)
	begin
		result <= std_logic_vector(unsigned(a) / unsigned(b));
	end process d1;
end architecture behavior;
