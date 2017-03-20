library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_stage is
  port(
    clock : in std_logic;
    reset : in std_logic;
    stall : in std_logic;
    start : in std_logic;   --program is ready to start (program fully transfered to i_memory)
    branch : in std_logic;  -- enable branching
    branch_adr : in integer; --branch address
    i_memread : out std_logic := '0';
    i_memwrite : out std_logic := '0';
    pc : out integer := 0
  );
end IF_stage;

architecture IF_arch of IF_stage is
signal program_counter : integer := 0;
  
begin
  
  instruction_fecth: process(clock)
  begin
    if reset = '1' then
      program_counter <= 0;
    else
      if start = '1' then 
        if rising_edge(clock) then
          i_memread <= '1';
          i_memwrite <= '0';
          if branch = '1' then
            program_counter <= branch_adr;
          else
            program_counter <= program_counter + 1;
          end if;
          pc <= program_counter;
        end if;      
        if falling_edge(clock) then
          i_memread <= '0';
          i_memwrite <= '0';
        end if;
      end if;
    end if;
  end process;
  
          
end IF_arch;
        
    
  
  
  