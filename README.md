# Juego_del_tesoro
Programa diseñado para simular un juego entre el usuario y la máquina dentro de un tablero unidimensional.

## Reglas del juego
El juego termina cuando ocurre alguno de los siguientes casos:
  1. Un jugador encuentra tres tesoros.
      En este caso, gana inmediatamente.
  2. Ambos jugadores llegan al final del tablero.
     Si ninguno tiene tres tesoros:
     - Gana el jugador con más dinero acumulado.
     - Si hay empate en dinero, gana el que tenga más tesoros.
     - Si persiste el empate, se declara empate.
  3. Si un jugador llega al final, el otro todavía debe seguir avanzando hasta llegar también.
     
## Requisitos
El juego fue diseñado para ejecutarse bajo el entorno MARS 4.5, un simulador de la arquitectura MIPS. Se requiere disponer de:
  - El simulador MARS versión 4.5
  - Sistema operativo Windows, Linux o macOS
  - Los archivos .asm que conforman el proyecto

## Pasos para la ejecución
1.	Abrir MARS
2.	Cargar el archivo main.asm de la carpeta src/
3.	Verificar que la opción “Assemble all files in directory” esté activada
5.	Ensamblar el proyecto
6.	Ejecutar con Go
