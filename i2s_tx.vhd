library ieee;
use ieee.std_logic_1164.all;

entity i2s_tx is
	generic ( DATA_WIDTH : integer range 16 to 32 := 24;
    		  BITPERFRAME : integer := 24
    		);
	port (
    	  clk 		: in std_logic;
        reset 		: in std_logic;
    	  bclk 		: in std_logic;
		  lrclk		: in std_logic;
        sample_l	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
        sample_r	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
        serial_data	: out std_logic;
        ready 		: out std_logic
        );
end i2s_tx;

architecture rtl of i2s_tx is
    signal neg_edge, pos_edge : std_logic;
    signal lr_edge					: std_logic;
    signal new_sample 			: std_logic;
	 
    signal zbclk, zzbclk, zzzbclk 	: std_logic;
	 signal zlrclk, zzlrclk, zzzlrclk: std_logic;
	 
    signal cnt						: integer range 0 to 31 := 0;
    signal sr_out 				: std_logic_vector(DATA_WIDTH - 1 downto 0);
    
begin
	detect_edge : process(clk)
	begin
		if rising_edge(clk) then
			zbclk <= bclk;
			zzbclk <= zbclk;
			zzzbclk <= zzbclk;
			if zzbclk = '1' and zzzbclk = '0' then
				pos_edge <= '1';
			elsif zzbclk = '0' and zzzbclk = '1' then
				neg_edge <= '1';
			else
				pos_edge <= '0';
				neg_edge <= '0';
			end if;
		end if;
	end process;	
	

    detect_lr_edge : process(clk)
    begin
    	if rising_edge(clk) then
        	zlrclk <= lrclk;
			zzlrclk <= zlrclk;
			zzzlrclk <= zzlrclk;
			if zzlrclk /= zzzlrclk then
				lr_edge <= '1';
			else
				lr_edge <= '0';
			end if;
      end if;
   end process;
	
	
	detect_sample : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then 
				cnt <= 0;
			else
				if lr_edge = '1' then
					cnt <= 0;
				end if;
				if pos_edge = '1' then
					if cnt < BITPERFRAME/2 - 1 then
							cnt <= cnt + 1;
						end if;
				end if;
				if neg_edge = '1' then  	
					if cnt = 1 then
							new_sample <= '1';
						elsif cnt >= DATA_WIDTH + 1 and cnt < BITPERFRAME/2 - 1 then
							new_sample <= '0';
						end if;
				end if;
			end if;
		end if;
	end process;	
	
	send_data : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				ready <= '0';
			else
				if new_sample = '0' then -- get data during delay period
					if pos_edge = '1' then
						if lr_edge = '0' then
							sr_out <= sample_l;
						else
							sr_out <= sample_r;
						end if;
						ready <= '1';
					end if;
				else
					if cnt = 0 or cnt > DATA_WIDTH then
						serial_data <= 'X';
					else
						serial_data <= sr_out(DATA_WIDTH - cnt);
					end if;
					ready <= '0';
				end if;
			end if;
		end if;
	end process;
end rtl;
        