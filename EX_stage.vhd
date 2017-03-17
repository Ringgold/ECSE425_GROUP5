library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_stage is
  port(
    clock : in std_logic;
	stall: in std_logic;
    rs : in std_logic_vector(31 downto 0);
	rt : in std_logic_vector(31 downto 0);
	imm : in std_logic_vector(31 downto 0);
	opcode : in std_logic_vector(5 downto 0);
	src : in std_logic;									-- src='1' when instru is R and branch; src='0' when instru is I except branch
	branch: in std_logic;								-- branch='1' when "beq"; branch='0' when "bne"
	destination_reg: in std_logic_vector(4 downto 0);
	write_en: in std_logic;

	destination_reg_go: out std_logic_vector(4 downto 0);
	write_en_go: out std_logic;
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

	execution: process(clock)
	begin
		if rising_edge(clock) then
			if (stall='0') then
				destination_reg_go <= destination_reg;
				write_en_go <= write_en;
				RD1 <= rs;
				RD2 <= rt;
				Immediate <= imm;
				Control_op <= opcode;
				Mux_src <= src;
				mem_wdata <= RD2;
				result <= Alu_res;
				taken <= branch xnor Alu_zero;
			end if;	
		end if;
	end process;
  
end beh;

      
  
  
