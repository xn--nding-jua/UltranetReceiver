---------------------------------------------------------------------------------
-- Einbindung Bibliotheken ------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--library unisim;
--use unisim.vcomponents.all;
---------------------------------------------------------------------------------
-- Entity -----------------------------------------------------------------------
---------------------------------------------------------------------------------
entity RS232_Interface is
	generic(	clk_rate						: integer := 4000000;								-- Taktrate Systemtakt in Hz
				baud_rate					: integer := 19200								   -- Baudrate RS232 in baud
				);
	port(	clk								: in std_logic;										-- Systemtakt
			rs232_rxd						: in std_logic;										-- RS232 RxD
			rs232_tra_en					: in std_logic;										-- Byte soll auf TxD abgesetzt werden
			rs232_dat_in					: in std_logic_vector(7 downto 0);				-- auf TxD abzusetzendes Byte
			rs232_txd						: out std_logic := '1';								-- RS232 TxD
			rs232_txd_busy					: out std_logic;										-- RS232 TxD besetzt
			rs232_rec_en					: out std_logic := '0';								-- Byte wurde ueber RxD empfangen
			rs232_dat_out					: out std_logic_vector(7 downto 0)				-- empfangenes Byte
			);
end RS232_Interface;
---------------------------------------------------------------------------------
-- Architecture -----------------------------------------------------------------
---------------------------------------------------------------------------------
architecture Behavioral of RS232_Interface is
	-- Deklarationen -------------------------------------------------------------
	------------------------------------------------------------------------------
	function vector_width(m : integer) return integer is
		variable n							: integer := 0;
	begin
		while(2 ** n <= m) loop
			n := n + 1;
		end loop;
		return n;
	end function vector_width;
	------------------------------------------------------------------------------
	constant cnt_const0					: integer := clk_rate / baud_rate;
	constant cnt_const1					: integer := clk_rate / (2 * baud_rate) + cnt_const0;
	constant cnt_width					: integer := vector_width(cnt_const1);
	------------------------------------------------------------------------------
	type rec_states						is (start_bit, data_byte, stop_bit);
	signal rec_state						: rec_states := start_bit;
	type tra_states						is (start_bit, data_byte, stop_bit);
	signal tra_state						: tra_states := start_bit;
	signal rec_sync						: std_logic_vector(2 downto 0) := (others => '1');
	signal rec_cnt							: std_logic_vector(cnt_width - 1 downto 0) := (others => '1');
	signal rec_bit_cnt					: std_logic_vector(2 downto 0) := (others => '0');
	signal rec_byte_reg					: std_logic_vector(7 downto 0) := (others => '0');
	signal tra_en							: std_logic := '0';
	signal tra_cnt							: std_logic_vector(cnt_width - 1 downto 0) := (others => '1');
	signal tra_bit_cnt					: std_logic_vector(2 downto 0) := (others => '0');
	signal tra_byte_reg					: std_logic_vector(7 downto 0) := (others => '0');
	signal tra_sync						: std_logic_vector(2 downto 0) := (others => '1');
	------------------------------------------------------------------------------
begin
	------------------------------------------------------------------------------
	Sync_to_CLK : process(clk)
	begin
		if rising_edge(clk) then
			rec_sync(0) <= rs232_rxd;
			rec_sync(1) <= rec_sync(0);
			rec_sync(2) <= rec_sync(1);
			tra_sync(0) <= rs232_tra_en;
			tra_sync(1) <= tra_sync(0);
			tra_sync(2) <= tra_sync(1);
		end if;
	end process;
	------------------------------------------------------------------------------
	Receiver : process(clk)
	begin
		if rising_edge(clk) then
			case rec_state is
				when start_bit =>
					if rec_sync(1) = '0' and rec_sync(2) = '1' then
						rs232_rec_en <= '0';
						rec_cnt <= conv_std_logic_vector(cnt_const1, cnt_width);
						rec_state <= data_byte;
					end if;
				when data_byte =>
					if rec_cnt = 0 then
						rec_cnt <= conv_std_logic_vector(cnt_const0, cnt_width);
						rec_bit_cnt <= rec_bit_cnt + 1;
						rec_byte_reg(conv_integer(rec_bit_cnt)) <= rec_sync(1);
						if rec_bit_cnt = 7 then
							rec_state <= stop_bit;
						end if;
					else
						rec_cnt <= rec_cnt - 1;
					end if;
				when stop_bit =>
					rec_cnt <= rec_cnt - 1;
					if rec_cnt = 0 then
						rs232_rec_en <= '1';
						rec_state <= start_bit;
					end if;
			end case;		
		end if;
	end process;
	------------------------------------------------------------------------------
	Transmitter : process(clk)
	begin
		if rising_edge(clk) then
			case tra_state is
				when start_bit =>
					if tra_sync(1) = '1' and tra_sync(2) = '0' then
						tra_byte_reg <= rs232_dat_in;
						tra_cnt <= conv_std_logic_vector(cnt_const0, cnt_width);
						tra_en <= '1';
					elsif tra_en = '1' then
						rs232_txd <= '0';
						if tra_cnt = 0 then
							tra_cnt <= conv_std_logic_vector(cnt_const0, cnt_width);
							tra_state <= data_byte;
						else
							tra_cnt <= tra_cnt - 1;
						end if;	
					end if;
				when data_byte =>
					rs232_txd <= tra_byte_reg(conv_integer(tra_bit_cnt));
					if tra_cnt = 0 then
						tra_cnt <= conv_std_logic_vector(cnt_const0, cnt_width);
						tra_bit_cnt <= tra_bit_cnt + 1;
						if tra_bit_cnt = 7 then
							tra_state <= stop_bit;
						end if;
					else
						tra_cnt <= tra_cnt - 1;	
					end if;
				when stop_bit =>
					tra_cnt <= tra_cnt - 1;
					rs232_txd <= '1';
					if tra_cnt = 0 then
						tra_state <= start_bit;
						tra_en <= '0';
					end if;
			end case;		
		end if;
	end process;
	------------------------------------------------------------------------------
	rs232_txd_busy <= tra_en;
	rs232_dat_out <= rec_byte_reg;
end Behavioral;
