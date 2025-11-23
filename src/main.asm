# =============================================================
# main.asm
#
# Juego del Tesoro
#
# Flujo:
#   1) Pedir tamaño del tablero
#   2) Crear tablero
#   3) Inicializar jugadores
#   4) Turnos alternados:
#           usuario → máquina → verificar estado
#
# Termina cuando:
#   - Un jugador consigue 3 tesoros
#   - Ambos llegan al final del tablero
#
# =============================================================

        .text
        .globl main


main:

    #Guardar contexto
    addi    $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s6, 0($sp)

    jal imprimir_titulo

    ############################################################
    # Pedir tamaño del tablero
    ############################################################

    # Mostrar mensaje
    la  $a0, msg_tamano
    jal imprimir_text

    # Validar entrada 20–120
    li  $a0, 20
    li  $a1, 120
    jal leer_entero_validado

    move $s7, $v0           # s7 = N tamaño del tablero


    ############################################################
    # Crear tablero
    ############################################################

    move $a0, $s7           # N
    jal crear_tablero

    move $s6, $v0 # base del tablero


    ############################################################
    # Inicializar jugadores
    ############################################################

    la  $a0, jugador_usuario
    la  $a1, jugador_cpu
    jal inicializar_jugadores


    ############################################################
    # Comienzo del bucle del juego
    ############################################################
loop_juego:

    ############################################################
    # Turno del usuario
    ############################################################

    move $a0, $s6
    la  $a1, jugador_usuario
    move $a2, $s7
    jal turno_usuario

    # Mostrar estado usuario
    la $a0, jugador_usuario
    la $a1, lbl_usuario
    jal imprimir_jugador

    ############################################################
    # Evaluar estado tras turno del usuario
    ############################################################

    move $a0, $s7
    la   $a1, jugador_usuario
    la   $a2, jugador_cpu
    jal  check_estado

    move $t0, $v0

    beq $t0, 0, seguir_cpu       # sigue el flujo normal (usuario->cpu)
    beq $t0, 1, usuario_gano
    beq $t0, 2, cpu_gano
    beq $t0, 3, empate_final
    beq $t0, 4, cpu_only         # usuario llegó al final (sin 3 tesoros) -> cpu continúa
    beq $t0, 5, user_only        # cpu llegó al final (sin 3 tesoros) -> usuario continúa


seguir_cpu:

    ############################################################
    # Turno de la máquina
    ############################################################

    move $a0, $s6
    la  $a1, jugador_cpu
    move $a2, $s7
    jal turno_maquina

    # Mostrar estado cpu
    la $a0, jugador_cpu
    la $a1, lbl_cpu
    jal imprimir_jugador

    ############################################################
    # Evaluar estado tras turno de la CPU
    ############################################################

    move $a0, $s7
    la   $a1, jugador_usuario
    la   $a2, jugador_cpu
    jal  check_estado

    move $t0, $v0

    beq $t0, 0, loop_juego       # sigue el flujo normal (cpu->usuario)
    beq $t0, 1, usuario_gano
    beq $t0, 2, cpu_gano
    beq $t0, 3, empate_final
    beq $t0, 4, cpu_only         # usuario llegó al final (sin 3 tesoros) -> cpu continúa
    beq $t0, 5, user_only        # cpu llegó al final (sin 3 tesoros) -> usuario continúa

# ==========================
# cpu_only: la CPU juega hasta que check_estado cambie
# (se ejecuta cuando el usuario ya llegó al final y debe esperar)
# ==========================
cpu_only:

    # Turno de la máquina (solo la CPU)
    move $a0, $s6
    la   $a1, jugador_cpu
    move $a2, $s7
    jal  turno_maquina

    # Mostrar estado cpu
    la $a0, jugador_cpu
    la $a1, lbl_cpu
    jal imprimir_jugador

    # Re-evaluar estado
    move $a0, $s7
    la   $a1, jugador_usuario
    la   $a2, jugador_cpu
    jal  check_estado
    move $t0, $v0

    beq $t0, 0, cpu_only    # si sigue la condición "usuario en final", repetir CPU-only
    beq $t0, 1, usuario_gano
    beq $t0, 2, cpu_gano
    beq $t0, 3, empate_final
    beq $t0, 4, cpu_only    # (caso raro: sigue siendo 4) -> continuar
    beq $t0, 5, user_only   # (si cpu pasó a estar en final) -> ahora usuario deberá continuar

    j mostrar_final         # por si retorna otro código


# ==========================
# user_only: el USUARIO juega (con interacción) hasta que check_estado cambie
# ==========================
user_only:

    # Turno del usuario (solo el usuario)
    move $a0, $s6
    la   $a1, jugador_usuario
    move $a2, $s7
    jal  turno_usuario

    # Mostrar estado usuario
    la $a0, jugador_usuario
    la $a1, lbl_usuario
    jal imprimir_jugador

    # Re-evaluar estado
    move $a0, $s7
    la   $a1, jugador_usuario
    la   $a2, jugador_cpu
    jal  check_estado
    move $t0, $v0

    beq $t0, 0, user_only    # si sigue la condición "cpu en final", repetir usuario-only
    beq $t0, 1, usuario_gano
    beq $t0, 2, cpu_gano
    beq $t0, 3, empate_final
    beq $t0, 5, user_only
    beq $t0, 4, cpu_only

    j mostrar_final


###############################################################
# Mostrar resultados finales
###############################################################
usuario_gano:

    la $a0, msg_usuario_gano
    jal imprimir_text
    j mostrar_final


cpu_gano:

    la $a0, msg_cpu_gano
    jal imprimir_text
    j mostrar_final


empate_final:

    la $a0, msg_empate
    jal imprimir_text



###############################################################
# Mostrar estado final de todo
###############################################################
mostrar_final:

    jal imprimir_nl

    # Mostrar estado usuario
    la $a0, jugador_usuario
    la $a1, lbl_usuario
    jal imprimir_jugador

    # Mostrar estado cpu
    la $a0, jugador_cpu
    la $a1, lbl_cpu
    jal imprimir_jugador

    # Mostrar tablero final
    move $a0, $s6
    move $a1, $s7
    jal imprimir_tablero

    # Restaurar contexto
    sw      $s6, 0($sp)
    sw      $ra, 4($sp)
    addi    $sp, $sp, 4

    ############################################################
    # Salir
    ############################################################
    li $v0, 10
    syscall




# =============================================================
# DATA
# =============================================================
        .data

msg_tamano:         .asciiz "Ingrese el tamaño del tablero (20-120): "

msg_usuario_gano:   .asciiz "\n¡¡¡EL USUARIO HA GANADO!!!\n"
msg_cpu_gano:       .asciiz "\nLa máquina ha ganado.\n"
msg_empate:         .asciiz "\nEl juego ha terminado en empate.\n"

lbl_usuario:        .asciiz "\n--- ESTADO DEL USUARIO ---\n"
lbl_cpu:            .asciiz "\n--- ESTADO DE LA MÁQUINA ---\n"

                    .align 2

# Estructura jugador: posición, dinero, tesoros
jugador_usuario:    .space 12
jugador_cpu:        .space 12