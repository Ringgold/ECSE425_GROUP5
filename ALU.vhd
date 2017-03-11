LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU is
	generic(B: natural := 32);
	port (
		a, b: in std_logic_vector(B-1 downto 0);
		op: in std_logic_vector(3 downto 0);
		result: out std_logic_vector(B-1 downto 0) := "00000000000000000000000000000000";
		zero: out std_logic := '0'
	);
end ALU;

architecture beh of ALU is 
	signal hi : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal lo : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

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
	hi <= std_logic_vector(signed(a) * signed(b))(63 downto 32) when(op = mult) else
			std_logic_vector(signed(a) rem signed(b)) when(op = div);

	lo <= std_logic_vector(signed(a) * signed(b))(31 downto 0) when(op = mult) else
			std_logic_vector(signed(a) / signed(b)) when(op = div);


	result <=	a + b when(op = add) else
					a - b when(op = sub) else
					a and b when(op = op_and) else
					a or b when(op = op_or) else
					a nor b when(op = op_nor) else
					a xor b when(op = op_xor) else
					hi when(op = mfhi) else
					lo when(op = mflo) else
					shift_left(a, 16) when(op = lui) else
					shift_left(a, to_integer(b)) when(op = shiftleft_L) else
					shift_right(a, to_integer(b)) when(op = shiftright_L) else
					unsigned(shift_right(signed(a), to_integer(b))) when(op = shiftright_A) else
					"00000000000000000000000000000001" when(op = slt and a < b) else
					"00000000000000000000000000000000";
					
	zero <=	'1' when(op = beq and a = b) else
				'0';
end beh;
