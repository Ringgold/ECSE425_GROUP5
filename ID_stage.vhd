library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_stage is
  port(
    clock : in std_logic;
    reset : in std_logic;
    stall : in std_logic;
    instruction : in std_logic_vector(31 downto 0);
    opcode : out std_logic_vector(5 downto 0);
    rs_out : out std_logic_vector(4 downto 0);
    rt_out : out std_logic_vector(4 downto 0);
    rd_out : out std_logic_vector(4 downto 0);
    immediate_out : out std_logic_vector(15 downto 0);
    address : out std_logic_vector(25 downto 0)
  );
end ID_stage;

architecture ID_arch of ID_stage is
  signal registers : std_logic_vector(1023 downto 0):=(others=> '0');
  signal opcode : std_logic_vector(5 downto 0);
  signal rs : std_logic_vector(4 downto 0);
  signal rt : std_logic_vector(4 downto 0);
  signal rd : std_logic_vector(4 downto 0);
  signal shamt : std_logic_vector(4 downto 0);
  signal funct : std_logic_vector(5 downto 0);
  signal immediate : std_logic_vector(15 downto 0);
  signal address : std_logic_vector(25 downto 0);
  signal instruction_format : std_logic_vector(1 downto 0); -- 00=r  01=i  10=j
begin
  
  opcode <= instruction(31 downto 26);
  instruction_format <= "00" when opcode = "000000" else
                        "10" when (opcode = "00010") or (opcode = "00011") else
                        "01";
  funct <= instruction(5 downto 0) when instruction_format = "00";
  rs <= instruction(25 downto 21);
  rt <= instruction(20 downto 16);
  rd <= instruction(15 downto 11);
  shamt <= instruction(10 downto 6);
  immediate <= instruction(15 downto 0);
  address <= instruction(25 downto 0);
  
  
  process(clock)
    begin
      if instruction_format = "00" then -- R instruction
        if funct /= "001000" then -- everything except jump register
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
        else --jump register
          rs_out <= "00000";
          rt_out <= "00000";      
          pc_out <= to_integer(unsigned(registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32)))/4;
        end if;
        
      elsif instruction_format = "10" then  --J instruction
        if opcode = "000010" then --jump
          rs_out <= "00000";
          rt_out <= "00000"; 
          pc_out <= to_integer(unsigned(address))/4;
        elsif opcode = "000011" then --jump and link
          rs_out <= "00000";
          rt_out <= "00000"; 
          registers(1023 downto 992) <= std_logic_vector(to_unsigned(pc_in+1,32));
          
      elsif instruction_format = "01" then  --I instruction
        if opcode = "001000" or opcode = "001100" or opcode = "001101" or opcode = "001010" or opcode = "001111"  --addi andi ori slti lui
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          immediate_out <= immediate
        
        elsif opcode = "000100" or opcode = "000101"  --beq bne
        
        elsif opcode = "100011" or opcode = "101011"  --LW SW
      
      
        
        
      
      
      
       
  
  
  
                        
                        
end ID_arch;