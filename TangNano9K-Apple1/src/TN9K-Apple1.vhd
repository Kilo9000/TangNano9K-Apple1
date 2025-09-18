---------------------------------------------------------------------------------
--                          Apple1 - Tang Nano 9K
--                         Code from Alan & Niels
--
--                        Modified for Tang Nano 9K 
--                            by pinballwiz.org 
--                               17/09/2025
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity apple1_tn9k is
port(
	Clock_27    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
 	led         : out std_logic_vector(5 downto 0) 
 );
end apple1_tn9k;
------------------------------------------------------------------------------
architecture struct of apple1_tn9k is

 signal clock_25  : std_logic;
 signal clock_50  : std_logic;
 --
 signal video_r   : std_logic;
 signal video_g   : std_logic;
 signal video_b   : std_logic;
 --
 signal h_sync     : std_logic;
 signal v_sync	   : std_logic;
 --
 signal uart_rx    : std_logic;
 signal uart_tx	   : std_logic;
 signal uart_cts   : std_logic;
 --
 signal reset      : std_logic;
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
begin

    reset <= not I_RESET;
---------------------------------------------------------------------------
-- Clocks
Clock1: entity work.Gowin_rPLL
    port map (
        clkout => clock_50,
        clkin  => Clock_27
    );
---------------------------------------------------------------------------
process (clock_50)
begin
 if rising_edge(clock_50) then
  clock_25  <= not clock_25;
 end if;
end process;
---------------------------------------------------------------------------
apple1 : entity work.apple1
  port map (
 clk25     => clock_25,
 rst_n      => I_RESET,
 uart_rx    => uart_rx,
 uart_tx    => uart_tx,
 uart_cts   => uart_cts,
 ps2_clk    => ps2_clk,
 ps2_din    => ps2_dat,
 ps2_select => '1',
 vga_red 	=> video_r,
 vga_grn 	=> video_g,
 vga_blu 	=> video_b,
 vga_h_sync => h_sync,
 vga_v_sync	=> v_sync,
 vga_cls    => reset,
 pc_monitor => open,
 AD         => AD
   );
-------------------------------------------------------------------------
-- to output

	O_VIDEO_R <= video_r & video_r & video_r;
	O_VIDEO_G <= video_g & video_g & video_g;
	O_VIDEO_B <= video_b & video_b;
	O_HSYNC   <= h_sync;
	O_VSYNC   <= v_sync;
------------------------------------------------------------------------------
-- debug

process(reset, clock_27)
begin
  if reset = '1' then
    clock_4hz <= '0';
    counter_clk <= (others => '0');
  else
    if rising_edge(clock_27) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(5 downto 0) <= not AD(9 downto 4);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------
end struct;