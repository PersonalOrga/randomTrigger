--!@file top_randomTrigger.vhd
--!@brief generate pulse trigger with pseudocasual delay
--!@details (iFREQ_DIV=iINT_BUSY hypothesys), f_avarage_trigger = (1/(SHAPER_T_ON*20*10^-9 + INT_BUSY*20*10^-9)) * ((2^32 - THRESHOLD)/2^32)
--!@setup 
--!         1) --> select SHAPER_T_ON
--!         2) --> select INT_BUSY
--!         3) --> put FREQ_DIV = INT_BUSY
--!         4) --> select THRESHOLD to get the desidered f_avarage_trigger
--!@author Matteo D'Antonio, matteo.dantonio@pg.infn.it
--!@date 09/05/2022


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.paperoPackage.all;
use work.basic_package.all;


--!@copydoc top_randomTrigger.vhd
entity top_randomTrigger is
  port(
    iCLK            : in  std_logic;        --!Main clock
    -- Peripherals
    iKEY        : in    std_logic_vector(1 downto 0);   --!2 x Key
    iSW         : in    std_logic_vector(3 downto 0);   --!4 x Switch
    oLED        : out   std_logic_vector(7 downto 0);   --!8 x Led
    -- Output
    oTRIG           : out std_logic;         --!Trigger
    oSLOW_CLOCK     : out std_logic          --!PRBS32 enable
    );
end top_randomTrigger;


--!@copydoc top_randomTrigger.vhd
architecture Behavior of top_randomTrigger is  
  --!randomTrigger signals
  signal sRst            : std_logic;                       --!Reset
  signal sThreshold      : std_logic_vector(31 downto 0);   --!Threshold to configure trigger rate
  signal sIntBusy        : std_logic_vector(31 downto 0);   --!Ignore trigger for "N" clock cycles after trigger
  signal sShaperTOn      : std_logic_vector(31 downto 0);   --!Length of the pulse trigger
  signal sFreqDiv        : std_logic_vector(31 downto 0);   --!Slow clock duration
  signal sIntTrig        : std_logic;
  signal sTrig           : std_logic;                       --!Output trigger
  signal sTrigSync       : std_logic;                       --!Output trigger flip-flopped
  signal sSlowClock      : std_logic;                       --!Slow clock for PRBS32
  signal sSlowClockSync  : std_logic;                       --!Slow clock for PRBS32 flip-flopped
  
  --!peripherals signals
  signal sLed            : std_logic_vector(7 downto 0);    --!LEDs
  
begin
  --!Trigger parameters
  sIntBusy        <= x"00000008";  --Def "0000C31E" --> 49,950
  sShaperTOn      <= x"00000001";  --Def "00000032" --> 50
  sFreqDiv        <= x"0000000A";  --Def "0000C350" --> 50,000  --> f_avarage_trigger = 1 kHz
  -- sThreshold      <= x"7FDA1A40";  --Def "7FDA1A40"
  threshold_level : process (iCLK)
  begin
    if (rising_edge(iCLK)) then
      if (iSW = 0) then
        sThreshold      <= x"00000000";   -- 0%
      elsif (iSW = 1) then
        sThreshold      <= x"19999999";   -- 10%
      elsif (iSW = 2) then
        sThreshold      <= x"33333333";   -- 20%
      elsif (iSW = 3) then
        sThreshold      <= x"4CCCCCCC";   -- 30%  
      elsif (iSW = 4) then
        sThreshold      <= x"66666666";   -- 40%  
      elsif (iSW = 5) then
        sThreshold      <= x"80000000";   -- 50%  
      elsif (iSW = 6) then
        sThreshold      <= x"99999999";   -- 60%  
      elsif (iSW = 7) then
        sThreshold      <= x"B3333333";   -- 70%  
      elsif (iSW = 8) then
        sThreshold      <= x"CCCCCCCC";   -- 80%  
      elsif (iSW = 9) then
        sThreshold      <= x"E6666666";   -- 90%
      elsif (iSW = 10) then
        sThreshold      <= x"FD70A3D1";   -- 99%
      elsif (iSW = 11) then
        sThreshold      <= x"FFFFFFFF";   -- 100% 
      else
        sThreshold      <= x"80000000";   -- 50%
      end if;
    end if;
  end process;
  
  Trigger_generator : randomTrigger
  port map(
      iCLK            => iCLK,
      iRST            => sRst,
      iEN             => '1',
      iEXT_BUSY       => '0',
      iTHRESHOLD      => sThreshold,
      iINT_BUSY       => sIntBusy,
      iSHAPER_T_ON    => sShaperTOn,
      iFREQ_DIV       => sFreqDiv,
      oTRIG           => sIntTrig,
      oSLOW_CLOCK     => sSlowClock
      );
  
  trig_count : entity work.countGenerator
  generic map(
    pWIDTH    => 8,
    pPOLARITY => '1',
    pLENGTH   => 1
  )
  port map(
    iCLK          => iCLK,
    iRST          => sRst,
    iCOUNT        => sIntTrig,
    iOCCURRENCES  => x"03",
    oPULSE        => sTrig,
    oPULSE_FLAG   => open
  );

  --------------------  L E D  --------------------
  oLED <= sLed;
  --!Power on (LED '0')
  sLed(0)           <= '1';
  sLed(3 downto 2)  <= "00";
  
  --!Reset (LED '1')
  reset_proc : process (iCLK)
  begin
    if (rising_edge(iCLK)) then
      if (iKEY(1) = '0') then
        sRst    <= '1';
        sLed(1) <= '1';
      else
        sRst    <= '0';
        sLed(1) <= '0';
      end if;
    end if;
  end process;
  
  --!Costant trigger (LED '4', LED '5')
  led_cst_trig_proc : process (iCLK)
  begin
    if (rising_edge(iCLK)) then
      if (sRst = '1') then
        sLed(4)   <= '0';
        sLed(5)   <= '0';
      elsif (sSlowClockSync = '1') then
        sLed(4)   <= not sLed(4);
        sLed(5)   <= not sLed(5);
      end if;
    end if;
  end process;
  
  --!Random trigger (LED '6', LED '7')
  led_rnd_trig_proc : process (iCLK)
  begin
    if (rising_edge(iCLK)) then
      if (sTrig = '1') then
        sLed(6)   <= '1';
        sLed(7)   <= '1';
      else
        sLed(6)   <= '0';
        sLed(7)   <= '0';
      end if;
    end if;
  end process;
  
  --------------------  O U T P U  T  --------------------
  oTRIG <= sTrigSync;
  trigger_ffd : sync_stage
    generic map (
      pSTAGES => 2
      )
    port map (
      iCLK  => iCLK,
      iRST  => '0',
      iD    => sTrig,
      oQ    => sTrigSync
      );
  
  oSLOW_CLOCK <= sSlowClockSync;
  SlowClock_ffd : sync_stage
    generic map (
      pSTAGES => 2
      )
    port map (
      iCLK  => iCLK,
      iRST  => '0',
      iD    => sSlowClock,
      oQ    => sSlowClockSync
      );
  
 
end Behavior;
