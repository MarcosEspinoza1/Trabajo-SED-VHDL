----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2024 18:43:35
-- Design Name: 
-- Module Name: EDGEDTCTR - Behavioral
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

entity EDGEDTCTR is
    port (
        CLK       : in std_logic;
        SYNC_IN   : in std_logic;
        EDGE      : out std_logic
    );
end EDGEDTCTR;

architecture BEHAVIORAL of EDGEDTCTR is
    signal sreg : std_logic_vector(2 downto 0);
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            sreg <= sreg(1 downto 0) & SYNC_IN;
        end if;
    end process;

    EDGE <= '1' when sreg = "100" else '0';
end BEHAVIORAL;

