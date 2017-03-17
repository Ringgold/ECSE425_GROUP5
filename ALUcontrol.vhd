LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALUcontrol is
	port (
		opcode: in std_logic_vector(5 downto 0);
		ALU_op: out std_logic_vector(3 downto 0)
	);
end ALUcontrol;

architecture beh of ALUcontrol is 
	signal add : std_logic_vector(3 downto 0) := "0000";
	signal sub : std_logic_vector(3 downto 0) := "0001";
	signal mult : std_logic_vector(3 downto 0) := "0010";
	signal div : std_logic_vector(3 downto 0) := "0011";
	signal slt : std_logic_vector(3 downto 0) := "0100";
	signal op_and : std_logic_vector(3 downto 0) := "0101";
	signal op_or : std_logic_vector(3 downto 0) := "0110";
	signal op_nor : std_logic_vector(3 downto 0) := "0111";
	signal op_xor : std_logic_vector(3 downto 0) := "1000";
	signal mfhi : std_logic_vector(3 downto 0) := "1001";
	signal mflo : std_logic_vector(3 downto 0) := "1010";
	signal lui : std_logic_vector(3 downto 0) := "1011";
	signal shiftleft_L : std_logic_vector(3 downto 0) := "1100";
	signal shiftright_L : std_logic_vector(3 downto 0) := "1101";
	signal shiftright_A : std_logic_vector(3 downto 0) := "1110";
	signal beq : std_logic_vector(3 downto 0) := "1111";

begin

	ALU_op <=		add when(opcode = "100000" or opcode = "001000" or opcode = "100011" or opcode = "101011") else
					sub when(opcode = "100010") else
					mult when(opcode = "011000" or opcode = "011001") else
					div when(opcode = "011010" or opcode = "011011") else
					slt when(opcode = "101010" or opcode = "001010") else
					op_and when(opcode = "100100" or opcode = "001100") else
					op_or when(opcode = "100101" or opcode = "001101") else
					op_nor when(opcode = "100111") else
					op_xor when(opcode = "100110" or opcode = "001110") else
					mfhi when(opcode = "010000") else
					mflo when(opcode = "010010") else
					lui when(opcode = "001111") else
					shiftleft_L when(opcode = "000000") else
					shiftright_L when(opcode = "000010") else
					shiftright_A when(opcode = "000011") else
					beq when(opcode = "000100" or opcode = "000101") else
					"0000";
end beh;
