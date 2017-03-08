LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU is
	generic(B: natural := 32);
	port (
		a, b: in std_logic_vector(B-1 downto 0);
		op: in std_logic_vector(3 downto 0);
		result: out std_logic_vector(B-1 downto 0);
		zero: out std_logic
	);
end ALU;

architecture beh of ALU is 
	signal add : std_logic_vector(3 downto 0) := "0001";
	signal sub : std_logic_vector(3 downto 0) := "0010";
	signal slt : std_logic_vector(3 downto 0) := "0011";
	signal beq : std_logic_vector(3 downto 0) := "0100";
	signal bne : std_logic_vector(3 downto 0) := "0101";
	signal op_and : std_logic_vector(3 downto 0) := "0110";
	signal op_or : std_logic_vector(3 downto 0) := "0111";
	signal op_nor : std_logic_vector(3 downto 0) := "1000";
	signal op_xor : std_logic_vector(3 downto 0) := "1001";
	signal shiftleft_L : std_logic_vector(3 downto 0) := "1010";
	signal shiftright_L : std_logic_vector(3 downto 0) := "1011";
	signal shiftright_A : std_logic_vector(3 downto 0) := "1100";
begin
	result <=	a + b when(op = add) else
					a - b when(op = sub) else
					a and b when(op = op_and) else
					a or b when(op = op_or) else
					a nor b when(op = op_nor) else
					a xor b when(op = op_xor) else
					shift_left(a, to_integer(b)) when(op = shiftleft_L) else
					shift_right(a, to_integer(b)) when(op = shiftright_L) else
					unsigned(shift_right(signed(a), to_integer(b))) when(op = shiftright_A) else
					"00000000000000000000000000000001" when(op = slt and a < b) else
					"00000000000000000000000000000000";
					
	zero <=	'1' when(op = beq and a = b) else
				'0' when(op = beq and a /= b) else
				'1' when(op = bne and a /= b) else
				'0';
end beh;