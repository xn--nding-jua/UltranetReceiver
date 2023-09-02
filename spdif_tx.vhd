library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity spdif_tx is
 port(
  bit_clock : in std_logic; -- 128x Fsample (6.144MHz for 48K samplerate)
  data_in : in std_logic_vector(23 downto 0);
  address_out : out std_logic := '0'; -- 1 address bit means stereo only
  spdif_out : out std_logic
 );
end entity spdif_tx;

architecture behavioral of spdif_tx is

 signal data_in_buffer : std_logic_vector(23 downto 0);
 signal bit_counter : std_logic_vector(5 downto 0) := (others => '0');
 signal frame_counter : std_logic_vector(8 downto 0) := (others => '0');
 signal data_biphase : std_logic := '0';
 signal data_out_buffer : std_logic_vector(7 downto 0);
 signal parity : std_logic;
 signal channel_status_shift : std_logic_vector(23 downto 0);
 signal channel_status : std_logic_vector(23 downto 0) := "001000000000000001000000";
 
begin
 
 bit_clock_counter : process (bit_clock)
 begin
  if bit_clock'event and bit_clock = '1' then
   bit_counter <= bit_counter + 1;
  end if;
 end process bit_clock_counter;

 data_latch : process (bit_clock)
 begin
  if bit_clock'event and bit_clock = '1' then
   parity <= data_in_buffer(23) xor data_in_buffer(22) xor data_in_buffer(21) xor data_in_buffer(20) xor data_in_buffer(19) xor data_in_buffer(18) xor data_in_buffer(17)  xor data_in_buffer(16) xor data_in_buffer(15) xor data_in_buffer(14) xor data_in_buffer(13) xor data_in_buffer(12) xor data_in_buffer(11) xor data_in_buffer(10) xor data_in_buffer(9) xor data_in_buffer(8) xor data_in_buffer(7) xor data_in_buffer(6) xor data_in_buffer(5) xor data_in_buffer(4) xor data_in_buffer(3) xor data_in_buffer(2) xor data_in_buffer(1) xor data_in_buffer(0) xor channel_status_shift(23);
   if bit_counter = "000011" then
    data_in_buffer <= data_in;
   end if;
   if bit_counter = "111111" then
    if frame_counter = "101111111" then
     frame_counter <= (others => '0');
    else
     frame_counter <= frame_counter + 1;
    end if;
   end if;
  end if;
 end process data_latch;

 data_output : process (bit_clock)
 begin
  if bit_clock'event and bit_clock = '1' then
   if bit_counter = "111111" then
    if frame_counter = "101111111" then -- next frame is 0, load preamble Z
     address_out <= '0';
     channel_status_shift <= channel_status;
     data_out_buffer <= "10011100";
    else
     if frame_counter(0) = '1' then -- next frame is even, load preamble X
      channel_status_shift <= channel_status_shift(22 downto 0) & '0';
      data_out_buffer <= "10010011";
      address_out <= '0';
     else -- next frame is odd, load preable Y
      data_out_buffer <= "10010110";
      address_out <= '1';
     end if;
    end if;
   else
    if bit_counter(2 downto 0) = "111" then -- load new part of data into buffer
     case bit_counter(5 downto 3) is
      when "000" =>
       data_out_buffer <= '1' & data_in_buffer(0) & '1' & data_in_buffer(1) & '1' & data_in_buffer(2) & '1' & data_in_buffer(3);
      when "001" =>
       data_out_buffer <= '1' & data_in_buffer(4) & '1' & data_in_buffer(5) & '1' & data_in_buffer(6) & '1' & data_in_buffer(7);
      when "010" =>
       data_out_buffer <= '1' & data_in_buffer(8) & '1' & data_in_buffer(9) & '1' & data_in_buffer(10) & '1' & data_in_buffer(11);
      when "011" =>
       data_out_buffer <= '1' & data_in_buffer(12) & '1' & data_in_buffer(13) & '1' & data_in_buffer(14) & '1' & data_in_buffer(15);
      when "100" =>
       data_out_buffer <= '1' & data_in_buffer(16) & '1' & data_in_buffer(17) & '1' & data_in_buffer(18) & '1' & data_in_buffer(19);
      when "101" =>
       data_out_buffer <= '1' & data_in_buffer(20) & '1' & data_in_buffer(21) & '1' & data_in_buffer(22) & '1' & data_in_buffer(23);
      when "110" =>
       data_out_buffer <= "10101" & channel_status_shift(23) & "1" & parity;
      when others =>
     end case;
    else
     data_out_buffer <= data_out_buffer(6 downto 0) & '0';
    end if;
   end if;
  end if;
 end process data_output;
 
 biphaser : process (bit_clock)
 begin
  if bit_clock'event and bit_clock = '1' then
   if data_out_buffer(data_out_buffer'left) = '1' then
    data_biphase <= not data_biphase;
   end if;
  end if;
 end process biphaser;
 spdif_out <= data_biphase;
 
end behavioral;