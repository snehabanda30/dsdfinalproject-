# DSDFinalProject : COLLECT 

## Introduction
In **COLLECT**, player must get five points by collecting green circles and avoiding red squares.  

**GOAL**: Player should collect circles, while red squares are also falling down.  

**Score**: Displays score on the board. 
          **Increments** when a green ball hits bat
           **Decrements** when a red square hits bat  


## Attachments:
[NI Digilent Nexys A7-100T FPGA Trainer Board](https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/)

![NI Digilent Nexys A7-100T FPGA Trainer Board](NexysA7-obl-600__85101.jpg)

## Video (Sneha)

## Steps to Run Project (Sneha)

## Modifications 
WRITE DESCRIPITION OF PROJECT --> Any inspiration for project --> pong lab and project evade 
PLACE PICTURE ENTITY TREE
### Set of nine balls
* Nine balls were initialized with different X coordinates and a Y coordinate set to zero to display the balls at various positions across the top of the screen.
* A new variable called 'ball_on_screen' was created as a std_logic_vector(8 downto 0) to manage the visibility of the nine balls on the screen.
* For the balls to move vertically (in the y direction), all ball_x_motion values are set to zero, while ball_y_motion is determined by the specified ball_speed.

```vhdl
    SIGNAL start_pos : STD_LOGIC_VECTOR(10 downto 0);
    SIGNAL ball_x0 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(100, 11);
    SIGNAL ball_x1 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(350, 11);
    SIGNAL ball_x2 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450, 11);
    SIGNAL ball_x3 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(550, 11);
    SIGNAL ball_x4 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(650, 11);
    SIGNAL ball_x5 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(750, 11);
    SIGNAL ball_y0, ball_y1, ball_y2,ball_y3,ball_y4,ball_y5 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion0, ball_x_motion1, ball_x_motion2,ball_x_motion3,ball_x_motion4,ball_x_motion5 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,11);
    SIGNAL ball_y_motion0, ball_y_motion1, ball_y_motion2,ball_y_motion3,ball_y_motion4,ball_y_motion5 : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    SIGNAL ball_on_screen : std_logic_vector(5 DOWNTO 0) := (OTHERS => '0')
```
### Pixel Encoding 
* Determines the colors of the balls and squares
* The ball_on(0), ball_on(2),ball_on(6) or ball_on(8) are green circles. ball_on(1), ball_on(3),ball_on(4),ball_on(5) and ball_on(7) are red
```vhdl
    red <=NOT (ball_on(0) or ball_on(2) or ball_on(6) or ball_on(8));  -- color setup
    green <= NOT (ball_on(1) or ball_on(3) or ball_on(4) or ball_on(5) or ball_on(7));
    blue <= NOT (bat_on or ball_on(1)OR ball_on(0)or ball_on(2)or ball_on(3)or ball_on(4)or   ball_on(5) or ball_on(6) or ball_on(7) or ball_on(8));
    
```
### Drawing Circles and Squares (Sneha)
* The group used the circle equation multiple times to draw each ball. The If/Else statement is used to turn the pixels on and off based on circle equation.
```vhdl
IF ball_on_screen(0) = '1' THEN 
        IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x0))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y0))**2) <= (bsize*bsize) THEN
                ball_on(0) <= '1';
            ELSE
                ball_on(0) <= '0';
        END IF;
    END IF;
```
* The group used the square equation multiple times to draw each square. The If/Else statement is used to turn the pixels on and off to create a square.
```vhdl
IF ball_on_screen(1) = '1' THEN 
            IF pixel_col >= ball_x1 - bsize AND
            pixel_col <= ball_x1 + bsize AND
                pixel_row >= ball_y1 - bsize AND
                pixel_row <= ball_y1 + bsize THEN
                   ball_on(1) <= '1';
            ELSE
                ball_on(1) <= '0';
            END IF;
        END IF;
```
### Ball-Basket Collisions
* Original Code
```vhdl
 -- allow for bounce off bat
        IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
         (ball_x - bsize/2) <= (bat_x + bat_w) AND
             (ball_y + bsize/2) >= (bat_y - bat_h) AND
             (ball_y - bsize/2) <= (bat_y + bat_h) THEN
                ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        END IF;
```
* Altered Code
```vhdl
WHEN START_COLL =>
                -- allow ball to fall into basket
                IF (ball_x0 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x0 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y0 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y0 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(0) <= '0'; -- turns off pixels 
                           game_on(0) <= '0'; -- resets motion
                           -- ...
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;
```
* The group utilized the collision logic provided to us from the original Pong lab, however they edited the code to simulate the ball falling into a basket, rather than allow the ball to bounce off of the bat.
* Once the ball collides with the bat, which is based on the provided conditions, ```ball_on_screen(i) <= '0'```, which allows the pixels to turn off.
* ```game_on(i) <= '0'```, resulting in the motion of the ball to cease.
* ```ps_state <= pr_state``` which is important for the ability of the balls to respawn.
### Ball-Wall Collisions 
* Once the ball reaches the bottom of screen (at 600 pixels), the ball wall will disappear
  *   The equation adds the current ball position and the radius of the ball.
  *   The ball_on_screen signal will be set to zero.
  *   The game_on(0) signal is set to '0'.
  **   The state returns to Enter_Game.
```vhdl
ELSIF ball_y0 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(0) <= '0';
                           game_on(0) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME; 
```
### Motion (Sneha)
### Respawn Logic
* Original Code
```vhdl
WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels

  -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(440, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
        -- compute next ball horizontal position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_x is close to zero and ball_x_motion is negative
        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
        IF temp(11) = '1' THEN
            ball_x <= (OTHERS => '0');
        ELSE ball_x <= temp(10 DOWNTO 0);
        END IF;
```
* Altered Code
```vhdl
WHEN ENTER GAME =>
        -- respawns ball and initializes motion
        IF (game_on(1) = '0' AND ball_on_screen(1) = '0' AND ps_state = START_COLL) THEN
                    game_on(1) <= '1';
                    ball_on_screen(1) <= '1';
                    ball_y_motion1 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
-- resets x and y positions of ball after it collides with bat
temp := ('0' & ball_y0) + (ball_y_motion0(10) & ball_y_motion0);
                        IF game_on(0) = '0' THEN
                            ball_y0 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x0 <= conv_std_logic_vector(conv_integer(start_pos) * 5 mod 700, 11);
                        ELSIF temp(11) = '1' THEN
                            ball_y0 <= (OTHERS => '0');
                        ELSE ball_y0 <= temp(10 DOWNTO 0);
                        END IF;
```
* The original code allows for balls to manually respawn when the button that turns the serve signal "on" is depressed
* This code also utilizes the temp variable to reset the x and y position.
* The group's altered code utilizes the temp variable to reset the balls' positions, randomly selecting x positions based on a unique factor for each temp variable, when ```game_on(i) = '0'```, which occurs after a collision.
* However, they also set the next state to ```ENTER_GAME``` once a collison occurs, and it is in this state that ball's pixels turn on and the motion is reset.
### Respawning in Random x-Positions.
```vhdl
randomizer: PROCESS IS
     VARIABLE rand : INTEGER;        
    BEGIN
        WAIT UNTIL (falling_edge(v_sync));
        rand := conv_integer(conv_std_logic_vector(counter, 11) XOR bat_x XOR pixel_row XOR pixel_col) mod 700 ;
        start_pos <= conv_std_logic_vector(rand,11);
```
* The group utilized code from the [Evade Game -- Final Project Work for Digital System Design](https://github.com/Aoli03/DSD-Final-Lab-Project/tree/main?tab=readme-ov-file) in order to set random x positions for the balls before they respawned.
* Assigned on the falling edge of every clock cycle.
* Mod division 700 prevents the balls from spawning off screen.
### Finite State Machine 
* Original Code
```vhdl
mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        ELSIF ball_y <= bsize THEN -- bounce off top wall
            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
        ELSIF ball_y + bsize >= 600 THEN -- if ball meets bottom wall
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            game_on <= '0'; -- and make ball disappear
        END IF;
```  
* Altered Code
```vhdl
CASE pr_state IS 
 WHEN ENTER_GAME =>
                IF serve = '1' THEN
                    nx_state <= SERVE_RELEASE;
WHEN SERVE_RELEASE =>
               IF serve = '0' THEN
                    hit_counter <= "0000000000000000";
                    display_hits <= hit_counter;
                -- ...
                    nx_state <= ENTER_GAME;
               ELSE nx_state <= SERVE_RELEASE;
               END IF;
WHEN START_COLL =>
                -- ...
WHEN END_GAME =>
                -- ...                
```
* In order to implement respawn logic, the best course of action for the group was to implement a Finite State Machine (FSM), which would re-enter the enter game state and respawn the balls once a collision occurs.
* States:   
  * ENTER_GAME: Initializes ball motion and pixels after serve button is released.
  * SERVE_RELEASE: initializes hit counter and turns game and balls on
  * START_COLL: Checks for collisions and distributes points accordingly
  * END__GAME: game ends end and balls would stop respawning if the player reaches either 0 or 5 points. 
### Corrected Hit_Counter Incrementation
* Counter will **increase**  when a green ball hits and **decrease** when red square hits the bat.
     * Checks to see if **hit_counter <= "0000000000000000"**  to see whether the state will 
     change to END_GAME 
     * If the **collision_detected** is true, then **hit_counter <= hit_counter - / + 
      "0000000000000001";**.
```vhdl
 IF (ball_x1 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x1 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y1 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y1 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(1) <= '0';
                           game_on(1) <= '0';
                           If hit_counter <= "0000000000000000" THEN
                                ps_state <= pr_state;
                                nx_state <= END_GAME;
                           ELSE
                                ps_state <= pr_state;
                                nx_state <= ENTER_GAME;
                           end if; 
                           if not collision_detected then
                           hit_counter <= hit_counter - "0000000000000001";
                           end if;
                           display_hits <= hit_counter;
                           collision_detected <= TRUE;          
                ELSIF ball_y1 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(1) <= '0';
                           game_on(1) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF;

```
* If the next tate becomes ENTER_GAME, then the collision_detected resets to False.   
```
IF nx_state = ENTER_GAME THEN
                    collision_detected <= FALSE;
                END IF;
```
### Sound Effects (Naz)
* The music was intended to operate similar to a MIDI player, drawing inspiration from the project [Tetris_Music](https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/). This project utilized fixed notes and square waves, aligning with a similar logical framework.
* To create the sound effects for the game an online midi sequencer was utilized. This is the simple sound effect that the team decided on when the player start and ends the game: [Collect_Music](https://onlinesequencer.net/3988488).
* First File that was added to achieve that sound was ```game_sound_effects.vhd```.
* The code dynamically changes the note output signal to produce different notes when the sound is enabled, following a predefined duration for each note when the **sound_onn** is '1' as shown below:
```vhdl
 SIGNAL NOTE_DURATION : INTEGER := 4880000;  -- Duration for each note
    SIGNAL note_counter : INTEGER := 0;
BEGIN
    sound_effects : PROCESS (clk) 
    BEGIN
        IF rising_edge(clk) THEN
           if sound_onn <= '1'THEN 
                note_counter <= note_counter + 1;
                --nx_state <= pr_state;
                    IF note_counter < NOTE_DURATION THEN
                        note <= "01111";
                    Elsif note_counter >NOTE_DURATION AND note_counter < NOTE_DURATION *2 THEN
                        note <= "01000";
                  --...
```
* The code outputs the played notes and the aud_clk signal to the ```WaveGenerator.vhd``` file. This helps with processing, as that file functions as a clock divider, generating square waves that are subsequently transformed into audio signals.
```vhdl
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
```
* The code:
  * Compares the 5-bit input to a 32-entry lookup table associating each bit combination with a note
  * Utilizes calculated values for each note in a clock divider.
  * Divides the input 48.8KHz clock by the corresponding table value.
  * Generates a temporary clock with the desired frequency.
  * Outputs a 16-bit signed value (either 10240 or -10240) based on the state of the new clock signal.
* The team specifically included only the four mentioned notes. 
* **tonee** epresents the resulting audio data output.
* Also ```ClkDiv2.vhd``` was incorporated to halve the 100 MHz system clock to 50 MHz. This was done to align with the lab 5 inspired sections of the code, which specifically required a 50 MHz clock.
```vhdl
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
```

## Process Summary (Sneha)

## Important Ports and Signals (Pre)
* ```ball_on_screen(8 downto 0)```, ```ball_on(8 downto 0)```, ```game_on(8 downto 0)```: controls individual balls' pixels, drawing, and motions
* ```collision_detected```: boolean signal that toggles "true" when a collision occurs, flag that prevents hit_counter from incrementing more than once after a collision occurs.
* ```pr_state```,```nx_state```: signals that are assigned states after every clock cycle.
* ```display_hits```, ```hit_counter```: the port that communicates with leddec regarding the number of points a player has received, corresponding signal that counts hits based on the occurence of collisions between the balls and bat

## Contributions 
* Sneha was responsible for the creation of multiple balls and aided with the drawing and respawn logic.
* Nazanin was responsible for the music, debugged the hit_counter signal so that it would increment correctly within the FSM, and implemented drawing logic for the balls.
* Prerana worked on the conception of the newly implemented motion logic FSM and contributed to the development of the respawn logic.
