library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;
use IEEE.NUMERIC_STD.ALL;

ENTITY CPU IS
    Port (   
	clk : INOUT STD_LOGIC;
    HWDATA : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    HRDATA : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'Z');
    HADDR : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
    switch_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    led_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    ssd_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0');
    load_store : INOUT STD_LOGIC:='Z';
    busReady : INOUT STD_LOGIC:='Z';
    writeEnableAHB : INOUT STD_LOGIC:='Z';
    accControl : INOUT STD_LOGIC:='Z'
    );
END CPU;

ARCHITECTURE Behavioral OF CPU IS
SIGNAL reset : STD_LOGIC:='0';
SIGNAL PW : STD_LOGIC;
SIGNAL IorD : STD_LOGIC;
SIGNAL branch : STD_LOGIC;
SIGNAL MR : STD_LOGIC;
SIGNAL MW : STD_LOGIC;
SIGNAL IW : STD_LOGIC;
SIGNAL DW : STD_LOGIC;
SIGNAL M2R : STD_LOGIC;
SIGNAL shift : STD_LOGIC;
SIGNAL Rsrc : STD_LOGIC;
SIGNAL RW : STD_LOGIC;
SIGNAL AW : STD_LOGIC;
SIGNAL BW : STD_LOGIC;
SIGNAL OW : STD_LOGIC;
SIGNAL Asrc1 : STD_LOGIC;
SIGNAL Asrc2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL opc : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Fset : STD_LOGIC:='0';
SIGNAL ReW : STD_LOGIC;
SIGNAL IR : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
SIGNAL Flags : STD_LOGIC_VECTOR(3 DOWNTO 0):="0000"; -- N Z C V


BEGIN

CPU_datapath:
ENTITY work.CPU_datapath
port map(clk, reset, PW, IorD, branch, MR, MW, IW, DW, M2R, Rsrc, RW, AW, BW, OW, Asrc1, Asrc2, shift, opc, Fset, Rew, IR, Flags, HRDATA, HWDATA, load_store, HADDR, switch_data,led_data,ssd_data);

CPU_control:
ENTITY work.CPU_control
port map(clk, PW, IorD, branch, MR, MW, IW, DW, M2R, shift, Rsrc,  RW, AW, BW, OW, Asrc1, Asrc2, opc, Fset, Rew, accControl, writeEnableAHB, busReady, IR, Flags);

END Behavioral;