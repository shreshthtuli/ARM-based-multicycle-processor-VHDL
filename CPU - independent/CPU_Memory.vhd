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
    array_address : IN STD_LOGIC_VECTOR(14 DOWNTO 0):=(others=>'0');
    array_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0')
    );
END CPU_Memory;
    
ARCHITECTURE Behavioral OF CPU_Memory IS
type arr is array(0 to 31) of STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL memory_array : arr:= (
    X"00000001", -- initialize data memory          Initial Array
    X"00000007", -- mem 1
    X"00000006",
    X"00000009",
    X"0000002D",
    X"00000017",
    X"0000000C",
    X"00000008",
    X"00000000",                        -- Array memory location already loaded in r1
    X"E1A02001",                        -- mov r2, r1
    X"E282201C", -- mem 10              -- add r2, r2, #28
    X"E1A03001",                        -- OL : mov r3, r1
    X"E5934000",                        -- IL : ldr r4, [r3,#0]
    X"E5935004",                        -- ldr r5, [r3,#4]
    X"E1540005",                        -- cmp r4, r5
    X"BA000001",                        -- blt Exit
    X"E5835000",                        -- str r5, [r3, #0]
    X"E5834004",                        -- str r4, [r3, #4]
    X"E2833004",                        -- Exit : add r3, r3, #4
    X"E1530002",                        -- cmp r3, r2
    X"1AFFFFF6", -- mem 20              -- bne IL
    X"E2422004",                        -- sub r2, r2, #4
    X"E1510002",                        -- cmp r1, r2
    X"1AFFFFF2",                        -- bne OL
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
array_data <= memory_array(to_integer(unsigned(array_address)));

PROCESS(clk)
BEGIN

IF(clk = '1' and clk'EVENT) THEN
	IF writeEnable(0) = '1' AND MW = '1' THEN memory_array(to_integer(shift_right(unsigned(address), 2)))(7 DOWNTO 0) <= writeData(7 DOWNTO 0); END IF;
	IF writeEnable(1) = '1' AND MW = '1' THEN memory_array(to_integer(shift_right(unsigned(address), 2)))(15 DOWNTO 8) <= writeData(15 DOWNTO 8);  END IF;
	IF writeEnable(2) = '1' AND MW = '1' THEN memory_array(to_integer(shift_right(unsigned(address), 2)))(23 DOWNTO 16) <= writeData(23 DOWNTO 16);  END IF;
    IF writeEnable(3) = '1' AND MW = '1' THEN memory_array(to_integer(shift_right(unsigned(address), 2)))(31 DOWNTO 24) <= writeData(31 DOWNTO 24);  END IF;
END IF;

END PROCESS;    
	
END Behavioral;
