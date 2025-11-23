# =============================================================
# output.asm
#
# Funciones para mostrar información del tablero y jugadores.
#
# FUNCIONES:
#   
#   imprimir_nl()
#       Imprime un salto de linea.
#
#   imprimir_num(num)
#       Imprime un num.
#
#   imprimir_text(ptr)
#       Imprime un texto.
#
#   imprimir_titulo()
#       Imprimir el titulo del juego.
#
#   imprimir_jugador(jugador_ptr, etiqueta_ptr)
#       Imprime formato:
#       <etiqueta>
#       Posición: X
#       Dinero:   Y
#       Tesoros:  Z
#
#   imprimir_tablero(tablero_ptr, N)
#       Imprime todo el tablero casilla por casilla.
#
# =============================================================

        .text


# -------------------------------------------------------------
# imprimir_nl()
#   Imprime salto de línea
# -------------------------------------------------------------
        .globl imprimir_nl
imprimir_nl:

    li      $v0, 4
    la      $a0, nl
    syscall
    jr      $ra



# -------------------------------------------------------------
# imprimir_num(num)
#   $a0 = número a imprimir
# -------------------------------------------------------------
        .globl imprimir_num
imprimir_num:

    li      $v0, 1
    syscall
    jr      $ra



# -------------------------------------------------------------
# imprimir_text(ptr)
#   $a0 = puntero a string .asciiz
# -------------------------------------------------------------
        .globl imprimir_text
imprimir_text:

    li      $v0, 4
    syscall
    jr      $ra


# -------------------------------------------------------------
#   imprimir_titulo()
#       Imprimir el titulo del juego.
# -------------------------------------------------------------
        .globl imprimir_titulo
imprimir_titulo:

    # Guardar contexto
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    la $a0, sep_titulo
    jal imprimir_text

    la $a0, titulo
    jal imprimir_text

    la $a0, sep_titulo
    jal imprimir_text

    # Restaurar contexto
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4

    jr $ra


# -------------------------------------------------------------
# imprimir_jugador(jugador_ptr, etiqueta_ptr)
#
# Entradas:
#   $a0 = puntero a struct jugador
#   $a1 = puntero a texto para etiqueta ("Usuario", "Máquina")
# -------------------------------------------------------------
        .globl imprimir_jugador
imprimir_jugador:

    # Guardar contexto
    addi    $sp, $sp, -12
    sw      $ra, 8($sp)
    sw      $s0, 4($sp)
    sw      $s1, 0($sp)

    move    $s0, $a0        # struct jugador
    move    $s1, $a1        # etiqueta


    # ----------------------------------------
    # Mostrar etiqueta
    # ----------------------------------------
    move    $a0, $s1
    jal     imprimir_text
    jal     imprimir_nl

    # ----------------------------------------
    # Posición
    # ----------------------------------------
    li      $v0, 4
    la      $a0, lbl_pos
    syscall

    move    $a0, $s0
    jal     get_posicion

    move    $a0, $v0
    jal     imprimir_num
    jal     imprimir_nl


    # ----------------------------------------
    # Dinero
    # ----------------------------------------
    li      $v0, 4
    la      $a0, lbl_money
    syscall

    move    $a0, $s0
    jal     get_dinero

    move    $a0, $v0
    jal     imprimir_num
    jal     imprimir_nl


    # ----------------------------------------
    # Tesoros
    # ----------------------------------------
    li      $v0, 4
    la      $a0, lbl_tesoros
    syscall

    move    $a0, $s0
    jal     get_tesoros

    move    $a0, $v0
    jal     imprimir_num
    jal     imprimir_nl


    # Restaurar contexto
    lw      $s1, 0($sp)
    lw      $s0, 4($sp)
    lw      $ra, 8($sp)
    addi    $sp, $sp, 12

    jr      $ra



# -------------------------------------------------------------
# imprimir_tablero(tablero_ptr, N)
#
# Entradas:
#   $a0 = puntero a tabla
#   $a1 = N (tamaño)
#
# Imprime:
#   [ 5, -1, 12, 8, -1, 2 ]
#
# -------------------------------------------------------------
        .globl imprimir_tablero
imprimir_tablero:

    # Guardar contexto
    addi    $sp, $sp, -12
    sw      $ra, 8($sp)
    sw      $s0, 4($sp)
    sw      $s1, 0($sp)

    move    $s0, $a0      # ptr tablero
    move    $s1, $a1      # N

    # Imprimir encabezado
    la      $a0, lbl_tablero
    jal     imprimir_text

    # Imprimir [
    la      $a0, texto_abre
    jal     imprimir_text


    # ==============================
    # Recorrido del tablero
    # ==============================
    li      $t0, 0        # i = 0

loop_tablero:

    beq     $t0, $s1, fin_tablero

    # Calcular dirección casilla
    sll     $t1, $t0, 2       # *4
    add     $t1, $t1, $s0     # ptr + offset
    lw      $t2, 0($t1)

    # Imprimir número
    move    $a0, $t2
    jal     imprimir_num

    # Si no es la última, imprimir coma
    addi $t0, $t0, 1
    blt  $t0, $s1, imprimir_coma
    j    fin_tablero

imprimir_coma:
    la $a0, texto_coma
    jal imprimir_text
    j loop_tablero


fin_tablero:

    # Imprimir ]
    la      $a0, texto_cierra
    jal     imprimir_text
    jal     imprimir_nl

    # Restaurar contexto
    lw      $s1, 0($sp)
    lw      $s0, 4($sp)
    lw      $ra, 8($sp)
    addi    $sp, $sp, 12

    jr      $ra


# -------------------------------------------------------------
# Segmento de datos
# -------------------------------------------------------------
        .data

sep_titulo:    .asciiz "\n-------------------------------------------------------------\n"
titulo:        .asciiz "\t\tJUEGO DEL TESORO"

lbl_tablero:   .asciiz "Tablero: "
lbl_pos:       .asciiz "Posición: "
lbl_money:     .asciiz "Dinero:   "
lbl_tesoros:   .asciiz "Tesoros:  "

texto_abre:    .asciiz "[ "
texto_coma:    .asciiz ", "
texto_cierra:  .asciiz " ]"
nl:            .asciiz "\n"