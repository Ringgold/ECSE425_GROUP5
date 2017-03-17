LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

ENTITY EX_stage_tb IS
END EX_stage_tb;

ARCHITECTURE behaviour OF EX_stage_tb IS

COMPONENT EX_stage IS
port (
    clock : in std_logic;
	  stall: in std_logic;
    rs : in std_logic_vector(31 downto 0);
    rt : in std_logic_vector(31 downto 0);
	  imm : in std_logic_vector(31 downto 0);
	  opcode : in std_logic_vector(5 downto 0);
	  src : in std_logic;									-- src='1' when instru is R and branch; src='0' when instru is I except branch
	  branch: in std_logic;								-- branch='1' when "beq"; branch='0' when "bne"
    pc_in: in integer;
    jump: in std_logic;
    jump_addr: in std_logic_vector(25 downto 0);

	  destination_reg: in std_logic_vector(4 downto 0);
	  write_en: in std_logic;
    mem_read_in: in std_logic;
    mem_write_in: in std_logic;
    wb_src_in: in std_logic;
	  destination_reg_go: out std_logic_vector(4 downto 0);
	  write_en_go: out std_logic;
    mem_read_out: out std_logic;
    mem_write_out: out std_logic;
    wb_src_out: out std_logic;

	  mem_wdata : out std_logic_vector(31 downto 0);
	  result : out std_logic_vector(31 downto 0);
    taken: out std_logic;
    branch_addr: out integer
  );
END COMPONENT;

CONSTANT clk_period : time := 1 ns;
--The input signals with their initial values
SIGNAL clk: std_logic := '0';
SIGNAL ss: std_logic := '0';
SIGNAL s, t, im : std_logic_vector(31 downto 0);
SIGNAL op : std_logic_vector(5 downto 0);
SIGNAL sel, br, j : std_logic;
SIGNAL pc, br_addr: integer;
SIGNAL take: std_logic;
SIGNAL j_addr : std_logic_vector(25 downto 0);
SIGNAL wd, res : std_logic_vector(31 downto 0);

SIGNAL des_reg_in, des_reg_out : std_logic_vector(4 downto 0) := "00000";
SIGNAL wen_in, wen_out, memr_in, memr_out, memw_in, memw_out, wbs_in, wbs_out : std_logic := '0';

BEGIN
dut: EX_stage
PORT MAP(clk, ss, s, t, im, op, sel, br, pc, j, j_addr, des_reg_in, wen_in, memr_in, memw_in, wbs_in, des_reg_out, wen_out, memr_out, memw_out, wbs_out, wd, res, take, br_addr);

 --clock process
clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;
 

stim_process: PROCESS
BEGIN   
	REPORT "start simulating";
	s <= "00000000000000000000000000000100";
	t <= "00000000000000000000000000000001";
	im <= "00000000000000000000000000000010";
	op <= "100000";
	sel <= '0';
	br <= '1';
	pc <= 1;
	j <= '0';
	j_addr <= "00000000000000000000000111";
	
	WAIT FOR clk_period;	
	WAIT;
END PROCESS stim_process;
END;
