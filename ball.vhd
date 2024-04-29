LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real.all;
use IEEE.math_complex.all;

ENTITY ball IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC
	);
END ball;

ARCHITECTURE Behavioral OF ball IS
	CONSTANT size  : INTEGER := 10;
	SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	-- current ball position - intitialized to center of screen
	SIGNAL ball_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL ball_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current ball motion - initialized to +4 pixels/frame
	SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	SIGNAL ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
BEGIN
	green <= '1'; -- color setup for red ball on white background
	red <= NOT ball_on;
	blue  <= NOT ball_on;
	-- process to draw ball current pixel address is covered by ball position
	bdraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
	BEGIN
	   IF (pixel_col >= ball_x - size) AND
		    (pixel_col <= ball_x + size) AND
			(pixel_row >= ball_y - size) AND
			(pixel_row <= ball_y + size) THEN
			     ball_on <= '1';
		ELSE
			ball_on <= '0';
		END IF;
   -- IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y))**2) <= (size*size) THEN
       -- ball_on <= '1'; -- inside the circle
      --IF (CONV_INTEGER(pixel_col) <= CONV_INTEGER(ball_x) + CONV_INTEGER(size)) AND
	     --(CONV_INTEGER(pixel_row) <= CONV_INTEGER(ball_y) + CONV_INTEGER(size)) AND
		-- (CONV_INTEGER(ball_y) <= CONV_INTEGER(pixel_row) + CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x)) THEN
		IF (CONV_INTEGER(pixel_col) <= CONV_INTEGER(ball_x) + CONV_INTEGER(size)) AND
	     (CONV_INTEGER(pixel_row) <= CONV_INTEGER(ball_y) + CONV_INTEGER(size)) AND
		 (CONV_INTEGER(ball_y) <= CONV_INTEGER(pixel_row)- CONV_INTEGER(ball_x)) THEN
	 				ball_on <= '1';
      ELSE
         ball_on <= '0'; -- outside the circle
      END IF;
END PROCESS;
 		-- process to move ball once every frame (i.e. once every vsync pulse)
		mball : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF ball_x + size >= 800 THEN
				ball_x_motion <= "11111111100"; -- -4 pixels
			ELSIF ball_x <= size THEN
				ball_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			IF ball_y + size >= 600 THEN
				ball_y_motion <= "11111111100"; -- -4 pixels
			ELSIF ball_y <= size THEN
				ball_y_motion <= "00000000100"; -- +4 pixels
			END IF;
			ball_y <= ball_y + ball_y_motion; -- compute next ball position
			ball_x <= ball_x +ball_x_motion;
		END PROCESS;
END Behavioral;
