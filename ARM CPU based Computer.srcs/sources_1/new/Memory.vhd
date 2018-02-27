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

ENTITY Memory IS
    Port(
	clk : IN STD_LOGIC; 
    writeEnable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	MW : IN STD_LOGIC;
	MR : IN STD_LOGIC;
	address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	writeData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    );
END Memory;
    
ARCHITECTURE Behavioral OF Memory IS
type memory_array is array(32767 DOWNTO 0) of STD_LOGIC_VECTOR;

readData <= memory_array(to_integer(unsigned(address))) WHEN MR = '1' AND MW = '0';

PROCESS(clk)
BEGIN

IF(clk = '1' and clk'EVENT) THEN
	memory_array(to_integer(unsigned(address)))(7 DOWNTO 0) <= writeData(7 DOWNTO 0) WHEN writeEnable(0) = '1' AND MW = '1' AND MR = '0';
	memory_array(to_integer(unsigned(address)))(15 DOWNTO 8) <= writeData(15 DOWNTO 8) WHEN writeEnable(1) = '1' AND MW = '1' AND MR = '0';
	memory_array(to_integer(unsigned(address)))(23 DOWNTO 16) <= writeData(23 DOWNTO 16) WHEN writeEnable(2) = '1' AND MW = '1' AND MR = '0';
	memory_array(to_integer(unsigned(address)))(31 DOWNTO 24) <= writeData(31 DOWNTO 24) WHEN writeEnable(3) = '1' AND MW = '1' AND MR = '0';
END IF;

END PROCESS;    
	
END Behavioral;
