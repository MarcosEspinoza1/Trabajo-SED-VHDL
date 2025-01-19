----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2024 20:13:32
-- Design Name: 
-- Module Name: game_timer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_timer is
    Port (
        clk       : in std_logic;                     -- Reloj principal
        rst       : in std_logic;                     -- Señal de reinicio global
        enable    : in std_logic;                     -- Habilita el temporizador
        start_btn : in std_logic;                     -- Botón de inicio
        limit     : in unsigned(13 downto 0);         -- Límite en segundos
        seconds   : out unsigned(13 downto 0);        -- Tiempo transcurrido en segundos
        time_up   : out std_logic                     -- Señal de "tiempo agotado"
    );
end game_timer;

architecture Behavioral of game_timer is
    constant CLOCK_FREQ : unsigned(26 downto 0) := to_unsigned(100_000_000, 27); -- Frecuencia del reloj (100 MHz)
    signal clk_counter  : unsigned(26 downto 0) := (others => '0');              -- Contador de ciclos de reloj
    signal second_count : unsigned(13 downto 0) := (others => '0');              -- Contador de segundos
    signal timer_active : std_logic := '1';                                      -- Control interno para detener el temporizador  
begin

    process(clk, rst)
    begin
        if rst = '0' then
            clk_counter <= (others => '0');
            second_count <= (others => '0');
            time_up <= '0';
            timer_active <= '1';
        elsif rising_edge(clk) then
            if enable = '1' and timer_active = '1' then
                -- Incrementa el contador de ciclos
                if clk_counter = CLOCK_FREQ - 1 then
                    clk_counter <= (others => '0');         -- Reinicia el contador de ciclos
                    second_count <= second_count + 1;      -- Incrementa el contador de segundos
                else
                    clk_counter <= clk_counter + 1;        -- Incrementa el contador de ciclos
                end if;

                -- Comprueba si se alcanzó el límite
                if second_count = limit then
                    time_up <= '1';                        -- Indica que el tiempo ha terminado
                    timer_active <= '0';                   -- Detiene el temporizador                 
                end if;
            end if;
        end if;
    end process;

    -- Salida del contador de segundos
    seconds <= second_count;

end Behavioral;

