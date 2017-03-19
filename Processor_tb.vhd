library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity Processor_tb is
end Processor_tb; 

architecture behavior of Processor_tb is
  
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
	
	component D_Memory is
    generic(
		  ram_size : INTEGER := 8192;
		  mem_delay : time := 0 ns;
		  clock_period : time := 1 ns
	  );
    port(
      clock: in STD_LOGIC;
		  writedata: in STD_LOGIC_VECTOR (31 DOWNTO 0);
		  address: in INTEGER RANGE 0 TO 8192;
		  memwrite: in STD_LOGIC;
		  memread: in STD_LOGIC;
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
	  
	  data_memory: D_Memory
	  port map(
	    clock => clock,
	    writedata => d_writedata,
	    address => d_address,
	    memwrite => d_memwrite,
	    memread => d_memread,
	    readdata => d_readdata,
	    waitrequest => d_waitrequest
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
          i_address <= pc+1;         
        end if;       
       wait for 1 ps;
    end process;   
    

    --run_program : process
     -- begin
        --if start = '1' then
          --i_memread <= processor_i_memread;
          --i_memwrite <= processor_i_memwrite;
          --i_address <= pc;
          --wait until rising_edge(i_waitrequest);
          --input <= i_readdata;
      -- end if; 
       -- wait for 1 ps;
   -- end process; 
       
 end behavior;
	  
