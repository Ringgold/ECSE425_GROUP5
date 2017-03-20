library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB_stage is
  port(
  clock : in std_logic;
	stall: in std_logic;
	src: in std_logic;								-- if src='0', take read_data; elif src='1', take alu_result
	read_data: in std_logic_vector(31 downto 0);
	alu_result: in std_logic_vector(31 downto 0) := (others => '0');
	destination_reg: in std_logic_vector(4 downto 0);
	write_en: in std_logic := '0';

	code    : in std_logic_vector(31 downto 0);
    code_go : out std_logic_vector(31 downto 0);

	destination_reg_go: out std_logic_vector(4 downto 0);
	write_en_go: out std_logic := '0';
	output : out std_logic_vector(31 downto 0) := (others => '0')
  );
end WB_stage;

architecture beh of WB_stage is
  signal RD : std_logic_vector(31 downto 0);
  signal Alu_res : std_logic_vector(31 downto 0);
  signal Mux_src : std_logic;
  signal Mux_res : std_logic_vector(31 downto 0);
  
  component Mux
    port(
		x, y: in std_logic_vector(31 downto 0);
		s: in std_logic;
		output: out std_logic_vector(31 downto 0)
    );
  end component;
  
begin
MUX1: MUX port map(RD, Alu_res, Mux_src, Mux_res);

	--write_back: process(clock)
	--begin
	--	if rising_edge(clock) then
	--		if (stall='0') then
				code_go <= code;
				RD <= read_data;
				Alu_res <= alu_result;
				Mux_src <= src;
				output <= Mux_res;
				destination_reg_go <= destination_reg;
				write_en_go <= write_en;
	--		end if;	
	--	end if;
	-- end process;

end beh;

      
  
  
