library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_stage is
  port(
    clock : in std_logic;
    reset : in std_logic;
    stall : out std_logic;
    instruction : in std_logic_vector(31 downto 0);     --instruction to decode
    pc_in : in integer;                                 --current pc
    rd_in : in std_logic_vector(4 downto 0);          --destination register
    write_data : in std_logic_vector(31 downto 0);      --data to write to rd
    write_en : in std_logic;                            --write enable
    opcode_out : out std_logic_vector(5 downto 0);      --opcode of current instruction
    rs_out : out std_logic_vector(31 downto 0);         --data in rs register
    rt_out : out std_logic_vector(31 downto 0);         --data in rt register
    immediate_out : out std_logic_vector(31 downto 0);  --immediate value shifted appropriately
    address_out : out std_logic_vector(25 downto 0);    -- address for J instructions
    pc_out : out integer                                --new pc
  );
end ID_stage;

architecture ID_arch of ID_stage is
  type registers is array (31 downto 0) of std_logic_vector(31 downto 0);
  signal reg_block : registers := (others =>(others=>'0'));
  signal registers_in_use : std_logic_vector(31 downto 0) := (others => '0');
  signal opcode : std_logic_vector(5 downto 0);
  signal rs : std_logic_vector(4 downto 0);
  signal rt : std_logic_vector(4 downto 0);
  signal rd : std_logic_vector(4 downto 0);
  signal shamt : std_logic_vector(4 downto 0);
  signal funct : std_logic_vector(5 downto 0);
  signal immediate : std_logic_vector(15 downto 0);
  signal address : std_logic_vector(25 downto 0);
  signal instruction_format : std_logic_vector(1 downto 0); -- 00=r  01=i  10=j
  signal write_done : std_logic := '0';
  signal test : std_logic:='0';
  
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

  
  process(clock,rd_in,write_data)
    begin
      if clock = '1' then
        reg_block(to_integer(unsigned(rd_in)))(31 downto 0) <= write_data;
        registers_in_use(to_integer(unsigned(rd_in))) <= '0';
        write_done <= '1';
      elsif falling_edge(clock) then
        write_done <= '0';
      end if;
      
      if falling_edge(clock) then
      if write_en = '0' or (write_en = '1' and write_done = '1') then  --If write is disabled or its enabled but we're done writing(in the first half of the cc) then we decode the instruction
        test <= '1';
        if registers_in_use(to_integer(unsigned(rs))) = '1' or registers_in_use(to_integer(unsigned(rt))) = '1' then --if we're trying to access data from a register that is in use
          stall <= '1';
        else
          registers_in_use(to_integer(unsigned(rd))) <= '1';
          if instruction_format = "00" then  -- R instruction           
            if funct = "100000" or funct = "100010" or funct = "011000" or funct = "011010" or funct = "101010" or funct = "100100" or funct = "100101" or funct = "100111" or funct = "100110" then -- add sub mult div slt and or nor xor
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
            elsif funct = "010000" or funct = "010010" then  --MFHI MFLO
          
            elsif funct = "000000" or funct = "000010" or funct = "000011" then   --sll srl sra
          
            else --jr
              rs_out <= (others => '0');
              rt_out <= (others => '0');    
              pc_out <= to_integer(unsigned(reg_block(to_integer(unsigned(rs)))(31 downto 0)))/4;
            end if;
        
          elsif instruction_format = "10" then  --J instruction
            if opcode = "000010" then --jump
              rs_out <= (others => '0');
              rt_out <= (others => '0'); 
              pc_out <= to_integer(unsigned(address))/4;
            elsif opcode = "000011" then --jump and link
              rs_out <= (others => '0');
              rt_out <= (others => '0');
              reg_block(31)(31 downto 0) <= std_logic_vector(to_unsigned(pc_in+1,32));
            end if;
          
          elsif instruction_format = "01" then  --I instruction
            if opcode = "001000" then --addi
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= (others => '0');
              immediate_out <= std_logic_vector(resize(signed(immediate), 32));
            elsif opcode = "001100" then  --andi    
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= (others => '0');
              immediate_out <= std_logic_vector(resize(unsigned(immediate), 32));
            elsif opcode = "001101" then  --ori
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= (others => '0');
              immediate_out <= std_logic_vector(resize(unsigned(immediate), 32));
            elsif opcode = "001010" then  --slti
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= (others => '0');
              immediate_out <= std_logic_vector(resize(unsigned(immediate), 32));
            elsif opcode = "001111" then  --lui
              rs_out <= (others => '0');
              rt_out <= (others => '0');
              immediate_out <= immediate & "0000000000000000"; 
            elsif opcode = "000100" then  --beq
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
          
            elsif opcode = "000101" then  --bne
        
            elsif opcode = "100011" then  --LW
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
              immediate_out <= std_logic_vector(resize(signed(immediate), 32));
             -- pc_
            elsif opcode = "101011" then  --SW
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
              immediate_out <= std_logic_vector(resize(signed(immediate), 32));
            elsif opcode = "001110" then    --XORI
          
            end if;
          end if;         
        end if;
      end if;
    end if;
  end process;
  

end ID_arch;
      
