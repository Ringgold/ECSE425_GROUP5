LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU is
	port (
		a, b: in std_logic_vector(31 downto 0);
		op: in std_logic_vector(3 downto 0);
		result: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
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

	signal long : std_logic_vector(63 downto 0);

begin
	
	long <= std_logic_vector(signed(a) * signed(b));
	
	hi <= 	long(63 downto 32) when(op = mult) else
			std_logic_vector(signed(a) rem signed(b)) when(op = div);

	lo <= 	long(31 downto 0) when(op = mult) else
			std_logic_vector(signed(a) / signed(b)) when(op = div);


	result <=		std_logic_vector(signed(a) + signed(b)) when(op = add) else
					std_logic_vector(signed(a) - signed(b)) when(op = sub) else
					a and b when(op = op_and) else
					a or b when(op = op_or) else
					a nor b when(op = op_nor) else
					a xor b when(op = op_xor) else
					hi when(op = mfhi) else
					lo when(op = mflo) else
					std_logic_vector(shift_left(signed(a), 16)) when(op = lui) else
					std_logic_vector(shift_left(signed(a), to_integer(signed(b)))) when(op = shiftleft_L) else
					std_logic_vector(shift_right(signed(a), to_integer(signed(b)))) when(op = shiftright_L) else
					To_StdLogicVector(to_bitvector(a) sra to_integer(signed(b))) when(op = shiftright_A) else
					"00000000000000000000000000000001" when(op = slt and a < b) else
					"00000000000000000000000000000000";
					
	zero <=		'1' when(op = beq and a = b) else
				'0';
end beh;
