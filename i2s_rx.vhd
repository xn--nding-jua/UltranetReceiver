library ieee;
use ieee.std_logic_1164.all;

entity i2s_rx is
	generic ( DATA_WIDTH : integer range 16 to 32 := 24;
    		  BITPERFRAME : integer := 24
    		);
	port (
		clk 		: in std_logic;
		bsync		: in std_logic;
        bclk 		: in std_logic;
        sdata		: in std_logic;
        lrclk		: in std_logic;
        ch_out_l	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
        ch_out_r	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
        new_data	: out std_logic
        );
end i2s_rx;

architecture rtl of i2s_rx is
	signal sr_in_l					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sr_in_r					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal neg_edge, pos_edge 	: std_logic;
	signal lr_edge					: std_logic;
	signal new_sample 			: std_logic;

	signal zbclk, zzbclk, zzzbclk 	: std_logic;
	signal zlrclk, zzlrclk, zzzlrclk: std_logic;
	signal cnt						: integer range 0 to 31 := 0;

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
		if bsync = '1' then 
			cnt <= 0;
			new_data <= '0';
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
				if cnt = DATA_WIDTH + 1 and neg_edge = '1' then
					new_data <= '1';
				else
					new_data <= '0';
				end if;
			end if;
		end if;
	end process;

	ch_out_l <= sr_in_l;
	ch_out_r <= sr_in_r;
 
	get_data : process(clk)
	begin
		if rising_edge(clk) then
			if pos_edge = '1' and new_sample = '1' then
				-- receive
				if lr_edge = '0' then
					sr_in_l <= sr_in_l(sr_in_l'high - 1 downto 0) & sdata;
				else
					sr_in_r <= sr_in_r(sr_in_r'high - 1 downto 0) & sdata;
				end if;
			end if;
		end if;
	end process;
end rtl;
        