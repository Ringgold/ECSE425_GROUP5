library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity ID_stage_tb is
end ID_stage_tb; 

architecture behavior of ID_stage_tb is
  
  signal clock : std_logic;
  signal reset : std_logic;
  signal stall : std_logic;
  signal instruction : std_logic_vector(31 downto 0);
  signal opcode_out : std_logic_vector(5 downto 0);
  signal rs_out : std_logic_vector(31 downto 0);
  signal rt_out : std_logic_vector(31 downto 0);
  signal immediate_out : std_logic_vector(31 downto 0);
  signal address_out : std_logic_vector(25 downto 0);
  signal pc_in : integer;
  signal pc_out : integer;
  signal rd_in : std_logic_vector(4 downto 0):="00000";
  signal write_data : std_logic_vector(31 downto 0);
  signal write_en : std_logic := '0';
  
  
  component ID_stage is
    port(
    clock : in std_logic;
    reset : in std_logic;
    stall : out std_logic;
    instruction : in std_logic_vector(31 downto 0);     --instruction to decode
    pc_in : in integer;                                 --current pc
    rd_in : in std_logic_vector(4 downto 0);           --destination register
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

begin
  
  identification: ID_stage
  port map(
    clock => clock,
    reset => reset,
    stall => stall,
    instruction => instruction,
    rd_in => rd_in,
    write_data => write_data,
    write_en => write_en,
    opcode_out => opcode_out,
    rs_out => rs_out,
    rt_out => rt_out,
    immediate_out => immediate_out,
    address_out => address_out,
    pc_out => pc_out,
    pc_in => pc_in
  );
    
    
	  clk_process : process
      begin
        clock <= '0';
        wait for 0.25 ns;
        clock <= '1';
        wait for 0.25 ns;
    end process;
    
    test_process: process
      begin
        wait until rising_edge(clock);
        instruction <= "00000000010000010001000000100000";
        write_en <= '1';
        write_data <= std_logic_vector(to_unsigned(2,32));
        rd_in <= "00001";

        wait until rising_edge(clock);
        instruction <= "00000000100001010100000000100000";
        write_en <= '1';
        write_data <= std_logic_vector(to_unsigned(6,32));
        rd_in <= "00100";

        
        
        wait;
    end process;
      
end behavior;
