LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

ENTITY EX_stage_tb IS
END EX_stage_tb;

ARCHITECTURE behaviour OF EX_stage_tb IS

COMPONENT EX_stage IS
port (clock : in std_logic;
    rs : in std_logic_vector(31 downto 0);
	rt : in std_logic_vector(31 downto 0);
	imm : in std_logic_vector(31 downto 0);
	opcode : in std_logic_vector(5 downto 0);
	src : in std_logic;
	branch: in std_logic;
	mem_wdata : out std_logic_vector(31 downto 0);
	result : out std_logic_vector(31 downto 0);
	taken: out std_logic
  );
END COMPONENT;

CONSTANT clk_period : time := 1 ns;
--The input signals with their initial values
SIGNAL clk: std_logic := '0';
SIGNAL s, t, im : std_logic_vector(31 downto 0);
SIGNAL op : std_logic_vector(5 downto 0);
SIGNAL sel, br, take : std_logic;
SIGNAL wd, res : std_logic_vector(31 downto 0);

BEGIN
dut: EX_stage
PORT MAP(clk, s, t, im, op, sel, br, wd, res, take);

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
	WAIT FOR clk_period;	
	WAIT;
END PROCESS stim_process;
END;
