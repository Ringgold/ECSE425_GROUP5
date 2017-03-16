library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Processor is
  port(
    clock : in std_logic;
    reset : in std_logic;
    input : in std_logic_vector(31 downto 0);
    start : in std_logic;
    i_memread : out std_logic;
    i_memwrite : out std_logic;
    pc : out integer
  );
end Processor;

architecture Pro_Arch of Processor is
  
  signal opcode: std_logic_vector(5 downto 0);
  signal rs: std_logic_vector(4 downto 0);
  signal rt: std_logic_vector(4 downto 0);
  signal rd: std_logic_vector(4 downto 0);
  signal shamt: std_logic_vector(4 downto 0);
  signal funct: std_logic_vector(5 downto 0);
  signal immediate: std_logic_vector(15 downto 0);
  signal address: std_logic_vector(25 downto 0);
  signal stall: std_logic := '0';
  
  
  --REGISTER SIGNALS
  signal IF_ID_Reg_input : std_logic_vector(31 downto 0);
  signal IF_ID_Reg_enable : std_logic := '1';
  signal IF_ID_Reg_output : std_logic_vector(31 downto 0);
  
  signal ID_EX_Reg_input : std_logic_vector(31 downto 0);
  signal ID_EX_Reg_enable : std_logic := '1';
  signal ID_EX_Reg_output : std_logic_vector(31 downto 0);
  
  signal EX_MEM_Reg_input : std_logic_vector(31 downto 0);
  signal EX_MEM_Reg_enable : std_logic := '1';
  signal EX_MEM_Reg_output : std_logic_vector(31 downto 0);
  
  signal MEM_WB_Reg_input : std_logic_vector(31 downto 0);
  signal MEM_WB_Reg_enable : std_logic := '1';
  signal MEM_WB_Reg_output : std_logic_vector(31 downto 0);

    
  --ID SIGNALS
  signal pc_in_id : integer;
  signal rd_in_id : std_logic_vector(4 downto 0);  
  signal write_data_id : std_logic_vector(31 downto 0);
  signal write_en_id : std_logic := '0';
  signal opcode_out_id : std_logic_vector(5 downto 0);
  signal rs_out_id : std_logic_vector(31 downto 0);
  signal rt_out_id : std_logic_vector(31 downto 0);
  signal immediate_out_id : std_logic_vector(31 downto 0);
  signal address_out_id : std_logic_vector(25 downto 0);
  signal pc_out_id : integer;
  
  
  component Reg
    generic(
      size : integer
    );
    port(
      clock : in std_logic;
      input : in std_logic_vector(size-1 downto 0);
      enable : in std_logic;
      output : out std_logic_vector(size-1 downto 0)
    );
  end component;
  
  component IF_stage 
    port(
      clock : in std_logic;
      reset : in std_logic;
      stall : in std_logic;
      start : in std_logic;
      i_memread : out std_logic;
      i_memwrite : out std_logic;
      pc : out integer := 0
    );
  end component;
  
  component ID_stage
   port(
    clock : in std_logic;
    reset : in std_logic;
    stall : out std_logic;
    instruction : in std_logic_vector(31 downto 0);     --instruction to decode
    pc_in : in integer;                                 --current pc
    rd_in : in std_logic_vector(4 downto 0);          --destination register
    write_data : in std_logic_vector(31 downto 0);      --data to write to rd
    write_en : in std_logic;                            --write enable
    opcode_out : out std_logic_vector(5 downto 0);      --opcode of current instruction
    rs_out : out std_logic_vector(31 downto 0);         --data in rs register
    rt_out : out std_logic_vector(31 downto 0);         --data in rt register
    immediate_out : out std_logic_vector(31 downto 0);  --immediate value shifted appropriately
    address_out : out std_logic_vector(25 downto 0);    -- address for J instructions
    pc_out : out integer                                --new pc
  );
  end component;
  
  component EX_stage
    port(
    clock : in std_logic;
	  stall: in std_logic;
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
  end component;
  
  component MEM_stage
    port(
    clock : in std_logic;
		--rdy: in std_logic; -- indicates if the stall is over
		opcode : in std_logic_vector(5 downto 0); --operation code
		register_data: in std_logic_vector(31 downto 0); --RD2
   	alu_result: in std_logic_vector(31 downto 0); -- redult from ALU
   	destination_addr: in std_logic_vector (4 downto 0);
   	memory_data: out std_logic_vector(31 downto 0); --passed from memory to WB
   	alu_result_go: out std_logic_vector(31 downto 0); -- redult from ALU to be forwarded to WB
   	writeback_addr: out std_logic_vector(4 downto 0)
    );
  end component;
  
  component WB_stage
    port(
      clk: in  std_logic;
    memory_data: in std_logic_vector(31 downto 0);
    alu_result: in std_logic_vector(31 downto 0);
    opcode : in std_logic_vector(5 downto 0);
    writeback_addr: in std_logic_vector(4 downto 0);
    writeback_data: out std_logic_vector(31 downto 0);
    writeback_addr_go: out std_logic_vector(4 downto 0)
    );
  end component;
  
  
  
  
  
  
  
  
  
begin
  
  IF_ID_Register : Reg
  generic map(
    size => 32
  )
  port map(
    clock => clock,
    input => input,
    enable => IF_ID_Reg_enable,
    output => IF_ID_Reg_output
  );
  
  ID_EX_Register : Reg
  generic map(
    size => 32
  )
  port map(
    clock => clock,
    input => ID_EX_Reg_input,
    enable => ID_EX_Reg_enable,
    output => ID_EX_Reg_output
  );
  
  EX_MEM_Register : Reg
  generic map(
    size => 32
  )
  port map(
    clock => clock,
    input => EX_MEM_Reg_input,
    enable => EX_MEM_Reg_enable,
    output => EX_MEM_Reg_output
  );
  
  MEM_WB_Register : Reg
  generic map(
    size => 32
  )
  port map(
    clock => clock,
    input => MEM_WB_Reg_input,
    enable => MEM_WB_Reg_enable,
    output => MEM_WB_Reg_output
  );
    
  instruction_fetch_stage : IF_stage
  port map(
    clock => clock,
    reset => reset,
    stall => stall,
    start => start,
    i_memread => i_memread,
    i_memwrite => i_memwrite,
    pc => pc  
  );
  
  instruction_decode_stage : ID_stage
  port map(
    clock => clock,
    reset => reset,
    stall => stall,
    instruction => IF_ID_Reg_output,
    pc_in => pc_in_id,
    rd_in => rd_in_id,
    write_data => write_data_id,
    write_en => write_en_id,
    opcode_out => opcode_out_id,
    rs_out => rs_out_id,
    rt_out => rt_out_id,
    immediate_out => immediate_out_id,
    address_out => address_out_id,
    pc_out => pc_out_id
  );
  
  execute_stage : EX_stage
  port map(
    clock : in std_logic;
	  stall: in std_logic;
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
  
  memory_stage : MEM_stage
  port map(
  		clock : in std_logic;
		--rdy: in std_logic; -- indicates if the stall is over
		opcode : in std_logic_vector(5 downto 0); --operation code
		register_data: in std_logic_vector(31 downto 0); --RD2
   	alu_result: in std_logic_vector(31 downto 0); -- redult from ALU
   	destination_addr: in std_logic_vector (4 downto 0);
   	memory_data: out std_logic_vector(31 downto 0); --passed from memory to WB
   	alu_result_go: out std_logic_vector(31 downto 0); -- redult from ALU to be forwarded to WB
   	writeback_addr: out std_logic_vector(4 downto 0);
  );
  
  Write_back_stage : WB_stage
  port map(
    clk: in  std_logic;
    memory_data: in std_logic_vector(31 downto 0);
    alu_result: in std_logic_vector(31 downto 0);
    opcode : in std_logic_vector(5 downto 0);
    writeback_addr: in std_logic_vector(4 downto 0);
    writeback_data: out std_logic_vector(31 downto 0);
    writeback_addr_go: out std_logic_vector(4 downto 0) 
  );
  
    
    
  
  
end Pro_Arch;

      
  
  