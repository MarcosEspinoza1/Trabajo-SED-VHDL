library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all; -- Importa el paquete con `state_type`


entity top is
    generic (
       FIN : positive := 100_000_000
    Port (
        clk         : in std_logic;                      -- Reloj principal
        rst         : in std_logic;                      -- Señal de reinicio global
        start_btn   : in std_logic;                      -- Botón para iniciar el juego
        sw          : in std_logic_vector(7 downto 0);   -- Interruptores de entrada
        leds        : out std_logic_vector(7 downto 0);  -- LEDs de salida
        --score       : out std_logic_vector(7 downto 0);  -- Puntuación del juego
        anodes      : out std_logic_vector(6 downto 0);  -- Control de los anodos de los displays
        segments    : out std_logic_vector(6 downto 0)   -- Señales para los segmentos de los displays        
    );
end top;

architecture Structural of top is

    -- Señales internas para interconexión
    signal sync_start_btn : std_logic;                      -- Botón sincronizado
    signal edge           : std_logic;                      -- Pulso de un solo ciclo de reloj
    signal random_led     : std_logic_vector(7 downto 0);    -- Salida aleatoria del LFSR (un-hot)
    signal led_active     : std_logic;                      -- Señal para activar LEDs
    signal current_score  : unsigned(7 downto 0) := (others => '0'); -- Puntuación interna    
    signal seconds        : unsigned(13 downto 0);           -- Tiempo global en segundos
    signal topo_time_up   : std_logic;                      -- Señal de tiempo agotado para cada topo
    signal game_time_up   : std_logic;                      -- Señal de tiempo agotado para el juego

    -- Declaración de componentes
    component synchronizer
        Port (
            clk       : in std_logic;
            async_in  : in std_logic;
            sync_out  : out std_logic
        );
    end component;

    component EDGEDTCTR
        Port (
            CLK       : in std_logic;
            SYNC_IN   : in std_logic;
            EDGE      : out std_logic
        );
    end component;

        component lfsr_generator
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        enable_lfsr : in std_logic;
        seed        : in std_logic_vector(7 downto 0);
        lfsr_out    : out std_logic_vector(7 downto 0)
    );
end component;


    component fsm_controller
        Port (
            clk          : in std_logic;
            rst          : in std_logic;
            sync_btn     : in std_logic;
            sw           : in std_logic_vector(7 downto 0);
            random_led   : in std_logic_vector(7 downto 0);
            topo_time_up : in std_logic;
            game_time_up : in std_logic;
            current_score: out unsigned(7 downto 0);
            led_active   : out std_logic
        );
    end component;


    component game_timer
        Port (
            clk       : in std_logic;
            rst       : in std_logic;
            enable    : in std_logic;
            limit     : in unsigned(13 downto 0);
            seconds   : out unsigned(13 downto 0);
            time_up   : out std_logic
        );
    end component;

    component topo_timer
        Port (
            clk       : in std_logic;
            rst       : in std_logic;
            enable    : in std_logic;
            time_up   : out std_logic
        );
    end component;

    component display_controller
        Port (
            clk        : in std_logic;
            rst        : in std_logic;
            score      : in unsigned(7 downto 0);   -- Puntaje (0-255)
            seconds    : in unsigned(13 downto 0);  -- Tiempo en segundos (0-9999)
            anodes     : out std_logic_vector(6 downto 0); -- Control de anodos
            segments   : out std_logic_vector(6 downto 0)  -- Señales para segmentos
        );
    end component;
        
begin

    -- Instancia del sincronizador
    u_sync: synchronizer
        Port map (
            clk       => clk,
            async_in  => start_btn,
            sync_out  => sync_start_btn
        );

    -- Instancia del detector de flancos
    u_edge: EDGEDTCTR
        Port map (
            CLK     => clk,
            SYNC_IN => sync_start_btn,
            EDGE    => edge
        );

            -- Instancia del generador LFSR
    u_lfsr: lfsr_generator
    Port map (
        clk         => clk,
        rst         => rst,
        enable_lfsr => topo_time_up,
        seed        => "00000001",
        lfsr_out    => random_led
    );
    
    -- Instancia del temporizador global de 30 segundos
    u_game_timer: game_timer
        Port map (
            clk     => clk,
            rst     => rst,
            enable  => '1',                        -- Siempre habilitado durante el juego
            limit   => to_unsigned(30, 14),        -- Límite de 30 segundos
            seconds => seconds,                    -- Tiempo transcurrido en segundos
            time_up => game_time_up                -- Señal de "tiempo agotado"
        );

    -- Instancia del temporizador local de 1 segundo
    u_topo_timer: topo_timer
        Port map (
            clk     => clk,
            rst     => rst,
            enable  => led_active,                 -- Habilitado mientras el LED está activo
            time_up => topo_time_up               -- Señal de "tiempo agotado"
        );

    -- Instancia de la FSM principal
    u_fsm: fsm_controller
        Port map (
            clk           => clk,
            rst           => rst,
            sync_btn      => edge,
            sw            => sw,
            random_led    => random_led,
            topo_time_up  => topo_time_up,
            game_time_up  => game_time_up,
            current_score => current_score,
            led_active    => led_active
        );

    -- Instancia del controlador de displays
    u_display: display_controller
        Port map (
            clk        => clk,
            rst        => rst,
            score      => current_score,           -- Conecta la puntuación desde la FSM
            seconds    => seconds,                 -- Conecta el tiempo global del temporizador
            anodes     => anodes,                  -- Salida para los anodos
            segments   => segments                 -- Salida para los segmentos
        );

    -- Asignaciones de salida
    leds <= random_led when led_active = '1' else (others => '0'); -- LEDs activados
 
end Structural;
