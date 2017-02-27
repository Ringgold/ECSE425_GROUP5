library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Processor is
  port(
    clock : in std_logic;
    reset : in std_logic
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
  
  component IF_stage 
    port(
      clock : in std_logic;
      reset : in std_logic;
      instruction : out std_logic_vector(31 downto 0)
    );
  end component;
  
  component ID_stage
    port(
      clock : in std_logic;
      reset : in std_logic;
      instruction : in std_logic_vector(31 downto 0);
      opcode : out std_logic_vector(5 downto 0);
      rs : out std_logic_vector(4 downto 0);
      rt : out std_logic_vector(4 downto 0);
      rd : out std_logic_vector(4 downto 0);
      shamt : out std_logic_vector(4 downto 0);
      funct : out std_logic_vector(5 downto 0);
      immediate : out std_logic_vector(15 downto 0);
      address : out std_logic_vector(25 downto 0)
    );
  end component;
  
  component EX_stage
    port(
      clock : in std_logic;
      reset : in std_logic
    );
  end component;
  
  component MEM_stage
    port(
      clock : in std_logic;
      reset : in std_logic
    );
  end component;
  
  component WB_stage
    port(
      clock : in std_logic;
      reset : in std_logic
    );
  end component;
  
begin
  
  change change
  
end Pro_Arch;

      
  
  