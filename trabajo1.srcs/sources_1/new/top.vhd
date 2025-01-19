library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all; -- Paquete personalizado con tipos de datos (como state_type)

entity top is 
    Port (
        clk         : in std_logic;                      -- Señal de reloj principal
        rst         : in std_logic;                      -- Señal de reinicio global
        start_btn   : in std_logic;                      -- Botón para iniciar el juego
        sw          : in std_logic_vector(7 downto 0);   -- Interruptores de entrada
        sw_mode       : in std_logic;                      -- Switch para seleccionar el modo (0: 1 segundo, 1: 2 segundos)
        leds        : out std_logic_vector(7 downto 0);  -- LEDs de salida controlados por LFSR
        anodes      : out std_logic_vector(6 downto 0);  -- Control de los anodos del display de 7 segmentos
        segments    : out std_logic_vector(6 downto 0);  -- Señales para los segmentos del display
        rgb_red_out : out std_logic;                     -- Salida PWM para el canal rojo del LED RGB
        rgb_green_out : out std_logic                    -- Salida PWM para el canal verde del LED RGB
    );
end top;

architecture Structural of top is

    -- Declaración de señales internas para conectar componentes
    signal sync_start_btn : std_logic;                      -- Botón sincronizado con el reloj
    signal edge           : std_logic;                      -- Pulso de un solo ciclo generado por el detector de flancos
    signal random_led     : std_logic_vector(7 downto 0);    -- Salida pseudoaleatoria del LFSR, un-hot (solo un bit en '1')
    signal led_active     : std_logic;                      -- Señal para activar/desactivar LEDs
    signal current_score  : unsigned(7 downto 0) := (others => '0'); -- Puntuación interna acumulada
    signal seconds        : unsigned(13 downto 0);           -- Tiempo global del juego en segundos
    signal topo_time_up   : std_logic;                      -- Señal que indica que el temporizador local ha terminado
    signal game_time_up   : std_logic;                      -- Señal que indica que el tiempo total del juego ha terminado
    signal enable_lfsr    : std_logic;                      -- Señal de habilitación del LFSR
    signal rgb_red        : unsigned(7 downto 0);           -- Ciclo de trabajo PWM para el canal rojo
    signal rgb_green      : unsigned(7 downto 0);           -- Ciclo de trabajo PWM para el canal verde
    signal sw_sync        : std_logic_vector(7 downto 0);   -- Interruptores sincronizados

    -- Declaración de componentes utilizados
    component synchronizer
        Port (
            clk       : in std_logic;
            async_in  : in std_logic;
            sync_out  : out std_logic
        );
    end component;

    component EDGEDTCTR
        Port (
            CLK       : in std_logic;                    -- Señal de reloj
            SYNC_IN   : in std_logic;                    -- Entrada sincronizada
            EDGE      : out std_logic                    -- Pulso de un ciclo cuando hay un flanco
        );
    end component;

    component lfsr_generator
        Port (
            clk         : in std_logic;                  -- Señal de reloj
            rst         : in std_logic;                  -- Señal de reinicio
            enable_lfsr : in std_logic;                  -- Señal de habilitación del LFSR
            seed        : in std_logic_vector(7 downto 0); -- Valor inicial del LFSR
            lfsr_out    : out std_logic_vector(7 downto 0) -- Salida del LFSR (LEDs pseudoaleatorios)
        );
    end component;

    component fsm_controller
        Port (
            clk          : in std_logic;                     -- Señal de reloj
            rst          : in std_logic;                     -- Señal de reinicio
            sync_btn     : in std_logic;                     -- Botón sincronizado
            sw           : in std_logic_vector(7 downto 0);  -- Interruptores sincronizados
            random_led   : in std_logic_vector(7 downto 0);  -- Salida del LFSR
            topo_time_up : in std_logic;                     -- Tiempo agotado para el LED actual
            game_time_up : in std_logic;                     -- Tiempo total agotado
            current_score: out unsigned(7 downto 0);         -- Puntuación del jugador
            led_active   : out std_logic;                    -- Señal para activar LEDs
            rgb_red      : out unsigned(7 downto 0);         -- Ciclo de trabajo del canal rojo
            rgb_green    : out unsigned(7 downto 0)          -- Ciclo de trabajo del canal verde
        );
    end component;

    component game_timer
        Port (
            clk       : in std_logic;                     -- Señal de reloj
            rst       : in std_logic;                     -- Señal de reinicio
            enable    : in std_logic;                     -- Señal de habilitación
            start_btn : in std_logic;                     -- Botón de inicio
            limit     : in unsigned(13 downto 0);         -- Límite de tiempo del juego
            seconds   : out unsigned(13 downto 0);        -- Tiempo transcurrido en segundos
            time_up   : out std_logic                     -- Señal que indica que el tiempo ha terminado
        );
    end component;

    component topo_timer
        Port (
            clk       : in std_logic;                     -- Señal de reloj
            rst       : in std_logic;                     -- Señal de reinicio
            enable    : in std_logic;                     -- Señal de habilitación
            mode_sel  : in std_logic;                     -- Entrada para seleccionar el modo
            time_up   : out std_logic                     -- Señal que indica que el tiempo ha terminado
        );
    end component;

    component display_controller
        Port (
            clk        : in std_logic;                    -- Señal de reloj
            rst        : in std_logic;                    -- Señal de reinicio
            score      : in unsigned(7 downto 0);         -- Puntuación
            seconds    : in unsigned(13 downto 0);        -- Tiempo global
            anodes     : out std_logic_vector(6 downto 0); -- Control de los anodos del display
            segments   : out std_logic_vector(6 downto 0)  -- Señales para los segmentos del display
        );
    end component;

    component pwm_rgb
        Port (
            clk        : in std_logic;                    -- Señal de reloj
            rst        : in std_logic;                    -- Señal de reinicio
            red_duty   : in unsigned(7 downto 0);         -- Ciclo de trabajo del canal rojo
            green_duty : in unsigned(7 downto 0);         -- Ciclo de trabajo del canal verde
            blue_duty  : in unsigned(7 downto 0);         -- Ciclo de trabajo del canal azul
            red_out    : out std_logic;                   -- Salida PWM para el canal rojo
            green_out  : out std_logic;                   -- Salida PWM para el canal verde
            blue_out   : out std_logic                    -- Salida PWM para el canal azul
        );
    end component;

begin
    -- Sincronización de los interruptores
    process(clk)
    begin
        if rising_edge(clk) then
            sw_sync <= sw; -- Sincroniza los interruptores al reloj
        end if;
    end process;

    -- Instancia del sincronizador del botón de inicio
    u_sync: synchronizer
        Port map (
            clk       => clk,
            async_in  => start_btn,
            sync_out  => sync_start_btn
        );

    -- Instancia del detector de flancos para el botón de inicio
    u_edge: EDGEDTCTR
        Port map (
            CLK     => clk,
            SYNC_IN => sync_start_btn,
            EDGE    => edge
        );

    -- Instancia del generador LFSR para LEDs pseudoaleatorios
    u_lfsr: lfsr_generator
        Port map (
            clk         => clk,
            rst         => rst,
            enable_lfsr => topo_time_up, -- El LFSR se habilita con topo_time_up
            seed        => "00000001",   -- Semilla inicial
            lfsr_out    => random_led
        );

    -- Instancia del temporizador global de 30 segundos
    u_game_timer: game_timer
        Port map (
            clk     => clk,
            rst     => rst,
            enable  => '1',              -- Siempre habilitado
            start_btn => sync_start_btn, -- Botón sincronizado de inicio
            limit   => to_unsigned(30, 14), -- Límite de tiempo de 30 segundos
            seconds => seconds,          -- Tiempo transcurrido
            time_up => game_time_up      -- Tiempo global agotado
        );

    -- Instancia del temporizador local de 1 segundo para el LED activo
    u_topo_timer: topo_timer
        Port map (
            clk     => clk,
            rst     => rst,
            enable  => led_active,       -- Habilitado mientras el LED está activo
            mode_sel  => sw_mode,        -- Conexión del switch `sw_mode` para seleccionar el modo
            time_up => topo_time_up      -- Indica tiempo agotado para el LED actual
        );

    -- Instancia de la FSM principal
    u_fsm: fsm_controller
        Port map (
            clk           => clk,
            rst           => rst,
            sync_btn      => edge,       -- Pulso único generado por el detector de flancos
            sw            => sw_sync,    -- Conecta la señal sincronizada
            random_led    => random_led, -- Salida del LFSR
            topo_time_up  => topo_time_up, -- Tiempo agotado para el LED actual
            game_time_up  => game_time_up, -- Tiempo global agotado
            current_score => current_score, -- Puntuación acumulada
            led_active    => led_active,    -- Control de LEDs
            rgb_red       => rgb_red,       -- Salida PWM roja
            rgb_green     => rgb_green      -- Salida PWM verde
        );

    -- Instancia del controlador de displays para puntuación y tiempo
    u_display: display_controller
        Port map (
            clk        => clk,
            rst        => rst,
            score      => current_score, -- Conecta la puntuación interna
            seconds    => seconds,       -- Conecta el tiempo global
            anodes     => anodes,        -- Control de anodos del display
            segments   => segments       -- Control de segmentos del display
        );

    -- Instancia del módulo PWM para LEDs RGB
    u_pwm: pwm_rgb
        Port map (
            clk        => clk,
            rst        => rst,
            red_duty   => rgb_red,       -- Ciclo de trabajo para el canal rojo
            green_duty => rgb_green,     -- Ciclo de trabajo para el canal verde
            blue_duty  => "00000000",    -- Ciclo de trabajo apagado para el canal azul
            red_out    => rgb_red_out,   -- Salida PWM roja
            green_out  => rgb_green_out, -- Salida PWM verde
            blue_out   => open           -- Sin conexión para el canal azul
        );

    -- Asignación de salida de LEDs
    leds <= random_led when led_active = '1' else (others => '0'); -- Control de LEDs por LFSR y FSM

end Structural;
