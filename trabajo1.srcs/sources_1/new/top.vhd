library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top is
    Port (
        clk         : in std_logic;                      -- Reloj principal
        rst         : in std_logic;                      -- Señal de reinicio global
        start_btn   : in std_logic;                      -- Botón para iniciar el juego
        sw          : in std_logic_vector(7 downto 0);   -- Interruptores de entrada
        leds        : out std_logic_vector(7 downto 0);  -- LEDs de salida
        score       : out std_logic_vector(7 downto 0)  -- Puntuación del juego
    );
end top;

architecture Structural of top is

    -- Señales internas para interconexión
    signal sync_start_btn : std_logic;                      -- Botón sincronizado
    signal edge           : std_logic;                      -- Pulso de un solo ciclo de reloj
 
    signal led_active     : std_logic;                      -- Señal para activar LEDs
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

    

    -- Asignaciones de salida
 
end Structural;
