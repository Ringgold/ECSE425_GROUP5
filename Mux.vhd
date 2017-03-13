LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Mux is
	port (
		x, y: in std_logic_vector(31 downto 0);
		s: in std_logic;
		output: out std_logic_vector(31 downto 0)
	);
end Mux;

architecture beh of Mux is 
begin
	output <= x when (s='0') else y;
end beh;
