LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY game_sound_effects IS
    PORT (
        clk : IN STD_LOGIC;  -- Main clock input
        aud_clk : OUT STD_LOGIC;  -- Clock signal for WaveGenerator
        note : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- Control signal for notes
        sound_onn :IN STD_LOGIC
       -- tone : IN signed (15 DOWNTO 0)
    );
END game_sound_effects;

ARCHITECTURE Behavioral OF game_sound_effects IS
    -- Define states for controlling sound effects
   -- TYPE state IS (PLAY_A5_SHARP, PLAY_A5, PLAY_G5_SHARP, PLAY_G5, END_SOUND );
   -- SIGNAL pr_state, nx_state : state := PLAY_A5_SHARP;

    -- Constants for note durations and transitions
    SIGNAL NOTE_DURATION : INTEGER := 4880000;  -- Duration for each note (1 seconds)
    SIGNAL note_counter : INTEGER := 0;

BEGIN
    -- FSM to control sound effects
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
                     Elsif note_counter >NOTE_DURATION*2 AND note_counter < NOTE_DURATION *3 THEN
                        note <= "00111";
                     Elsif note_counter >NOTE_DURATION*3 AND note_counter < NOTE_DURATION *4 THEN
                        note <= "01001";
                     Else 
                     note <= "00000";
                     END IF;
          --ELSE 
          --note <= "00000";
         END IF;
        END IF;
    END PROCESS sound_effects;
            -- Increment note counter
            -- State transitions based on note duration
       -- CASE pr_state IS
               -- WHEN PLAY_A5_SHARP =>
                   -- IF note_counter >= note_duration * 2 THEN
                        --nx_state <= PLAY_A5;
                    --ELSIF note_counter > 0 THEN 
                        --note <= "01111"; -- A5#
                        --nx_state <= PLAY_A5_SHARP;
                    --ELSE
                        --note <= "00000";
                        --nx_state <= PLAY_A5_SHARP;
                   --END IF;
               -- WHEN PLAY_A5 =>
                   -- IF note_counter >= note_duration * 3 THEN
                       -- nx_state <= PLAY_G5_SHARP;
                    --ELSE 
                        --note <= "01000"; -- A5
                       -- nx_state <= PLAY_A5;
                   -- END IF;
                    
                --WHEN PLAY_G5_SHARP =>
                    --IF note_counter >= note_duration * 4 THEN
                       -- nx_state <= PLAY_G5;
                    --ELSE 
                       -- note <= "00111"; -- A5
                       -- nx_state <= PLAY_G5_SHARP;
                  --  END IF;
                    
              --  WHEN PLAY_G5 =>
                   -- IF note_counter >= note_duration * 5 THEN
                       -- nx_state <= END_SOUND;
                    --ELSE 
                       -- note <= "01001"; -- G5 -- A5
                        --nx_state <= PLAY_G5;
                    --END IF;
                --WHEN END_SOUND =>
                    -- Stop playing sound effects
                    --note <= "00000";
            --END CASE;

    -- Connect clock to WaveGenerator
    aud_clk <= clk;

END Behavioral;
