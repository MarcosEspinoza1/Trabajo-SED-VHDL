----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.12.2024 17:30:31
-- Design Name: 
-- Module Name: lfsr1 - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr1 is
    port (
        clk         : in  std_logic;                  -- Reloj
        reset       : in  std_logic;                  -- Reinicio
        seed        : in  std_logic_vector(7 downto 0); -- Valor inicial (semilla)
        leds        : out std_logic_vector(7 downto 0) -- Salida a los LEDs
    );
end entity;

architecture rtl of lfsr1 is
    signal lfsr          : std_logic_vector(7 downto 0); -- Registro LFSR
    signal cuentaTiempo  : integer range 0 to 10 := 0;   -- Contador de tiempo
    signal feedback      : std_logic;                   -- Feedback para LFSR
begin

    -- Generación del LFSR con retroalimentación
    feedback <= lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3); -- operación pseudoaleatoriedad

    process (clk, reset)
    begin
        if reset = '1' then
            lfsr <= seed;           -- Inicializa el LFSR con la semilla
            cuentaTiempo <= 0;      -- Reinicia el contador de tiempo
        elsif rising_edge(clk) then
            if cuentaTiempo = 10 then
                lfsr <= lfsr(6 downto 0) & feedback; -- Desplaza y agrega feedback
                cuentaTiempo <= 0;                  -- Reinicia el contador
            else
                cuentaTiempo <= cuentaTiempo + 1;   -- Incrementa el contador
            end if;
        end if;
    end process;

    -- Control de LEDs: sólo un LED encendido a la vez
    process (lfsr)
    variable led_index : integer range 0 to 7;
    begin
        -- Inicializa todos los LEDs apagados
        leds <= (others => '0');
        
        -- Determina el índice del LED a encender según el valor de lfsr
        led_index := to_integer(unsigned(lfsr(2 downto 0))); -- Usa los 3 bits menos significativos
        if led_index <= 7 then --Verificamos que es menor que 7
            leds(led_index) <= '1'; -- Enciende el LED correspondiente
        end if;
    end process;

end architecture;

