--------------------------------------------------------------------------------
-- Company: Indian Institute of Technology, Delhi, India
-- Engineer: Shreshth Tuli, Shashank Goel
-- 
-- Create Date: 07.03.2018 20:34:42
-- Design Name: ARM Based CPU
-- Module Name: CPU_datapath_tb - Behavioral
-- Project Name: COL216 Lab - Multicycle CPU design
-- Revision:
-- Revision 0.01 - File Created
-- 
-- VHDL Test Bench Created by ISE for module: CPU_datapath
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY  CPU_datapath_tb_ldr IS
END CPU_datapath_tb_ldr;
 
ARCHITECTURE BEHAVIOR OF CPU_datapath_tb_ldr IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CPU_datapath
    PORT(
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
         IR : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
         Flags : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0)
         );
    END COMPONENT;
    
    COMPONENT Register_File
    PORT(
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
    END COMPONENT;
    
    COMPONENT CPU_Memory
    PORT(
         clk : IN STD_LOGIC; 
         writeEnable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         MW : IN STD_LOGIC;
         MR : IN STD_LOGIC;
         address : IN STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
         writeData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;
    
   --Inputs
   SIGNAL reset : STD_LOGIC := '0';
   SIGNAL PW : STD_LOGIC := '0';
   SIGNAL IorD : STD_LOGIC := '0';
   SIGNAL branch : STD_LOGIC := '0';
   SIGNAL IW : STD_LOGIC := '0';
   SIGNAL DW : STD_LOGIC := '0';
   SIGNAL M2R : STD_LOGIC := '0';
   SIGNAL Rsrc : STD_LOGIC := '0';
   SIGNAL RW : STD_LOGIC := '0';
   SIGNAL AW : STD_LOGIC := '0';
   SIGNAL BW : STD_LOGIC := '0';
   SIGNAL OW : STD_LOGIC := '0';
   SIGNAL Asrc1 : STD_LOGIC := '0';
   SIGNAL Asrc2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
   SIGNAL shift : STD_LOGIC := '0';
   SIGNAL opc : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
   SIGNAL fset : STD_LOGIC := '0';
   SIGNAL ReW : STD_LOGIC := '0';
   --InOuts
   SIGNAL clk : STD_LOGIC := '0';
   SIGNAL MR : STD_LOGIC := '0';
   SIGNAL MW : STD_LOGIC := '0';
   SIGNAL IR : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others=>'0');
   SIGNAL Flags : STD_LOGIC_VECTOR(3 DOWNTO 0);
   
   --Outputs

   -- Clock period definitions
   CONSTANT clk_period : TIME := 10 ns;
    
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut1: CPU_datapath PORT MAP (
          clk => clk,
          reset => reset,
          PW => PW,
          IorD => IorD,
          branch => branch,
          MR => MR,
          MW => MW,
          IW => IW,
          DW => DW,
          M2R => M2R,
          Rsrc => Rsrc,
          RW => RW,
          AW => AW,
          BW => BW,
          OW => OW,
          Asrc1 => Asrc1,
          Asrc2 => Asrc2,
          shift => shift,
          opc => opc,
          fset => fset,
          ReW => ReW,
          IR => IR,
          Flags => Flags
        );

   -- Clock process definitions
   clk_process : PROCESS
   BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
   END PROCESS;
 

   -- Stimulus process
   stim_proc: PROCESS
        
   BEGIN        
    -- add r0, r1, #1, ROR #2
        -------------------------------------------------------------
      ---------------------  Stage 1 -------------------------------
        -------------------------------------------------------------
        
        MR <= '1';
        IW <= '1';
        Asrc2 <= "01";
        opc <= "0100";
        ReW <= '1';
        
        WAIT FOR clk_period;    
    
-------------------------------------------end-stage 1----------------------------------------------------


        -------------------------------------------------------------
      ---------------------  Stage 2 -------------------------------
        -------------------------------------------------------------
        
        MR <= '0';
        IW <= '0';
        PW <= '1';
        ReW <= '0';
        AW <= '1';
        BW <= '1';
        
        WAIT FOR clk_period;    
    
---------------------------------------------end-stage 2--------------------------------------------    
        
        -------------------------------------------------------------
      ---------------------  Stage 3 -------------------------------
        -------------------------------------------------------------
        
        PW <= '0';
        AW <= '0';
        BW <= '0';
        shift <= '1';
        OW <= '1';
        
        WAIT FOR clk_period;    
    
-------------------------------------------------------end-stage 3------------------------------------------------------------    
    
        -------------------------------------------------------------
      ---------------------  Stage 4 -------------------------------
        -------------------------------------------------------------
        
        shift <= '0';
        OW <= '0';
        BW <= '1';
        Rsrc <= '1';
        
        WAIT FOR clk_period;    
    
-----------------------------------------------------end-stage 4----------------------------------------------------    

        -------------------------------------------------------------
      ---------------------  Stage 5 -------------------------------
        -------------------------------------------------------------
        
        ReW <= '1';
        Asrc1 <= '1';
        shift <= '1';
        BW <= '0';
        
        WAIT FOR clk_period;    
    
-------------------------------------------------end-stage 5------------------------------------------------------

        -------------------------------------------------------------
      ---------------------  Stage 6 -------------------------------
        -------------------------------------------------------------
        
        ReW <= '0';
        RW <= '1';
        M2R <= '1';
        IorD <= '1';
        MR <= '1';
        DW <= '1';
        
        WAIT FOR clk_period;  

        -------------------------------------------------------------
      ---------------------  Stage 7 -------------------------------
        -------------------------------------------------------------  
        M2R <= '0';
        MR <= '0';
        DW <= '0';
        
        
        WAIT FOR clk_period;  
        
        assert false
        report "simulation ended"
        severity failure;  
    
-------------------------------------------------end-stage 6------------------------------------------------------
       
   END PROCESS;

END;
