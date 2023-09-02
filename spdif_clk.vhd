-- create LRCLK from BCLK for I2S

LIBRARY IEEE;    
USE IEEE.STD_LOGIC_1164.ALL;    

entity spdif_clk is
    port (
        clk			: in std_logic;
        bit_clk	: out std_logic
    );
end spdif_clk;

architecture Behavioral of spdif_clk is
    signal count : integer := 0;
    signal b : std_logic := '0';
begin
    process(clk)     
    begin
        if(rising_edge(clk)) then
            count <= count + 1;
            if(count = 7) then -- we are using rising edge, so input-clock is divided by 2! 6.144MHz = (100/2)/8
                b <= not b;
                count <=0;
            end if;
        end if;
    end process;

    bit_clk<=b;
end;
