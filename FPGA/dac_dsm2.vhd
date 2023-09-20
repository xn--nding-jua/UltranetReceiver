-------------------------------------------------------------------------------
-- Title      : DAC_DSM2 - sigma-delta DAC converter with double loop
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dac_dsm2.vhd
-- Author     : Wojciech M. Zabolotny ( wzab[at]ise.pw.edu.pl )
-- Company    : 
-- Created    : 2009-04-28
-- Last update: 2009-04-29
-- Platform   : 
-- Standard   : VHDL'93c
-------------------------------------------------------------------------------
-- Description: Implementation without variables
-------------------------------------------------------------------------------
-- Copyright (c) 2009 - THIS IS PUBLIC DOMAIN CODE!!!
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009-04-28  1.0      wzab    Created
-------------------------------------------------------------------------------
-- There are two implementations:
-- dsm2 - allows to obtain higher clock frequency, and therefore 
--        higher oversampling ratio, but number of rising and falling
--        slopes in time unit depends on signal value. Therefore
--        you may experience nonlinear distortions if those two slopes
--        are not symmetrical.
-- dsm3 - The output of the DAC is updated once every three clock pulses.
--        If there is a '1' on the DAC output, the sequence '110' is generated
--        on the dout output. If there is a '0' on the DAC output, the sequence
--        '100' is generated. Therefore we always have one rising slope and one 
--        falling slope generated in each DAC cycle.
--        Unfortunately this implementation accepts lower clock frequencies,
--        so the oversampling ratio is lower
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_dsm2 is
  
  generic (
    nbits : integer := 24);

  port (
    din   : in  signed((nbits-1) downto 0);
    dout  : out std_logic;
    clk   : in  std_logic;
    n_rst : in  std_logic);

end dac_dsm2;

architecture beh1 of dac_dsm2 is

  signal del1, del2, d_q : signed(nbits+2 downto 0) := (others => '0');
  constant c1            : signed(nbits+2 downto 0) := to_signed(1, nbits+3);
  constant c_1           : signed(nbits+2 downto 0) := to_signed(-1, nbits+3);
begin  -- beh1

  process (clk, n_rst)
  begin  -- process
    if n_rst = '0' then                 -- asynchronous reset (active low)
      del1 <= (others => '0');
      del2 <= (others => '0');
      dout <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      del1 <= din - d_q + del1;
      del2 <= din - d_q + del1 - d_q + del2;
      if din - d_q + del1 - d_q + del2 > 0 then
        d_q  <= shift_left(c1, nbits);
        dout <= '1';
      else
        d_q  <= shift_left(c_1, nbits);
        dout <= '0';
      end if;
    end if;
  end process;
  

end beh1;
