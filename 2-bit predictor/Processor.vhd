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
  

  --IF SIGNALS
  signal branch_in_if : std_logic;
  signal branch_adr_in_if : integer;
  signal pc_out_if : integer;
  signal stall_in_if : std_logic;
  signal branch_outcome_in_if : std_logic := '0';
  signal btb_index_in_if : integer;
  signal cancel_stall_out_if : std_logic;
  signal predict_taken_out_if : std_logic;
  signal mispredicted_in_if : std_logic;
  signal update_branch_target_buffer_in_if : std_logic := '0';
  
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
  signal instruction_in_id : std_logic_vector(31 downto 0) := (others => '0');
  signal alu_src_out_id : std_logic;
  signal mem_read_out_id : std_logic;
  signal mem_write_out_id : std_logic;
  signal wb_src_out_id : std_logic;
  signal branch_out_id : std_logic;
  signal destination_reg_go_out_id : std_logic_vector(4 downto 0);
  signal write_en_go_out_id : std_logic := '0';
  signal jump_address_out_id : std_logic_vector(31 downto 0);
  signal jump_en_out_id : std_logic;
  signal stall_out_id : std_logic;
  signal branch_outcome_out_id : std_logic := '0';
  signal btb_index_out_id : integer;
  signal predict_taken_in_id : std_logic;
  signal mispredicted_out_id : std_logic;
  signal update_branch_target_buffer_out_id : std_logic := '0';
  
  --EX SIGNALS
  signal rs_in_ex : std_logic_vector(31 downto 0);
	signal rt_in_ex : std_logic_vector(31 downto 0);
	signal immediate_in_ex : std_logic_vector(31 downto 0);
	signal opcode_in_ex : std_logic_vector(5 downto 0);
	signal alu_src_in_ex	: std_logic;					-- src='1' when instru is R and branch; src='0' when instru is I except branch
	signal branch_in_ex	: std_logic;						-- branch='1' when "beq"; branch='0' when "bne"	
	signal pc_in_ex : integer;
	signal jump_in_ex : std_logic;
	signal jump_addr_in_ex :  std_logic_vector(25 downto 0);
	signal destination_reg_in_ex : std_logic_vector(4 downto 0);
	signal write_en_in_ex : std_logic;
	signal mem_read_in_ex : std_logic;
	signal mem_write_in_ex : std_logic := '0';
	signal wb_src_in_ex : std_logic;
	signal destination_reg_out_ex : std_logic_vector(4 downto 0);
	signal write_en_go_out_ex : std_logic := '0'; 
	signal mem_read_out_ex : std_logic;
	signal mem_write_out_ex : std_logic;
	signal wb_src_out_ex : std_logic;
	signal mem_wdata_out_ex : std_logic_vector(31 downto 0);
	signal result_out_ex : std_logic_vector(31 downto 0):= (others => '0');
	signal taken_out_ex : std_logic;
	signal branch_addr_out_ex : integer;
	
	--MEM SIGNALS
	signal	register_data_in_mem : std_logic_vector(31 downto 0);
  signal alu_result_in_mem : std_logic_vector(31 downto 0):= (others => '0');
  signal memWrite_in_mem : std_logic;
  signal	memRead_in_mem : std_logic;
  signal	destination_reg_in_mem : std_logic_vector(4 downto 0);
  signal	write_en_in_mem : std_logic := '0';
  signal wb_src_in_mem : std_logic;
  signal	destination_reg_go_out_mem : std_logic_vector(4 downto 0);
  signal	write_en_go_out_mem : std_logic := '0';
  signal wb_src_out_mem : std_logic;
  signal	memory_data_out_mem : std_logic_vector(31 downto 0);
  signal	alu_result_go_out_mem : std_logic_vector(31 downto 0):= (others => '0');
  
  
  --WB SIGNALS
	signal src_in_wb : std_logic;					-- if src='0', take read_data; elif src='1', take alu_result
	signal read_data_in_wb : std_logic_vector(31 downto 0);
	signal alu_result_in_wb : std_logic_vector(31 downto 0):= (others => '0');
	signal destination_reg_in_wb : std_logic_vector(4 downto 0);
	signal write_en_in_wb : std_logic := '0';
	signal destination_reg_go_out_wb : std_logic_vector(4 downto 0);
	signal write_en_go_out_wb : std_logic := '0';
	signal output_out_wb : std_logic_vector(31 downto 0):= (others => '0');
	
	
  
  component IF_stage 
    port(
      clock : in std_logic;
      reset : in std_logic;
      stall : in std_logic;
      start : in std_logic;
      branch : in std_logic;  -- enable branching
      branch_adr : in integer; --branch address
      fetched_instruction : in std_logic_vector(31 downto 0);
      branch_outcome : in std_logic;
      btb_index : in integer;
      mispredicted : in std_logic;
      update_branch_target_buffer: in std_logic := '0';
      i_memread : out std_logic;
      i_memwrite : out std_logic;
      pc : out integer := 0;
      cancel_stall : out std_logic := '0';
      predict_taken : out std_logic := '0'
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
    predict_taken : in std_logic;
    opcode_out : out std_logic_vector(5 downto 0);      --opcode of current instruction
    rs_out : out std_logic_vector(31 downto 0);         --data in rs register
    rt_out : out std_logic_vector(31 downto 0);         --data in rt register
    immediate_out : out std_logic_vector(31 downto 0);  --immediate value shifted appropriately
    address_out : out std_logic_vector(25 downto 0);    -- address for J instructions
    pc_out : out integer;                               --new pc
    jump_address : out std_logic_vector(31 downto 0);   --jr address
    jump_en : out std_logic;
    
    destination_reg_go : out std_logic_vector(4 downto 0); --the destination to pass to WB_stage in order to make the WB work
    write_en_go: out std_logic;
    mem_read: out std_logic;
    mem_write: out std_logic;
    wb_src: out std_logic;
    alu_src: out std_logic;
    branch: out std_logic;
    
    branch_outcome: out std_logic;
    btb_index: out integer;
    mispredicted: out std_logic := '0';
    update_branch_target_buffer: out std_logic := '0'
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
  end component;
  
  component MEM_stage
    port(
      clock : in std_logic;
		  stall: in std_logic; -- indicates if the stall is over
		  register_data: in std_logic_vector(31 downto 0); --RD2
      alu_result: in std_logic_vector(31 downto 0); -- result from ALU
      memWrite: in std_logic;
    	 memRead: in std_logic;
    	 destination_reg: in std_logic_vector(4 downto 0);
    	 write_en: in std_logic;
      wb_src_in: in std_logic;

    	 destination_reg_go: out std_logic_vector(4 downto 0);
    	 write_en_go: out std_logic;
      wb_src_out: out std_logic;
    	 memory_data: out std_logic_vector(31 downto 0); --passed from memory to WB
    	 alu_result_go: out std_logic_vector(31 downto 0) -- redult from ALU to be forwarded to WB
    );
  end component;
  
  component WB_stage
    port(
     clock : in std_logic;
	   stall: in std_logic;
	   src: in std_logic;								-- if src='0', take read_data; elif src='1', take alu_result
	   read_data: in std_logic_vector(31 downto 0);
	   alu_result: in std_logic_vector(31 downto 0);
	   destination_reg: in std_logic_vector(4 downto 0);
	   write_en: in std_logic;

	   destination_reg_go: out std_logic_vector(4 downto 0);
	   write_en_go: out std_logic;
	   output : out std_logic_vector(31 downto 0)
    );
  end component;
  
  
  
begin
  
    
  instruction_fetch_stage : IF_stage
  port map(
    clock => clock,
    reset => reset,
    stall => stall_in_if,
    start => start,
    i_memread => i_memread,
    i_memwrite => i_memwrite,
    fetched_instruction => input,
    pc => pc_out_if,
    branch => branch_in_if,
    branch_adr => branch_adr_in_if,
    branch_outcome => branch_outcome_in_if,
    btb_index => btb_index_in_if,
    cancel_stall => cancel_stall_out_if,
    predict_taken => predict_taken_out_if,
    mispredicted => mispredicted_in_if,
    update_branch_target_buffer => update_branch_target_buffer_in_if
  );
  
  instruction_decode_stage : ID_stage
  port map(
    clock => clock,
    reset => reset,
    stall => stall_out_id,
    instruction => instruction_in_id,
    pc_in => pc_in_id,
    rd_in => rd_in_id,
    write_data => write_data_id,
    write_en => write_en_id,
    predict_taken => predict_taken_in_id,
    opcode_out => opcode_out_id,
    rs_out => rs_out_id,
    rt_out => rt_out_id,
    immediate_out => immediate_out_id,
    address_out => address_out_id,
    pc_out => pc_out_id, 
    jump_address => jump_address_out_id,
    jump_en => jump_en_out_id,
    
    destination_reg_go => destination_reg_go_out_id,
    write_en_go => write_en_go_out_id,
    mem_read => mem_read_out_id,
    mem_write => mem_write_out_id,
    wb_src => wb_src_out_id,
    alu_src => alu_src_out_id,
    branch => branch_out_id,
    
    branch_outcome => branch_outcome_out_id,
    btb_index => btb_index_out_id,
    mispredicted => mispredicted_out_id,
    update_branch_target_buffer => update_branch_target_buffer_out_id
  );
  
  execute_stage : EX_stage
  port map(
    clock => clock,
	  stall => stall,
    rs => rs_in_ex,
	  rt => rt_in_ex,
	  imm => immediate_in_ex,
	  opcode => opcode_in_ex,
	  src => alu_src_in_ex,								-- src='1' when instru is R and branch; src='0' when instru is I except branch
	  branch => branch_in_ex,								-- branch='1' when "beq"; branch='0' when "bne"
	  pc_in => pc_in_ex,
	  jump => jump_in_ex,
	  jump_addr => jump_addr_in_ex,
	  
	  destination_reg => destination_reg_in_ex,
	  write_en => write_en_in_ex,
	  mem_read_in => mem_read_in_ex,
	  mem_write_in => mem_write_in_ex,
	  wb_src_in => wb_src_in_ex,
	  destination_reg_go => destination_reg_out_ex,	  
	  mem_read_out => mem_read_out_ex,
    mem_write_out => mem_write_out_ex,    
	  write_en_go => write_en_go_out_ex,
	  wb_src_out => wb_src_out_ex,
	  mem_wdata => mem_wdata_out_ex,
	  result => result_out_ex,
	  taken => taken_out_ex,
	  branch_addr => branch_addr_out_ex
  );
  
  memory_stage : MEM_stage
  port map(
  		clock => clock,
		stall => stall,
		register_data => register_data_in_mem,
    alu_result => alu_result_in_mem,
    memWrite => memWrite_in_mem,
  	 memRead => memRead_in_mem,
  	 destination_reg => destination_reg_in_mem,
  	 write_en => write_en_in_mem,
    wb_src_in => wb_src_in_mem,

  	 destination_reg_go => destination_reg_go_out_mem,
  	 write_en_go => write_en_go_out_mem,
    wb_src_out => wb_src_out_mem,
  	 memory_data => memory_data_out_mem,
  	 alu_result_go => alu_result_go_out_mem
  );
  
  Write_back_stage : WB_stage
  port map(
    clock => clock,
	  stall => stall,
	  src => src_in_wb,						-- if src='0', take read_data; elif src='1', take alu_result
	  read_data => read_data_in_wb,
	  alu_result => alu_result_in_wb,
	  destination_reg => destination_reg_in_wb,
	  write_en => write_en_in_wb,

	  destination_reg_go => destination_reg_go_out_wb,
	  write_en_go => write_en_go_out_wb,
	  output => output_out_wb
  );
  
  
  
  
  --wb to id
  rd_in_id <= destination_reg_go_out_wb;
  write_en_id <= write_en_go_out_wb;
  write_data_id <= output_out_wb;

  --pc from if to i_memory
  pc <= pc_out_if;
  
  
  --id to if
  stall_in_if <= stall_out_id;
  branch_in_if <= jump_en_out_id;
  branch_adr_in_if <= to_integer(unsigned(jump_address_out_id));
  mispredicted_in_if <= mispredicted_out_id;
  
  process(clock)
    variable previous_instruction : std_logic_vector(31 downto 0) := (others => '0');
    begin
      if rising_edge(clock) then 
        previous_instruction := instruction_in_id;
        
        --if to id
        if stall_out_id = '1' then
          instruction_in_id <= previous_instruction;
        elsif jump_en_out_id = '1' and cancel_stall_out_if = '0' then
          instruction_in_id <= "00000000000000000000000000100000"; --stall with add $0, $0, $0
        elsif mispredicted_out_id = '1' then
          instruction_in_id <= "00000000000000000000000000100000"; --stall with add $0, $0, $0
        else
          instruction_in_id <= input;
        end if; 
        pc_in_id <= pc_out_if;
        predict_taken_in_id <= predict_taken_out_if;
               
        --id to if
        branch_outcome_in_if <= branch_outcome_out_id;
        btb_index_in_if <= btb_index_out_id;
        update_branch_target_buffer_in_if <= update_branch_target_buffer_out_id;
        
        
        --id to ex
        destination_reg_in_ex <= destination_reg_go_out_id;
        rs_in_ex <= rs_out_id;        
        rt_in_ex <= rt_out_id;
        immediate_in_ex <= immediate_out_id;
        opcode_in_ex <= opcode_out_id;  
        alu_src_in_ex <= alu_src_out_id;
        branch_in_ex <= branch_out_id;
        mem_read_in_ex <= mem_read_out_id;
        mem_write_in_ex <= mem_write_out_id;
        write_en_in_ex <= write_en_go_out_id;
        wb_src_in_ex <= wb_src_out_id;
        jump_in_ex <= branch_out_id;
        jump_addr_in_ex <= address_out_id;
        
        --ex to mem
        register_data_in_mem <= mem_wdata_out_ex;
        destination_reg_in_mem <= destination_reg_out_ex;
        alu_result_in_mem <= result_out_ex;      
        memRead_in_mem <= mem_read_out_ex;
        memWrite_in_mem <= mem_write_out_ex;
        write_en_in_mem <= write_en_go_out_ex;
        wb_src_in_mem <= wb_src_out_ex;
        
        --mem to wb
        read_data_in_wb <= memory_data_out_mem;
        destination_reg_in_wb <= destination_reg_go_out_mem;
        alu_result_in_wb <= alu_result_go_out_mem;
        src_in_wb <= wb_src_out_mem;
        write_en_in_wb <= write_en_go_out_mem;
      end if;
    end process;
   
end Pro_Arch;

      
  
  