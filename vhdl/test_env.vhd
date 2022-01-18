----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2021 10:45:21 AM
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
component MPG 
        Port (en : out STD_LOGIC;
        input : in STD_LOGIC;
        clock : in STD_LOGIC);
    end component;
 component SSD
            Port ( digits : in STD_LOGIC_VECTOR (15 downto 0);
                   clk : in STD_LOGIC;
                   cat : out STD_LOGIC_VECTOR (6 downto 0);
                   an : out STD_LOGIC_VECTOR (3 downto 0));   
        end component;
  component RF
         Port ( clk : in STD_LOGIC;
          RA1 : in STD_LOGIC_VECTOR(2 downto 0);
          RA2 : in STD_LOGIC_VECTOR(2 downto 0);
          WA : in STD_LOGIC_VECTOR(2 downto 0);
          WD : in STD_LOGIC_VECTOR(15 downto 0);
          RegWr : in STD_LOGIC;
          RD1 : out STD_LOGIC_VECTOR(15 downto 0);
          RD2 : out STD_LOGIC_VECTOR(15 downto 0) );
   end component;
   component RAM
         Port ( clk : in STD_LOGIC;
              address : in STD_LOGIC_VECTOR (3 downto 0);
              wd : in STD_LOGIC_VECTOR (15 downto 0);
              RamWr : in STD_LOGIC;
              rd : out STD_LOGIC_VECTOR (15 downto 0) );
   end component;
   component Instr_IF
     Port ( clk : in STD_LOGIC;
            en : in STD_LOGIC;
            rst : in STD_LOGIC;
            jump_address : in STD_LOGIC_VECTOR (15 downto 0);
            branch_address : in STD_LOGIC_VECTOR (15 downto 0);
            PCSrc : in STD_LOGIC;
            Jump : in STD_LOGIC;
            Instruction : out STD_LOGIC_VECTOR (15 downto 0);
            PC_plusOne : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
component Instruction_Decode
    Port ( clk : in STD_LOGIC;
          Instr : in STD_LOGIC_VECTOR (15 downto 0);
          wa: in STD_LOGIC_VECTOR(2 downto 0);
          wd : in STD_LOGIC_VECTOR (15 downto 0);
          RegWrite : in STD_LOGIC;
          ExtOp : in STD_LOGIC;
          rd1_rs : out STD_LOGIC_VECTOR (15 downto 0);
          rd2_rt : out STD_LOGIC_VECTOR (15 downto 0);
          Ext_imm : out STD_LOGIC_VECTOR (15 downto 0);
          func : out STD_LOGIC_VECTOR (2 downto 0);
          sa : out STD_LOGIC);
end component;
         
    component UC
        Port ( Instr : in STD_LOGIC_VECTOR (2 downto 0);
               RegDst : out STD_LOGIC;
               ExtOp : out STD_LOGIC;
               ALUSrc : out STD_LOGIC;
               Branch : out STD_LOGIC;
               NotBranch : out STD_LOGIC;
               Jump : out STD_LOGIC;
               ALUOp : out STD_LOGIC_VECTOR (1 downto 0);
               MemWrite : out STD_LOGIC;
               MemtoReg : out STD_LOGIC;
               RegWrite : out STD_LOGIC);
    end component;
    component EX
            Port ( rd1 : in STD_LOGIC_VECTOR (15 downto 0);
                   ALUSrc : in STD_LOGIC;
                   rd2 : in STD_LOGIC_VECTOR (15 downto 0);
                   Ext_Imm : in STD_LOGIC_VECTOR (15 downto 0);
                   sa : in STD_LOGIC;
                   func : in STD_LOGIC_VECTOR (2 downto 0);
                   ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
                   ALURes : out STD_LOGIC_VECTOR (15 downto 0);
                   Zero : out STD_LOGIC);
         end component;
         
         component MEM
            Port ( clk : in STD_LOGIC;
                   MemWrite : in STD_LOGIC;
                   ALURes_In : in STD_LOGIC_VECTOR (15 downto 0);
                   rd2_rt : in STD_LOGIC_VECTOR (15 downto 0);
                   MemData : out STD_LOGIC_VECTOR (15 downto 0);
                   ALURes_Out : out STD_LOGIC_VECTOR (15 downto 0));
         end component;
         
signal enable1 : STD_LOGIC;   --PCsrc
signal enable2 : STD_LOGIC;   --Jump
signal jump_address: STD_LOGIC_VECTOR (15 downto 0) := x"0002";
signal branch_address: STD_LOGIC_VECTOR (15 downto 0) := x"0004";
signal instruction: STD_LOGIC_VECTOR (15 downto 0);
signal pc_plus_one: STD_LOGIC_VECTOR (15 downto 0);
signal digits: STD_LOGIC_VECTOR (15 downto 0);

signal RegDst : STD_LOGIC;
signal ExtOp : STD_LOGIC;
signal ALUSrc : STD_LOGIC;
signal Branch : STD_LOGIC;
signal NotBranch : STD_LOGIC;
signal PCSrc : STD_LOGIC; 
signal Jump : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR (1 downto 0);
signal MemWrite : STD_LOGIC;
signal MemtoReg : STD_LOGIC;
signal RegWrite : STD_LOGIC;

signal WD_signal : STD_LOGIC_VECTOR(15 downto 0);
signal rd1_rs_signal: STD_LOGIC_VECTOR(15 downto 0);
signal rd2_rt_signal: STD_LOGIC_VECTOR(15 downto 0);
signal ext_immediate_signal: STD_LOGIC_VECTOR(15 downto 0);
signal func_signal: STD_LOGIC_VECTOR(2 downto 0);
signal sa_signal: STD_LOGIC;
signal RegWrite_MPG: STD_LOGIC;
signal write_address_signal: STD_LOGIC_VECTOR(2 downto 0);

signal ALURes_In: STD_LOGIC_VECTOR(15 downto 0);

signal ALURes_Out: STD_LOGIC_VECTOR(15 downto 0);
signal MemData: STD_LOGIC_VECTOR(15 downto 0);
signal MemWrite_ENABLE: STD_LOGIC;
signal RegWrite_enable : STD_LOGIC;
signal Zero: STD_LOGIC;

--pipeline
signal IF_ID: STD_LOGIC_VECTOR(31 downto 0);
signal ID_EX: STD_LOGIC_VECTOR(78 downto 0);
signal EX_MEM: STD_LOGIC_VECTOR(56 downto 0);
signal MEM_WB: STD_LOGIC_VECTOR(36 downto 0);


begin
C1: MPG port map (en => enable1, input => btn(0), clock => clk); 
C2: MPG port map (en => enable2, input => btn(1), clock => clk); 
C3: Instr_IF port map (clk => clk,
                       en => enable1,
                       rst => enable2,
                       jump_address => jump_address,
                       branch_address => branch_address,
                       PCSrc => branch,
                       Jump => Jump,
                       Instruction => instruction,
                       PC_plusOne => pc_plus_one);
                       

--IF/ID                                 
process(clk, enable1, pc_plus_one, Instruction)
   begin
    if(rising_edge(clk)) then
       if(enable1 = '1') then
           IF_ID(31 downto 16) <= pc_plus_one;
           IF_ID(15 downto 0) <= Instruction;
        end if;
    end if;
 end process; 
                             
C4: UC port map ( instr => IF_ID(15 downto 13),
                  RegDst => RegDst,
                  ExtOp => ExtOp,
                  ALUSrc => ALUSrc,
                  Branch => Branch,
                  NotBranch => NotBranch,
                  Jump => Jump,
                  ALUOp => ALUOp,
                  MemWrite => MemWrite,
                  MemtoReg => MemtoReg,
                  RegWrite => RegWrite);
              
C5: Instruction_Decode port map( clk => clk,
                                 instr => IF_ID(15 downto 0),
                                 wa => MEM_WB(2 downto 0),
                                 wd => WD_signal,
                                 RegWrite => RegWrite_MPG,
                                 ExtOp => ExtOp,
                                 rd1_rs => rd1_rs_signal,
                                 rd2_rt => rd2_rt_signal,
                                 Ext_imm => ext_immediate_signal,
                                 func => func_signal,
                                 sa => sa_signal);
                                 
 --RegDst MUX
process(RegDst, IF_ID(9 downto 7), IF_ID(6 downto 4))
    begin
      case RegDst is
          when '0' => write_address_signal <= IF_ID(9 downto 7);
          when '1' => write_address_signal <= IF_ID(6 downto 4);
      end case;
end process;  
       --ID/EX                                 
process(clk, enable1, MemtoReg, RegWrite, MemWrite, Branch, NotBranch, ALUOp, ALUSrc, IF_ID(15 downto 0), rd1_rs_signal, rd2_rt_signal, ext_immediate_signal, func_signal, sa_signal, write_address_signal)
  begin
    if(rising_edge(clk)) then
       if(enable1 = '1') then
            ID_EX(78) <= MemtoReg; --WB
            ID_EX(77) <= RegWrite; --WB
            ID_EX(76) <= MemWrite;  --M
            ID_EX(75) <= Branch;    --M
            ID_EX(74) <= NotBranch; --M
            ID_EX(73 downto 72) <= ALUOp; --EX
            ID_EX(71) <= ALUSrc; --EX
            ID_EX(70 downto 55) <= IF_ID(31 downto 16); --pc_plus_one
            ID_EX(54 downto 39) <= rd1_rs_signal;
            ID_EX(38 downto 23) <= rd2_rt_signal;
            ID_EX(22 downto 7) <= ext_immediate_signal;
            ID_EX(6 downto 4) <= func_signal;
            ID_EX(3) <= sa_signal;
            ID_EX(2 downto 0) <= write_address_signal;
        end if;
      end if;
end process; 
                                              
C6: EX port map ( rd1 => ID_EX(54 downto 39),
                  ALUSrc => ID_EX(71),
                  rd2 => ID_EX(38 downto 23),
                  Ext_Imm => ID_EX(22 downto 7),
                  sa => ID_EX(3),
                  func => ID_EX(6 downto 4),
                  ALUOp => ID_EX(73 downto 72),
                  ALURes => ALURes_In,
                  Zero => Zero);
  --EX/MEM            
process(clk, enable1, ID_EX(78 downto 77), ID_EX(76 downto 74), branch_address, ALURes_In, ID_EX(38 downto 23), ID_EX(2 downto 0))
  begin
    if(rising_edge(clk)) then
      if(enable1 = '1') then
        EX_MEM(56 downto 55) <= ID_EX(78 downto 77); --WB
        EX_MEM(54 downto 52) <= ID_EX(76 downto 74); --M
        EX_MEM(51 downto 36) <= branch_address;
        EX_MEM(35) <= Zero;
        EX_MEM(34 downto 19) <= ALURes_In;
        EX_MEM(18 downto 3) <= ID_EX(38 downto 23);  --rd2_rt_signal
        EX_MEM(2 downto 0) <= ID_EX(2 downto 0);     --write_address_signal  
       end if;
      end if;
end process;

C7: MEM port map ( clk => clk,
                   MemWrite => MemWrite_ENABLE,
                   ALURes_In => EX_MEM(34 downto 19),
                   rd2_rt => EX_MEM(18 downto 3),
                   MemData => MemData,
                   ALURes_Out => ALURes_Out);
                   
--MEM/WB
process(clk)
   begin
     if(rising_edge(clk)) then
        if(enable1 = '1') then
            MEM_WB(36 downto 35) <= EX_MEM(56 downto 55); -- WB
            MEM_WB(34 downto 19) <= MemData;
            MEM_WB(18 downto 3) <= ALURes_Out;
            MEM_WB(2 downto 0) <= EX_MEM(2 downto 0);    --write_address_signal 
         end if;
      end if;
end process;

 
RegWrite_ENABLE <= MEM_WB(35) AND enable1;  
 process(MEM_WB(36), MEM_WB(18 downto 3), MEM_WB(34 downto 19))
   begin
       case MEM_WB(36) is
           when '0' => WD_signal <= MEM_WB(18 downto 3);  --ALURes_Out 
           when '1' => WD_signal <= MEM_WB(34 downto 19); --MemData
       end case;
end process;
                                  
process(sw(7 downto 5),instruction,pc_plus_one,rd1_rs_signal, rd2_rt_signal, WD_signal, ext_immediate_signal, func_signal, sa_signal)
begin
case sw(7 downto 5) is
            when "000" => digits <= Instruction;
            when "001" => digits <= pc_plus_one;
            when "010" => digits <= rd1_rs_signal;
            when "011" => digits <= MemData;
            when "100" => digits <= WD_signal;
            when "101" => digits <= rd2_rt_signal;
            when "110" => digits <= ALURes_Out;
            when others => digits <= ext_immediate_signal;
        end case; 
end process;  
  MemWrite_ENABLE <= EX_MEM(54) AND enable1;
 jump_address <= "000" & IF_ID(12 downto 0);
 branch_address <= ID_EX(70 downto 55) + ID_EX(22 downto 7); 
 PCSrc <= (EX_MEM(53) AND EX_MEM(35)) OR (EX_MEM(52) AND NOT(EX_MEM(35)));
 
SSD1: SSD port map( digits => digits, clk => clk, cat => cat, an => an);

    led(0) <= MemtoReg; 
    led(1) <= MemWrite; 
    led(2) <= Jump; 
    led(3) <= NotBranch; 
    led(4) <= Branch; 
    led(5) <= ALUOp(0); 
    led(6) <= ALUOp(1);
    led(7) <= ALUSrc; 
    led(8) <= ExtOp; 
    led(9) <= RegWrite; 
    led(10) <= RegDst; 
    led(11) <= Zero; 
    led(12) <= MemWrite_ENABLE;
    led(13) <= Instruction(13);
    led(14) <= Instruction(14); 
    led(15) <= Instruction(15);  
    
end Behavioral;
