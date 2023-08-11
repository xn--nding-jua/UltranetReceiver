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
         ch1_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
         ch2_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
         ch3_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
         ch4_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
         ch5_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
         ch6_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
         ch7_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
         ch8_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
         new_data	: out std_logic
        );
end i2s_rx;

architecture rtl of i2s_rx is
	signal sr_in1 					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sr_in2 					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sr_in3 					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sr_in4 					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sr_in5 					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sr_in6 					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sr_in7 					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sr_in8 					: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal neg_edge, pos_edge 	: std_logic;
	signal lr_edge					: std_logic;
	signal new_sample 			: std_logic;

	signal zbclk, zzbclk, zzzbclk 	: std_logic;
	signal zlrclk, zzlrclk, zzzlrclk: std_logic;
	signal cnt						: integer range 0 to 31 := 0;
	signal ch_cnt					: integer range 0 to 8 := 0;

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
			ch_cnt <= 1;
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
					-- increase ch_cnt
					if ch_cnt < 8 then
						ch_cnt <= ch_cnt + 1;
					else
						ch_cnt <= 1;
						new_data <= '1';
					end if;
				else
					new_data <= '0';
				end if;
			end if;
		end if;
	end process;

	ch1_out <= sr_in1;
	ch2_out <= sr_in2;
	ch3_out <= sr_in3;
	ch4_out <= sr_in4;
	ch5_out <= sr_in5;
	ch6_out <= sr_in6;
	ch7_out <= sr_in7;
	ch8_out <= sr_in8;
	 
	get_data : process(clk)
	begin
		if rising_edge(clk) then
			if pos_edge = '1' and new_sample = '1' then
				-- receive
				if ch_cnt = 1 then
					sr_in1 <= sr_in1(sr_in1'high - 1 downto 0) & sdata;
				end if;
				if ch_cnt = 2 then
					sr_in2 <= sr_in1(sr_in2'high - 1 downto 0) & sdata;
				end if;
				if ch_cnt = 3 then
					sr_in3 <= sr_in1(sr_in3'high - 1 downto 0) & sdata;
				end if;
				if ch_cnt = 4 then
					sr_in4 <= sr_in1(sr_in4'high - 1 downto 0) & sdata;
				end if;
				if ch_cnt = 5 then
					sr_in5 <= sr_in1(sr_in5'high - 1 downto 0) & sdata;
				end if;
				if ch_cnt = 6 then
					sr_in6 <= sr_in1(sr_in6'high - 1 downto 0) & sdata;
				end if;
				if ch_cnt = 7 then
					sr_in7 <= sr_in1(sr_in7'high - 1 downto 0) & sdata;
				end if;
				if ch_cnt = 8 then
					sr_in8 <= sr_in1(sr_in8'high - 1 downto 0) & sdata;
				end if;
			end if;
		end if;
	end process;
end rtl;
        