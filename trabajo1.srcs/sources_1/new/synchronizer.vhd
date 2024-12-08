----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2024 18:43:35
-- Design Name: 
-- Module Name: synchronizer - Behavioral
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

entity synchronizer is
    Port (
        clk       : in std_logic;
        async_in  : in std_logic;
        sync_out  : out std_logic
    );
end synchronizer;

architecture Behavioral of synchronizer is
    signal sync_reg : std_logic_vector(1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            sync_reg(0) <= async_in;
            sync_reg(1) <= sync_reg(0);
        end if;
    end process;

    sync_out <= sync_reg(1);
end Behavioral;

