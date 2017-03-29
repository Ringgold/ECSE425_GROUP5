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
signal previous_pc : integer := 0;
  
begin
  
        
      
  instruction_fecth: process(clock, branch, stall)
  begin
      if start = '1' then
       
        if (clock = '1' or rising_edge(branch)) and stall = '0' then
          i_memread <= '1';
          i_memwrite <= '0';
          if branch = '1' then
            if program_counter = branch_adr then 
              pc <= program_counter + 1;
              previous_pc <= program_counter;
              program_counter <= program_counter +1;
            else
              pc <= branch_adr;
              previous_pc <= program_counter;
              program_counter <= branch_adr;
            end if;
          else
            pc <= program_counter + 1;
            previous_pc <= program_counter;
            program_counter <= program_counter +1;
          end if;
          
        elsif rising_edge(stall) then
          previous_pc <= previous_pc;
          program_counter <= previous_pc;
          pc <= previous_pc;
          i_memread <= '1';
          i_memwrite <= '0';
        end if;
              
        if falling_edge(clock) then
          i_memread <= '0';
          i_memwrite <= '0';
        end if;
        
      end if;
  end process;
  
          
end IF_arch;
        
    
  
  
  