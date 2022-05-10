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
entity randomTrigger is
  port(
    iCLK            : in  std_logic;        --!Main clock
    iRST            : in  std_logic;        --!Main reset
    iEN             : in  std_logic;        --!Enable Comparison between iTHRESHOLD and pseudocasual 32-bit value
    -- External Busy
    iEXT_BUSY       : in std_logic;         --!Ignore trigger
    -- Settings
    iTHRESHOLD      : in std_logic_vector(31 downto 0);  --!Threshold to configure trigger rate (low threshold --> High trigger rate)
    iINT_BUSY       : in std_logic_vector(31 downto 0);  --!Ignore trigger for "N" clock cycles after trigger
    iSHAPER_T_ON    : in std_logic_vector(31 downto 0);  --!Length of the pulse trigger
    iFREQ_DIV       : in std_logic_vector(31 downto 0);  --!Slow clock duration (in number of iCLK cycles) to drive PRBS32
    -- Output
    oTRIG           : out std_logic;   --!Trigger
    oSLOW_CLOCK     : out std_logic    --!PRBS32 enable (or trigger with costant frequency)
    );
end randomTrigger;


--!@copydoc top_randomTrigger.vhd
architecture Behavior of randomTrigger is  
  signal sPRBS32Out      : std_logic_vector(31 downto 0);   --!PRBS32 output
  signal sBusyCounter    : std_logic_vector(31 downto 0);   --!Counter for trigger pause
  signal sShaperCounter  : std_logic_vector(31 downto 0);   --!Counter for shaper
  signal sTrig           : std_logic;                       --!Output trigger
  signal sSlowClock      : std_logic;                       --!Slow clock for PRBS32
  signal sFreqDiv        : std_logic_vector(31 downto 0);   --!Slow clock duration
  signal sFreqDivDelay   : std_logic_vector(31 downto 0);   --!Slow clock duration (1-CLK delay)
  signal sFreqDivFlag    : std_logic;                       --!iFREQ_DIV[k] /= iFREQ_DIV[k-1]
  signal sFreqDivRst     : std_logic;                       --!Slow clock reset
  
begin
  --!Combinatorial assignments
  sFreqDiv        <= iFREQ_DIV;
  sFreqDivRst     <= iRST or sFreqDivFlag;
  oTRIG           <= sTrig;
  oSLOW_CLOCK     <= sSlowClock;
  
  pseudocasual_32bit_value : PRBS32
    port map(
      iCLK       => iCLK,
      iRST       => iRST,
      iPRBS32_en => sSlowClock,
      oDATA      => sPRBS32Out
      );
      
  slow_clock : clock_divider_2
	generic map(
		pPOLARITY => '1',
    pWIDTH    => 32
		)
	port map(
		iCLK 					    => iCLK,
		iRST 					    => sFreqDivRst,
		iEN 					    => '1',
		oCLK_OUT 			    => sSlowClock,
		oCLK_OUT_RISING 	=> open,
		oCLK_OUT_FALLING 	=> open,
    iFREQ_DIV         => iFREQ_DIV,
    iDUTY_CYCLE       => x"00000001"
		);
      
  --!comparison between threshold and PRBS32 output
  comp : process (iCLK)
  begin
    if (rising_edge(iCLK)) then
    
      --!RESET
      if (iRST = '1') then
        sTrig <= '0';
        sShaperCounter <= (others => '0');
      
      elsif (iEN = '1') then
      --!default value
      sShaperCounter <= (others => '0');
      sBusyCounter   <= (others => '0');
        --!TRIGGER ON  
        if (sTrig = '1') then
          if (sShaperCounter < iSHAPER_T_ON) then
            sTrig <= '1';
            sShaperCounter <= sShaperCounter + 1;
          else
            sTrig <= '0';
            sBusyCounter <= sBusyCounter + 1;
          end if;
        
        --!TRIGGER OFF  
        elsif (sTrig = '0') then
          if (sBusyCounter < iINT_BUSY and sBusyCounter > 0) then
            sBusyCounter <= sBusyCounter + 1;
          elsif (sPRBS32Out > iTHRESHOLD and (iEXT_BUSY = '0')) then
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
  ffd : process (iCLK)
	begin
		if rising_edge(iCLK) then
			sFreqDivDelay <= sFreqDiv;
		end if;
	end process;
  
  --!chek for iFREQ_DIV changes
  FREQ_DIV_changes : process (iCLK)
  begin
    if rising_edge(iCLK) then
      if (sFreqDiv /= sFreqDivDelay) then
        sFreqDivFlag <= '1';
      else
        sFreqDivFlag <= '0';
      end if;
    end if;
  end process;
  
 
end Behavior;
