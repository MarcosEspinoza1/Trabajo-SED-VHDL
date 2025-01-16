library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchronizer_vector is
    Port (
        clk      : in std_logic;
        async_in : in std_logic_vector(7 downto 0); -- Vector de señales asíncronas
        sync_out : out std_logic_vector(7 downto 0) -- Vector de señales sincronizadas
    );
end synchronizer_vector;

architecture Behavioral of synchronizer_vector is
    signal sync_stage1 : std_logic_vector(7 downto 0); -- Etapa intermedia
begin
    process(clk)
    begin
        if rising_edge(clk) then
            sync_stage1 <= async_in;
            sync_out <= sync_stage1; -- Segunda etapa de sincronización
        end if;
    end process;
end Behavioral;
