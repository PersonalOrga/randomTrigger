--!@file PRBS32_sr.vhd
--!@brief Linear-feedback shift register implementation of a PRBS32 algorithm
--!@brief with polynomial x^32 + x^7 + x^5 + x^3 + x^2 + x^1 + 1
--!@author Matteo D'Antonio, matteo.dantonio@studenti.unipg.it
--!@author Mattia Barbanera, mattia.barbanera@infn.it

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.paperoPackage.all;


--!@copydoc PRBS32_sr.vhd
entity PRBS32_sr is
  generic(
    pINIT : std_logic_vector(31 downto 0) := x"FFFFFFFF"
  );
  port(
    iCLK  : in  std_logic;
    iRST  : in  std_logic;
    iEN   : in  std_logic;
    oPRBS : out std_logic_vector(31 downto 0)
  );
end PRBS32_sr;

--!@copydoc PRBS32_sr.vhd
architecture Behavior of PRBS32_sr is
  signal sLfsr  : std_logic_vector(31 downto 0);  -- Linear-Feedback shift register
  signal sXor   : std_logic; --XOR result of the taps

begin
  --Combinatorial assignments
  oPRBS <= sLfsr;

  --Linear feedback shift register
  LFSR : process (iCLK)
	begin
		if rising_edge(iCLK) then
      if (iRST = '1') then
        sLfsr <= pINIT;
      elsif (iEN = '1') then
        sLfsr(sLfsr'left downto 1) <= sLfsr(sLfsr'left-1 downto 0);
        sLfsr(0) <= sXor;
      end if;
		end if;
	end process;

  
  --x"80000057"
  --XOR taps decided by the polinomial. For PRBS-32, we use:
  --  x^32 + x^7 + x^5 + x^3 + x^2 + x^1 + 1
  --which corresponds to the taps:
  --  31, 6, 4, 2, 1, 0
  --sXor <= sLfsr(31) xor sLfsr(6)
  --         xor sLfsr(4)  xor sLfsr(2)
  --         xor sLfsr(1) xor sLfsr(0)
  --        ;
          
  --x"b2457a93" -> 
  --31, 29, 28, 25, 22, 18, 16, 14, 13, 12, 11, 9, 7, 4, 1, 0
  sXor <= sLfsr(31) xor sLfsr(29) xor sLfsr(28) xor sLfsr(25) xor
          sLfsr(22) xor sLfsr(18) xor sLfsr(16) xor sLfsr(14) xor
          sLfsr(13) xor sLfsr(12) xor sLfsr(11) xor sLfsr(9) xor
          sLfsr(7) xor sLfsr(4) xor sLfsr(1) xor sLfsr(0)
          ;

end Behavior;
