library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_stage is
  port(
    clock : in std_logic;
    rs : in std_logic_vector(31 downto 0);
	rt : in std_logic_vector(31 downto 0);
	imm : in std_logic_vector(31 downto 0);
	opcode : in std_logic_vector(5 downto 0);
	src : in std_logic;									-- src='1' when instru is R and branch; src='0' when instru is I except branch
	branch: in std_logic;								-- branch='1' when "beq"; branch='0' when "bne"
	mem_wdata : out std_logic_vector(31 downto 0);
	result : out std_logic_vector(31 downto 0);
	taken: out std_logic	
  );
end EX_stage;

architecture beh of EX_stage is
  signal RD1 : std_logic_vector(31 downto 0);
  signal RD2 : std_logic_vector(31 downto 0);
  signal Immediate : std_logic_vector(31 downto 0);
  signal Mux_src : std_logic;
  signal Mux_res : std_logic_vector(31 downto 0);
  signal Control_op : std_logic_vector(5 downto 0);
  signal Alu_op : std_logic_vector(3 downto 0);
  signal Alu_res : std_logic_vector(31 downto 0);
  signal Alu_zero : std_logic;
  
  component Mux
    port(
		x, y: in std_logic_vector(31 downto 0);
		s: in std_logic;
		output: out std_logic_vector(31 downto 0)
    );
  end component;
  
  component ALU
    port(
      	a, b: in std_logic_vector(31 downto 0);
		op: in std_logic_vector(3 downto 0);
		result: out std_logic_vector(31 downto 0);
		zero: out std_logic
    );
  end component;

  component ALUcontrol
	port (
		opcode: in std_logic_vector(5 downto 0);
		ALU_op: out std_logic_vector(3 downto 0)
	);
  end component;
  
begin
MUX1: MUX port map(RD2, Immediate, Mux_src, Mux_res);
ALU_C: ALUcontrol port map(Control_op, Alu_op);
ALU1: ALU port map(RD1, Mux_res, Alu_op, Alu_res, Alu_zero);

	RD1 <= rs;
	RD2 <= rt;
	Immediate <= imm;
	Mux_src <= src;
	Control_op <= opcode;		
	
	mem_wdata <= RD2;
	result <= Alu_res;
	taken <= '1' when(branch = Alu_zero) else '0';
  
end beh;

      
  
  