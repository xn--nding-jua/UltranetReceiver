-- RS232-Command-Decoder
-- v1.0 13.01.2013
-- Dipl.-Ing. Christian Nöding

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity RS232_Decoder is 
	port
	(
		RX_Data			: in std_logic_vector(7 downto 0);
		RX_DataReady	: in std_logic;

		main_volume	: out std_logic_vector(31 downto 0);

		ch1_volume	: out std_logic_vector(31 downto 0);
		ch2_volume	: out std_logic_vector(31 downto 0);
		ch3_volume	: out std_logic_vector(31 downto 0);
		ch4_volume	: out std_logic_vector(31 downto 0);
		ch5_volume	: out std_logic_vector(31 downto 0);
		ch6_volume	: out std_logic_vector(31 downto 0);
		ch7_volume	: out std_logic_vector(31 downto 0);
		ch8_volume	: out std_logic_vector(31 downto 0);

		ch9_volume	: out std_logic_vector(31 downto 0);
		ch10_volume	: out std_logic_vector(31 downto 0);
		ch11_volume	: out std_logic_vector(31 downto 0);
		ch12_volume	: out std_logic_vector(31 downto 0);
		ch13_volume	: out std_logic_vector(31 downto 0);
		ch14_volume	: out std_logic_vector(31 downto 0);
		ch15_volume	: out std_logic_vector(31 downto 0);
		ch16_volume	: out std_logic_vector(31 downto 0)
	);
end entity;

architecture Behavioral of RS232_Decoder is
begin
	process (RX_DataReady)
		variable b1 : std_logic_vector(7 downto 0);	-- "A" = 0x41
		variable b2 : std_logic_vector(7 downto 0);	-- C
		variable b3 : std_logic_vector(7 downto 0);	-- V1
		variable b4 : std_logic_vector(7 downto 0);	-- V2
		variable b5 : std_logic_vector(7 downto 0);	-- V3
		variable b6 : std_logic_vector(7 downto 0);	-- V4
		variable b7 : std_logic_vector(7 downto 0);	-- "E" = 0x45
	begin
		if (rising_edge(RX_DataReady)) then
			-- Alle Bytes um ein Byte verschieben und neues Byte hinten einfügen
			b1 := b2;
			b2 := b3;
			b3 := b4;
			b4 := b5;
			b5 := b6;
			b6 := b7;
			b7 := RX_Data;
			
			-- State-Machine zum Empfangen von RS232-Daten
			if ((unsigned(b1)=65)) then -- and (unsigned(b7)=69)) then
				-- Anfang und Ende gefunden --> Daten auswerten
				
				if (unsigned(b2)=0) then
					-- Command = 0 (Main)
					main_volume(31 downto 24) <= b3;
					main_volume(23 downto 16) <= b4;
					main_volume(15 downto 8) <= b5;
					main_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=1) then
					ch1_volume(31 downto 24) <= b3;
					ch1_volume(23 downto 16) <= b4;
					ch1_volume(15 downto 8) <= b5;
					ch1_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=2) then
					ch2_volume(31 downto 24) <= b3;
					ch2_volume(23 downto 16) <= b4;
					ch2_volume(15 downto 8) <= b5;
					ch2_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=3) then
					ch3_volume(31 downto 24) <= b3;
					ch3_volume(23 downto 16) <= b4;
					ch3_volume(15 downto 8) <= b5;
					ch3_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=4) then
					ch4_volume(31 downto 24) <= b3;
					ch4_volume(23 downto 16) <= b4;
					ch4_volume(15 downto 8) <= b5;
					ch4_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=5) then
					ch5_volume(31 downto 24) <= b3;
					ch5_volume(23 downto 16) <= b4;
					ch5_volume(15 downto 8) <= b5;
					ch5_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=6) then
					ch6_volume(31 downto 24) <= b3;
					ch6_volume(23 downto 16) <= b4;
					ch6_volume(15 downto 8) <= b5;
					ch6_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=7) then
					ch7_volume(31 downto 24) <= b3;
					ch7_volume(23 downto 16) <= b4;
					ch7_volume(15 downto 8) <= b5;
					ch7_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=8) then
					ch8_volume(31 downto 24) <= b3;
					ch8_volume(23 downto 16) <= b4;
					ch8_volume(15 downto 8) <= b5;
					ch8_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=9) then
					ch9_volume(31 downto 24) <= b3;
					ch9_volume(23 downto 16) <= b4;
					ch9_volume(15 downto 8) <= b5;
					ch9_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=10) then
					ch10_volume(31 downto 24) <= b3;
					ch10_volume(23 downto 16) <= b4;
					ch10_volume(15 downto 8) <= b5;
					ch10_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=11) then
					ch11_volume(31 downto 24) <= b3;
					ch11_volume(23 downto 16) <= b4;
					ch11_volume(15 downto 8) <= b5;
					ch11_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=12) then
					ch12_volume(31 downto 24) <= b3;
					ch12_volume(23 downto 16) <= b4;
					ch12_volume(15 downto 8) <= b5;
					ch12_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=13) then
					ch13_volume(31 downto 24) <= b3;
					ch13_volume(23 downto 16) <= b4;
					ch13_volume(15 downto 8) <= b5;
					ch13_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=14) then
					ch14_volume(31 downto 24) <= b3;
					ch14_volume(23 downto 16) <= b4;
					ch14_volume(15 downto 8) <= b5;
					ch14_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=15) then
					ch15_volume(31 downto 24) <= b3;
					ch15_volume(23 downto 16) <= b4;
					ch15_volume(15 downto 8) <= b5;
					ch15_volume(7 downto 0) <= b6;
				elsif (unsigned(b2)=16) then
					ch16_volume(31 downto 24) <= b3;
					ch16_volume(23 downto 16) <= b4;
					ch16_volume(15 downto 8) <= b5;
					ch16_volume(7 downto 0) <= b6;
				end if;
			end if;
		end if;
	end process;
end Behavioral;