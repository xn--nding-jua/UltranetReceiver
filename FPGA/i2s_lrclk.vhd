-- create LRCLK from BCLK for I2S

LIBRARY IEEE;    
USE IEEE.STD_LOGIC_1164.ALL;    

entity i2s_lrclk is
    port (
        clk		: in std_logic;
        lrclk	: out std_logic
    );
end i2s_lrclk;

architecture Behavioral of i2s_lrclk is
    signal count : integer := 0;
    signal b : std_logic := '0';
begin
    process(clk)     
    begin
        if(rising_edge(clk)) then
            count <=count+1;
            if(count = 999) then
                b <= not b;
                count <=0;
            end if;
        end if;
    end process;

	 lrclk<=b;
end;
