-------------------------------------------------------------------------------
-- RS232 Command decoder
-- https://github.com/xn--nding-jua/UltranetReceiver
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity RS232_Decoder is 
	port
	(
		clk				: in std_logic;
	
		RX_DataReady	: in std_logic;
		RX_Data			: in std_logic_vector(7 downto 0);

		main_volume_l	: out std_logic_vector(23 downto 0);
		main_volume_r	: out std_logic_vector(23 downto 0);

		ch1_volume_l	: out std_logic_vector(23 downto 0);
		ch1_volume_r	: out std_logic_vector(23 downto 0);

		ch2_volume_l	: out std_logic_vector(23 downto 0);
		ch2_volume_r	: out std_logic_vector(23 downto 0);

		ch3_volume_l	: out std_logic_vector(23 downto 0);
		ch3_volume_r	: out std_logic_vector(23 downto 0);

		ch4_volume_l	: out std_logic_vector(23 downto 0);
		ch4_volume_r	: out std_logic_vector(23 downto 0);

		ch5_volume_l	: out std_logic_vector(23 downto 0);
		ch5_volume_r	: out std_logic_vector(23 downto 0);

		ch6_volume_l	: out std_logic_vector(23 downto 0);
		ch6_volume_r	: out std_logic_vector(23 downto 0);

		ch7_volume_l	: out std_logic_vector(23 downto 0);
		ch7_volume_r	: out std_logic_vector(23 downto 0);

		ch8_volume_l	: out std_logic_vector(23 downto 0);
		ch8_volume_r	: out std_logic_vector(23 downto 0);

		ch9_volume_l	: out std_logic_vector(23 downto 0);
		ch9_volume_r	: out std_logic_vector(23 downto 0);

		ch10_volume_l	: out std_logic_vector(23 downto 0);
		ch10_volume_r	: out std_logic_vector(23 downto 0);

		ch11_volume_l	: out std_logic_vector(23 downto 0);
		ch11_volume_r	: out std_logic_vector(23 downto 0);

		ch12_volume_l	: out std_logic_vector(23 downto 0);
		ch12_volume_r	: out std_logic_vector(23 downto 0);

		ch13_volume_l	: out std_logic_vector(23 downto 0);
		ch13_volume_r	: out std_logic_vector(23 downto 0);

		ch14_volume_l	: out std_logic_vector(23 downto 0);
		ch14_volume_r	: out std_logic_vector(23 downto 0);

		ch15_volume_l	: out std_logic_vector(23 downto 0);
		ch15_volume_r	: out std_logic_vector(23 downto 0);

		ch16_volume_l	: out std_logic_vector(23 downto 0);
		ch16_volume_r	: out std_logic_vector(23 downto 0)
	);
end entity;

architecture Behavioral of RS232_Decoder is
	signal pos_edge			: std_logic;
	signal zRX_DataReady		: std_logic;
	signal ErrorCheckWord	: unsigned(15 downto 0);
	signal PayloadSum			: unsigned(15 downto 0);
begin
	detect_edge : process(clk)
	begin
		if rising_edge(clk) then
			zRX_DataReady <= RX_DataReady;
			if RX_DataReady = '1' and zRX_DataReady = '0' then
				pos_edge <= '1';
			else
				pos_edge <= '0';
			end if;
		end if;
	end process;

	process (clk)
		variable b1 : std_logic_vector(7 downto 0);	-- "A" = 0x41
		variable b2 : std_logic_vector(7 downto 0);	-- C
		variable b3 : std_logic_vector(7 downto 0);	-- V1 = MSB of payload
		variable b4 : std_logic_vector(7 downto 0);	-- V2
		variable b5 : std_logic_vector(7 downto 0);	-- V3
		variable b6 : std_logic_vector(7 downto 0);	-- V4 = LSB of payload
		variable b7 : std_logic_vector(7 downto 0);	-- ErrorCheckWord_MSB
		variable b8 : std_logic_vector(7 downto 0);	-- ErrorCheckWord_LSB
		variable b9 : std_logic_vector(7 downto 0);	-- "E" = 0x45
	begin
		if (rising_edge(clk)) then
			if pos_edge = '1' then
				-- Alle Bytes um ein Byte verschieben und neues Byte hinten einfügen
				b1 := b2;
				b2 := b3;
				b3 := b4;
				b4 := b5;
				b5 := b6;
				b6 := b7;
				b7 := b8;
				b8 := b9;
				b9 := RX_Data;
				
				-- State-Machine zum Empfangen von RS232-Daten
				if ((unsigned(b1)=65)) then -- and (unsigned(b9)=69)) then
					-- Anfang und Ende gefunden --> Daten auswerten
					
					-- check ErrorCheckWord against sum of payload here. Lateron we could use CRC16 to check payload against errors
					ErrorCheckWord <= unsigned(b7 & b8);
					-- build sum of payload and compare with ErrorCheckWord
					PayloadSum <= unsigned("00000000" & b3) + unsigned("00000000" & b4) + unsigned("00000000" & b5) + unsigned("00000000" & b6);
								
					if (PayloadSum = ErrorCheckWord) then
						-- sum of payload has expected content
						
						if (unsigned(b2)=0) then
							-- Command = 0 (Main L)
							main_volume_l(23 downto 24) <= b3;
							main_volume_l(23 downto 16) <= b4;
							main_volume_l(15 downto 8) <= b5;
							main_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=1) then
							ch1_volume_l(23 downto 24) <= b3;
							ch1_volume_l(23 downto 16) <= b4;
							ch1_volume_l(15 downto 8) <= b5;
							ch1_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=2) then
							ch2_volume_l(23 downto 24) <= b3;
							ch2_volume_l(23 downto 16) <= b4;
							ch2_volume_l(15 downto 8) <= b5;
							ch2_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=3) then
							ch3_volume_l(23 downto 24) <= b3;
							ch3_volume_l(23 downto 16) <= b4;
							ch3_volume_l(15 downto 8) <= b5;
							ch3_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=4) then
							ch4_volume_l(23 downto 24) <= b3;
							ch4_volume_l(23 downto 16) <= b4;
							ch4_volume_l(15 downto 8) <= b5;
							ch4_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=5) then
							ch5_volume_l(23 downto 24) <= b3;
							ch5_volume_l(23 downto 16) <= b4;
							ch5_volume_l(15 downto 8) <= b5;
							ch5_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=6) then
							ch6_volume_l(23 downto 24) <= b3;
							ch6_volume_l(23 downto 16) <= b4;
							ch6_volume_l(15 downto 8) <= b5;
							ch6_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=7) then
							ch7_volume_l(23 downto 24) <= b3;
							ch7_volume_l(23 downto 16) <= b4;
							ch7_volume_l(15 downto 8) <= b5;
							ch7_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=8) then
							ch8_volume_l(23 downto 24) <= b3;
							ch8_volume_l(23 downto 16) <= b4;
							ch8_volume_l(15 downto 8) <= b5;
							ch8_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=9) then
							ch9_volume_l(23 downto 24) <= b3;
							ch9_volume_l(23 downto 16) <= b4;
							ch9_volume_l(15 downto 8) <= b5;
							ch9_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=10) then
							ch10_volume_l(23 downto 24) <= b3;
							ch10_volume_l(23 downto 16) <= b4;
							ch10_volume_l(15 downto 8) <= b5;
							ch10_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=11) then
							ch11_volume_l(23 downto 24) <= b3;
							ch11_volume_l(23 downto 16) <= b4;
							ch11_volume_l(15 downto 8) <= b5;
							ch11_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=12) then
							ch12_volume_l(23 downto 24) <= b3;
							ch12_volume_l(23 downto 16) <= b4;
							ch12_volume_l(15 downto 8) <= b5;
							ch12_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=13) then
							ch13_volume_l(23 downto 24) <= b3;
							ch13_volume_l(23 downto 16) <= b4;
							ch13_volume_l(15 downto 8) <= b5;
							ch13_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=14) then
							ch14_volume_l(23 downto 24) <= b3;
							ch14_volume_l(23 downto 16) <= b4;
							ch14_volume_l(15 downto 8) <= b5;
							ch14_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=15) then
							ch15_volume_l(23 downto 24) <= b3;
							ch15_volume_l(23 downto 16) <= b4;
							ch15_volume_l(15 downto 8) <= b5;
							ch15_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=16) then
							ch16_volume_l(23 downto 24) <= b3;
							ch16_volume_l(23 downto 16) <= b4;
							ch16_volume_l(15 downto 8) <= b5;
							ch16_volume_l(7 downto 0) <= b6;
						elsif (unsigned(b2)=17) then
							-- Command = 17 (Main R)
							main_volume_r(23 downto 24) <= b3;
							main_volume_r(23 downto 16) <= b4;
							main_volume_r(15 downto 8) <= b5;
							main_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=18) then
							ch1_volume_r(23 downto 24) <= b3;
							ch1_volume_r(23 downto 16) <= b4;
							ch1_volume_r(15 downto 8) <= b5;
							ch1_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=19) then
							ch2_volume_r(23 downto 24) <= b3;
							ch2_volume_r(23 downto 16) <= b4;
							ch2_volume_r(15 downto 8) <= b5;
							ch2_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=20) then
							ch3_volume_r(23 downto 24) <= b3;
							ch3_volume_r(23 downto 16) <= b4;
							ch3_volume_r(15 downto 8) <= b5;
							ch3_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=21) then
							ch4_volume_r(23 downto 24) <= b3;
							ch4_volume_r(23 downto 16) <= b4;
							ch4_volume_r(15 downto 8) <= b5;
							ch4_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=22) then
							ch5_volume_r(23 downto 24) <= b3;
							ch5_volume_r(23 downto 16) <= b4;
							ch5_volume_r(15 downto 8) <= b5;
							ch5_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=23) then
							ch6_volume_r(23 downto 24) <= b3;
							ch6_volume_r(23 downto 16) <= b4;
							ch6_volume_r(15 downto 8) <= b5;
							ch6_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=24) then
							ch7_volume_r(23 downto 24) <= b3;
							ch7_volume_r(23 downto 16) <= b4;
							ch7_volume_r(15 downto 8) <= b5;
							ch7_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=25) then
							ch8_volume_r(23 downto 24) <= b3;
							ch8_volume_r(23 downto 16) <= b4;
							ch8_volume_r(15 downto 8) <= b5;
							ch8_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=26) then
							ch9_volume_r(23 downto 24) <= b3;
							ch9_volume_r(23 downto 16) <= b4;
							ch9_volume_r(15 downto 8) <= b5;
							ch9_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=27) then
							ch10_volume_r(23 downto 24) <= b3;
							ch10_volume_r(23 downto 16) <= b4;
							ch10_volume_r(15 downto 8) <= b5;
							ch10_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=28) then
							ch11_volume_r(23 downto 24) <= b3;
							ch11_volume_r(23 downto 16) <= b4;
							ch11_volume_r(15 downto 8) <= b5;
							ch11_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=29) then
							ch12_volume_r(23 downto 24) <= b3;
							ch12_volume_r(23 downto 16) <= b4;
							ch12_volume_r(15 downto 8) <= b5;
							ch12_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=30) then
							ch13_volume_r(23 downto 24) <= b3;
							ch13_volume_r(23 downto 16) <= b4;
							ch13_volume_r(15 downto 8) <= b5;
							ch13_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=31) then
							ch14_volume_r(23 downto 24) <= b3;
							ch14_volume_r(23 downto 16) <= b4;
							ch14_volume_r(15 downto 8) <= b5;
							ch14_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=32) then
							ch15_volume_r(23 downto 24) <= b3;
							ch15_volume_r(23 downto 16) <= b4;
							ch15_volume_r(15 downto 8) <= b5;
							ch15_volume_r(7 downto 0) <= b6;
						elsif (unsigned(b2)=33) then
							ch16_volume_r(23 downto 24) <= b3;
							ch16_volume_r(23 downto 16) <= b4;
							ch16_volume_r(15 downto 8) <= b5;
							ch16_volume_r(7 downto 0) <= b6;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
end Behavioral;