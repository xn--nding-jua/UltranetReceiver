library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; -- lib for unsigned and signed

entity ultranet_demux is
	port
	(
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
	-- ChangeEndian-function from https://gist.github.com/mrsoliman/992875e525e2789c2b45e80304d327c8
	function ChangeEndian(vec : std_ulogic_vector) return std_ulogic_vector is
		variable vRet      : std_ulogic_vector(vec'range);
		constant cNumBits  : natural := vec'length;
	begin
		for i in 0 to cNumBits-1 loop
			vRet(i) := vec(cNumBits-1-i);
		end loop;

		return vRet;
	end function ChangeEndian;

	function ChangeEndian(vec : std_logic_vector) return std_logic_vector is
	begin
		return std_logic_vector(ChangeEndian(std_ulogic_vector(vec)));
	end function ChangeEndian;
begin
	process(new_data)
	begin
		if (rising_edge(new_data)) then
			-- store individual channels to output-vectors
			
			if channel = 0 then
				ch1_out <= ChangeEndian(sample_in);
			elsif channel = 1 then
				ch2_out <= ChangeEndian(sample_in);
			elsif channel = 2 then
				ch3_out <= ChangeEndian(sample_in);
			elsif channel = 3 then
				ch4_out <= ChangeEndian(sample_in);
			elsif channel = 4 then
				ch5_out <= ChangeEndian(sample_in);
			elsif channel = 5 then
				ch6_out <= ChangeEndian(sample_in);
			elsif channel = 6 then
				ch7_out <= ChangeEndian(sample_in);
			elsif channel = 7 then
				ch8_out <= ChangeEndian(sample_in);
			end if;
		end if;
	end process;
end rtl;