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
        time_up   : out std_logic                     -- Señal de "tiempo agotado"
    );
end topo_timer;

architecture Behavioral of topo_timer is
    constant CLOCK_FREQ : unsigned(26 downto 0) := to_unsigned(100_000_000, 27); -- Frecuencia del reloj (100 MHz)
    signal clk_counter  : unsigned(26 downto 0) := (others => '0');              -- Contador de ciclos de reloj
begin

    process(clk, rst)
    begin
        if rst = '1' then
            clk_counter <= (others => '0');
            time_up <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if clk_counter = CLOCK_FREQ - 1 then
                    clk_counter <= (others => '0'); -- Reinicia el contador
                    time_up <= '1';                -- Indica que el tiempo ha terminado
                else
                    clk_counter <= clk_counter + 1;
                    time_up <= '0';                -- Tiempo aún en curso
                end if;
            end if;
        end if;
    end process;

end Behavioral;

