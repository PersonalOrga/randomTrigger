library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity randomTrigger_tb is
end randomTrigger_tb;


architecture Behavior of randomTrigger_tb is
component top_randomTrigger is
  port(
    iCLK            : in  std_logic;        --!Main clock
    iRST            : in  std_logic;        --!Main reset
    iEN             : in  std_logic;        --!Enable PRBS32 Unit
    -- Peripherals
    iKEY        : in    std_logic_vector(1 downto 0);   --!2 x Key
    iSW         : in    std_logic_vector(3 downto 0);   --!4 x Switch
    oLED        : out   std_logic_vector(7 downto 0);   --!8 x Led
    -- External Busy
    iEXT_BUSY       : in std_logic;         --!Ignore trigger
    -- Settings
    iTHRESHOLD      : in std_logic_vector(31 downto 0);  --!Threshold to configure trigger rate (low threshold --> High trigger rate)
    iINT_BUSY       : in std_logic_vector(31 downto 0);  --!Ignore trigger for "N" clock cycles
    iSHAPER_T_ON    : in std_logic_vector(31 downto 0);  --!Length of the pulse trigger
    iFREQ_DIV       : in std_logic_vector(15 downto 0);  --!Slow clock duration (in number of iCLK cycles) to drive PRBS32
    -- Output
    oTRIG           : out std_logic         --!Output trigger
    );
end component;

signal sCLK           : std_logic := '0';
signal sRST           : std_logic := '1';
signal sEN            : std_logic := '0';
signal sKEY           : std_logic_vector(1 downto 0) := "00";
signal sSW            : std_logic_vector(3 downto 0) := "0000";
signal sLED           : std_logic_vector(7 downto 0);
signal sEXT_BUSY      : std_logic := '0';
signal sTHRESHOLD     : std_logic_vector(31 downto 0) := (others => '0');
signal sINT_BUSY      : std_logic_vector(31 downto 0) := (others => '0');
signal sSHAPER_T_ON   : std_logic_vector(31 downto 0) := (others => '0');
signal sFREQ_DIV      : std_logic_vector(15 downto 0) := (others => '0');
signal sTRIG          : std_logic;
constant clk_period	  : time := 20 ns;			-- Definizione della costante "clk_period" di tipo "tempo".

begin
  uut : top_randomTrigger
  port map(
      iCLK            => sCLK,
      iRST            => sRST,
      iEN             => sEN,
      iKEY            => sKEY,
      iSW             => sSW,
      oLED            => sLED,
      iEXT_BUSY       => sEXT_BUSY,
      iTHRESHOLD      => sTHRESHOLD,
      iINT_BUSY       => sINT_BUSY,
      iSHAPER_T_ON    => sSHAPER_T_ON,
      iFREQ_DIV       => sFREQ_DIV,
      oTRIG           => sTRIG
      );
  
  
  -- Processo per la simulazione del segnale di clock
	clock_simulation : process
	begin
		wait for (clk_period/2);
		sCLK <= '1';
		wait for (clk_period/2);
		sCLK <= '0';
	end process;
	
	-- Processo per la simulazione dei segnali d'ingresso
	in_simulation : process			
	begin
		-------------------------------------------------- START 01 (OK)
    wait for 30 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"DDDDDDDD";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"000A";
		
		-------------------------------------------------- START 02 (RESET)
		wait for 940 ns;
		sRST		      <= '1';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"000A";
    wait for 60 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"000A";
    
    -------------------------------------------------- START 03 (ENABLE)
		wait for 940 ns;
		sRST		      <= '0';
		sEN		        <= '0';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"000A";
    wait for 240 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"000A";
    
    -------------------------------------------------- START 04 (THRESHOLD)
		wait for 1000 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"AAAAAAAA";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"000A";
    wait for 5000 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"000A";
    
    -------------------------------------------------- START 05 (BUSY_PERIOD)
		wait for 1000 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"DDDDDDDD";
    sINT_BUSY       <= x"0000004F";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"000A";
    wait for 15000 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"000A";
    
    -------------------------------------------------- START 06 (EXTERNAL BUSY)
    wait for 1000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"000A";
    wait for 1000 ns;
    sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '1';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"000A";
    wait for 5000 ns;
    sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"000A";
    
    -------------------------------------------------- START 07 (SHAPER TIME ON)
    wait for 1000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000064";
    sFREQ_DIV       <= x"000A";
    wait for 10000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"000A";
    
    -------------------------------------------------- START 08 (SLOW CLOCK)
    wait for 1000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"0002";
    wait for 1000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"000A";
    
    -------------------------------------------------- START 09 (f_trig = 500Hz)
    wait for 30 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"7FDA1A40";
    sINT_BUSY       <= x"0000C350";
    sSHAPER_T_ON    <= x"00000005";
    sFREQ_DIV       <= x"C350";
    
    
    
		wait;
	end process;


end Behavior;
      
      
      