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
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY ALU IS
    Port(
    I1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
    I2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
    OpCode : IN STD_LOGIC_VECTOR(3 DOWNTO 0):="0";
    Cin : IN STD_LOGIC:='0';
    Output : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    N : OUT STD_LOGIC;
    Z : OUT STD_LOGIC;
    C : OUT STD_LOGIC;
    V : OUT STD_LOGIC
    );
END ALU;
    
ARCHITECTURE Behavioral OF ALU IS
SIGNAL sigC : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL one : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL c31 : STD_LOGIC;
SIGNAL c32 : STD_LOGIC;

BEGIN

sigC(0) <= Cin;
one(0) <= '1';
c31 <= I1(31) XOR I2(31) XOR Output(31);
c32 <= (I1(31) AND I2(31)) OR (I1(31) AND c31) OR (I2(31) AND c31); 

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
                  NOT I2 WHEN "1111";
    
    N <= Output(31) WHEN ((opcode(3) = '1') AND ((opcode(2) = '0')));
    Z <= '1' WHEN ((Output = "0") AND ((opcode(3) = '1') AND ((opcode(2) = '0'))));
    C <= c32 WHEN ((opcode(3) = '1') AND ((opcode(2) = '0')) AND (opcode(1) = '1'));
    V <= (c31 XOR c32) WHEN ((opcode(3) = '1') AND ((opcode(2) = '0')) AND (opcode(1) = '1'));                

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
    shiftAmount : IN Unsigned(4 DOWNTO 0)
    );
END Shifter;
    
ARCHITECTURE Behavioral OF Shifter IS
SIGNAL one : Unsigned(31 DOWNTO 0):="0001";

BEGIN

WITH shiftType select
    Output <= STD_LOGIC_VECTOR(shift_left(unsigned(I), to_integer(shiftAmount))) WHEN "00",
              STD_LOGIC_VECTOR(shift_right(unsigned(I), to_integer(shiftAmount))) WHEN "01",
              STD_LOGIC_VECTOR(shift_right(signed(I), to_integer(shiftAmount))) WHEN "10",
              STD_LOGIC_VECTOR(rotate_right(unsigned(I), to_integer(shiftAmount))) WHEN "11";
    C <= I(32 - to_integer(shiftAmount)) WHEN (NOT(shiftAmount = "00") AND shiftType = "00") ELSE
         I(to_integer(shiftAmount) -1) WHEN (NOT(shiftAmount = "00") AND (shiftType = "01" OR shiftType = "10" OR shiftType = "11")) ELSE
         Cin WHEN shiftAmount = "00";
         
END Behavioral;

------------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY Multiplier IS
    Port(
    I1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    I2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    Output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END Multiplier;
    
ARCHITECTURE Behavioral OF Multiplier IS

BEGIN

Output <= STD_LOGIC_VECTOR(signed(I1) * signed(I2));
         
END Behavioral;  

-----------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY Register_File IS
    Port(
    WD : IN STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
    WAD : IN STD_LOGIC_VECTOR(3 DOWNTO 0):="0";
    RAD1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0):="0";
    RAD2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0):="0";   
    RD1: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    RD2: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC:='0';
    reset : IN STD_LOGIC:='0';
    writeEnable : IN STD_LOGIC:='0';
    PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END Register_File;
    
ARCHITECTURE Behavioral OF Register_File IS
type arr is array(15 DOWNTO 0) of STD_LOGIC_VECTOR;
SIGNAL r : arr;

BEGIN

PROCESS(clk, reset)

BEGIN  
       RD1 <= r(to_integer(unsigned(RAD1)));
       RD2 <= r(to_integer(unsigned(RAD2)));
       if(clk = '1' and clk'EVENT) then
           if writeEnable = '1' then
                r(to_integer(unsigned(WAD))) <= WD;
           end if;
           if reset = '1' then
                PC <= "0";
           end if;
       end if;
      
END PROCESS;
END Behavioral; 

-----------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY Processor_Memory IS -- MW, MR need to mapped from Control
    Port(
    IP : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    IM : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    load_store : IN STD_LOGIC;
    byte : IN STD_LOGIC;
    half : IN STD_LOGIC;
    signed_bit : IN STD_LOGIC;
    offset : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    OP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
    OM : OUT STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
    writeEnable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0):="0000"
	MW : IN STD_LOGIC;
	MR : IN STD_LOGIC;
    );
END Processor_Memory;
    
ARCHITECTURE Behavioral OF Processor_Memory IS
SIGNAL writeEnableTemp : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL sign : STD_LOGIC;
SIGNAL OPtemp : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL OMtemp : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

Memory : ENTITY WORK.Memory
	port map(
	clk => clk,
	writeEnable => writeEnable,
	MR => MR,
	MW => MW,
	offset => address,
	IM => writeData,
	OM => readData
	);
writeEnableTemp <=  "0001" WHEN (offset(1 DOWNTO 0) = "00") ELSE
    			  	"0010" WHEN (offset(1 DOWNTO 0) = "01") ELSE
    				"0100" WHEN (offset(1 DOWNTO 0) = "10") ELSE
    				"1000" WHEN (offset(1 DOWNTO 0) = "11");

writeEnable <= 	writeEnableTemp WHEN (byte = '1' AND load_store = '0') ELSE 
    			writeEnableTemp OR STD_LOGIC_VECTOR(shift_left(unsigned(writeEnableTemp), 1)) WHEN (half = '1' AND load_store = '0') ELSE
    			"1111" WHEN (byte = '0' AND half = '0' AND load_store = '0');
     
sign <= IP(7) WHEN (byte = '1' AND load_store = '0' AND signed_bit = '1') ELSE
    	IP(15) WHEN (half = '1' AND load_store = '0' AND signed_bit = '1') ELSE 
    	IP(31) WHEN (byte = '0' AND half = '0' and load_store = '0' AND signed_bit = '1') ELSE
    	IM(7) WHEN (byte = '1' AND load_store = '1' AND signed_bit = '1') ELSE
    	IM(15) WHEN (half = '1' AND load_store = '1' AND signed_bit = '1') ELSE 
    	IM(31) WHEN (byte = '0' AND half = '0' and load_store = '1' AND signed_bit = '1') ELSE
    	'0';
    
OPtemp <= 	(others => '0') WHEN (byte = '0' AND half = '0' and load_store = '1') ELSE
    		(31 DOWNTO 16 => sign) WHEN (half = '1' and load_store = '1') ELSE
    		(31 DOWNTO 8 => sign) WHEN (byte = '1' and load_store = '1');

OP <= OPtemp OR IM WHEN load_store = '1';

OMtemp <= 	(others => '0') WHEN (byte = '0' AND half = '0' and load_store = '0') ELSE
    		(31 DOWNTO 16 => sign) WHEN (half = '1' and load_store = '0') ELSE
    		(31 DOWNTO 8 => sign) WHEN (byte = '1' and load_store = '0');

OM <= OMtemp OR IP WHEN load_store = '0';
    
END Behavioral;

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY CPU_datapath IS
    Port (   
    clk : IN STD_LOGIC;
    DPcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0)
	MW : IN STD_LOGIC;
	MR : IN STD_LOGIC;
    );
END CPU_datapath;

ARCHITECTURE Behavioral OF CPU_datapath IS
SIGNAL four : STD_LOGIC_VECTOR(3 DOWNTO 0):="0100";
SIGNAL IR : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Op1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Op2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Op3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
--shifter
SIGNAL shiftAmount : UNSIGNED(4 DOWNTO 0);
SIGNAL shiftType : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL I : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Output : STD_LOGIC_VECTOR(31 DOWNTO 0);
--register file
SIGNAL PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL WD : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL WAD : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL RAD1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL RAD2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL RD1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL RD2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL writeEnable : STD_LOGIC;
--ALU
SIGNAL I1 : STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
SIGNAL I2 : STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
SIGNAL OpCode : STD_LOGIC_VECTOR(3 DOWNTO 0):="0";
SIGNAL Cin : STD_LOGIC:='0';
SIGNAL OutputALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL N : STD_LOGIC;
SIGNAL Z : STD_LOGIC;
SIGNAL C : STD_LOGIC;
SIGNAL V : STD_LOGIC;
--Processor Memory
SIGNAL IP : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IM : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL load_store : STD_LOGIC;
SIGNAL byte : STD_LOGIC;
SIGNAL half : STD_LOGIC;
SIGNAL signed_bit : STD_LOGIC;
SIGNAL offset : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL OP : STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
SIGNAL OM : STD_LOGIC_VECTOR(31 DOWNTO 0):="0";
SIGNAL writeEnableDM : STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
SIGNAL I1M : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL I2M : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL OutputM : STD_LOGIC_VECTOR(31 DOWNTO 0);
begin

four <= "0100";

Register_File:
ENTITY work.Register_File
port map(
    PC => PC,
    WD => WD,
    WAD => WAD,
    RAD1 => RAD1,
    RAD2 => RAD2,
    RD1 => RD1,
    RD2 => RD2,
    writeEnable => writeEnable
    );
    
Shifter:
ENTITY work.Shifter
port map(
    I => I,
    Output => Output,
    shiftAmount => shiftAmount,
    shiftType => shiftType
    );
    
ALU:
ENTITY work.ALU
port map(
    I1 => I1,
    I2 => I2,
    OpCode => OpCode,
    Cin => Cin,
    Output => OutputALU,
    N => N,
    Z => Z,
    C => C,
    V => V
    );
   
Processor_Memory:
ENTITY work.Processor_Memory
port map(
    IP => IP,
    IM =>IM,
    load_store => load_store,
    byte => byte,
    half => half,
    signed_bit => signed_bit,
    offset => offset,
    OP => OP,
    OM => OM,
    writeEnable => writeEnableDM,
	MW => MW,
	MR => MR
    );
    
Multiplier:
ENTITY work.Multiplier
port map(
    I1 => I1M,
    I2 => I2M,
    Output => OutputM
    );
    
PROCESS(clk)
BEGIN

    IF(clk = '1' and clk'EVENT) THEN
    
        IF DPcode(4 DOWNTO 3) = "00" THEN       --DP
            --Step 1:
            IF DPcode(2 DOWNTO 0) = "000" THEN
				RAD1 <= PC;
                IR <= RD1;
                writeEnable <= '1';
                WAD <= "1111";
                WD <= STD_LOGIC_VECTOR(unsigned(PC)+unsigned(four));
            --Step 2:
            ELSIF DPcode(2 DOWNTO 0) = "001" THEN
                IF NOT(IR(24 DOWNTO 21) = "1101" OR IR(24 DOWNTO 21) = "1111") THEN
                    RAD1 <= IR(19 DOWNTO 16);
                    Op1 <= RD1;
                ELSE
                    Op1 <= "0";
                END IF;
                IF (IR(25) = '0') THEN
                    RAD2 <= IR(3 DOWNTO 0);
                    Op2 <= RD2;
                ELSE
                    Op2 <= IR(7 DOWNTO 0);
                END IF;
            --Step 3:
            ELSIF DPcode(2 DOWNTO 0) = "010" THEN
				IF(IR(25) = '0') THEN
					IF (IR(4) = '1') THEN
						RAD1 <= IR(11 DOWNTO 8);
						shiftAmount <= unsigned(RD1);
					ELSE
						shiftAmount <= unsigned(IR(11 DOWNTO 7));
					END IF;
					shiftType <= IR(6 DOWNTO 5); 
				ELSE
					shiftAmount <= unsigned(IR(11 DOWNTO 8));
					shiftType <= "11";
				END IF;
            --Step 4:
            ELSIF DPcode(2 DOWNTO 0) = "011" THEN
                I <= Op2;
                Op2 <= Output;
            --Step 5:
            ELSIF DPcode(2 DOWNTO 0) = "100" THEN
                OpCode <= IR(24 DOWNTO 21);
                I1 <= Op1;
                I2 <= Op2;
                Cin <= C; 
				IF(IR(24 DOWNTO 21) = "1000" OR IR(24 DOWNTO 21) = "1001") THEN
                    N <= N;
                    Z <= Z;
				ELSIF(IR(20) = '1' OR IR(24 DOWNTO 21) = "1010" OR IR(24 DOWNTO 21) = "1011") THEN
					N <= N;
                    Z <= Z;
					C <= C;
					V <= V;
                END IF;
            --Step 6:
            ELSIF DPcode(2 DOWNTO 0) = "101" THEN
                IF NOT(IR(24 DOWNTO 21) = "1000" OR IR(24 DOWNTO 21) = "1001" OR IR(24 DOWNTO 21) = "1010" OR IR(24 DOWNTO 21) = "1011") THEN
                    writeEnable <= '1';
                    WAD <= IR(15 DOWNTO 12);
                    WD <= OutputALU;
                END IF;
            END IF;       
               
        ELSIF DPcode(4 DOWNTO 3) = "01" THEN    --DT
            --Step 1:
            IF DPcode(2 DOWNTO 0) = "000" THEN
				RAD1 <= PC;
                IR <= RD1;
                writeEnable <= '1';
                WAD <= "1111";
                WD <= STD_LOGIC_VECTOR(unsigned(PC)+unsigned(four));
            --Step 2:
            ELSIF DPcode(2 DOWNTO 0) = "001" THEN
                RAD1 <= IR(19 DOWNTO 16);
                Op1 <= RD1; --base
                IF (IR(25) = '0') THEN
                    RAD2 <= IR(3 DOWNTO 0); --offset
                    Op2 <= RD2;
                ELSE
                    Op2 <= IR(11 DOWNTO 0);
                END IF;
            --Step 3:
            ELSIF DPcode(2 DOWNTO 0) = "010" THEN
				IF(IR(25) = '1') THEN
					IF (IR(4) = '1') THEN
						RAD2 <= IR(11 DOWNTO 8);
						shiftAmount <= unsigned(RD2);
					ELSE
						shiftAmount <= unsigned(IR(11 DOWNTO 7));
					END IF;
					shiftType <= IR(6 DOWNTO 5);
					I <= Op2;
					Op2 <= Output;
				END IF;
				 --shifted offset
            --Step 4:
            ELSIF DPcode(2 DOWNTO 0) = "011" THEN
                 I1 <= Op1;
                 I2 <= Op2;
                 IF (IR(23) = '1') THEN
                    OpCode <= "0100";
                ELSE
                    OpCode <= "0010";
                END IF;
                Op1 <= OutputALU; --base + shifted offset
                IF (IR(20) = '0') THEN
                    RAD2 <= IR(15 DOWNTO 12);
                    Op2 <= RD2; --store val
                END IF;
            --Step 5: -- half separately for control signal
            ELSIF DPcode(2 DOWNTO 0) = "100" THEN
                IF (IR(20) = '1') THEN --load
                    byte <= IR(22);
                    IF (IR(24) = '1') THEN --pre index
                        offset <= Op1;
                        Op2 <= OP;
                    ELSE --post index
                        offset <= RD1;
                        Op2 <= OP;
                    END IF;
                    IF (IR(24) = '0' OR IR(21) = '1') THEN
                        WAD <= IR(19 DOWNTO 16);
                        WD <= Op1;
                        writeEnable <= '1';
                    END IF;
                ELSE -- store
                    byte <= IR(22);
                    RAD1 <= IR(15 DOWNTO 12);
                    IP <= RD1;               
                END IF;
            --Step 6:
            ELSIF DPcode(2 DOWNTO 0) = "101" THEN
                IF (IR(20) = '1') THEN
                    writeEnable <= '1';
                    WAD <= IR(15 DOWNTO 12);
                    WD <= Op2;
                END IF;
            END IF;
                    
        ELSIF DPcode(4 DOWNTO 3) = "10" THEN    --Branch
            --Step 1:
            IF DPcode(2 DOWNTO 0) = "000" THEN
				RAD1 <= PC;
                IR <= RD1;
                writeEnable <= '1';
                WAD <= "1111";
                WD <= STD_LOGIC_VECTOR(unsigned(PC)+unsigned(four));
            --Step 2.1:
            ELSIF DPcode(2 DOWNTO 0) = "001" THEN
                IF (IR(24) = '1') THEN
                   writeEnable <= '1';
                   WAD <= "1110";
                   WD <= PC;
                END IF;
            --Step 2.2: -- two writes not allowed in register file
            ELSIF DPcode(2 DOWNTO 0) = "010" THEN
                IF(IR(24) = '1') THEN
                    writeEnable <= '1';
                    WAD <= "1111";
                    WD <= STD_LOGIC_VECTOR(unsigned(PC)+unsigned(four)); 
                END IF;
            --Step 3:
            ELSIF DPcode(2 DOWNTO 0) = "011" THEN
                writeEnable <= '1';
                WAD <= "1111";
                WD <= STD_LOGIC_VECTOR(unsigned(PC)+unsigned(IR(23 DOWNTO 0)));            
            END IF;
            
        ELSIF DPcode(4 DOWNTO 3) = "11" THEN    --Multiply
            --Step 1:
            IF DPcode(2 DOWNTO 0) = "000" THEN
				RAD1 <= PC;
                IR <= RD1;
                writeEnable <= '1';
                WAD <= "1111";
                WD <= STD_LOGIC_VECTOR(unsigned(PC)+unsigned(four));
            --Step 2:
            ELSIF DPcode(2 DOWNTO 0) = "001" THEN
                RAD1 <= IR(3 DOWNTO 0);
                Op1 <= RD1;
                RAD2 <= IR(11 DOWNTO 8);
                Op2 <= RD2;
			--Step 3:
            ELSIF DPcode(2 DOWNTO 0) = "010" THEN
                IF (IR(21) = '1') THEN
                    RAD2 <= IR(15 DOWNTO 12);
                    Op3 <= RD2;
                END IF;
                I1M <= Op1;
                I2M <= Op2;
                Op1 <= OutputM;
			--Step 4
            ELSIF DPcode(2 DOWNTO 0) = "011" THEN
                IF (IR(21) = '1') THEN
                    I1 <= Op1;
                    I2 <= Op3;
                    Op1 <= OutputALU;
                END IF;
			--Step 5
            ELSIF DPcode(2 DOWNTO 0) = "100" THEN
                writeEnable <= '1';
                WAD <= IR(19 DOWNTO 16);
                WD <= Op1;
            END IF;
        END IF;
    END IF;

END PROCESS;

END Behavioral;
