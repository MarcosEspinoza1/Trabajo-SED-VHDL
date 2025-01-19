----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2024 20:14:28
-- Design Name: 
-- Module Name: topo_timer - Behavioral
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

entity topo_timer is
    Port (
        clk       : in std_logic;                     -- Reloj principal
        rst       : in std_logic;                     -- Señal de reinicio global
        enable    : in std_logic;                     -- Habilita el temporizador
        mode_sel  : in std_logic;                      -- Selección de modo (0: 1 segundo, 1: 2 segundos)
        time_up   : out std_logic                     -- Señal de "tiempo agotado"
    );
end topo_timer;

architecture Behavioral of topo_timer is
    constant CLOCK_FREQ_1S : unsigned(26 downto 0) := to_unsigned(100_000_000, 27); -- 1 segundo
    constant CLOCK_FREQ_2S : unsigned(26 downto 0) := to_unsigned(200_000_000, 27); -- 2 segundos
    signal clk_counter  : unsigned(26 downto 0) := (others => '0');              -- Contador de ciclos de reloj
    signal current_limit : unsigned(26 downto 0);                                -- Límite actual del contador
begin
    -- Proceso para seleccionar el límite del contador según `mode_sel`
    process(mode_sel)
    begin
        if mode_sel = '0' then
            current_limit <= CLOCK_FREQ_1S; -- 1 segundo
        else
            current_limit <= CLOCK_FREQ_2S; -- 2 segundos
        end if;
    end process;

    -- Proceso principal del temporizador
    process(clk, rst)
    begin
        if rst = '0' then
            clk_counter <= (others => '0');
            time_up <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if clk_counter = current_limit - 1 then
                    clk_counter <= (others => '0'); -- Reinicia el contador
                    time_up <= '1';                -- Indica que el tiempo ha terminado
                else
                    clk_counter <= clk_counter + 1;
                    time_up <= '0';                -- Tiempo aún en curso
                end if;
            else
                clk_counter <= (others => '0');    -- Reinicia el contador si no está habilitado
                time_up <= '0';
            end if;
        end if;
    end process;

end Behavioral;

