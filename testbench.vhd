library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library modelsim_lib;
use modelsim_lib.util.all;


entity testbench is
end testbench; 

architecture behavior of testbench is
  
  component Processor is
    port(
      clock : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(31 downto 0);
      start : in std_logic;
      i_memread : out std_logic;
      i_memwrite : out std_logic;
      pc : out integer
    );
  end component;
  
  component I_Memory is
    generic(
		  ram_size : INTEGER := 8192;
		  mem_delay : time := 0.5 ns;
		  clock_period : time := 0.5 ns
	  );
    port(
      clock: in STD_LOGIC;
		  writedata: in STD_LOGIC_VECTOR (31 DOWNTO 0);
		  writedata_initialization : in STD_LOGIC_VECTOR (31 DOWNTO 0);
		  address_initialization: in INTEGER RANGE 0 TO 8192;
		  address: in INTEGER RANGE 0 TO 8192;
		  memwrite: in STD_LOGIC;
		  memread: in STD_LOGIC;
		  initialization: in std_logic; 
		  readdata: out STD_LOGIC_VECTOR (31 DOWNTO 0);
		  waitrequest: OUT STD_LOGIC
  	 );
	end component;
	
	
	constant clock_period : time := 1 ns;
	signal clock : std_logic;
	signal reset : std_logic;
	signal input : std_logic_vector(31 downto 0) := (others => '0');
	signal pc : integer;
	signal program_transfered : std_logic := '0';
	signal processor_i_memread : std_logic;
	signal processor_i_memwrite : std_logic;
	signal start : std_logic := '0';
	
	signal i_writedata : std_logic_vector(31 downto 0);
	signal i_address : integer range 0 to 8192;
	signal i_memwrite : std_logic;
	signal i_memread : std_logic;
	signal i_readdata : std_logic_vector(31 downto 0);
	signal i_waitrequest : std_logic;
	signal writedata_initialization : std_logic_vector(31 downto 0);
	signal address_initialization : integer range 0 to 8192;
	signal initialization : std_logic;
	
	signal d_writedata : std_logic_vector(31 downto 0);
	signal d_address : integer range 0 to 8192;
	signal d_memwrite : std_logic;
	signal d_memread : std_logic;
	signal d_readdata : std_logic_vector(31 downto 0);
	signal d_waitrequest : std_logic;
	
	signal input1 : std_logic_vector(31 downto 0);
	
	type registers is array (31 downto 0) of std_logic_vector(31 downto 0);
  signal reg_block : registers;
  
  TYPE MEM IS ARRAY(8191 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM;
	
	
	begin
	  
	  instruction_memory: I_Memory
	  port map(
	    clock => clock,
	    writedata => i_writedata,
	    address => i_address,
	    memwrite => i_memwrite,
	    memread => i_memread,
	    readdata => i_readdata,
	    waitrequest => i_waitrequest,
	    initialization => initialization,
	    address_initialization => address_initialization,
	    writedata_initialization => writedata_initialization
	  );
	  
	  processor1: Processor
	  port map(
	    clock => clock,
	    reset => reset,
	    input => input,
	    pc => pc,	 
	    i_memread => processor_i_memread,
	    i_memwrite => processor_i_memwrite,
	    start => start
	  );
	  

	  
	  clk_process : process
      begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;    
    
    read_file : process
      file in_file: text;
      variable line_str: line;
      variable address: integer range 0 to 8192 := 0;
      variable data: std_logic_vector(31 downto 0);
      
      begin
        if program_transfered = '0' then
          file_open(in_file, "program.txt", read_mode);
          wait for 4 ns;
          i_memread <= '0';
          i_memwrite <= '1';
          initialization <= '1';
          wait until rising_edge(i_waitrequest);
          while not endfile(in_file) loop
            wait until rising_edge(clock);
            readline(in_file, line_str);
            read(line_str, data);            
            address_initialization <= address;
            writedata_initialization <= data;
            address := address + 1;
            wait for 0.1 ns; 
          end loop;
          wait until rising_edge(clock);
          address_initialization <= address;
          writedata_initialization <= data;
          i_memread <= '0';
          i_memwrite <= '0';
          wait for 4 ns;
          program_transfered <= '1';
          start <= '1';
          initialization <= '0';
          file_close(in_file);
        elsif program_transfered = '1' then
          input <= i_readdata;
          i_memread <= processor_i_memread;
          i_memwrite <= processor_i_memwrite;
          i_address <= pc;         
        end if;       
       wait for 1 ps;
    end process;   
    

    write_file : process
      file out_file1: text;
      file out_file2: text;
      variable line_str: line;
      variable data: std_logic_vector(31 downto 0);
      variable reg_begin : integer := 0;
      
     begin
        wait for 100 ns;
        init_signal_spy("/processor1/instruction_decode_stage/reg_block","/reg_block",1);
        file_open(out_file1, "register_file.txt", write_mode);        
        while reg_begin < 32 loop
          data := reg_block(reg_begin)(31 downto 0);
          write(line_str, data);
          writeline(out_file1, line_str);
          reg_begin := reg_begin + 1;
        end loop;
        file_close(out_file1);
        reg_begin := 0;
        
        wait for 10 ns;
        
        init_signal_spy("/processor1/memory_stage/MEM1/ram_block ","/ram_block",1);
        file_open(out_file2, "memory.txt", write_mode);
        while reg_begin < 8192 loop
          data := ram_block(reg_begin)(31 downto 0);
          write(line_str, data);
          writeline(out_file2, line_str);
          reg_begin := reg_begin + 1;
        end loop;
        file_close(out_file2);
        reg_begin := 0;
        
    end process; 
       
 end behavior;
	  
