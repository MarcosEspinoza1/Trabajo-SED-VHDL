library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;

entity fsm_controller is
    Port (
        clk          : in std_logic;                     -- Reloj principal
        rst          : in std_logic;                     -- Señal de reinicio global
        sync_btn     : in std_logic;                     -- Botón sincronizado
        sw           : in std_logic_vector(7 downto 0);  -- Interruptores del jugador
        random_led   : in std_logic_vector(7 downto 0);  -- LED activo del LFSR
        topo_time_up : in std_logic;                     -- Tiempo agotado para el LED actual
        game_time_up : in std_logic;                     -- Tiempo total del juego agotado
        current_score: out unsigned(7 downto 0);         -- Puntuación del jugador
        led_active   : out std_logic                     -- Señal de activación de LEDs
    );
end fsm_controller;

architecture Behavioral of fsm_controller is
    type state_type is (INIT, LED_ON, CHECK);
    signal current_state, next_state : state_type;
    signal score_internal : unsigned(7 downto 0) := (others => '0');
    signal sw_last : std_logic_vector(7 downto 0) := (others => '0'); -- Estado anterior de los switches
    constant ZERO_VECTOR : std_logic_vector(7 downto 0) := (others => '0');

begin

    -- Proceso de transición de estados
    process(clk, rst)
    begin
        if rst = '0' then
            current_state <= INIT;                       -- Reinicia al estado inicial
        elsif rising_edge(clk) then
            current_state <= next_state;                -- Actualiza el estado
        end if;
    end process;

    -- Proceso de lógica de la FSM
    process(current_state, sync_btn, topo_time_up, game_time_up, sw, random_led)
    
    begin
        -- Valores predeterminados
        next_state <= current_state;
        led_active <= '0';

        case current_state is
            -- Estado Inicial: Espera el botón de inicio
            when INIT =>
                score_internal <= (others => '0');      -- Reinicia la puntuación
                led_active <= '0';                     -- Apaga los LEDs
                if sync_btn = '1' then
                    next_state <= LED_ON;              -- Pasa al estado LED_ON
                end if;

            -- Estado LED_ON: Activa un LED y espera el tiempo límite
            when LED_ON =>
                led_active <= '1';                     -- Mantén el LED activo
                if topo_time_up = '1' then
                    next_state <= CHECK;               -- Pasa al estado de verificación
                end if;

            -- Estado CHECK: Verifica si el interruptor es correcto
            when CHECK =>
                led_active <= '0';                     -- Apaga los LEDs
                if (sw and random_led) /= ZERO_VECTOR then
                    score_internal <= score_internal + 1; -- Incrementa la puntuación si acierta
                end if;
               -- sw_last <= sw; -- Actualiza el estado anterior de los switches
                -- Transiciones según el tiempo de juego
                if game_time_up = '1' then
                    next_state <= INIT;                -- Vuelve al estado inicial si el tiempo global se acaba
                else
                    next_state <= LED_ON;              -- Pasa al siguiente LED
                end if;

            -- Estado Por Defecto
            when others =>
                next_state <= INIT;
        end case;
    end process;

    -- Asigna la puntuación interna al puerto de salida
    current_score <= score_internal;

end Behavioral;
