LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY WaveGenerator IS
	PORT (
		aud_clk : IN std_logic; --48.8khz
		notee : IN std_logic_vector (4 DOWNTO 0);
		tonee : OUT signed (15 DOWNTO 0)
	);
END WaveGenerator;

ARCHITECTURE Behavioral OF WaveGenerator IS
	SIGNAL tmp_clk : std_logic := '0';
BEGIN
	square : PROCESS (aud_clk, tmp_clk, notee) 
		VARIABLE div_cnt : INTEGER := 0;
		VARIABLE max_count : INTEGER := 0;
	BEGIN
		CASE notee IS --When the clock speed is 48800hz
			WHEN "00000" => max_count := 0; --empty note
			WHEN "01111" => max_count := 52; --A#5 52
			WHEN "01000" => max_count := 55; --A5 55
			WHEN "00111" => max_count := 62; --G#5 62
			WHEN "01001" => max_count := 65; --G5 70
			WHEN OTHERS => 
		END CASE;
		IF (rising_edge(aud_clk)) THEN
			IF (div_cnt >= max_count) THEN
				tmp_clk <= NOT tmp_clk;
				div_cnt := 0;
			ELSE
				div_cnt := div_cnt + 2;
			END IF;
		END IF;

		IF (notee = "00000") THEN
			tonee <= "0000000000000000";
		ELSE
			CASE tmp_clk IS
				WHEN '0' => tonee <= TO_SIGNED(10240, 16);
				WHEN '1' => tonee <= TO_SIGNED( - 10240, 16);
			END CASE;
		END IF;
 
	END PROCESS square;
END Behavioral;
