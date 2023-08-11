LIBRARY IEEE;    
USE IEEE.STD_LOGIC_1164.ALL;    

entity clk_by_2 is
    port (
        clk_in : in std_logic;
        clk_out : out std_logic
    );
end clk_by_2;

architecture Behavioral of clk_by_2 is
    signal count : integer := 0;
    signal b : std_logic := '0';
begin
    process(clk_in)     
    begin
        if(rising_edge(clk_in)) then
            count <=count+1;
            if(count = 1) then
                b <= not b;
                count <=0;
            end if;
        end if;
        clk_out<=b;
    end process;
end;
