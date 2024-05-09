-- Inspired by https://github.com/fabioperez/space-invaders-vhdl/blob/master/lib/general/general.vhd
-- Inspired by https://github.com/Aoli03/DSD-Final-Lab-Project/blob/main/bat_n_ball.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
-- first the ball falls into the basket 
-- second make sure the ball just keeps falling regardless of whether it is there 
    -- the ball will keep falling when we see the serve 
ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        serve : IN STD_LOGIC; -- initiates serve 
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        SW : IN UNSIGNED (4 DOWNTO 0);
        display_hits: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        sound: OUT STD_LOGIC
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    SIGNAL bat_w : INTEGER := 35; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 45; -- bat height in pixels
    SIGNAL hit_counter : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL count_tmp : STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- ADD AN INTEGER 
    -- distance ball moves each frame
    --CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
   -- SIGNAL ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
    SIGNAL ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL ball_on : STD_LOGIC_VECTOR (8 DOWNTO 0):= (OTHERS => '0'); -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC_VECTOR (8 DOWNTO 0) := "000000000"; -- indicates whether ball is in play
    --SIGNAL game_on1 : STD_LOGIC := '0';
    -- current ball position - intitialized to center of screen
    SIGNAL start_pos : STD_LOGIC_VECTOR(10 downto 0);
    SIGNAL ball_x0 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(100, 11);
    SIGNAL ball_x1 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(150, 11);
    SIGNAL ball_x2 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
    SIGNAL ball_x3 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    SIGNAL ball_x4 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_x5 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    SIGNAL ball_x6 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(600, 11);
    SIGNAL ball_x7 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(650, 11); 
    SIGNAL ball_x8 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(750, 11); 
    SIGNAL ball_y0, ball_y1, ball_y2,ball_y3,ball_y4,ball_y5,ball_y6,ball_y7,ball_y8 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion0, ball_x_motion1, ball_x_motion2,ball_x_motion3,ball_x_motion4,ball_x_motion5,ball_x_motion6,ball_x_motion7,ball_x_motion8 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,11);
    SIGNAL ball_y_motion0, ball_y_motion1, ball_y_motion2,ball_y_motion3,ball_y_motion4,ball_y_motion5,ball_y_motion6,ball_y_motion7,ball_y_motion8 : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    SIGNAL ball_on_screen : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');
    --SIGNAL show_x : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL counter: INTEGER := 0;
    SIGNAL counter1 : INTEGER := 0;
    SIGNAL counter2 : INTEGER := 2;
    SIGNAL collision_detected : BOOLEAN := FALSE;
     SIGNAL sound_on : STD_LOGIC := '0';
    TYPE state IS (ENTER_GAME, SERVE_RELEASE, START_COLL,END_GAME);
    SIGNAL ps_state, pr_state, nx_state : state;
    --SIGNAL start_pos : STD_LOGIC_VECTOR(10 downto 0);
BEGIN
    red <=NOT (ball_on(0) or ball_on(2) or ball_on(6) or ball_on(8));  -- color setup
    green <= NOT (ball_on(1) or ball_on(3) or ball_on(4) or ball_on(5) or ball_on(7));
    blue <= NOT (bat_on or ball_on(1)OR ball_on(0)or ball_on(2)or ball_on(3)or ball_on(4)or ball_on(5) or ball_on(6) or ball_on(7) or ball_on(8));
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position


    -- use binary conversion to get from 0-31 to 1-32 range for problem with each switch representing a bit
    balldraw : PROCESS (ball_x0, ball_y0, ball_x1, ball_y1,ball_x2, ball_y2,ball_x3, ball_y3,ball_x4, ball_y4, ball_x5, ball_y5, ball_x6, ball_y6, ball_x7, ball_y7,ball_x8, ball_y8, pixel_row, pixel_col) IS
        VARIABLE vx0, vy0, vx1, vy1, vx2, vy2 : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
    IF ball_on_screen(0) = '1' THEN 
        IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x0))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y0))**2) <= (bsize*bsize) THEN
                ball_on(0) <= '1';
            ELSE
                ball_on(0) <= '0';
        END IF;
    END IF;
    -- draw second sqaure
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
    -- draw third circle
    IF ball_on_screen(2) = '1' THEN 
        IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x2))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y2))**2) <= (bsize*bsize) THEN
                   ball_on(2) <= '1';
            ELSE
                ball_on(2) <= '0';
            END IF;
    END IF;
    IF ball_on_screen(3) = '1' THEN 
            IF pixel_col >= ball_x3 - bsize AND
            pixel_col <= ball_x3 + bsize AND
                pixel_row >= ball_y3 - bsize AND
                pixel_row <= ball_y3 + bsize THEN
                   ball_on(3) <= '1';
            ELSE
                ball_on(3) <= '0';
            END IF;
      END IF;
      IF ball_on_screen(4) = '1' THEN 
            IF pixel_col >= ball_x4 - bsize AND
            pixel_col <= ball_x4 + bsize AND
                pixel_row >= ball_y4 - bsize AND
                pixel_row <= ball_y4 + bsize THEN
                   ball_on(4) <= '1';
            ELSE
                ball_on(4) <= '0';
            END IF;
       END IF;
       IF ball_on_screen(5) = '1' THEN 
            IF pixel_col >= ball_x5 - bsize AND
            pixel_col <= ball_x5 + bsize AND
                pixel_row >= ball_y5 - bsize AND
                pixel_row <= ball_y5 + bsize THEN
                   ball_on(5) <= '1';
            ELSE
                ball_on(5) <= '0';
            END IF;
         END IF;
        IF ball_on_screen(6) = '1' THEN 
        IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x6))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y6))**2) <= (bsize*bsize) THEN
                   ball_on(6) <= '1';
            ELSE
                ball_on(6) <= '0';
            END IF;
        END IF;
        IF ball_on_screen(7) = '1' THEN 
            IF pixel_col >= ball_x7 - bsize AND
            pixel_col <= ball_x7 + bsize AND
                pixel_row >= ball_y7 - bsize AND
                pixel_row <= ball_y7 + bsize THEN
                   ball_on(7) <= '1';
            ELSE
                ball_on(7) <= '0';
            END IF;
         END IF;
         IF ball_on_screen(8) = '1' THEN 
        IF ((CONV_INTEGER(pixel_col) - CONV_INTEGER(ball_x8))**2 + (CONV_INTEGER(pixel_row) - CONV_INTEGER(ball_y8))**2) <= (bsize*bsize) THEN
                   ball_on(8) <= '1';
            ELSE
                ball_on(8) <= '0';
            END IF;
         END IF;   
    END PROCESS;
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    -- process to move ball once every frame (i.e., once every vsync pulse)
    --change our ball_speed
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp1 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp2 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp3 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp4 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp5 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp6 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp7 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp8 : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        ball_speed <= "00000000010";
        WAIT UNTIL rising_edge(v_sync);
            pr_state <= nx_state;
        CASE pr_state IS 
            WHEN ENTER_GAME => 
                IF serve = '1' THEN
                    nx_state <= SERVE_RELEASE;
                ELSIF (game_on(0) = '1' AND game_on(1) = '1' AND game_on(2) ='1' AND game_on(3) ='1' AND game_on(4) ='1'AND game_on(5) ='1' AND game_on(6) ='1' AND game_on(7) ='1'AND game_on(8) ='1') THEN
                   --modify and clean 
                    counter <= counter + 1;
                    ball_on_screen(0) <= '1';
                    ball_on_screen(1) <= '1';
                    ball_on_screen(2) <= '1';
                    ball_on_screen(3) <= '1';
                    ball_on_screen(4) <= '1';
                    ball_on_screen(5) <= '1';
                    ball_on_screen(6) <= '1';
                    ball_on_screen(7) <= '1';
                    ball_on_screen(8) <= '1';
                    ball_y_motion0 <= ball_speed + 3;
                    ball_y_motion1 <= ball_speed + 1;
                    ball_y_motion2 <= ball_speed + 3;
                    ball_y_motion3 <= ball_speed + 1;
                    ball_y_motion4 <= ball_speed + 3;
                    ball_y_motion5 <= ball_speed + 1;
                    ball_y_motion6 <= ball_speed + 3;
                    ball_y_motion7 <= ball_speed + 1;
                    ball_y_motion8 <= ball_speed + 3;
                    nx_state <= START_COLL;
                ELSIF (game_on(0) = '0' AND ball_on_screen(0) = '0' AND ps_state = START_COLL) THEN
                    game_on(0) <= '1';
                    ball_on_screen(0) <= '1';
                    ball_y_motion0 <= ball_speed + 3;
                    nx_state <= START_COLL;
                ELSE nx_state <= ENTER_GAME;
                END IF; 

                IF (game_on(1) = '0' AND ball_on_screen(1) = '0' AND ps_state = START_COLL) THEN
                    game_on(1) <= '1';
                    ball_on_screen(1) <= '1';
                    ball_y_motion1 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
                
                IF (game_on(2) = '0' AND ball_on_screen(2) = '0' AND ps_state = START_COLL) THEN
                    game_on(2) <= '1';
                    ball_on_screen(2) <= '1';
                    ball_y_motion2 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
                
                IF (game_on(3) = '0' AND ball_on_screen(3) = '0' AND ps_state = START_COLL) THEN
                    game_on(3) <= '1';
                    ball_on_screen(3) <= '1';
                    ball_y_motion3 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
                
                IF (game_on(4) = '0' AND ball_on_screen(4) = '0' AND ps_state = START_COLL) THEN
                    game_on(4) <= '1';
                    ball_on_screen(4) <= '1';
                    ball_y_motion4 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
                
                IF (game_on(5) = '0' AND ball_on_screen(5) = '0' AND ps_state = START_COLL) THEN
                    game_on(5) <= '1';
                    ball_on_screen(5) <= '1';
                    ball_y_motion5 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
                IF (game_on(6) = '0' AND ball_on_screen(6) = '0' AND ps_state = START_COLL) THEN
                    game_on(6) <= '1';
                    ball_on_screen(6) <= '1';
                    ball_y_motion6 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
                IF (game_on(7) = '0' AND ball_on_screen(7) = '0' AND ps_state = START_COLL) THEN
                    game_on(7) <= '1';
                    ball_on_screen(7) <= '1';
                    ball_y_motion7 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
                IF (game_on(8) = '0' AND ball_on_screen(8) = '0' AND ps_state = START_COLL) THEN
                    game_on(8) <= '1';
                    ball_on_screen(8) <= '1';
                    ball_y_motion8 <= ball_speed + 3;
                    nx_state <= START_COLL;
                END IF;
                
            WHEN SERVE_RELEASE =>
                IF serve = '0' THEN
                    hit_counter <= "0000000000000000";
                    display_hits <= hit_counter;
                    game_on(0) <= '1';
                    game_on(1) <= '1';
                    game_on(2) <= '1';
                    game_on(3) <= '1';
                    game_on(4) <= '1';
                    game_on(5) <= '1';
                    game_on(6) <= '1';
                    game_on(7) <= '1';
                    game_on(8) <= '1';
                    --ps_state <= pr_state;
                    nx_state <= ENTER_GAME;
                ELSE nx_state <= SERVE_RELEASE;
                END IF;
            WHEN START_COLL =>
                IF (ball_x0 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x0 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y0 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y0 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(0) <= '0';
                           game_on(0) <= '0';
                             If hit_counter <= "0000000000000000"  THEN
                                ps_state <= pr_state;
                                nx_state <= END_GAME;
                           ELSE
                                ps_state <= pr_state;
                                nx_state <= ENTER_GAME;
                           end if; 
                           if not collision_detected then
                                hit_counter <= hit_counter + "0000000000000001";
                           end if;
                           display_hits <= hit_counter;
                           collision_detected <= TRUE;
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;
                ELSIF ball_y0 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(0) <= '0';
                           game_on(0) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF;
                
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
                
                 IF (ball_x2 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x2 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y2 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y2 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(2) <= '0';
                           game_on(2) <= '0';
                           If hit_counter <= "0000000000000000" THEN
                                ps_state <= pr_state;
                                nx_state <= END_GAME;
                           ELSE
                                ps_state <= pr_state;
                                nx_state <= ENTER_GAME;
                           end if;
                           
                           if not collision_detected then
                                hit_counter <= hit_counter + "0000000000000001";
                           end if;
                           display_hits <= hit_counter;
                           collision_detected <= TRUE;
                           
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;
                ELSIF ball_y2 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(2) <= '0';
                           game_on(2) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF;  
                
                 IF (ball_x3 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x3 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y3 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y3 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(3) <= '0';
                           game_on(3) <= '0';
                            If hit_counter = "0000000000000000"  THEN
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
                          

                ELSIF ball_y3 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(3) <= '0';
                           game_on(3) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF; 
                
                 IF (ball_x4 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x4 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y4 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y4 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(4) <= '0';
                           game_on(4) <= '0';
                            If hit_counter = "0000000000000000" THEN
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
                           If hit_counter = "0000000000000000" THEN
                                --ps_state <= pr_state;
                                nx_state <= END_GAME;
                           ELSE
                                ps_state <= pr_state;
                                nx_state <= ENTER_GAME;
                           end if;
                ELSIF ball_y4 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(4) <= '0';
                           game_on(4) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF; 
                 IF (ball_x5 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x5 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y5 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y5 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(5) <= '0';
                           game_on(5) <= '0';
                             
                           if not collision_detected then 
                           hit_counter <= hit_counter - "0000000000000001";
                           end if;
                           If hit_counter = "0000000000000000"  THEN
                                ps_state <= pr_state;
                                nx_state <= END_GAME;
                           ELSE
                                ps_state <= pr_state;
                                nx_state <= ENTER_GAME;
                           end if;
                           display_hits <= hit_counter;
                           collision_detected <= TRUE;
                          
                ELSIF ball_y5 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(5) <= '0';
                           game_on(5) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF; 
                IF (ball_x6 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x6 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y6 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y6 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(6) <= '0';
                           game_on(6) <= '0';
                             If hit_counter <= "0000000000000000"  THEN
                                ps_state <= pr_state;
                                nx_state <= END_GAME;
                           ELSE
                                ps_state <= pr_state;
                                nx_state <= ENTER_GAME;
                           end if; 
                           if not collision_detected then
                                hit_counter <= hit_counter + "0000000000000001";
                           end if;
                           display_hits <= hit_counter;
                           collision_detected <= TRUE;
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;
                ELSIF ball_y6 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(6) <= '0';
                           game_on(6) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF;
                IF (ball_x7 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x7 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y7 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y7 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(7) <= '0';
                           game_on(7) <= '0';
                             
                           if not collision_detected then 
                           hit_counter <= hit_counter - "0000000000000001";
                           end if;
                           If hit_counter = "0000000000000000"  THEN
                                ps_state <= pr_state;
                                nx_state <= END_GAME;
                           ELSE
                                ps_state <= pr_state;
                                nx_state <= ENTER_GAME;
                           end if;
                           display_hits <= hit_counter;
                           collision_detected <= TRUE;
                          
                ELSIF ball_y7 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(7) <= '0';
                           game_on(7) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF; 
                 IF (ball_x8 + bsize/2) >= (bat_x - bat_w) AND
                   (ball_x8 - bsize/2) <= (bat_x + bat_w) AND
                   (ball_y8 + bsize/2) >= (bat_y - bat_h) AND
                   (ball_y8 - bsize/2) <= (bat_y + bat_h) THEN
                           ball_on_screen(8) <= '0';
                           game_on(8) <= '0';
                             If hit_counter <= "0000000000000000"  THEN
                                ps_state <= pr_state;
                                nx_state <= END_GAME;
                           ELSE
                                ps_state <= pr_state;
                                nx_state <= ENTER_GAME;
                           end if; 
                           if not collision_detected then
                                hit_counter <= hit_counter + "0000000000000001";
                           end if;
                           display_hits <= hit_counter;
                           collision_detected <= TRUE;
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;
                ELSIF ball_y8 + bsize >= 600 THEN -- if ball meets bottom wall
                           ball_on_screen(8) <= '0';
                           game_on(8) <= '0';
                           ps_state <= pr_state;
                           nx_state <= ENTER_GAME;       
                END IF;
                
                IF nx_state = ENTER_GAME THEN
                    collision_detected <= FALSE;
                END IF; 
                If hit_counter >= "0000000000000101" THEN
                    ps_state <= pr_state;
                    nx_state <= END_GAME;
                 ELSE
                    ps_state <= pr_state;
                    nx_state <= ENTER_GAME;
                 end if;   
             WHEN END_GAME =>
                ball_on_screen <= "000000000";
                game_on <= "000000000";
                sound_on <= '1';
                sound <= sound_on;
                --ps_state <= pr_state;
                IF serve = '1' THEN
                    nx_state <= ENTER_GAME;
                END IF;
            END CASE;              
            
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
              temp2 := ('0' & ball_y2) + (ball_y_motion2(10) & ball_y_motion2);
                        IF game_on(2) = '0' THEN
                            ball_y2 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x2 <= conv_std_logic_vector(conv_integer(start_pos) * 7 mod 700, 11);
                        ELSIF temp2(11) = '1' THEN
                            ball_y2 <= (OTHERS => '0');
                        ELSE ball_y2 <= temp2(10 DOWNTO 0); -- 9 downto 0
                        END IF;    
               temp3 := ('0' & ball_y3) + (ball_y_motion3(10) & ball_y_motion3);
                        IF game_on(3) = '0' THEN
                            ball_y3 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x3 <= conv_std_logic_vector(conv_integer(start_pos) * 8 mod 700, 11);
                        ELSIF temp3(11) = '1' THEN
                            ball_y3 <= (OTHERS => '0');
                        ELSE ball_y3 <= temp3(10 DOWNTO 0); -- 9 downto 0
                        END IF; 
               temp4 := ('0' & ball_y4) + (ball_y_motion4(10) & ball_y_motion4);
                        IF game_on(4) = '0' THEN
                            ball_y4 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x4 <= conv_std_logic_vector(conv_integer(start_pos) * 9 mod 700, 11);
                        ELSIF temp4(11) = '1' THEN
                            ball_y4 <= (OTHERS => '0');
                        ELSE ball_y4 <= temp4(10 DOWNTO 0); -- 9 downto 0
                        END IF;  
               temp5 := ('0' & ball_y5) + (ball_y_motion5(10) & ball_y_motion5);
                        IF game_on(5) = '0' THEN
                            ball_y5 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x5 <= conv_std_logic_vector(conv_integer(start_pos) * 10 mod 700, 11);
                        ELSIF temp5(11) = '1' THEN
                            ball_y5 <= (OTHERS => '0');
                        ELSE ball_y5 <= temp5(10 DOWNTO 0); -- 9 downto 0
                        END IF;  
               temp6 := ('0' & ball_y6) + (ball_y_motion6(10) & ball_y_motion6);
                        IF game_on(6) = '0' THEN
                            ball_y6 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x6 <= conv_std_logic_vector(conv_integer(start_pos) * 11 mod 700, 11);
                        ELSIF temp6(11) = '1' THEN
                            ball_y6 <= (OTHERS => '0');
                        ELSE ball_y6 <= temp5(10 DOWNTO 0); -- 9 downto 0
                        END IF;  
               temp7 := ('0' & ball_y7) + (ball_y_motion7(10) & ball_y_motion7);
                        IF game_on(7) = '0' THEN
                            ball_y7 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x7 <= conv_std_logic_vector(conv_integer(start_pos) * 12 mod 700, 11);
                        ELSIF temp7(11) = '1' THEN
                            ball_y7 <= (OTHERS => '0');
                        ELSE ball_y7 <= temp7(10 DOWNTO 0); -- 9 downto 0
                        END IF; 
                temp8 := ('0' & ball_y8) + (ball_y_motion8(10) & ball_y_motion8);
                        IF game_on(8) = '0' THEN
                            ball_y8 <= CONV_STD_LOGIC_VECTOR(0, 11);
                            ball_x8 <= conv_std_logic_vector(conv_integer(start_pos) * 14 mod 700, 11);
                        ELSIF temp8(11) = '1' THEN
                            ball_y8 <= (OTHERS => '0');
                        ELSE ball_y8 <= temp5(10 DOWNTO 0); -- 9 downto 0
                        END IF;                                     
    END PROCESS;
    randomizer: PROCESS IS
     VARIABLE rand : INTEGER;        
    BEGIN
        WAIT UNTIL (falling_edge(v_sync));
        rand := conv_integer(conv_std_logic_vector(counter, 11) XOR bat_x XOR pixel_row XOR pixel_col) mod 700 ;
        start_pos <= conv_std_logic_vector(rand,11);
    END PROCESS;
END Behavioral;
