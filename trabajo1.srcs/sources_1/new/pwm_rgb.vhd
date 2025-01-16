----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2024 12:42:58
-- Design Name: 
-- Module Name: pwm_rgb - Behavioral
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

entity pwm_rgb is
    Port (
        clk        : in std_logic;               -- Reloj principal
        rst        : in std_logic;               -- Señal de reinicio
        red_duty   : in unsigned(7 downto 0);    -- Ciclo de trabajo para el canal rojo
        green_duty : in unsigned(7 downto 0);    -- Ciclo de trabajo para el canal verde
        blue_duty  : in unsigned(7 downto 0);    -- Ciclo de trabajo para el canal azul
        red_out    : out std_logic;              -- Salida PWM para el canal rojo
        green_out  : out std_logic;              -- Salida PWM para el canal verde
        blue_out   : out std_logic               -- Salida PWM para el canal azul
    );
end pwm_rgb;

architecture Behavioral of pwm_rgb is
    signal pwm_counter : unsigned(7 downto 0) := (others => '0'); -- Contador de PWM
begin
    -- Generador de PWM
    process(clk, rst)
    begin
        if rst = '0' then
            pwm_counter <= (others => '0');
        elsif rising_edge(clk) then
            pwm_counter <= pwm_counter + 1;
        end if;
    end process;

    -- Salidas PWM
    red_out <= '1' when pwm_counter < red_duty else '0';
    green_out <= '1' when pwm_counter < green_duty else '0';
    blue_out <= '1' when pwm_counter < blue_duty else '0';
end Behavioral;

