# =============================================================
# tablero.asm
# Módulo de creación y gestión del tablero.
#
# El tablero es un array dinámico de enteros, asignado con
# syscall 9, donde cada casilla contiene:
#   -1   → tesoro
#   > 0  → cantidad de dinero (10 a 100)
#
# FUNCIONES:
#
#   crear_tablero(N)
#       Entrada:
#           $a0 = número de casillas (N)
#       Salida:
#           $v0 = dirección base del tablero asignado
#
#   colocar_tesoros(base, N)
#           $a0 = dirección base del tablero
#           $a1 = número total de casillas
#
#   colocar_dinero(base, N)
#           $a0 = dirección base del tablero
#           $a1 = número total de casillas
#
#   leer_casilla(base, index)
#       Entrada:
#           $a0 = dirección base
#           $a1 = índice de la casilla
#       Salida:
#           $v0 = valor almacenado
# =============================================================

        .text


# -------------------------------------------------------------
# crear_tablero(N)
# Solicita memoria dinámica con syscall 9.
# Cada casilla ocupa 4 bytes.
#
# Entrada:
#   $a0 = N
# Salida:
#   $v0 = dirección base del tablero
# -------------------------------------------------------------
        .globl crear_tablero
crear_tablero:

    # Guardar contexto
    addi    $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s0, 0($sp)

    # Validacion N <= 120
    li      $t6, 120
    bgt     $a0, $t6, invalid_n     # Si N > 120, saltar a error

    move    $t0, $a0        # t0 = N (Valor validado)

    # Calcular bytes: N * 4
    li      $t1, 4
    mul     $t2, $t0, $t1   # $t2 = Bytes necesarios

    # Solicitar memoria
    li      $v0, 9
    move    $a0, $t2
    syscall

    move    $s0, $v0       # s0 = base del tablero (dirección asignada)
    move    $s5, $v0       # copia segura
    
    # 5. Inicializar todo a 0
    li      $t3, 0
    move    $t4, $s0        # puntero de recorrido
    move    $t5, $t0        # contador N


init_loop:
    beq     $t5, $zero, init_done

    sw      $t3, 0($t4)   # tablero[i] = 0

    addi    $t4, $t4, 4
    addi    $t5, $t5, -1
    j       init_loop

init_done:
    j fill

# Manejo del Caso N > 120
invalid_n:
    move $t0, $a0

    # Mensaje de error
    la $a0, msg_err_tablero
    jal imprimir_text

    move $a0, $t0
    jal imprimir_num

    # Terminación del programa
    li $v0, 10
    syscall

fill:
    ########################################################
    # Llamar a colocar_tesoros(base, N)
    ########################################################
    move $a0, $s5     # base del tablero
    move $a1, $t0     # N
    jal colocar_tesoros

    ########################################################
    # Llamar a colocar_dinero(base, N)
    ########################################################
    move $a0, $s5     # base del tablero
    move $a1, $t0     # N
    jal colocar_dinero

restore_ra:

    move $v0, $s5

    lw      $s0, 0($sp)
    lw      $ra, 4($sp)
    addi    $sp, $sp, 8

    jr      $ra


# -------------------------------------------------------------
# colocar_tesoros(base, N)
#
# El número de tesoros = 30% de N
# Cada tesoro se marca como -1 en su posición.
#
# Entrada:
#   $a0 = base
#   $a1 = N
# -------------------------------------------------------------
        .globl colocar_tesoros
colocar_tesoros:

    # Guardar contexto
    addi    $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $s0, 0($sp)

    move    $s0, $a0      # base
    move    $t0, $a1      # N

    # calcular num_tesoros = 30% de N
    li      $t1, 30
    mul     $t2, $t0, $t1
    li      $t3, 100
    div     $t2, $t3
    mflo    $t4            # t4 = cantidad de tesoros

tesoro_loop:
    beq     $t4, $zero, tesoros_listos

    # random_in_range(0, N-1)
    li      $a0, 0
    addi    $a1, $t0, -1
    jal     random_in_range
    move    $t5, $v0       # índice aleatorio

    # posicion = base + index*4
    mul     $t6, $t5, 4
    add     $t7, $s0, $t6

    # escribir -1 (solo si no hay tesoro ya)
    lw      $t8, 0($t7)
    li      $t9, -1
    beq     $t8, $t9, tesoro_loop   # si ya era tesoro, genera otro

    sw      $t9, 0($t7)             # colocar tesoro

    addi    $t4, $t4, -1
    j       tesoro_loop

tesoros_listos:

    # restaurar contexto
    lw      $s0, 0($sp)
    lw      $ra, 4($sp)
    addi    $sp, $sp, 8

    jr      $ra


# -------------------------------------------------------------
# colocar_dinero(base, N)
#
# Para cada casilla que no tiene tesoro,
# poner dinero con random_dinero() (10 a 100).
#
# Entrada:
#   $a0 = base
#   $a1 = N
# -------------------------------------------------------------
        .globl colocar_dinero
colocar_dinero:

    # Guardar contexto
    addi    $sp, $sp, -16
    sw      $ra, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)

    move    $s0, $a0      # base
    move    $s1, $a1      # N

    li      $s2, 0        # índice i

dinero_loop:

    beq     $s2, $s1, dinero_listo

    # posición memoria = base + index*4
    mul     $t2, $s2, 4
    add     $t3, $s0, $t2

    lw      $t4, 0($t3)
    li      $t5, -1
    beq     $t4, $t5, skip_dinero   # si ya es tesoro, no poner dinero

    # llamar random_dinero()
    jal     random_dinero

    sw      $v0, 0($t3)   # guardar dinero

skip_dinero:
    addi    $s2, $s2, 1
    j       dinero_loop

dinero_listo:

    # Restaurar contexto
    lw      $s0, 0($sp)
    lw      $s1, 4($sp)
    lw      $s2, 8($sp)
    lw      $ra, 12($sp)
    addi    $sp, $sp, 16

    jr      $ra


# -------------------------------------------------------------
# leer_casilla(base, index)
#
# Entrada:
#   $a0 = base
#   $a1 = index
# Salida:
#   $v0 = valor
# -------------------------------------------------------------
        .globl leer_casilla

leer_casilla:

    # DEBUG: si la base es cero, mostrará mensaje y hará exit
    beq   $a0, $zero, leer_error_base

    # Codigo normal
    mul   $t0, $a1, 4
    add   $t1, $a0, $t0
    lw    $v0, 0($t1)
    jr    $ra

leer_error_base:
    la    $a0, msg_err_base
    li    $v0, 4
    syscall

    # imprimir índice (a1)
    move  $a0, $a1
    li    $v0, 1
    syscall

    la    $a0, msg_nl
    li    $v0, 4
    syscall

    # terminar programa
    li    $v0, 10
    syscall


# -------------------------------------------------------------
# Datos
# -------------------------------------------------------------
        .data

msg_err_tablero:    .asciiz "ERROR: Creación de Tablero con tamaño: "
msg_err_base:       .asciiz "ERROR: base del tablero = 0. index = "
msg_nl:             .asciiz "\n"
