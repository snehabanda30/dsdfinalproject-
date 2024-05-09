LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CLKDIV2 IS
	PORT (
		inclk : IN std_logic;
		Clk50 : OUT std_logic
	);
END CLKDIV2;

ARCHITECTURE Behavioral OF CLKDIV2 IS
	SIGNAL count : INTEGER := 1;
	SIGNAL clk_reg : std_logic := '0';
	SIGNAL counter : INTEGER := 0;
BEGIN
	PROCESS (inclk)
	BEGIN
		IF rising_edge(inclk) THEN
			IF (counter >= count) THEN
				counter <= 0;
				clk_reg <= NOT(clk_reg);
			ELSE
				counter <= counter + 1;
			END IF;
		END IF;
	END PROCESS;
	Clk50 <= clk_reg;
END Behavioral;
