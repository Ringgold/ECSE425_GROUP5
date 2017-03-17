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
    rd_in : in std_logic_vector(4 downto 0);            --destination register
    write_data : in std_logic_vector(31 downto 0);      --data to write to rd
    write_en : in std_logic;                            --write enable
    opcode_out : out std_logic_vector(5 downto 0);      --opcode of current instruction
    rs_out : out std_logic_vector(31 downto 0);         --data in rs register
    rt_out : out std_logic_vector(31 downto 0);         --data in rt register
    immediate_out : out std_logic_vector(31 downto 0);  --immediate value shifted appropriately
    address_out : out std_logic_vector(25 downto 0);    -- address for J instructions
    pc_out : out integer;                               --new pc

    destination_reg_go : out std_logic_vector(4 downto 0); --the destination to pass to WB_stage in order to make the WB work
    write_en_go: out std_logic;
    mem_read: out std_logic;
    mem_write: out std_logic;
    wb_src: out std_logic;
    alu_src: out std_logic;
    branch: out std_logic
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
        mem_read <= '0';
        mem_write <= '0';
        wb_src <= '0';
        alu_src <= '0';
        branch <= '0';

        --initialize the WB value and WB address
        IF(now < 1 ps)THEN
          write_en_go <= '0';
          destination_reg_go <=  "00000"; 
        end if;

      --write result to register during first half of cc
      if clock = '1' and write_en = '1' then
        reg_block(to_integer(unsigned(rd_in)))(31 downto 0) <= write_data;
        registers_in_use(to_integer(unsigned(rd_in))) <= '0';
        write_done <= '1';
        write_en_go <= '0';
      elsif falling_edge(clock) then
        write_done <= '0';
      end if;
      
      --decode instruction during second half of cc
    if falling_edge(clock) then
      if write_en = '0' or (write_en = '1' and write_done = '1') then  --If write is disabled or its enabled but we're done writing(in the first half of the cc) then we decode the instruction
        if registers_in_use(to_integer(unsigned(rs))) = '1' or registers_in_use(to_integer(unsigned(rt))) = '1' then --if we're trying to access data from a register that is in use
          stall <= '1';
        else
          stall <= '0';
          registers_in_use(to_integer(unsigned(rd))) <= '1';
          if instruction_format = "00" then  -- R instruction

            --2 values which are going to be passed to the later stages so that to get back
            destination_reg_go <= rd;
            write_en_go <= '1';

            alu_src <= '1';
            opcode_out <= funct;         
            if funct = "100000" or funct = "100010" or funct = "011000" or funct = "011010" or funct = "101010" or funct = "100100" or funct = "100101" or funct = "100111" or funct = "100110" then -- add sub mult div slt and or nor xor
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
            elsif funct = "010000" or funct = "010010" then  --MFHI MFLO
          
            elsif funct = "000000" or funct = "000010" or funct = "000011" then   --sll srl sra
              rs_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(shamt)))(31 downto 0);
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
            alu_src <= '0';
            opcode_out <= opcode;
            if opcode = "001000" or opcode = "001100" or opcode = "001101" or opcode = "001010" or opcode = "001110" then --addi andi ori slti xori
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= (others => '0');
              immediate_out <= std_logic_vector(resize(signed(immediate), 32));
            elsif opcode = "001111" then  --lui
              rs_out <= (others => '0');
              rt_out <= (others => '0');
              immediate_out <= immediate & "0000000000000000"; 
            elsif opcode = "000100" then  --beq
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
              alu_src <= '1';
              branch <= '1';
            elsif opcode = "000101" then  --bne
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
              alu_src <= '1';
              branch <= '0';
            elsif opcode = "100011" then  --LW
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
              immediate_out <= std_logic_vector(resize(signed(immediate), 32));
              mem_read <= '1';
              mem_write <= '0';
              wb_src <= '1';
             -- pc_
            elsif opcode = "101011" then  --SW
              rs_out <= reg_block(to_integer(unsigned(rs)))(31 downto 0);
              rt_out <= reg_block(to_integer(unsigned(rt)))(31 downto 0);
              immediate_out <= std_logic_vector(resize(signed(immediate), 32));
              mem_read <= '0';
              mem_write <= '1';
            end if;
          end if;         
        end if;
      end if;
    end if;
  end process;
  

end ID_arch;