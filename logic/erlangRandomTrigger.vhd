--!@file top_randomTrigger.vhd
--!@brief generate pulse trigger with pseudocasual delay
--!@details (iFREQ_DIV=iINT_BUSY hypothesys), f_avarage_trigger = (1/(SHAPER_T_ON*20*10^-9 + INT_BUSY*20*10^-9)) * ((2^32 - THRESHOLD)/2^32)
--!@setup 
--!         1) --> select SHAPER_T_ON
--!         2) --> select INT_BUSY
--!         3) --> put FREQ_DIV = INT_BUSY
--!         4) --> select THRESHOLD to get the desidered f_avarage_trigger
--!@author Matteo D'Antonio, matteo.dantonio@pg.infn.it
--!@author Mattia Barbanera, mattia.barbanera@infn.it
--!@author Luca Tosti, luca.tosti@pg.infn.it
--!@date 09/05/2022


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.paperoPackage.all;
use work.basic_package.all;


--!@copydoc erlangRandomTrigger.vhd
entity erlangRandomTrigger is
  port(
    -- Main
    iCLK            : in std_logic;                       --!Clock
    iRST            : in std_logic;                       --!Reset
    iEN             : in std_logic;                       --!randomTrigger module enable
    -- External Busy
    iEXT_BUSY       : in std_logic;                       --!Ignore trigger
    -- Trigger Property    
    iTHRSH_LEVEL    : in std_logic_vector(31 downto 0);   --!Threshold to generate trigger by randomTrigger module [0 - 12]
    iPULSE_WIDTH    : in std_logic_vector(31 downto 0);   --!Length of the random trigger pulse
    iSHAPE_FACTOR   : in std_logic_vector(31 downto 0);   --!Statistic distribution: K=1 -> Exponential, K=8 -> Gaussian
    iFREQ_DIV       : in std_logic_vector(31 downto 0);   --!Period of periodic (in number of iCLK cycles) and comparison frequency for randomTrigger
    iDUTY_CYCLE     : in std_logic_vector(31 downto 0);   --!Duty cycle of periodic trigger (in number of iCLK cycles)
    -- Output
    oTRIG           : out std_logic;                      --!Trigger
    oSLOW_CLOCK     : out std_logic                       --!Periodic trigger
    );
end erlangRandomTrigger;


--!@copydoc erlangRandomTrigger.vhd
architecture Behavior of erlangRandomTrigger is  
  --!randomTrigger signals
  signal sThreshold      : std_logic_vector(31 downto 0);   --!Threshold to configure trigger rate
  signal sIntTrig        : std_logic;
  signal sTrig           : std_logic;                       --!Output trigger
  signal sSlowClock      : std_logic;                       --!Slow clock for PRBS32
  
  
begin
  --!Combinatorial assignment
  oTRIG           <= sTrig;
  oSLOW_CLOCK     <= sSlowClock
  sShaperTOn      <= x"00000001";  --Def "00000032" --> 50
  sFreqDiv        <= x"0000000A";  --Def "0000C350" --> 50,000  --> f_avarage_trigger = 1 kHz
  
  
  threshold_level : process (iCLK)
  begin
    if (rising_edge(iCLK)) then
      if (iTHRSH_LEVEL = 0) then
        sThreshold      <= x"00000000";   -- 0%
      elsif (iTHRSH_LEVEL = 1) then
        sThreshold      <= x"19999999";   -- 10%
      elsif (iTHRSH_LEVEL = 2) then
        sThreshold      <= x"33333333";   -- 20%
      elsif (iTHRSH_LEVEL = 3) then
        sThreshold      <= x"4CCCCCCC";   -- 30%  
      elsif (iTHRSH_LEVEL = 4) then
        sThreshold      <= x"66666666";   -- 40%  
      elsif (iTHRSH_LEVEL = 5) then
        sThreshold      <= x"80000000";   -- 50%  
      elsif (iTHRSH_LEVEL = 6) then
        sThreshold      <= x"99999999";   -- 60%  
      elsif (iTHRSH_LEVEL = 7) then
        sThreshold      <= x"B3333333";   -- 70%  
      elsif (iTHRSH_LEVEL = 8) then
        sThreshold      <= x"CCCCCCCC";   -- 80%  
      elsif (iTHRSH_LEVEL = 9) then
        sThreshold      <= x"E6666666";   -- 90%
      elsif (iTHRSH_LEVEL = 10) then
        sThreshold      <= x"FFFFFFFF";   -- 100% 
      else
        sThreshold      <= x"80000000";   -- 50%
      end if;
    end if;
  end process;
  
  Trigger_generator : randomTrigger
  port map(
      iCLK            => iCLK,
      iRST            => iRST,
      iEN             => iEN,
      iEXT_BUSY       => iEXT_BUSY,
      iTHRESHOLD      => sThreshold,
      iINT_BUSY       => x"00000001",
      iSHAPER_T_ON    => iDUTY_CYCLE,
      iFREQ_DIV       => iFREQ_DIV,
      oTRIG           => sIntTrig,
      oSLOW_CLOCK     => sSlowClock
      );
  
  trig_count : entity work.countGenerator
  generic map(
    pWIDTH    => 32,
    pPOLARITY => '1',
    pLENGTH   => iPULSE_WIDTH
  )
  port map(
    iCLK          => iCLK,
    iRST          => iRST,
    iCOUNT        => sIntTrig,
    iOCCURRENCES  => iSHAPE_FACTOR,
    oPULSE        => sTrig,
    oPULSE_FLAG   => open
  );
  
 
end Behavior;
