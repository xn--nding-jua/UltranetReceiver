-------------------------------------------------------------------------------
-- Receiver for Behringer UltraNet
-- based on OpenCore's i2s_interface
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
         channel	: out unsigned(7 downto 0); -- received channel-number
         new_data	: out std_logic -- new data received successfully
        );
end i2s_ultranet_rx;

architecture rtl of i2s_ultranet_rx is
	signal sample_data			: std_logic_vector(23 downto 0);
	signal neg_edge, pos_edge 	: std_logic;
	signal lr_edge					: std_logic;
	signal rx_sampledata 		: std_logic;

	signal zbclk, zzbclk, zzzbclk 	: std_logic;
	signal zlrclk, zzlrclk, zzzlrclk: std_logic;
	signal cnt						: integer range 0 to 31 := 0;
	
	signal chn_cnt					: integer range 0 to 8 := 1;
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
			if bsync = '1' then -- begin of new block (means channel 1 on Ultranet)
				cnt <= 0;
				chn_cnt <= 1; -- reset channel-counter to 1
				new_data <= '0';
			else
				if lr_edge = '1' then -- rising or falling edge on LRCLK detected
					cnt <= 0;
					chn_cnt <= chn_cnt + 1; -- increase channel-counter on each LRCLK-edge
				end if;
				if pos_edge = '1' then
					if cnt < 24 + 1 then
						cnt <= cnt + 1; -- increment cnt until 25
					end if;
				end if;
				if neg_edge = '1' then  	
					if cnt = 1 then -- begin of sampledata
						rx_sampledata <= '1';
					elsif cnt = 24 + 1 then -- reached end of sampledata
						rx_sampledata <= '0';
					end if;
				end if;
				if cnt = 24 + 1 and neg_edge = '1' then -- reached end of sampledata
					new_data <= '1';
				else
					new_data <= '0';
				end if;
			end if;
		end if;
	end process;

	sample_out <= sample_data;
	channel <= to_unsigned(chn_cnt, channel'length);

	get_data : process(clk)
	begin
		if rising_edge(clk) then
			-- receive individual bits for audio-data (24 bits)
			if pos_edge = '1' and rx_sampledata = '1' then
				sample_data <= sample_data(sample_data'high - 1 downto 0) & sdata;
			end if;
		end if;
	end process;
end rtl;
        