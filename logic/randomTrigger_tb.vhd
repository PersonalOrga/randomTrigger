library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.paperoPackage.all;
use work.basic_package.all;


entity randomTrigger_tb is
end randomTrigger_tb;


architecture Behavior of randomTrigger_tb is
signal sCLK           : std_logic := '0';
signal sRST           : std_logic := '1';
signal sEN            : std_logic := '0';
signal sEXT_BUSY      : std_logic := '0';
signal sTHRESHOLD     : std_logic_vector(31 downto 0) := (others => '0');
signal sINT_BUSY      : std_logic_vector(31 downto 0) := (others => '0');
signal sSHAPER_T_ON   : std_logic_vector(31 downto 0) := (others => '0');
signal sFREQ_DIV      : std_logic_vector(31 downto 0) := (others => '0');
signal sTRIG          : std_logic;
signal sSLOW_CLOCK    : std_logic;
constant clk_period	  : time := 20 ns;			-- Definizione della costante "clk_period" di tipo "tempo".

begin
  uut : randomTrigger
  port map(
      iCLK            => sCLK,
      iRST            => sRST,
      iEN             => sEN,
      iEXT_BUSY       => sEXT_BUSY,
      iTHRESHOLD      => sTHRESHOLD,
      iINT_BUSY       => sINT_BUSY,
      iSHAPER_T_ON    => sSHAPER_T_ON,
      iFREQ_DIV       => sFREQ_DIV,
      oTRIG           => sTRIG,
      oSLOW_CLOCK     => sSLOW_CLOCK
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
    sTHRESHOLD      <= x"E6666666"; --"DDDDDDDD"
    sINT_BUSY       <= x"00000080";
    sSHAPER_T_ON    <= x"00000003";
    sFREQ_DIV       <= x"0000000A";
		
		-------------------------------------------------- START 02 (RESET)
		wait for 20000940 ns;
		sRST		      <= '1';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"0000000A";
    wait for 60 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"0000000A";
    
    -------------------------------------------------- START 03 (ENABLE)
		wait for 1940 ns;
		sRST		      <= '0';
		sEN		        <= '0';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"0000000A";
    wait for 240 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"0000000A";
    
    -------------------------------------------------- START 04 (THRESHOLD)
		wait for 1000 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"AAAAAAAA";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"0000000A";
    wait for 5000 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"0000000A";
    
    -------------------------------------------------- START 05 (BUSY_PERIOD)
		wait for 1000 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"DDDDDDDD";
    sINT_BUSY       <= x"0000004F";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"0000000A";
    wait for 15000 ns;
		sRST		      <= '0';
		sEN		        <= '1';
    sEXT_BUSY     <= '0';
    sTHRESHOLD    <= x"DDDDDDDD";
    sINT_BUSY     <= x"0000000A";
    sSHAPER_T_ON  <= x"00000001";
    sFREQ_DIV     <= x"0000000A";
    
    -------------------------------------------------- START 06 (EXTERNAL BUSY)
    wait for 1000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"0000000A";
    wait for 1000 ns;
    sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '1';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"0000000A";
    wait for 5000 ns;
    sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"0000000A";
    
    -------------------------------------------------- START 07 (SHAPER TIME ON)
    wait for 1000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000064";
    sFREQ_DIV       <= x"0000000A";
    wait for 10000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"0000000A";
    
    -------------------------------------------------- START 08 (SLOW CLOCK)
    wait for 1000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"00000002";
    wait for 1000 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"77777777";
    sINT_BUSY       <= x"0000000A";
    sSHAPER_T_ON    <= x"00000001";
    sFREQ_DIV       <= x"0000000A";
    
    -------------------------------------------------- START 09 (f_trig = 500Hz)
    wait for 30 ns;
		sRST		        <= '0';
		sEN		          <= '1';
    sEXT_BUSY       <= '0';
    sTHRESHOLD      <= x"7FDA1A40";
    sINT_BUSY       <= x"0000C350";
    sSHAPER_T_ON    <= x"00000005";
    sFREQ_DIV       <= x"0000C350";
    
    
    
		wait;
	end process;


end Behavior;