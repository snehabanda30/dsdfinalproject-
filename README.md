# DSD Final Project : COLLECT 

# Introduction (Sneha)
In **COLLECT**, player must collect 5 circles and avoid squares. 

**GOAL**: Player should collect circles, while red squares are also falling down.  

**Score**: Displays score on the board. 
          **Increments** when a green ball hits bat
           **Decrements** when a red square hits bat  
# Expected Behavior 

COLLECT was developed from the lab 6 baseline code. Once the game appears on the monitor, a starting audio will play. The player will press on BTNC to make 5 squares and 4 circles appear with different speeds and locations. The player will need to use the BTNR and BTNL button to move the bat across the screen to catch the green circle. If the player catches the green circle, then the score increments by one. If the player mistakenly catches the red square, then the score will decrement by one. Once the player gets five points, the player has won the game and can restart the game. However, when the game is in play and score reaches zero, the player has lost the game and must restart.  


# Attachments: (Pre)

# Video (Sneha)
![image](screen.gif) 

![image](winningandlosingonboard.gif)
# Steps to Run Project (Sneha)
1. Download files: clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync, bat_n_ball, leddec16,pong and opng_2.xdc  
2. Connect the monitor's HDMI cable to VGA. Also, connect the VGA to Nexys A7-100T board by powering with a USB cable and connecting aux cord to board.  
3. Connect the board via a PROG UART to computer to upload code. 
4. Run Synthesis 
5. Run Implementation
6. Generate bitstream, open hardware manager, and program device
7. Press down BTNC to begin game
   * Use the BTNL and BTNR to move the bat across the screen
# Modifications 
WRITE DESCRIPITION OF PROJECT --> Any inspiration for project --> pong lab and project evade 
PLACE PICTURE ENTITY TREE
## Main Modifications 
### Set of Six Balls (Sneha) 
* Six balls were initialized with different X coordinates and a Y coordinate set to zero to display the balls at various positions across the top of the screen.
* A new variable called 'ball_on_screen' was created as a std_logic_vector(5 downto 0) to manage the visibility of the six balls on the screen.
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
### Pixel encoding (Sneha)
* Determines the colors of the balls and squares
* The ball_on(0), ball_on(2),ball_on(6) or ball_on(8) are green circles. ball_on(1), ball_on(3),ball_on(4),ball_on(5) and ball_on(7) are red
```
    red <=NOT (ball_on(0) or ball_on(2) or ball_on(6) or ball_on(8));  -- color setup
    green <= NOT (ball_on(1) or ball_on(3) or ball_on(4) or ball_on(5) or ball_on(7));
    blue <= NOT (bat_on or ball_on(1)OR ball_on(0)or ball_on(2)or ball_on(3)or ball_on(4)or   ball_on(5) or ball_on(6) or ball_on(7) or ball_on(8));
    
```
### Drawing Circles and Squares (Sneha)
* The group used the circle equation multiple times to draw each ball. The If/Else statement is used to turn the pixels on and off based on circle equation.
```
IF ball_on_screen(0) = '1' THEN 
        IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x0))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y0))**2) <= (bsize*bsize) THEN
                ball_on(0) <= '1';
            ELSE
                ball_on(0) <= '0';
        END IF;
    END IF;
```
* The group used the square equation multiple times to draw each square. The If/Else statement is used to turn the pixels on and off to create a square.
```
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
### ball - basket collisions (Pre)
*
### ball - wall collisions (Sneha)
* Once the ball reaches the bottom of screen (at 600 pixels), the ball wall will disappear
  *   The equation adds the current ball position and the radius of the ball.
  *   The ball_on_screen signal will be set to zero.
  *   The game_on(0) signal is set to '0'.
  **   The state returns to Enter_Game.
```
ELSIF ball_y0 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(0) <= '0';
                           game_on(0) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME; 
```
### respawn logic (Pre)
### random respawn positions (Pre)
### finite state machine (Pre)
### Hit_counter incrementation (Sneha) 
* Counter will **increase**  when a green ball hits and **decrease** when red square hits the bat.
     * Checks to see if **hit_counter <= "0000000000000000"**  to see whether the state will 
     change to END_GAME 
     * If the **collision_detected** is true, then **hit_counter <= hit_counter - / + 
      "0000000000000001";**.
```
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
### Music (Naz)
### Score (Naz)

# Process Summary (Sneha)
*CHALLENGES 
*  The team faced challenges with the ball respawning after each collision.
     * The team If/Else statements for the collision logic.The code below demonstrates that  no if/else statement do not allow ball to respawn. Ball movement changes only once. 
 
**INITIAL CODE**
``` VHDL 
IF  ball_on_screen(1) = '0' AND game_on = '1'  THEN -- test for new serve
            game_on <= '1';
            ball_on_screen(1) <= '1';
            ball_y_motion1 <= (NOT ball_speed) + 1; 
            --ball_on_screen(1) <= '1';
           -- ball_y_motion1 <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
ELSIF ball_y1 <= bsize THEN -- bounce off top wall
            ball_y_motion1 <= ball_speed; -- set vspeed to (+ ball_speed) pixels
ELSIF ball_y1 + bsize >= 600 THEN -- if ball meets bottom wall
            --ball_y_motion1 <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            game_on <= '0'; -- and make ball disappear
            ball_on_screen(1) <= '0';
END IF;
        -- allow for bounce off left or right of screen
IF ball_x1 + bsize >= 800 THEN -- bounce off right wall
            ball_x_motion1 <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
ELSIF ball_x1 <= bsize THEN -- bounce off left wall
            ball_x_motion1 <= ball_speed; -- set hspeed to (+ ball_speed) pixels
END IF;
        -- allow for ball to fall off
IF (ball_x1 + bsize/2) >= (bat_x - bat_w) AND
(ball_x1 - bsize/2) <= (bat_x + bat_w) AND
(ball_y0 + bsize/2) >= (bat_y - bat_h) AND
(ball_y0 - bsize/2) <= (bat_y + bat_h) THEN
         ball_on_screen(1) <= '0';
END IF;
```
* In order to combat the issue, the team needed to create multiple temp variables to move the ball regardless of current ball motion.  Once game_on <= '0', the ball will reposition itself to another random location and move the ball.  

**FINAL CODE**
``` VHDL 
temp := ('0' & ball_y0) + (ball_y_motion0(10) & ball_y_motion0);
                        IF game_on(0) = '0' THEN
                            ball_y0 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x0 <= conv_std_logic_vector(conv_integer(start_pos) * 5 mod 700, 11);
                        ELSIF temp(11) = '1' THEN
                            ball_y0 <= (OTHERS => '0');
                        ELSE ball_y0 <= temp(10 DOWNTO 0); -- 9 downto 0
                        END IF;
              temp1 := ('0' & ball_y1) + (ball_y_motion1(10) & ball_y_motion1);
                        IF game_on(1) = '0' THEN
                            ball_y1 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x1 <= conv_std_logic_vector(conv_integer(start_pos) * 6 mod 700, 11);
                        ELSIF temp1(11) = '1' THEN
                            ball_y1 <= (OTHERS => '0');
                        ELSE ball_y1 <= temp1(10 DOWNTO 0); -- 9 downto 0
                        END IF;
```
* With the temp additions, the ball infinitely respawn without considering collisions. Hence, the team decided to no longer use If/Else statements. An FSM was needed for respawn to occur. Initially, the team had four states, ENTER_GAME,SERVE_RELEASE, START_COLLISION and RESPAWN state. However, the respawn state was unnecessary instead new signals for past state and present state were created and used within the conditions to respawn.

**EXAMPLE OF PAST & PRESENT STATES**
```VHDL
ELSIF (game_on(0) = '0' AND ball_on_screen(0) = '0' AND ps_state = START_COLL) THEN
                    game_on(0) <= '1';
                    ball_on_screen(0) <= '1';
                    ball_y_motion0 <= ball_speed + 3;
                    nx_state <= START_COLL;
                ELSE nx_state <= ENTER_GAME;
                END IF; 
 ```




