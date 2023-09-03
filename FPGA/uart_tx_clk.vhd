-- reduce 4 MHz clock to 1 Hz clock.    

LIBRARY IEEE;    
USE IEEE.STD_LOGIC_1164.ALL;    

entity uart_tx_clk is
    port (
        clk_in : in std_logic;
        clk_out : out std_logic
    );
end uart_tx_clk;

architecture Behavioral of uart_tx_clk is
    signal count : integer :=0;
    signal b : std_logic :='0';
begin
    process(clk_in)     
    begin
        if(rising_edge(clk_in)) then
            count <=count+1;
            if(count = 1999999) then
                b <= not b;
                count <=0;
            end if;
        end if;
    end process;

    clk_out<=b;
end;
