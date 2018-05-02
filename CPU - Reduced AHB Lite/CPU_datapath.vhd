----------------------------------------------------------------------------------
-- Company: Indian Institute of Technology, Delhi, India
-- Engineer: Shreshth Tuli, Shashank Goel
-- 
-- Create Date: 12.02.2018 15:52:42
-- Design Name: ARM Based CPU
-- Module Name: CPU_datapath - Behavioral
-- Project Name: COL216 Lab - Multicycle CPU design
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY ALU IS
    Port(
    I1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    I2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    OpCode : IN STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');
    Cin_Logical : IN STD_LOGIC:='0';
    Cin_Arith : IN STD_LOGIC:='0';
    Multiply : IN STD_LOGIC:='0';
    Output : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    N : OUT STD_LOGIC:='0';
    Z : OUT STD_LOGIC:='0';
    C : OUT STD_LOGIC:='0';
    V : OUT STD_LOGIC:='0'
    );
END ALU;
    
ARCHITECTURE Behavioral OF ALU IS
SIGNAL sigC : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL one : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL c31 : STD_LOGIC;
SIGNAL c32_add : STD_LOGIC;
SIGNAL c32_sub : STD_LOGIC;
SIGNAL c32_rsub : STD_LOGIC;

BEGIN

sigC(0) <= Cin_Arith;
one(0) <= '1';
c31 <= I1(31) XOR I2(31) XOR Output(31);
c32_add <= (I1(31) AND I2(31)) OR (I1(31) AND c31) OR (I2(31) AND c31);
c32_sub <= (NOT I1(31) AND I2(31)) OR (NOT I1(31) AND c31) OR (I2(31) AND c31);
c32_rsub <= (I1(31) AND NOT I2(31)) OR (I1(31) AND c31) OR (NOT I2(31) AND c31);

    WITH opcode SELECT
        Output <= STD_LOGIC_VECTOR(signed(I1(31 DOWNTO 0)) + signed(I2(31 DOWNTO 0))) WHEN "0100",
                  STD_LOGIC_VECTOR(signed(I1(31 DOWNTO 0)) - signed(I2(31 DOWNTO 0))) WHEN "0010",
                  STD_LOGIC_VECTOR(signed(I2(31 DOWNTO 0)) - signed(I1(31 DOWNTO 0))) WHEN "0011",
                  STD_LOGIC_VECTOR(signed(I1(31 DOWNTO 0)) + signed(I2(31 DOWNTO 0)) + signed(sigC)) WHEN "0101",
                  STD_LOGIC_VECTOR(signed(I1(31 DOWNTO 0)) - signed(I2(31 DOWNTO 0)) + signed(sigC) - signed(one)) WHEN "0110",
                  STD_LOGIC_VECTOR(signed(I2(31 DOWNTO 0)) - signed(I1(31 DOWNTO 0)) + signed(sigC) - signed(one)) WHEN "0111",   

                  (I1 AND I2) WHEN "0000",
                  (I1 OR I2) WHEN "1100",
                  (I1 XOR I2) WHEN "0001",
                  (I1 AND (NOT I2)) WHEN "1110",
                  
                  STD_LOGIC_VECTOR(signed(I1(31 DOWNTO 0)) - signed(I2(31 DOWNTO 0))) WHEN "1010",
                  STD_LOGIC_VECTOR(signed(I1(31 DOWNTO 0)) + signed(I2(31 DOWNTO 0))) WHEN "1011",
                  (I1 XOR I2) WHEN "1001",
                  (I1 AND I2) WHEN "1000",
                  
                  I2 WHEN "1101",
                  NOT I2 WHEN "1111",
                  I2 WHEN OTHERS;
    
    N <= Output(31);
    Z <= '1' WHEN (Output = "00000000000000000000000000000000") ELSE '0';
    C <= c32_add WHEN ((opcode = "0100" OR opcode = "0101" OR opcode = "1011") AND Multiply = '0') ELSE NOT c32_sub WHEN ((opcode = "0010" OR opcode = "0110" OR opcode = "1010") AND Multiply = '0') ELSE NOT c32_rsub WHEN ((opcode = "0011" OR opcode = "0111") AND Multiply = '0') ELSE Cin_Logical WHEN Multiply = '0';
    V <= (c31 XOR c32_add) WHEN ((opcode = "0100" OR opcode = "0101" OR opcode = "1011") AND Multiply = '0') ELSE (c31 XOR c32_sub) WHEN ((opcode = "0010" OR opcode = "0110" OR opcode = "1010") AND Multiply = '0') ELSE (c31 XOR c32_rsub) WHEN ((opcode = "0011" OR opcode = "0111") AND Multiply = '0');                

END Behavioral;
    
----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY Shifter IS
    Port(
    I : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    Output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Cin : IN STD_LOGIC:='0';
    C : OUT STD_LOGIC;
    shiftType : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    shiftAmount : IN Unsigned(31 DOWNTO 0)
    );
END Shifter;
    
ARCHITECTURE Behavioral OF Shifter IS
SIGNAL one : Unsigned(31 DOWNTO 0):="00000000000000000000000000000001";

BEGIN

WITH shiftType select
    Output <= STD_LOGIC_VECTOR(shift_left(unsigned(I), to_integer(shiftAmount))) WHEN "00",
              STD_LOGIC_VECTOR(shift_right(unsigned(I), to_integer(shiftAmount))) WHEN "01",
              STD_LOGIC_VECTOR(shift_right(signed(I), to_integer(shiftAmount))) WHEN "10",
              STD_LOGIC_VECTOR(rotate_right(unsigned(I), 2 * to_integer(shiftAmount))) WHEN "11",
              I WHEN OTHERS;
    --C <= I(32 - to_integer(shiftAmount)) WHEN (NOT(shiftAmount = "00") AND shiftType = "00") ELSE
    --     I(to_integer(shiftAmount) -1) WHEN (NOT(shiftAmount = "00") AND (shiftType = "01" OR shiftType = "10" OR shiftType = "11")) ELSE
    --     Cin WHEN shiftAmount = "00";
         
END Behavioral;

------------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY Multiplier IS
    Port(
    I1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    I2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    Output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END Multiplier;
    
ARCHITECTURE Behavioral OF Multiplier IS
SIGNAL Output64 : INTEGER;

BEGIN

Output64 <= to_integer(signed(I1) * signed(I2));
Output <= CONV_STD_LOGIC_VECTOR(Output64,32);
         
END Behavioral;  

-----------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY Register_File IS
    Port(
    WD : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    WAD : IN STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');
    RAD1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');
    RAD2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');   
    RD1: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    RD2: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC:='0';
    reset : IN STD_LOGIC:='0';
    writeEnable : IN STD_LOGIC:='0'
    );
END Register_File;
    
ARCHITECTURE Behavioral OF Register_File IS
type arr is array(0 to 15) of STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL r : arr:= (
    X"00000000", -- initialize registers
    X"00000000", -- mem 1
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000", 
    X"00000000", -- mem 10 
    X"00000000", 
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000");
    
BEGIN
RD1 <= r(to_integer(unsigned(RAD1)));
RD2 <= r(to_integer(unsigned(RAD2)));
PROCESS(clk, reset)
BEGIN  

       if(clk = '1' and clk'EVENT) then
           if writeEnable = '1' then
                r(to_integer(unsigned(WAD))) <= WD;
           end if;
           if reset = '1' then
                r(15) <= (others=>'0');
           end if;
       end if;
      
END PROCESS;
END Behavioral; 

-----------------------------------------------------------  


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY Processor_Memory_Instruction IS -- MW, MR need to mapped from Control
    Port(
    reset : IN STD_LOGIC:='0';
    offsetPM : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'Z');
    OP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0')
    );
END Processor_Memory_Instruction;
    
ARCHITECTURE Behavioral OF Processor_Memory_Instruction IS
COMPONENT CPU_Memory_Instruction 
    PORT( 
    address : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'Z')   
    ); 
END COMPONENT;

BEGIN

--         _PM_      M
--  IP -> |    |  -> IM
--  OP <- |____| <-  OM

Mem: CPU_Memory_Instruction 
PORT MAP(
    address => offsetPM,
    readData => OP
    );
    
END Behavioral;

-----------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY Processor_Memory IS -- MW, MR need to mapped from Control
    Port(
    clk : INOUT STD_LOGIC:='Z';
    reset : IN STD_LOGIC:='0';
    IP : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'Z');
    IM : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=> 'Z');
    load_store : IN STD_LOGIC;
    byte : IN STD_LOGIC:='0';
    half : IN STD_LOGIC:='0';
    signed_bit : IN STD_LOGIC;
    offsetPM : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'Z');
    OP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    OM : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'Z');
    writeEnable : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
	MW : INOUT STD_LOGIC:='Z';
	MR : INOUT STD_LOGIC:='Z';
    switch : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    led : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    ssd : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Processor_Memory;
    
ARCHITECTURE Behavioral OF Processor_Memory IS
SIGNAL writeEnableTemp : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL sign : STD_LOGIC;
SIGNAL OPtemp : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IMtemp : STD_LOGIC_VECTOR(31 DOWNTO 0);
COMPONENT CPU_Memory PORT(
    clk : IN STD_LOGIC; 
    writeEnable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);  
    MW : IN STD_LOGIC;
    MR : IN STD_LOGIC;
    address : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    writeData : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    readData : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'Z');
    reset : IN STD_LOGIC:='0';
	switch_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    led_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    ssd_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0')
    
); END COMPONENT;

BEGIN

--         _PM_      M
--  IP -> |    |  -> IM
--  OP <- |____| <-  OM

Mem: CPU_Memory PORT MAP(
    clk => clk,
    writeEnable => writeEnable,
    MW => MW,
    MR => MR,
    address => offsetPM,
    writeData => IM,
    readData => OM,
    reset => reset,
    ssd_data => ssd,
    switch_data => switch,
    led_data => led
);
	
writeEnableTemp <=  "0001" WHEN (offsetPM(1 DOWNTO 0) = "00") ELSE
    			  	"0010" WHEN (offsetPM(1 DOWNTO 0) = "01") ELSE
    				"0100" WHEN (offsetPM(1 DOWNTO 0) = "10") ELSE
    				"1000" WHEN (offsetPM(1 DOWNTO 0) = "11");

writeEnable <= 	writeEnableTemp WHEN (byte = '1' AND load_store = '0') ELSE 
    			writeEnableTemp OR STD_LOGIC_VECTOR(shift_left(unsigned(writeEnableTemp), 1)) WHEN (half = '1' AND load_store = '0') ELSE
    			"1111" WHEN (byte = '0' AND half = '0' AND load_store = '0');
     
sign <= IP(7) WHEN (byte = '1' AND load_store = '0' AND signed_bit = '1') ELSE
    	IP(15) WHEN (half = '1' AND load_store = '0' AND signed_bit = '1') ELSE 
    	IP(31) WHEN (byte = '0' AND half = '0' and load_store = '0' AND signed_bit = '1') ELSE
    	OM(7) WHEN (byte = '1' AND load_store = '1' AND signed_bit = '1') ELSE
    	OM(15) WHEN (half = '1' AND load_store = '1' AND signed_bit = '1') ELSE 
    	OM(31) WHEN (byte = '0' AND half = '0' and load_store = '1' AND signed_bit = '1') ELSE
    	'0';
    
OPtemp <= 	(others => '0') WHEN (byte = '0' AND half = '0') ELSE
    		(31 DOWNTO 16 => sign, others => '0') WHEN (half = '1') ELSE
    		(31 DOWNTO 8 => sign, others => '0') WHEN (byte = '1');

OP <= OPtemp OR OM;

IM <= IP;
    
END Behavioral;

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY AHB_Lite IS
    Port(
    clk : INOUT STD_LOGIC:='Z';
    HACCESS : IN STD_LOGIC:= '0';
    HRESET : IN STD_LOGIC:= '0';
    HADDR : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    HRDATA  : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    HWDATA : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    HREADY : OUT STD_LOGIC:='1';
    HWRITE : INOUT STD_LOGIC:='1'
    );
END AHB_Lite;
    
ARCHITECTURE Behavioral OF AHB_Lite IS
SIGNAL state : STD_LOGIC_VECTOR(1 DOWNTO 0):= "00";

BEGIN

PROCESS(clk)
BEGIN

IF(clk = '1' AND clk'EVENT) THEN
    IF(state = "00") THEN 
        state <= "01";
    ELSE IF(state = "01") THEN
        HREADY <= '0';
        state <= "10";
    ELSE IF(state = "10") THEN
        HREADY <= '0';
        state <= "11";
    ELSE
        HREADY <= '1';
        IF(HACCESS = '1') THEN
            state <= "00";
        END IF;
    END IF;
END IF;
       
    END IF;
END IF;
  
END PROCESS;
  
END Behavioral;


----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY CPU_datapath IS
    Port (   
    clk : INOUT STD_LOGIC;
    reset : IN STD_LOGIC:='0';
    PW : IN STD_LOGIC:='0';
	IorD : IN STD_LOGIC:='0';
	branch : IN STD_LOGIC:='0';
	MR : INOUT STD_LOGIC:='0';
	MW : INOUT STD_LOGIC:='0';
	IW : IN STD_LOGIC:='0';
	DW : IN STD_LOGIC:='0';
	M2R : IN STD_LOGIC:='0';
	Rsrc : IN STD_LOGIC:='0';
	RW : IN STD_LOGIC:='0';
	AW : IN STD_LOGIC:='0';
	BW : IN STD_LOGIC:='0';
	OW : IN STD_LOGIC:='0';
	Asrc1 : IN STD_LOGIC:='0';
	Asrc2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0):="00";
	shift : IN STD_LOGIC:='0';
	opc : IN STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
	Fset : IN STD_LOGIC:='0';
	ReW : IN STD_LOGIC:='0';
	acc : IN STD_LOGIC;
    busReady : OUT STD_LOGIC;
	IR : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
	Flags : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0):="0000"; --Flag(3) = N, Flag(2) = Z, Flag(1) = C, Flag(0) = V
    switch_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    led_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    ssd_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0')
    );
END CPU_datapath;

ARCHITECTURE Behavioral OF CPU_datapath IS
SIGNAL four : STD_LOGIC_VECTOR(3 DOWNTO 0):="0100";
SIGNAL DR : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL A : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL B : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL PC : STD_LOGIC_VECTOR(31 DOWNTO 0):= X"00000000";
SIGNAL RES : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL multiply : STD_LOGIC:='0';
SIGNAL write_back : STD_LOGIC:='0';
SIGNAL pre_index : STD_LOGIC:='0';
--shifter
SIGNAL shiftAmount : UNSIGNED(31 DOWNTO 0):=(others=>'0');
SIGNAL shiftType : STD_LOGIC_VECTOR(1 DOWNTO 0):=(others=>'0');
SIGNAL I : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL Output : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL shiftOutput : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
--register file
SIGNAL WD : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL WAD : STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');
SIGNAL RAD1 : STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');
SIGNAL RAD2 : STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');
SIGNAL RD1 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL RD2 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
--ALU
SIGNAL I1 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL I2 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL OpCode : STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');
SIGNAL Cin_Logical : STD_LOGIC:='0';
SIGNAL Cin_Arith : STD_LOGIC:='0';
SIGNAL OutputALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL N : STD_LOGIC:='0';
SIGNAL Z : STD_LOGIC:='0';
SIGNAL C : STD_LOGIC:='0';
SIGNAL V : STD_LOGIC:='0';
--Processor Memory Data
SIGNAL IP : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL OP : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL load_store : STD_LOGIC:='1';
SIGNAL byte : STD_LOGIC:='0';
SIGNAL half : STD_LOGIC:='0';
SIGNAL signed_bit : STD_LOGIC:='0';
SIGNAL hs : STD_LOGIC:='0';
SIGNAL offset : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL writeEnableDM : STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
--Processor Memory Instruction
SIGNAL offsetI : STD_LOGIC_VECTOR(31 DOWNTO 0):= (others => '0');
SIGNAL OPI : STD_LOGIC_VECTOR(31 DOWNTO 0):= (others => '0'); 
--Multiplier
SIGNAL I1M : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL I2M : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL OutputM : STD_LOGIC_VECTOR(31 DOWNTO 0);
begin

four <= "0100";

Register_File:
ENTITY work.Register_File
port map(
    clk => clk,
    WD => WD,
    WAD => WAD,
    RAD1 => RAD1,
    RAD2 => RAD2,
    RD1 => RD1,
    RD2 => RD2,
    writeEnable => RW
    );
    
Shifter:
ENTITY work.Shifter
port map(
    I => I,
    Output => Output,
    Cin => Flags(1),
    C => Cin_Logical,
    shiftAmount => shiftAmount,
    shiftType => shiftType
    );
    
ALU:
ENTITY work.ALU
port map(
    I1 => I1,
    I2 => I2,
    OpCode => OpCode,
    Cin_Logical => Cin_Logical,
    Multiply => multiply,
    Output => OutputALU,
    N => N,
    Z => Z,
    C => C,
    V => V
    );
   
Processor_Memory_Instruction:
ENTITY work.Processor_Memory_Instruction
port map(
    OP => OPI,
    offsetPM => offsetI
    );
        
        
Processor_Memory_Data:
ENTITY work.Processor_Memory
port map(
    clk => clk,
    IP => IP,
    OP => OP,
    load_store => load_store,
    byte => byte,
    half => half,
    signed_bit => signed_bit,
    offsetPM => offset,
    writeEnable => writeEnableDM,
	MW => MW,
	MR => MR,
	reset => reset,
    switch => switch_data,
    led => led_data,
    ssd => ssd_data
    );
    
Multiplier:
ENTITY work.Multiplier
port map(
    I1 => I1M,
    I2 => I2M,
    Output => OutputM
    ); 
 
AHB_Lite:
    ENTITY work.AHB_Lite
    PORT MAP(
        clk => clk,
        HREADY => busReady,
        HACCESS => acc
            );
      
  
PC <= (others=>'0') WHEN reset = '1' ELSE RES WHEN PW = '1';
offset <= PC WHEN IorD = '0' ELSE RES WHEN pre_index = '1' ELSE A;
offsetI <= PC;
IP <= B WHEN MW = '1';
IR <= OPI WHEN MR = '1' AND IW = '1';
RAD1 <= IR(19 DOWNTO 16) WHEN multiply = '0' ELSE IR(11 DOWNTO 8);
RAD2 <= IR(11 DOWNTO 8) WHEN shift = '1'
    ELSE IR(3 DOWNTO 0) WHEN Rsrc = '0' 
    ELSE IR(15 DOWNTO 12) WHEN Rsrc = '1';
WAD <= IR(15 DOWNTO 12) WHEN (write_back = '0' and branch = '0' and multiply = '0') OR M2R = '1'
	ELSE IR(19 DOWNTO 16) WHEN branch = '0' OR multiply = '1' OR write_back = '1'
	ELSE "1110" WHEN branch = '1';
DR <= OP WHEN MR = '1' AND DW = '1';
WD <= STD_LOGIC_VECTOR(unsigned(PC) + unsigned(four)) WHEN branch = '1' 
    ELSE DR WHEN M2R = '1' AND RW = '1' 
    ELSE RES WHEN M2R = '0' AND RW = '1';

A <= OutputM WHEN AW = '1' AND multiply = '1' ELSE RD1 WHEN AW = '1';
B <= RD2 WHEN BW = '1' ELSE (others=>'0') WHEN IR(21) = '0' AND multiply = '1';

write_back <= IR(21) WHEN IR(27 DOWNTO 26) = "01";
pre_index <= IR(24) WHEN IR(27 DOWNTO 26) = "01";
load_store <= IR(20) WHEN IR(27 DOWNTO 26) = "01";
--HS
HS <= '1' WHEN (IR(27 DOWNTO 25) = "000" AND IR(7) = '1' AND IR(4) = '1'); 
signed_bit <= IR(6) AND HS;
half <= IR(5) AND HS;
byte <= IR(22) WHEN IR(27 DOWNTO 26) = "01" OR (HS = '1' AND IR(6 DOWNTO 5) = "10");

--multiplier
multiply <= '1' WHEN IR(27 DOWNTO 22) = "000000" AND IR(7 DOWNTO 4) = "1001";
I1M <= RD1 WHEN multiply = '1';
I2M <= RD2 WHEN multiply = '1';

--shift
I <= B WHEN (IR(25) = '0' AND IR(27 DOWNTO 26) = "00") OR (IR(25) = '1' AND IR(27 DOWNTO 26) = "01")
    ELSE "000000000000000000000000" & IR(7 DOWNTO 0);
shiftAmount <= unsigned("0000000000000000000000000000" & IR(11 DOWNTO 8)) WHEN IR(25) = '1' AND IR(27 DOWNTO 26) = "00"
	ELSE unsigned("000000000000000000000000000" & IR(11 DOWNTO 7)) WHEN IR(4) = '0'
	ELSE unsigned(RD2) WHEN IR(4) = '1';
shiftType <= "11" WHEN IR(25)='1' AND IR(27 DOWNTO 26) = "00" 
    ELSE IR(6 DOWNTO 5);
shiftOutput <= Output WHEN OW = '1';

--ALU
OpCode <= opc;
I1 <= PC WHEN Asrc1 = '0' ELSE A WHEN Asrc1 = '1';
I2 <= shiftOutput WHEN shift = '1'
    ELSE B WHEN Asrc2 = "00" 
	ELSE "00000000000000000000000000000100" WHEN Asrc2 = "01" 
	ELSE "00000000000000000000" & IR(11 DOWNTO 0) WHEN Asrc2 = "10"
	ELSE STD_LOGIC_VECTOR(SIGNED("000000" & IR(23 DOWNTO 0) & "00") + SIGNED(four)) WHEN (Asrc2 = "11" AND IR(23) = '0')
	ELSE STD_LOGIC_VECTOR(SIGNED("111111" & IR(23 DOWNTO 0) & "00") + SIGNED(four)) WHEN (Asrc2 = "11" AND IR(23) = '1');
Flags(3) <= N WHEN Fset = '1';
Flags(2) <= Z WHEN Fset = '1';
Flags(1) <= C WHEN Fset = '1';
Flags(0) <= V WHEN Fset = '1';
RES <= OutputALU WHEN ReW = '1';

END Behavioral;
