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
    pc_in: in integer := 0;
    jump: in std_logic;
    jump_addr: in std_logic_vector(25 downto 0);

	  destination_reg: in std_logic_vector(4 downto 0);
	  write_en: in std_logic := '0';
    mem_read_in: in std_logic;
    mem_write_in: in std_logic;
    wb_src_in: in std_logic;
	  destination_reg_go: out std_logic_vector(4 downto 0);
	  write_en_go: out std_logic := '0';
    mem_read_out: out std_logic;
    mem_write_out: out std_logic;
    wb_src_out: out std_logic;

	  mem_wdata : out std_logic_vector(31 downto 0);
	  result : out std_logic_vector(31 downto 0) := (others => '0');
    taken: out std_logic;
    branch_addr: out integer
  );
end EX_stage;

architecture beh of EX_stage is
  signal RD1 : std_logic_vector(31 downto 0);
  signal RD2 : std_logic_vector(31 downto 0);
  signal Immediate : std_logic_vector(31 downto 0);
  signal Mux1_src : std_logic;
  signal Mux1_res : std_logic_vector(31 downto 0);
  signal Control_op : std_logic_vector(5 downto 0);
  signal Alu_op : std_logic_vector(3 downto 0);
  signal Alu_res : std_logic_vector(31 downto 0);
  signal Alu_zero : std_logic;
  signal Branch_taken : std_logic;

  signal PC : std_logic_vector(31 downto 0);
  signal Imm_add : std_logic_vector(31 downto 0);
  signal J_addr : std_logic_vector(31 downto 0);
  signal B_addr : std_logic_vector(31 downto 0);
  signal Mux2_res : std_logic_vector(31 downto 0);
  signal Mux2_src : std_logic;
  signal Mux3_src : std_logic;

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
MUX1: MUX port map(Immediate, RD2, Mux1_src, Mux1_res);
ALU_C: ALUcontrol port map(Control_op, Alu_op);
ALU1: ALU port map(RD1, Mux1_res, Alu_op, Alu_res, Alu_zero);
MUX2: MUX port map(PC, Imm_add, Mux2_src, Mux2_res);
MUX3: MUX port map(Mux2_res, J_addr, Mux3_src, B_addr);


	RD1 <= rs;
	RD2 <= rt;
	Immediate <= imm;
	Control_op <= opcode;
	Mux1_src <= src;
  Branch_taken <= branch xnor Alu_zero;
  -- branch logic
  PC <= std_logic_vector(to_unsigned(pc_in, 32));
  Imm_add <= std_logic_vector(signed(PC)+signed(std_logic_vector(shift_left(signed(Immediate), 2))));
  J_addr <= PC(31 downto 28) & jump_addr & "00";
  Mux2_src <= Branch_taken;
  Mux3_src <= jump;
        
	execution: process(clock)
	begin
	  if (stall='0') then			
     if falling_edge(clock) then
        -- output
        mem_wdata <= RD2;
        result <= Alu_res;
        taken <= Branch_taken;
        branch_addr <= to_integer(signed(B_addr));

        destination_reg_go <= destination_reg;
        write_en_go <= write_en;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        wb_src_out <= wb_src_in;
			end if;
		end if;
	end process;

end beh;