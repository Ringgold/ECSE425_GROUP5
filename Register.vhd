library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
  generic(
    size : integer
  );
  port(
    clock : in std_logic;
    input : in std_logic_vector(size-1 downto 0);
    enable : in std_logic;
    output : out std_logic_vector(size-1 downto 0)
  );
end Reg;
architecture Behavior of Reg is
  signal data : std_logic_vector(size-1 downto 0);
  
begin
  
  data <= input;
  
  transfer : process(clock)
  begin
    if rising_edge(clock) then 
      if enable = '1' then
        output <= data;
      end if;
    end if;
  end process;
  
end Behavior;
