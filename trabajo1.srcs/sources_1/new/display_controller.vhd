----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2024 19:45:14
-- Design Name: 
-- Module Name: display_controller - Behavioral
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

entity display_controller is
    Port (
        clk        : in std_logic;                          -- Reloj principal
        rst        : in std_logic;                          -- Señal de reinicio
        score      : in unsigned(7 downto 0);               -- Puntaje (0-255)
        seconds    : in unsigned(13 downto 0);              -- Tiempo en segundos (0-9999)
        anodes     : out std_logic_vector(6 downto 0);      -- Control de los anodos de los displays
        segments   : out std_logic_vector(6 downto 0)       -- Señales para los segmentos del display
    );
end display_controller;

architecture Behavioral of display_controller is

    signal digit_select : unsigned(2 downto 0) := (others => '0'); -- Selección del display activo
    signal current_digit : std_logic_vector(3 downto 0);          -- Dígito actual para el display
    signal clk_div : unsigned(15 downto 0) := (others => '0');    -- Divisor de frecuencia para multiplexado

    -- Constantes para los displays
    constant MAX_DISPLAYS : integer := 7;

    -- Decodificación de dígitos a segmentos
    function decode_digit(digit : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case digit is
            when "0000" => return "0000001"; -- 0
            when "0001" => return "1001111"; -- 1
            when "0010" => return "0010010"; -- 2
            when "0011" => return "0000110"; -- 3
            when "0100" => return "1001100"; -- 4
            when "0101" => return "0100100"; -- 5
            when "0110" => return "0100000"; -- 6
            when "0111" => return "0001111"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0000100"; -- 9
            when others => return "1111111"; -- Apagado
        end case;
    end function;

begin

    -- Divisor de frecuencia para multiplexado
    process(clk, rst)
    begin
        if rst = '0' then
            clk_div <= (others => '0');
        elsif rising_edge(clk) then
            clk_div <= clk_div + 1;
        end if;
    end process;

    -- Selección del dígito y anodo activo
    process(clk_div(15), rst)
    begin
        if rst = '0' then
            digit_select <= (others => '0');
        elsif rising_edge(clk_div(15)) then
            if digit_select = to_unsigned(MAX_DISPLAYS - 1, 3) then
                digit_select <= (others => '0');
            else
                digit_select <= digit_select + 1;
            end if;
        end if;
    end process;

    -- Mapeo del contenido de los displays
    process(digit_select, score, seconds)
    begin
        case digit_select is
            when "000" => -- Display 1 (puntaje, centenas)
                current_digit <= std_logic_vector(to_unsigned(to_integer(score) / 100, 4));
                anodes <= "1111110"; -- Activa el display 1
            when "001" => -- Display 2 (puntaje, decenas)
                current_digit <= std_logic_vector(to_unsigned(to_integer(score / 10) mod 10, 4));
                anodes <= "1111101"; -- Activa el display 2
            when "010" => -- Display 3 (puntaje, unidades)
                current_digit <= std_logic_vector(to_unsigned(to_integer(score) mod 10, 4));
                anodes <= "1111011"; -- Activa el display 3
            when "011" => -- Display 4 (tiempo, millares)
                current_digit <= std_logic_vector(to_unsigned(to_integer(seconds) / 1000, 4));
                anodes <= "1110111"; -- Activa el display 4
            when "100" => -- Display 5 (tiempo, centenas)
                current_digit <= std_logic_vector(to_unsigned(to_integer(seconds / 100) mod 10, 4));
                anodes <= "1101111"; -- Activa el display 5
            when "101" => -- Display 6 (tiempo, decenas)
                current_digit <= std_logic_vector(to_unsigned(to_integer(seconds / 10) mod 10, 4));
                anodes <= "1011111"; -- Activa el display 6
            when "110" => -- Display 7 (tiempo, unidades)
                current_digit <= std_logic_vector(to_unsigned(to_integer(seconds) mod 10, 4));
                anodes <= "0111111"; -- Activa el display 7
            when others =>
                current_digit <= "0000";
                anodes <= "1111111"; -- Todos los displays apagados
        end case;
    end process;

    -- Decodificación de dígito a segmentos
    segments <= decode_digit(current_digit);

end Behavioral;



