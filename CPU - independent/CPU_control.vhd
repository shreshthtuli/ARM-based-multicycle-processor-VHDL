library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY CPU_control IS
    Port (   
    clk : IN STD_LOGIC;
	PW : INOUT STD_LOGIC;
	IorD : INOUT STD_LOGIC;
	branch : OUT STD_LOGIC;
	MR : INOUT STD_LOGIC;
	MW : INOUT STD_LOGIC;
	IW : INOUT STD_LOGIC;
	DW : INOUT STD_LOGIC;
	M2R : INOUT STD_LOGIC;
	shift : INOUT STD_LOGIC;
	Rsrc : INOUT STD_LOGIC;
	RW : INOUT STD_LOGIC;
	AW : INOUT STD_LOGIC;
	BW : INOUT STD_LOGIC;
	OW : OUT STD_LOGIC;
	Asrc1 : INOUT STD_LOGIC;
	Asrc2 : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	opc : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	Fset : OUT STD_LOGIC;
	ReW : INOUT STD_LOGIC;
	IR : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
	Flags : IN STD_LOGIC_VECTOR(3 DOWNTO 0):="0000"; -- N Z C V
	control_show : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END CPU_control;

ARCHITECTURE Behavioral OF CPU_control IS
SIGNAL state : STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
SIGNAL p : STD_LOGIC:='1';
SIGNAL multiply_state : STD_LOGIC_VECTOR(3 DOWNTO 0):="1011";
SIGNAL multiply : STD_LOGIC:='0';
SIGNAL destpc : STD_LOGIC:='0';

BEGIN
multiply_state <= "1011";
multiply <= '1' WHEN IR(27 DOWNTO 22) = "000000" AND IR(7 DOWNTO 4) = "1001";
destpc <= '1' WHEN IR(27 DOWNTO 26) = "00" AND IR(15 DOWNTO 12) = "1111";

--Bctrl
p <= 
    '1' WHEN IR(31 DOWNTO 28) = "1110" ELSE
    Flags(2) WHEN IR(31 DOWNTO 28) = "0000" ELSE
    NOT Flags(2) WHEN IR(31 DOWNTO 28) = "0001" ELSE
    Flags(1) WHEN IR(31 DOWNTO 28) = "0010" ELSE
    NOT Flags(1) WHEN IR(31 DOWNTO 28) = "0011" ELSE
    Flags(3) WHEN IR(31 DOWNTO 28) = "0100" ELSE
    NOT Flags(3) WHEN IR(31 DOWNTO 28) = "0101" ELSE
    Flags(0) WHEN IR(31 DOWNTO 28) = "0110" ELSE
    NOT Flags(0) WHEN IR(31 DOWNTO 28) = "0111" ELSE
    Flags(1) AND NOT Flags(2) WHEN IR(31 DOWNTO 28) = "1000" ELSE
    (NOT Flags(1)) OR Flags(2) WHEN IR(31 DOWNTO 28) = "1001" ELSE
    Flags(3) XNOR Flags(0) WHEN IR(31 DOWNTO 28) = "1010" ELSE
    Flags(3) XOR Flags(0) WHEN IR(31 DOWNTO 28) = "1011" ELSE
    (Flags(3) XNOR Flags(0)) AND (NOT Flags(2)) WHEN IR(31 DOWNTO 28) = "1100" ELSE
    (Flags(3) XOR Flags(0)) OR Flags(2) WHEN IR(31 DOWNTO 28) = "1101" ELSE
    '1';   

--Actrl

-- branch
branch <= '1' WHEN state = "1000" ELSE '0';
-- PW
PW <= '1' WHEN (state = "0001" OR state = "1000" OR (state = "1011" AND destpc = '1')) ELSE '0';
--IorD
IorD <= '1' WHEN (state = "0101") ELSE '0' WHEN (state = "0000");
--MR
MR <= IR(20) WHEN (state = "0101") ELSE '1' WHEN (state = "0000" OR state = "0100") ELSE '0';
--MW
MW <= NOT IR(20) WHEN (state = "0101") ELSE '0';
--IW
IW <= '1' WHEN (state = "0000") ELSE '0';
--DW
DW <= '1' WHEN (state = "0101") ELSE '0';
--Rsrc
Rsrc <= '1' WHEN (state = "0100" OR state = "1001") ELSE '0' WHEN(state = "0000" OR state = "0001"); 
--M2R
M2R <= '1' WHEN (state = "0110") ELSE '0' WHEN (state = "0000" OR state = "0101" OR state = "1011"); 
--shift
shift <= IR(25) WHEN (state = "0100") ELSE '1' WHEN(state = "0010" OR state = "0011") ELSE '0' WHEN(state = "0000" OR state = "0001" OR state = "0111" OR state = "1000");
--OW
OW <= '1' WHEN (state = "0010") ELSE '0';
--RW
RW <= IR(21) WHEN(state = "0101") ELSE IR(20) WHEN (state = "0110") ELSE IR(24) WHEN (state = "1000") ELSE '1' WHEN (state = "1011") ELSE '0';
--AW
AW <= '1' WHEN (state = "0001") ELSE '0';
--BW 
BW <= NOT(multiply) WHEN (state = "0001") ELSE '1' WHEN (state = "0100") ELSE IR(21) WHEN (state = "1001") ELSE '0';
--Asrc1
Asrc1 <= '0' WHEN (state = "0000" OR state = "0111") ELSE '1' WHEN (state = "0011" OR state = "0100" OR state = "1010");
--Asrc2
Asrc2 <= "01" WHEN(state = "0000") ELSE "10" WHEN (state = "0100") ELSE "11" WHEN (state = "0111") ELSE "00" WHEN (state = "1010");
--fset
fset <= IR(20) WHEN (state = "1011") ELSE opc(3) AND NOT opc(2) WHEN state = "0011" ELSE '0';
--opc
opc <= "0100" WHEN (state = "0000" OR state = "0111" OR state = "1010") ELSE IR(24 DOWNTO 21) WHEN (state = "0011") ELSE "0100" WHEN (state = "0100" AND IR(23) = '1') ELSE "0010" WHEN (state = "0100" AND IR(23) = '0');   
--ReW
ReW <= '1' WHEN (state = "0000" OR state = "0011" OR state = "0100" OR state = "0111" OR state = "1010") ELSE '0';

control_show <= PW & IorD & MR & MW & IW & DW & M2R & shift & Rsrc & RW & AW & BW & Asrc1 & Asrc2(1) & Asrc2(0)& ReW;

PROCESS(clk)
BEGIN

IF (clk = '1' AND clk'EVENT) THEN 
--variables dependent on state      
--next state
IF(state = "0000" OR state = "0100" OR state = "0101" OR state = "0111" OR state = "1001" OR state = "1010") THEN
    state <= STD_LOGIC_VECTOR(UNSIGNED(state) + 1);
ELSIF(state = "0110" OR state = "1000" OR state = "1011") THEN
    state <= "0000";
ELSIF(state = "0001") THEN
    IF(p = '1' or p = 'U') THEN 
        IF(multiply = '1') THEN 
            state <= "1001";
        ELSE 
            state <= "0010";
        END IF;
    ELSE
        state <= "0000";
    END IF;
ELSIF(state = "0010") THEN
    IF(IR(27 DOWNTO 26) = "00") THEN
        state <= "0011";
    ELSIF(IR(27 DOWNTO 26) = "01") THEN
        state <= "0100";
    ELSE
        state <= "0111";
    END IF;
ELSE
    IF(opc(3 DOWNTO 2) = "10") THEN
        state <= "0000";
    ELSE
        state <= "1011";
    END IF;
END IF;
   
END IF;

END PROCESS;

END Behavioral;