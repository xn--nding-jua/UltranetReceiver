library ieee;
use ieee.std_logic_1164.all;

entity i2s_ultranet_rx is
	generic ( BITPERFRAME : integer := 32 -- ultranet uses 24bit for audio-data + 8bit frame-data
    		);
	port (
			clk 		: in std_logic;
			bsync		: in std_logic;
         bclk 		: in std_logic;
         sdata		: in std_logic;
         lrclk		: in std_logic;
         sample_out	: out std_logic_vector(23 downto 0);
			frame_out	: out std_logic_vector(7 downto 0);
         new_data	: out std_logic
        );
end i2s_ultranet_rx;

architecture rtl of i2s_ultranet_rx is
	signal sample_data			: std_logic_vector(23 downto 0);
	signal frame_data				: std_logic_vector(7 downto 0);
	signal neg_edge, pos_edge 	: std_logic;
	signal lr_edge					: std_logic;
	signal rx_sampledata 		: std_logic;
	signal rx_framedata			: std_logic;

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
					if cnt < BITPERFRAME - 1 then
						cnt <= cnt + 1;
					end if;
				end if;
				if neg_edge = '1' then  	
					if cnt = 1 then -- begin of sampledata
						rx_sampledata <= '1';
						rx_framedata <= '0';
					elsif cnt > 24 and cnt < BITPERFRAME then -- reached end of sampledata, begin of framedata
						rx_sampledata <= '0';
						rx_framedata <= '1';
					elsif cnt = BITPERFRAME then -- reached end of framedata
						rx_framedata <= '0';
					end if;
				end if;
				if cnt = BITPERFRAME + 1 and neg_edge = '1' then -- reached end of sampledata
					new_data <= '1';
				else
					new_data <= '0';
				end if;
			end if;
		end if;
	end process;

	sample_out <= sample_data;
	frame_out <= frame_data;

	get_data : process(clk)
	begin
		if rising_edge(clk) then
			-- receive individual bits for audio-data (24 bits)
			if pos_edge = '1' and rx_sampledata = '1' then
				sample_data <= sample_data(sample_data'high - 1 downto 0) & sdata;
			end if;
			
			-- receive individual bits for frame-data (8 bits)
			if pos_edge = '1' and rx_framedata = '1' then
				frame_data <= frame_data(frame_data'high -1 downto 0) & sdata;
			end if;
		end if;
	end process;
end rtl;
        