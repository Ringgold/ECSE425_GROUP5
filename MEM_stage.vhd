library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_stage is
	GENERIC(
		ram_size : INTEGER := 8192;
		mem_delay : time := 1 ns;
		clock_period : time := 1 ns
	);
	port(
		clock : in std_logic;
		stall: in std_logic; -- indicates if the stall is over
		register_data: in std_logic_vector(31 downto 0) := (others => '0'); --RD2
   	alu_result: in std_logic_vector(31 downto 0) := (others => '0'); -- result from ALU
   	memWrite: in std_logic;
 	  memRead: in std_logic;
   	destination_reg: in std_logic_vector(4 downto 0);
   	write_en: in std_logic;
    wb_src_in: in std_logic;

    code    : in std_logic_vector(31 downto 0);
    code_go : out std_logic_vector(31 downto 0);

   	destination_reg_go: out std_logic_vector(4 downto 0) := (others => '0');
   	write_en_go: out std_logic := '0';
    wb_src_out: out std_logic;
   	memory_data: out std_logic_vector(31 downto 0) := (others => '0'); --passed from memory to WB
   	alu_result_go: out std_logic_vector(31 downto 0) := (others => '0') -- redult from ALU to be forwarded to WB
	);
end MEM_stage;

architecture beh of MEM_stage is
	signal clk : std_logic;
	signal wd : STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal alu : INTEGER RANGE 0 TO ram_size-1;
	signal const : INTEGER RANGE 0 TO ram_size-1:= 32;
	signal mw : std_logic;
	signal mr : std_logic;
	signal rd : STD_LOGIC_VECTOR (31 DOWNTO 0);
  
  	component data_memory
    	port(
	      	clock: IN STD_LOGIC;
			writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			address: IN INTEGER RANGE 0 TO ram_size-1;
			memwrite: IN STD_LOGIC;
			memread: IN STD_LOGIC;
			readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    	);
  	end component;
  
begin
MEM1: data_memory port map(clock, wd, alu, mw, mr, rd);



      	alu <= to_integer(unsigned(alu_result)); --/(const); --get word counted data memory address

      	--Set read and write signals
      	mr <= memRead;
      	mw <= memWrite;


Stage_process : process (clock)
begin
  	if clock = '0' then
  		if (stall='0') then
  			code_go <= code;
  		    wd <= register_data; 
		    alu_result_go <= alu_result;
		    destination_reg_go <= destination_reg;
		    write_en_go <= write_en;
            wb_src_out <= wb_src_in;
		end if;
    end if;
end process;
memory_data <= rd;	
end beh;
