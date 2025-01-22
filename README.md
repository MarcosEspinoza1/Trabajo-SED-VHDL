# Juego de Topos en FPGA

Proyecto implementado en FPGA donde el jugador debe activar interruptores que coincidan con LEDs aleatorios encendidos, con un sistema de puntuación y temporización.

## Características

- **FSM**: Controla la lógica del juego y los estados.
- **LFSR**: Genera LEDs activos de forma aleatoria.
- **Temporizadores**: 
  - Global: Duración total del juego.
  - Local: Tiempo de encendido de cada LED.
- **Indicadores RGB**: Muestra el resultado:
  - **Verde**: Correcto.
  - **Rojo**: Incorrecto o tiempo agotado.
- **Displays**: Puntuación y tiempo restante.

## Requisitos

- **Hardware**: FPGA ( Nexys 4 DDR ).
- **Software**: Xilinx Vivado.


## Autores

- **Marcos Espinoza Pino (56351)**
- **Mario García López (56379)**
- **Manuel Hidalgo (56416)**
