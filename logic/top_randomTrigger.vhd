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
    iRST            : in  std_logic;        --!Main reset
    iEN             : in  std_logic;        --!Enable Comparison between iTHRESHOLD and pseudocasual 32-bit value
    -- Peripherals
    iKEY        : in    std_logic_vector(1 downto 0);   --!2 x Key
    iSW         : in    std_logic_vector(3 downto 0);   --!4 x Switch
    oLED        : out   std_logic_vector(7 downto 0);   --!8 x Led
    -- External Busy
    iEXT_BUSY       : in std_logic;         --!Ignore trigger
    -- Settings
    iTHRESHOLD      : in std_logic_vector(31 downto 0);  --!Threshold to configure trigger rate (low threshold --> High trigger rate)
    iINT_BUSY       : in std_logic_vector(31 downto 0);  --!Ignore trigger for "N" clock cycles after trigger
    iSHAPER_T_ON    : in std_logic_vector(31 downto 0);  --!Length of the pulse trigger
    iFREQ_DIV       : in std_logic_vector(15 downto 0);  --!Slow clock duration (in number of iCLK cycles) to drive PRBS32
    -- Output
    oTRIG           : out std_logic         --!Output trigger
    );
end top_randomTrigger;


--!@copydoc top_randomTrigger.vhd
architecture Behavior of top_randomTrigger is  
  signal sPRBS32Out      : std_logic_vector(31 downto 0);   --!PRBS32 output
  signal sBusyCounter    : std_logic_vector(31 downto 0);   --!Counter for trigger pause
  signal sShaperCounter  : std_logic_vector(31 downto 0);   --!Counter for shaper
  signal sExt_Busy       : std_logic;                       --!Ignore trigger
  signal sThreshold      : std_logic_vector(31 downto 0);   --!Threshold to configure trigger rate
  signal sIntBusy        : std_logic_vector(31 downto 0);   --!Ignore trigger for "N" clock cycles after trigger
  signal sShaperTOn      : std_logic_vector(31 downto 0);   --!Length of the pulse trigger
  signal sTrig           : std_logic;                       --!Output trigger
  signal sSlowClock      : std_logic;                       --!Slow clock for PRBS32
  signal sFreqDiv        : std_logic_vector(15 downto 0);   --!Slow clock duration
  signal sFreqDivDelay   : std_logic_vector(15 downto 0);   --!Slow clock duration (1-CLK delay)
  signal sFreqDivFlag    : std_logic;                       --!iFREQ_DIV[k] /= iFREQ_DIV[k-1]
  signal sFreqDivRst     : std_logic;                       --!Slow clock reset
  signal sLed            : std_logic_vector(7 downto 0);    --!Led signals
  signal sRst            : std_logic;                       --!Reset
  signal sEn             : std_logic;                       --!Enable
  signal sCounter        : std_logic_vector(25 downto 0) := (others => '0');
  signal sClk            : std_logic;
  
begin
  --!Combinatorial assignments
  sExt_Busy       <= '0';          --iEXT_BUSY;    -- Def '0'
  --sThreshold      <= x"7FDA1A40";  --iTHRESHOLD;   -- Def "DDDDDDDD"
  sIntBusy        <= x"00000000";  --iINT_BUSY;    -- Def "0000C350"
  sShaperTOn      <= x"00000032";  --iSHAPER_T_ON; -- Def "005F5E10"
  sFreqDiv        <= x"C350";      --iFREQ_DIV;    -- Def "C350"  --> 1 Hz
  oTRIG           <= sTrig;
  sFreqDivRst     <= sRst or sFreqDivFlag; --iRST or sFreqDivFlag;
  oLED            <= sLed;
  --sRst            <= iRST;
  --sEn             <= iEN;
  sClk            <= iCLK;
  
  pseudocasual_32bit_value : PRBS32
    port map(
      iCLK       => sClk,
      iRST       => sRst,
      iPRBS32_en => sSlowClock,
      oDATA      => sPRBS32Out
      );
      
  slow_clock : clock_divider_2
	generic map(
		pPOLARITY => '1',
    pWIDTH    => 16
		)
	port map(
		iCLK 					    => sClk,
		iRST 					    => sFreqDivRst,
		iEN 					    => '1',
		oCLK_OUT 			    => sSlowClock,
		oCLK_OUT_RISING 	=> open,
		oCLK_OUT_FALLING 	=> open,
    iFREQ_DIV         => iFREQ_DIV,
    iDUTY_CYCLE       => x"0001"
		);
      
  --!comparison between threshold and PRBS32 output
  comp : process (sClk)
  begin
    if (rising_edge(sClk)) then
    
      --!RESET
      if (sRst = '1') then
        sTrig <= '0';
        sShaperCounter <= (others => '0');
      
      elsif (sEn = '1') then
      --!default value
      sShaperCounter <= (others => '0');
      sBusyCounter   <= (others => '0');
        --!TRIGGER ON  
        if (sTrig = '1') then
          if (sShaperCounter < sShaperTOn) then
            sTrig <= '1';
            sShaperCounter <= sShaperCounter + 1;
          else
            sTrig <= '0';
            sBusyCounter <= sBusyCounter + 1;
          end if;
        
        --!TRIGGER OFF  
        elsif (sTrig = '0') then
          if (sBusyCounter < sIntBusy and sBusyCounter > 0) then
            sBusyCounter <= sBusyCounter + 1;
          elsif (sPRBS32Out > sThreshold and (sExt_Busy = '0')) then
            sTrig <= '1';
            sShaperCounter <= sShaperCounter + 1;
          end if;
      
        --!TRIGGER 'X'
        else
          sTrig <= '0';
        end if;
      end if;
    end if;
  end process;
    
  --!delay iFREQ_DIV value
  ffd : process (sClk)
	begin
		if rising_edge(sClk) then
			sFreqDivDelay <= sFreqDiv;
		end if;
	end process;
  
  --!chek for iFREQ_DIV changes
  FREQ_DIV_changes : process (sClk)
  begin
    if rising_edge(sClk) then
      if (sFreqDiv /= sFreqDivDelay) then
        sFreqDivFlag <= '1';
      else
        sFreqDivFlag <= '0';
      end if;
    end if;
  end process;
  
  --!THRESHOLD VALUE
  threshold_proc : process (sClk)
  begin
    if (rising_edge(sClk)) then
      if (iSW(0) = '1') then
        sThreshold      <= x"3B9ACA00";   -- 25%
      elsif (iSW(1) = '1') then
        sThreshold      <= x"77359400";   -- 50%
      elsif (iSW(2) = '1') then
        sThreshold      <= x"B2D05E00";   -- 75%
      elsif (iSW(3) = '1') then
        sThreshold      <= x"EE6B2800";   -- 90%
      else
        sThreshold      <= x"7FDA1A40";   -- 50%
      end if;
    end if;
  end process;
  
  

  --!LED '0' (power on)
  sLed(0)           <= '1';
  sLed(6 downto 3)  <= (others => '0');
  
  --!LED '1' (reset)
  reset_proc : process (sClk)
  begin
    if (rising_edge(sClk)) then
      if (iKEY(1) = '0') then
        sRst    <= '1';
        sLed(1) <= '1';
      else
        sRst    <= '0';
        sLed(1) <= '0';
      end if;
    end if;
  end process;
  
  --!LED '2' (enable)
  enable_proc : process (sClk)
  begin
    if (rising_edge(sClk)) then
      if (iKEY(0) = '1') then
        sEn     <= '1';
        sLed(2) <= '1';
      else
        sEn     <= '0';
        sLed(2) <= '0';
      end if;
    end if;
  end process;
  
  --!LED '7' (trigger)
  led_trig_proc : process (sClk)
  begin
    if (rising_edge(sClk)) then
      if (sTrig = '1') then
        sLed(7)   <= '1';
      else
        sLed(7)   <= '0';
      end if;
    end if;
  end process;
 
 
end Behavior;
