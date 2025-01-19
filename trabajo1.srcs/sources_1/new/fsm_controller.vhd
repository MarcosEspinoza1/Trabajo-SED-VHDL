library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
        led_active   : out std_logic;                    -- Señal de activación de LEDs
        rgb_red      : out unsigned(7 downto 0);         -- Ciclo de trabajo del canal rojo
        rgb_green    : out unsigned(7 downto 0)          -- Ciclo de trabajo del canal verde
    );
end fsm_controller;

architecture Behavioral of fsm_controller is
    type state_type is (INIT, LED_ON, CHECK, FINAL);            -- Estados de la FSM
    signal current_state, next_state : state_type := INIT; -- Estado actual y próximo
    signal score_internal : unsigned(7 downto 0) := (others => '0'); -- Puntuación interna
    signal next_score     : unsigned(7 downto 0) := (others => '0'); -- Puntuación temporal
    signal last_result    : std_logic := '0';            -- Resultado anterior (para RGB)
    signal next_last_result: std_logic := '0';           -- Resultado temporal
    signal match_detected : std_logic := '0';            -- Detecta coincidencia en LED_ON
    signal next_match_detected: std_logic := '0';         -- Coincidencia temporal
begin

    -- Proceso de transición de estados y registro de puntuación
    process(clk, rst)
    begin
        if rst = '0' then
            current_state <= INIT;                       -- Reinicia al estado inicial
            score_internal <= (others => '0');           -- Reinicia la puntuación
            last_result <= '0';                          -- Reinicia el resultado
            match_detected <= '0';                       
        elsif rising_edge(clk) then
            current_state <= next_state;                 -- Actualiza el estado
            score_internal <= next_score;                -- Actualiza la puntuación
            last_result <= next_last_result;             -- Actualiza el resultado anterior
            match_detected <= next_match_detected; -- Registro de la coincidencia
        end if;
    end process;

    -- Proceso de lógica combinacional de la FSM
    process(current_state, sync_btn, topo_time_up, game_time_up, sw, random_led, score_internal,last_result, match_detected)
    begin
        -- Valores predeterminados
        next_state <= current_state;
        next_score <= score_internal;
        next_last_result <= last_result;
        next_match_detected <= match_detected;
        led_active <= '0';
        rgb_red <= (others => '0');
        rgb_green <= (others => '0');

        case current_state is
            -- Estado Inicial
            when INIT =>
                next_score <= (others => '0');
                next_last_result <= '0';
                next_match_detected <= '0';
                led_active <= '0';
                if sync_btn = '1' then
                    next_state <= LED_ON;
                end if;

            -- Estado LED_ON: Verificación en tiempo real
            when LED_ON =>
                led_active <= '1';
                -- Detecta coincidencia si el SW coincide con el LED encendido
                if sw = random_led then
                   next_match_detected <= '1'; -- Se detecta coincidencia
                else
                    next_match_detected <= '0'; -- No hay coincidencia
                end if;

                -- Muestra el resultado anterior
                if last_result = '1' then
                    rgb_green <= "11111111"; -- Verde si la respuesta anterior fue correcta
                else
                    rgb_red <= "11111111";   -- Rojo si fue incorrecta o tiempo agotado
                end if;

                if topo_time_up = '1' then
                    next_state <= CHECK; -- Transición al estado CHECK
                end if;

            -- Estado CHECK: Actualiza la puntuación y resultado
            when CHECK =>
                led_active <= '0';
                -- Actualiza la puntuación si hubo coincidencia detectada
                if match_detected = '1' then
                    next_score <= score_internal + 1;
                    next_last_result <= '1'; -- Correcto
                else
                    next_last_result <= '0'; -- Incorrecto
                end if;
                    
                -- Transición a LED_ON o FINAL según el tiempo del juego
                if game_time_up = '1' then
                    next_state <= FINAL; -- Transición al estado FINAL
                else
                    next_state <= LED_ON; -- Regresa a LED_ON
                    next_match_detected <= '0'; -- Reinicia coincidencia detectada
                end if;
            
            -- Estado FINAL: Muestra el score final
            when FINAL =>
                led_active <= '0';
                rgb_red <= "11111111";        -- LED rojo encendido indicando el fin del juego
                next_score <= score_internal; -- Mantiene el score final
                
            -- Estado por defecto
            when others =>
                next_state <= INIT;
        end case;
    end process;

    -- Asigna la puntuación interna al puerto de salida
    current_score <= score_internal;

end Behavioral;

