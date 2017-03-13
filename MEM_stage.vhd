library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_stage is
	GENERIC(
		ram_size : INTEGER := 32768;
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	port(
		clock : in std_logic;
		memRead : in std_logic;
		memWrite : in std_logic;
		address: IN INTEGER RANGE 0 TO ram_size-1;
		writeData: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		result: out INTEGER RANGE 0 TO ram_size-1;
		waitrequest: OUT STD_LOGIC
	);
end MEM_stage;

architecture beh of MEM_stage is
	signal clk : std_logic;
	signal wd : std_logic_vector(7 downto 0);
	signal add : IN INTEGER RANGE 0 TO ram_size-1;
	signal mw : std_logic;
	signal mr : std_logic;
	signal rd : std_logic_vector(7 downto 0);
	signal wr : std_logic;
  
  	component data_memory
    	port(
	      	clock: IN STD_LOGIC;
			writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			address: IN INTEGER RANGE 0 TO ram_size-1;
			memwrite: IN STD_LOGIC;
			memread: IN STD_LOGIC;
			readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			waitrequest: OUT STD_LOGIC
    	);
  	end component;
  
begin
MEM1: data_memory port map(clk, wd, add, mw, mr, rd, wr);

	clk <= clock;
	wd <= writeData;
	add <= address;
	mw <= memWrite;
	mr <= memRead;		
	rd <= readdata;
	wr <= waitrequest;
	result <= address;
	
end beh;

      
  
  
