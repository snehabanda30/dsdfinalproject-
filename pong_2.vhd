LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pong IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btn0 : IN STD_LOGIC;
        SW : IN UNSIGNED (4 DOWNTO 0);
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
		dac_LRCK : OUT STD_LOGIC;
		dac_SCLK : OUT STD_LOGIC;
		dac_SDIN : OUT STD_LOGIC
    ); 
END pong;

ARCHITECTURE Behavioral OF pong IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL clk, aud_clk,sound : STD_LOGIC;
    SIGNAL note : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL batpos : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    SIGNAL count : STD_LOGIC_VECTOR (20 DOWNTO 0);
    SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
    SIGNAL tcount : STD_LOGIC_VECTOR (19 DOWNTO 0);
    SIGNAL cnt : std_logic_vector(20 DOWNTO 0); -- counter to generate timing signals
    SIGNAL data_L, data_R : SIGNED (15 DOWNTO 0); -- 16-bit signed audio data
	SIGNAL dac_load_L, dac_load_R : STD_LOGIC; -- timing pulses to load DAC shift reg.
	SIGNAL slo_clk, sclk, audio_CLK : STD_LOGIC;
	SIGNAL tone: Signed (15 DOWNTO 0);
	SIGNAL clk_50mhz : std_logic;
    COMPONENT bat_n_ball IS
        PORT (
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            serve : IN STD_LOGIC;
            red : OUT STD_LOGIC;
            green : OUT STD_LOGIC;
            blue : OUT STD_LOGIC;
            SW : IN UNSIGNED (4 DOWNTO 0);
            display_hits : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            sound: OUT STD_LOGIC
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;
    COMPONENT CLKDiv2 IS
		PORT (
			inclk : IN std_logic;
			Clk50 : OUT std_logic
		);
	END COMPONENT;
    COMPONENT WaveGenerator IS
		PORT (
			aud_clk : IN std_logic;
			notee : IN std_logic_vector (4 DOWNTO 0);
			tonee : OUT signed (15 DOWNTO 0)
		);
    END COMPONENT;
    COMPONENT leddec16 IS
        PORT (
            dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT; 
    	COMPONENT dac_if IS
		PORT (
			SCLK : IN STD_LOGIC;
			L_start : IN STD_LOGIC;
			R_start : IN STD_LOGIC;
			L_data : IN signed (15 DOWNTO 0);
			R_data : IN signed (15 DOWNTO 0);
			SDATA : OUT STD_LOGIC
		);
	END COMPONENT;
    COMPONENT game_sound_effects IS
    PORT (
        clk : IN STD_LOGIC;  -- Main clock input
        aud_clk : OUT STD_LOGIC;  -- Clock signal for WaveGenerator
        note : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- Control signal for notes
        sound_onn:IN STD_LOGIC
        --tone : OUT signed (15 DOWNTO 0)
    );
      END COMPONENT;
    
    
BEGIN
    pos : PROCESS (clk_in) is
    BEGIN
        if rising_edge(clk_in) then
            count <= count + 1;
            IF (btnl = '1' and count = 0 and batpos > 0) THEN
                batpos <= batpos - 10;
            ELSIF (btnr = '1' and count = 0 and batpos < 800) THEN
                batpos <= batpos + 10;
            END IF;
         END IF;
    END PROCESS;
    
	tim_pr : PROCESS (clk_50MHz) is
	BEGIN
		if rising_edge(clk_50MHz) then
		IF (tcount(9 DOWNTO 0) >= X"00F") AND (tcount(9 DOWNTO 0) < X"02E") THEN
			dac_load_L <= '1';
		ELSE
			dac_load_L <= '0';
		END IF;
		IF (tcount(9 DOWNTO 0) >= X"20F") AND (tcount(9 DOWNTO 0) < X"22E") THEN
			dac_load_R <= '1';
		ELSE
			dac_load_R <= '0';
		END IF;
		tcount <= tcount + 1;
	end if;
END PROCESS;
    
    dac_MCLK <= NOT tcount(1); -- DAC master clock (12.5 MHz)
	audio_CLK <= tcount(9); -- audio sampling rate (48.8 kHz)
	dac_LRCK <= audio_CLK; -- also sent to DAC as left/right clock
	sclk <= tcount(4); -- serial data clock (1.56 MHz)
	dac_SCLK <= sclk; -- also sent to DAC as SCLK
	slo_clk <= tcount(19); -- clock to control wailing of tone (47.6 Hz)
    led_mpx <= tcount(19 DOWNTO 17); -- 7-seg multiplexing clock    
    add_bb : bat_n_ball
    PORT MAP(--instantiate bat and ball component
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        bat_x => batpos, 
        serve => btn0, 
        red => S_red, 
        green => S_green, 
        blue => S_blue,
        SW => SW,
        display_hits => display,
        sound => sound
        );
    
    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    clk50 : ClkDiv2
	PORT MAP(
		inclk => clk_in, 
		Clk50 => clk_50mhz
		);
    led1 : leddec16
    PORT MAP(
      dig => led_mpx, data => display, 
      anode => SEG7_anode, seg => SEG7_seg
    );
    music : game_sound_effects
    PORT MAP(
        clk => clk_50mhz,
        aud_clk => aud_clk,
        note => note, 
        sound_onn => sound
        --tone => data_L
    );
    dac : dac_if
		PORT MAP(
			SCLK => sclk, -- instantiate parallel to serial DAC interface
			L_start => dac_load_L, 
			R_start => dac_load_R, 
			L_data => data_L, 
			R_data => data_R, 
			SDATA => dac_SDIN
		);
		a1 : WaveGenerator
		PORT MAP(
			aud_clk => audio_CLK, 
			notee => note, 
			tonee => tone
		);
		data_L <= tone;
		data_R <= tone;
END Behavioral;
