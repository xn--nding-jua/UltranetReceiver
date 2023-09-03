-------------------------------------------------------------------------------
-- Receiver for Behringer UltraNet
-- based on OpenCore's i2s_interface by Geir Drange (https://opencores.org/projects/i2s_interface)
--
-- UltraNet sends eight 24-bit audio-samples in AES/EBU-format.
-- this file expects I2S-data converted from AES/EBU
--
-- bsync (Z subframe in AES/EBU) will signal channel 1 followed by seven more samples
-- individual samples are identified by lrclk
------------------------------------------------------------------------------- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use ieee.numeric_std.all; -- lib for unsigned and signed

entity i2s_ultranet_rx is
	port (
			clk 		: in std_logic; -- Master clock
			bsync		: in std_logic; -- Block start (asserted when Z subframe is being transmitted)
			bclk 		: in std_logic; -- output serial data clock (AES3-clock)
			sdata		: in std_logic; -- output serial data
			lrclk		: in std_logic; -- Frame sync (asserted for channel A, negated for B)
			
			sample_out	: out std_logic_vector(23 downto 0); -- received audio-sample
			channel		: out unsigned(2 downto 0); -- received channel-number
			new_data	: out std_logic -- new data received successfully
        );
end i2s_ultranet_rx;

architecture rtl of i2s_ultranet_rx is
	signal sample_data			: std_logic_vector(23 downto 0);
	signal bsync_pos_edge		: std_logic;
	signal neg_edge, pos_edge 	: std_logic;
	signal lr_edge					: std_logic;
	signal rx_sampledata 		: std_logic;

	signal zbsync, zzbsync, zzzbsync	: std_logic;
	signal zbclk, zzbclk, zzzbclk 	: std_logic;
	signal zlrclk, zzlrclk, zzzlrclk	: std_logic;

	signal bit_cnt					: integer range 0 to 31 := 0;
	signal chn_cnt					: integer range 0 to 7 := 0;
begin
	detect_bsync_pos_edge : process(clk)
	begin
		if rising_edge(clk) then
			zbsync <= bsync;
			zzbsync <= zbsync;
			zzzbsync <= zzbsync;
			if zzbsync = '1' and zzzbsync = '0' then
				bsync_pos_edge <= '1';
			else
				bsync_pos_edge <= '0';
			end if;
		end if;
	end process;

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
			if bsync_pos_edge = '1' then -- begin of new block (means channel 1 on Ultranet)
				bit_cnt <= 0;
				chn_cnt <= 0; -- reset channel-counter to 0
				new_data <= '0';
			else
				if lr_edge = '1' then -- rising or falling edge on LRCLK detected
					bit_cnt <= 0;

					if chn_cnt < 7 then
						chn_cnt <= chn_cnt + 1; -- increase channel-counter on each LRCLK-edge
					else
						chn_cnt <= 0; -- reset to 0 as we are receiving a bsync only every 192 frames
					end if;
				end if;
				if pos_edge = '1' then
					if bit_cnt < 31 then
						bit_cnt <= bit_cnt + 1; -- increment bit_cnt until bit 31
					end if;
				end if;
				if neg_edge = '1' then  	
					if bit_cnt = 1 then -- data is one cycle late with respect to the word strobe
						rx_sampledata <= '1';
					elsif bit_cnt >= 24+1 then -- reached end of sampledata
						rx_sampledata <= '0';
					end if;
				end if;
				if bit_cnt = 30 and neg_edge = '1' then -- raise new_data-signal within the unused 4bits at the end of the frame
					new_data <= '1';
				else
					new_data <= '0';
				end if;
			end if;
		end if;
	end process;

	--sample_out <= "0000" & sample_data(19 downto 0); -- take only 20 bit
	sample_out <= sample_data; -- take all 24 bits
	channel <= to_unsigned(chn_cnt, channel'length);

	get_data : process(clk)
	begin
		if rising_edge(clk) then
			-- receive individual bits for audio-data (24 bits)
			if pos_edge = '1' and rx_sampledata = '1' then
				--sample_data <= sample_data(sample_data'high - 1 downto 0) & sdata;
				sample_data <= sdata & sample_data(sample_data'high downto 1); -- in AES3/EBU the first bit after preamble is LSB, so we have to shift from the left to the right
			end if;
		end if;
	end process;
end rtl;
        