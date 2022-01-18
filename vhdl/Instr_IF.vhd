----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2021 10:28:50 AM
-- Design Name: 
-- Module Name: Instr_IF - Behavioral
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

entity Instr_IF is
 Port (  clk : in STD_LOGIC;
          en : in STD_LOGIC;
          rst : in STD_LOGIC;
          jump_address : in STD_LOGIC_VECTOR (15 downto 0);
          branch_address : in STD_LOGIC_VECTOR (15 downto 0);
          PCSrc : in STD_LOGIC;
          Jump : in STD_LOGIC;
          Instruction : out STD_LOGIC_VECTOR (15 downto 0);
          PC_plusOne : out STD_LOGIC_VECTOR (15 downto 0));
end Instr_IF;

architecture Behavioral of Instr_IF is
type type_rom is array(0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
signal memory : type_rom := (B"001_000_001_0000100",   --0.addi $1 $0 4     --2082
                             B"000_000_000_010_0_000",  --1.add $2 $0 $0    --0020
                             B"000_000_000_011_0_000", -- 2.add $3 $0 $0    --0030
                             B"000_000_000_100_0_000",  --3.add $4 $0 $0    --0040
                             B"000_000_000_101_0_000",   --4.add $5 $0 $0   --0050
                             B"000_000_000_110_0_000", -- 5.add $6 $0 $0    --0060
                             B"000_000_000_111_0_000", -- 6.add $7 $0 $0    --0070
                             B"100_001_010_1000001", -- 7.beq $2 $1 65(linia 72)  --8541
                             B"001_000_000_0000000", -- 8.addi $0 $0 0 (NoOp) --2000
                             B"001_000_000_0000000",  --9.addi $0 $0 0 (NoOp) --2000
                             B"001_000_000_0000000",   --10.addi $0 $0 0 (NoOp) --2000
                             B"100_001_011_0111001", -- 11.beq $3 $1 57(linia69)  --85B9
                             B"001_000_000_0000000",  --12.addi $0 $0 0 (NoOp) --2000
                             B"001_000_000_0000000",  --13.addi $0 $0 0 (NoOp) --2000
                             B"001_000_000_0000000",  --14.addi $0 $0 0 (NoOp) --2000
                             B"000_010_100_100_0_000", -- 15.add $4 $2 $4    --0A40
                             B"001_000_000_0000000",   --16.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --17.addi $0 $0 0 (NoOp) -2000
                             B"000_010_100_100_0_000", -- 18.add $4 $2 $4   --0A40
                             B"001_000_000_0000000",   --19.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --20.addi $0 $0 0 (NoOp) -2000
                             B"000_010_100_100_0_000", -- 21.add $4 $2 $4   --0A40
                             B"001_000_000_0000000",   --22.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --23.addi $0 $0 0 (NoOp) -2000
                             B"000_010_100_100_0_000", -- 24.add $4 $2 $4   --0A40
                             B"001_000_000_0000000",   --25.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --26.addi $0 $0 0 (NoOp) -2000
                             B"000_011_100_100_0_000", -- 27.add $4 $3 $4   --0E40
                             B"001_000_000_0000000",   --28.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --29.addi $0 $0 0 (NoOp) -2000
                             B"010_100_111_0000000", -- 30.lw $7 0($4)      --5380
                             B"000_000_000_100_0_000", -- 31.add $4 $0 $0   --0040
                             B"001_000_100_0010000", -- 32.addi $4 $0 16    --2210
                             B"001_000_000_0000000", --33.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000", --34.addi $0 $0 0 (NoOp) -2000
                             B"000_010_100_100_0_000", -- 35.add $4 $2 $4   --0A40
                             B"001_000_000_0000000",   --36.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",  --37.addi $0 $0 0 (NoOp)  -2000
                             B"010_100_101_0000000", -- 38.lw $5 0($4)      --5280
                             B"000_100_010_100_0_001", --39.sub &4 $4 $2    --1141
                             B"001_000_000_0000000",   --40.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --41.addi $0 $0 0 (NoOp) -2000
                             B"000_011_100_100_0_000", --42.add $4 $3 $4   --0E40 
                             B"001_000_000_0000000",   --43.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --44.addi $0 $0 0 (NoOp) -2000
                             B"010_100_110_0000000", -- 45.lw $6 0($4)      --5300
                             B"000_101_100_111_0_000", -- 46.add $7 $5 $4   --1670
                             B"001_000_000_0000000",   --47.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --48.addi $0 $0 0 (NoOp) -2000
                             B"000_100_101_111_0_111", -- 49.slt $7 $4 $6   --127F
                             B"001_000_000_0000000",   --50: addi $0 $0 0 (NoOp) - 2000
                             B"001_000_000_0000000",   --51: addi $0 $0 0 (NoOp) -2000
                             B"100_001_111_0001101", -- 52.beq $7 $1 13(linia66)     --878D
                             B"001_000_000_0000000",  --53.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",  --54.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",  --55.addi $0 $0 0 (NoOp) -2000
                             B"000_101_000_100_0_000", -- 56..add $4 $6 $0   --1140
                             B"000_000_000_111_0_000", -- 57.add $7 $0 $0  --0070 
                             B"001_000_111_0010000", -- 58.addi $7 $0 16   --2390
                             B"001_000_000_0000000",   --59.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --60.addi $0 $0 0 (NoOp) -2000
                             B"000_011_111_111_0_000", -- 61.add $7 $3 $7   --0FF0
                             B"001_000_000_0000000",   --62.addi $0 $0 0 (NoOp) -2000
                             B"001_000_000_0000000",   --63.addi $0 $0 0 (NoOp) -2000
                             B"011_111_100_0000000", -- 64.sw $4 0($7)      --7E00
                             B"111_0000000110100", -- 65.j 52               --E034
                             B"001_000_000_0000000",  --66. addi $0 $0 0 (NoOp) - 2000
                             B"001_000_011_0000001", -- 67.addi $3 $0 1     --2181
                             B"111_0000000001011", -- 68.j 11                --E00B
                             B"001_000_000_0000000", --69 addi $0 $0 0 (NoOp) -2000
                             B"001_000_010_0000001", -- 70.addi $2 $0 1     --2101
                             B"111_0000000000111", -- 71.j 7                --E007
                             others => "0000000000000000"); -- 0000
signal PC_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal address : STD_LOGIC_VECTOR(15 downto 0);
signal next_adr : STD_LOGIC_VECTOR(15 downto 0);
signal mux_branch : STD_LOGIC_VECTOR(15 downto 0);
begin

process(clk,en,rst)
begin
if(rst = '1') then
  PC_out <= x"0000";
else 
   if(rising_edge(clk)) then
    if( en = '1') then 
      PC_out <= address;
    end if;
   end if;
end if;
end process;

next_adr <= PC_out + '1';

process(PCsrc, next_adr, branch_address)
begin
case PCsrc is
  when '0' => mux_branch <= next_adr;
  when others => mux_branch <= next_adr;
end case;
end process;

process(Jump, jump_address, mux_branch)
begin
case Jump is
 when '0' => address <= mux_branch;
 when others => address <= Jump_address;
end case; 
end process;

Instruction <= memory(conv_integer(PC_out));
PC_plusOne <= next_adr;

end Behavioral;
