# DSDFinalProject : COLLECT 

# Introduction (Sneha)


# Attachments:
[NI Digilent Nexys A7-100T FPGA Trainer Board](https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/)


### A description of the expected behavior of the project, attachments needed (speaker module, VGA connector, etc.), related images/diagrams, etc. (10 points of the Submission category)
* The more detailed the better – you all know how much I love a good finite state machine and Boolean logic, so those could be some good ideas if appropriate for your system. If not, some kind of high level block diagram showing how different parts of your program connect together and/or showing how what you have created might fit into a more complete system could be appropriate instead.

# Video (Sneha)

# Steps to Run Project (Sneha)

# Modifications 
WRITE DESCRIPITION OF PROJECT --> Any inspiration for project --> pong lab and project evade 
PLACE PICTURE ENTITY TREE
## Main Modifications 
### set of six balls (Sneha)
*
### Pixel encoding (Sneha)

### Drawing (Sneha)
### ball - basket collisions
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
### ball - wall collisions (Sneha)
### motion
### respawn logic
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
### random respawn positions
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
### finite state machine (Pre)
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
### display hit_counter correct incrementation (Sneha)
### Music (Naz)

# Process Summary (Sneha)

# Important Ports and Signals (Pre)
* ```ball_on_screen(8 downto 0)```, ```ball_on(8 downto 0)```, ```game_on(8 downto 0)```: controls individual balls' pixels, drawing, and motions
* ```collision_detected```: boolean signal that toggles "true" when a collision occurs, flag that prevents hit_counter from incrementing more than once after a collision occurs.
* ```pr_state```,```nx_state```: signals that are assigned states after every clock cycle.
* ```display_hits```, ```hit_counter```: the port that communicates with leddec regarding the number of points a player has received, corresponding signal that counts hits based on the occurence of collisions between the balls and bat

### Description of inputs from and outputs to the Nexys board from the Vivado project (10 points of the Submission category)
  * As part of this category, if using starter code of some kind (discussed below), you should add at least one input and at least one output appropriate to your project to demonstrate your understa
nding of modifying the ports of your various architectures and components in VHDL as well as the separate .xdc constraints file.

# Contributions 



