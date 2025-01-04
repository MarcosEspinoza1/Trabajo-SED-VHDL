library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr_generator is
    port (
        clk         : in  std_logic;                  -- Reloj principal
        rst         : in  std_logic;                  -- Señal de reinicio
        enable_lfsr : in  std_logic;                  -- Señal de habilitación para el LFSR
        seed        : in  std_logic_vector(7 downto 0); -- Valor inicial (semilla)
        lfsr_out    : out std_logic_vector(7 downto 0) -- Salida con un LED encendido
    );
end entity;

architecture Behavioral of lfsr_generator is
    signal lfsr          : std_logic_vector(7 downto 0); -- Registro LFSR
    signal feedback      : std_logic;                   -- Feedback para LFSR
begin

    -- Generación del LFSR con retroalimentación
    feedback <= lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3); -- Ejemplo de taps para 8 bits

    process (clk, rst)
    begin
        if rst = '0' then
            lfsr <= seed; -- Inicializa el LFSR con la semilla
        elsif rising_edge(clk) then
            if enable_lfsr = '1' then
                lfsr <= lfsr(6 downto 0) & feedback; -- Desplaza y agrega feedback
            end if;
        end if;
    end process;

    -- Control de la salida: asegura que solo un LED esté encendido
    process (lfsr)
    variable led_index : integer range 0 to 7;
    begin
        -- Inicializa la salida con todos los LEDs apagados
        lfsr_out <= (others => '0');
        
        -- Determina el índice del LED a encender según el valor de LFSR
        led_index := to_integer(unsigned(lfsr(2 downto 0))); -- Usa los 3 bits menos significativos
        if led_index <= 7 then
            lfsr_out(led_index) <= '1'; -- Enciende el LED correspondiente
        end if;
    end process;

end Behavioral;
