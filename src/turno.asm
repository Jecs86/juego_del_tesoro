# =============================================================
# turno.asm
#
# Módulo que controla la lógica de cada turno del juego.
#
# FUNCIONES:
#
#   turno_usuario(bptr_tablero, bptr_usuario, N)
#       $a0 = base del tablero
#       $a1 = puntero a jugador usuario
#       $a2 = N (número de casillas del tablero)
#
#   turno_maquina(bptr_tablero, bptr_cpu, N)
#       $a0 = base del tablero
#       $a1 = puntero a jugador maquina
#       $a2 = N (número de casillas del tablero)
#
# Ambas funciones:
#   - Obtienen avance
#   - Actualizan posición
#   - Evalúan la casilla
#   - Suman dinero o tesoros
# =============================================================

        .text

# -------------------------------------------------------------
# turno_usuario(tablero, jugador, N)
#       $a0 = base del tablero
#       $a1 = puntero a jugador usuario
#       $a2 = N (número de casillas del tablero)
# -------------------------------------------------------------
        .globl turno_usuario
turno_usuario:

    # Guardar contexto
    addi    $sp, $sp, -16
    sw      $ra, 12($sp)
    sw      $s0, 8($sp)
    sw      $s1, 4($sp)
    sw      $s2, 0($sp)

    move    $s0, $a0       # base del tablero
    move    $s1, $a1       # puntero al jugador
    move    $s2, $a2       # N


    # Mostrar Mensaje del turno
    la  $a0, msg_turno_jugador
    jal imprimir_text

    # ==============================
    # Pedir avance (1-6)
    # ==============================
    li      $a0, 1
    li      $a1, 6
    jal     leer_entero_validado
    move    $t0, $v0       # t0 = avance elegido

    # ==============================
    # Sumar avance a la posición
    # ==============================
    move $a0, $s1
    move $a1, $t0
    move $a2, $s7     # s7 contiene N en main.asm
    jal add_posicion


    # ==============================
    # Obtener posición final
    # ==============================
    move    $a0, $s1
    jal     get_posicion
    move    $t1, $v0       # t1 = posición final

    # Si ya se pasó del tablero, fijarlo al final
    sub     $t2, $t1, $s2
    bltz    $t2, dentro_tablero

    # Ajustar a última casilla
    addi    $t1, $s2, -1
    move    $a0, $s1
    move    $a1, $t1
    jal     set_posicion

dentro_tablero:

    # ==============================
    # Leer casilla
    # ==============================

    move    $a0, $s0
    move    $a1, $t1
    jal     leer_casilla
    move    $t3, $v0       # valor de casilla

    # Evaluar:
    li      $t4, -1
    beq     $t3, $t4, encontro_tesoro

    # ==============================
    # No es tesoro → sumar dinero
    # ==============================
    move    $a0, $s1
    move    $a1, $t3
    jal     add_dinero
    j       fin_turno_usuario

# ==============================
# Sí encontró tesoro
# ==============================
encontro_tesoro:

    # Sumar tesoro
    move    $a0, $s1
    jal     add_tesoro

fin_turno_usuario:

    # Restaurar contexto
    lw      $s2, 0($sp)
    lw      $s1, 4($sp)
    lw      $s0, 8($sp)
    lw      $ra, 12($sp)
    addi    $sp, $sp, 16

    jr      $ra


# -------------------------------------------------------------
# turno_maquina(tablero, jugador, N)
#
# Igual que turno_usuario, pero el avance se genera
# automáticamente con un dado.
# -------------------------------------------------------------
        .globl turno_maquina
turno_maquina:

    # Guardar contexto (llamará jal)
    addi    $sp, $sp, -16
    sw      $ra, 12($sp)
    sw      $s0, 8($sp)
    sw      $s1, 4($sp)
    sw      $s2, 0($sp)

    move    $s0, $a0       # base del tablero
    move    $s1, $a1       # puntero al jugador
    move    $s2, $a2       # N

    # Mostrar Mensaje del turno
    la  $a0, msg_turno_maquina
    jal imprimir_text

    # ==============================
    # Obtener avance con dado (1-6)
    # ==============================
    jal     random_dado
    move    $t0, $v0       # t0 = avance de la máquina

    move $a0, $t0
    jal imprimir_num

    # ==============================
    # Sumar avance a la posición
    # ==============================
    move $a0, $s1
    move $a1, $t0
    move $a2, $s7     # s7 contiene N en el main.asm
    jal add_posicion

    # ==============================
    # Obtener nueva posición
    # ==============================
    move    $a0, $s1
    jal     get_posicion
    move    $t1, $v0       # t1 = posición final

    # No dejar pasarse del tablero
    sub     $t2, $t1, $s2
    bltz    $t2, dentro_tablero_cpu

    addi    $t1, $s2, -1
    move    $a0, $s1
    move    $a1, $t1
    jal     set_posicion

dentro_tablero_cpu:

    # ==============================
    # Leer casilla
    # ==============================

    move    $a0, $s0
    move    $a1, $t1
    jal     leer_casilla
    move    $t3, $v0

    # Evaluar casilla
    li      $t4, -1
    beq     $t3, $t4, maquina_tesoro

    # Sumar dinero
    move    $a0, $s1
    move    $a1, $t3
    jal     add_dinero
    j       fin_turno_maquina

# Encontró tesoro
maquina_tesoro:

    move    $a0, $s1
    jal     add_tesoro

fin_turno_maquina:

    # Restaurar contexto
    lw      $s2, 0($sp)
    lw      $s1, 4($sp)
    lw      $s0, 8($sp)
    lw      $ra, 12($sp)
    addi    $sp, $sp, 16

    jr      $ra


# -------------------------------------------------------------
# Datos
# -------------------------------------------------------------
    .data

msg_turno_jugador:     .asciiz "\nTurno del jugador - ingrese movimiento (1-6): "
msg_turno_maquina:     .asciiz "\nTurno de maquina: "
msg_pos_actual:        .asciiz "\nPosición actual: "