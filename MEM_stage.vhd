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
		register_data: in std_logic_vector(31 downto 0); --RD2
    	alu_result: in std_logic_vector(31 downto 0); -- result from ALU
    	memWrite: in std_logic;
    	memRead: in std_logic;

    	memory_data: out std_logic_vector(31 downto 0); --passed from memory to WB
    	alu_result_go: out std_logic_vector(31 downto 0); -- redult from ALU to be forwarded to WB
	);
end MEM_stage;

architecture beh of MEM_stage is
	signal clk : std_logic;
	signal wd : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal alu : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal mw : std_logic;
	signal mr : std_logic;
	signal rd : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
  
  	component data_memory
    	port(
	      	clock: IN STD_LOGIC;
			writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			address: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			memwrite: IN STD_LOGIC;
			memread: IN STD_LOGIC;
			readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    	);
  	end component;
  
begin
MEM1: data_memory port map(
	clock: => clk, 
	writedata: => wd, 
	address: => alu, 
	memwrite: => mw, 
	memread: => mr, 
	readdata: => rd
	);

For_DM : process
begin

    if rising_edge(clock) then

      	clk <= clock;
      	alu <= (signed(alu_result))/32; --get word counted data memory address

      	--Set read and write signals
      	mr <= memRead;
      	mw <= memWrite;

    end if;

end process;


Stage_process : process (clock)
begin
  	if rising_edge(clock) then
  		if (stall='0') then
		    alu_result <= alu_result_go;
		    memory_data <= rd;
		end if;
    end if;
end process;
	
end beh;

      
  
  
