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

-----------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY CPU_Memory IS
    Port(
	clk : IN STD_LOGIC:= 'Z'; 
	reset : IN STD_LOGIC:='0';
    writeEnable : IN STD_LOGIC_VECTOR(3 DOWNTO 0):= "0000";
	MW : IN STD_LOGIC:= '0';
	MR : IN STD_LOGIC:= '0';
	address : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
	writeData : IN STD_LOGIC_VECTOR(31 DOWNTO 0):= (others=>'0');
	readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	switch_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    led_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    ssd_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0')
    );
END CPU_Memory;
    
ARCHITECTURE Behavioral OF CPU_Memory IS
type arr is array(0 to 31) of STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL memory_array : arr:= (
    X"00001EDB", -- initialize data memory          Initial Array
    X"00000000", -- mem 1
    X"00000000", 
    X"00000000",
    X"00000000",
    X"00000000",                     
    X"00000000", 
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000", 
    X"00000000",
    X"00000000",
    X"00000000",                     
    X"00000000", 
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000", 
    X"00000000",
    X"00000000",
    X"00000000",                     
    X"00000000", 
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000",
    X"00000000", 
    X"00000000", -- mem 30
    X"00000000");


BEGIN

readData <= memory_array(to_integer(shift_right(unsigned(address), 2))) WHEN MR = '1' ELSE X"00000000";
led_data <= memory_array(30)(15 DOWNTO 0);
ssd_data <= memory_array(31)(15 DOWNTO 0);

PROCESS(clk)
BEGIN

IF(clk = '1' and clk'EVENT) THEN
	IF writeEnable(0) = '1' AND MW = '1' THEN memory_array(to_integer(shift_right(unsigned(address), 2)))(7 DOWNTO 0) <= writeData(7 DOWNTO 0); END IF;
	IF writeEnable(1) = '1' AND MW = '1' THEN memory_array(to_integer(shift_right(unsigned(address), 2)))(15 DOWNTO 8) <= writeData(15 DOWNTO 8);  END IF;
	IF writeEnable(2) = '1' AND MW = '1' THEN memory_array(to_integer(shift_right(unsigned(address), 2)))(23 DOWNTO 16) <= writeData(23 DOWNTO 16);  END IF;
    IF writeEnable(3) = '1' AND MW = '1' THEN memory_array(to_integer(shift_right(unsigned(address), 2)))(31 DOWNTO 24) <= writeData(31 DOWNTO 24);  END IF;
END IF;

IF(clk='0' and clk'EVENT) THEN
    memory_array(29) <= "0000000000000000"&switch_data;
END IF;

END PROCESS;   
	
END Behavioral;

----------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY CPU_Memory_Instruction IS
    Port(
	address : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
	readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END CPU_Memory_Instruction;
    
ARCHITECTURE Behavioral OF CPU_Memory_Instruction IS
type arr is array(0 to 31) of STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL memory_array : arr:= (
    X"E3A00000", -- initialize data memory          Initial Array
    X"E5901000", -- mem 1
    X"E5801004",
    X"E3A02FFA",
    X"E3A00000",
    X"E0511002",
    X"E2800001",
    X"E1510002",
    X"8AFFFFFB",
    X"E1A09600",
    X"E3A02064",                        
    X"E3A00000",                        -- mov r2, r1
    X"E0511002", -- mem 10              -- add r2, r2, #28
    X"E2800001",                        -- OL : mov r3, r1
    X"E1510002",                        -- IL : ldr r4, [r3,#0]
    X"8AFFFFFB",                        -- ldr r5, [r3,#4]
    X"E1A03400",                        -- cmp r4, r5
    X"E1899003",                        -- blt Exit
    X"E3A0200A",                        -- str r5, [r3, #0]
    X"E3A00000",                        -- str r4, [r3, #4]
    X"E0511002",                        -- Exit : add r3, r3, #4
    X"E2800001",                        -- cmp r3, r2
    X"E1510002", -- mem 20              -- bne IL
    X"8AFFFFFB",                        -- sub r2, r2, #4
    X"E1A03200",                        -- cmp r1, r2
    X"E1899003",                        -- bne OL                    
    X"E1899001", 
    X"E3A00000",
    X"E5809008",
    X"EAFFFFE1",
    X"00000000",
    X"00000000");


BEGIN

readData <= memory_array(to_integer(shift_right(unsigned(address), 2)));
	
END Behavioral;
