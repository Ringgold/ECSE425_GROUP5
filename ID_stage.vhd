library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_stage is
  port(
    clock : in std_logic;
    reset : in std_logic;
    stall : in std_logic;
    instruction : in std_logic_vector(31 downto 0);
    pc_in : in integer;
    opcode_out : out std_logic_vector(5 downto 0);
    rs_out : out std_logic_vector(31 downto 0);
    rt_out : out std_logic_vector(31 downto 0);
    rd_out : out std_logic_vector(31 downto 0);
    immediate_out : out std_logic_vector(31 downto 0);
    address_out : out std_logic_vector(25 downto 0);
    pc_out : out integer
  );
end ID_stage;

architecture ID_arch of ID_stage is
  signal registers : std_logic_vector(1023 downto 0):=((32) => '1', (65) => '1', others=> '0');
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
                        "10" when (opcode = "000010") or (opcode = "000011") else
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
    if rising_edge(clock) then 
      if instruction_format = "00" then -- R instruction
        if funct /= "001000" then -- everything except jump register
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= registers(to_integer(unsigned(rt))*32+31 downto to_integer(unsigned(rt))*32);
        else --jump register
          rs_out <= (others => '0');
          rt_out <= (others => '0');    
          pc_out <= to_integer(unsigned(registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32)))/4;
        end if;
        
      elsif instruction_format = "10" then  --J instruction
        if opcode = "000010" then --jump
          rs_out <= (others => '0');
          rt_out <= (others => '0'); 
          pc_out <= to_integer(unsigned(address))/4;
        elsif opcode = "000011" then --jump and link
          rs_out <= (others => '0');
          rt_out <= (others => '0');
          registers(1023 downto 992) <= std_logic_vector(to_unsigned(pc_in+1,32));
        end if;
          
      elsif instruction_format = "01" then  --I instruction
        if opcode = "001000" then --addi
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= (others => '0');
          immediate_out <= std_logic_vector(resize(signed(immediate), 32));
        elsif opcode = "001100" then  --andi    
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= (others => '0');
          immediate_out <= std_logic_vector(resize(unsigned(immediate), 32));
        elsif opcode = "001101" then  --ori
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= (others => '0');
          immediate_out <= std_logic_vector(resize(unsigned(immediate), 32));
        elsif opcode = "001010" then  --slti
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= (others => '0');
          immediate_out <= std_logic_vector(resize(unsigned(immediate), 32));
        elsif opcode = "001111" then  --lui
          rs_out <= (others => '0');
          rt_out <= (others => '0');
          immediate_out <= immediate & "0000000000000000"; 
        elsif opcode = "000100" then  --beq
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= registers(to_integer(unsigned(rt))*32+31 downto to_integer(unsigned(rt))*32);
          
        elsif opcode = "000101" then  --bne
        
        elsif opcode = "100011" then  --LW
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= registers(to_integer(unsigned(rt))*32+31 downto to_integer(unsigned(rt))*32);
          immediate_out <= std_logic_vector(resize(signed(immediate), 32));
        elsif opcode = "101011" then  --SW
          rs_out <= registers(to_integer(unsigned(rs))*32+31 downto to_integer(unsigned(rs))*32);
          rt_out <= registers(to_integer(unsigned(rt))*32+31 downto to_integer(unsigned(rt))*32);
          immediate_out <= std_logic_vector(resize(signed(immediate), 32));
        --elsif opcode = XORI then    --XORI
          
        end if;
      end if;
    end if;
  end process;
end ID_arch;
      
