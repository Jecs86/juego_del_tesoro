# =============================================================
# rules.asm
#
# Reglas del juego.
#
#   check_estado(N, usuario, cpu)
#
# Entradas:
#   $a0 = tamaño del tablero (N)
#   $a1 = struct usuario
#   $a2 = struct cpu
#
# Retorno:
#   $v0 =
#       0 -> el juego continúa
#       1 -> gana usuario
#       2 -> gana máquina
#       3 -> empate
#       4 -> usuario llego al final
#       5 -> máquina llego al final
#
# =============================================================

        .text

# -------------------------------------------------------------
# check_estado(N, usuario, cpu)
#   $a0 = tamaño del tablero (N)
#   $a1 = struct usuario
#   $a2 = struct máquina
# -------------------------------------------------------------
        .globl check_estado
check_estado:

    # Guardar contexto ($ra $s0 $s1 $s2)
    addi    $sp, $sp, -16
    sw      $ra, 12($sp)
    sw      $s0, 8($sp)
    sw      $s1, 4($sp)
    sw      $s2, 0($sp)

    move    $s0, $a0       # N
    move    $s1, $a1       # usuario (ptr)
    move    $s2, $a2       # cpu (ptr)


    # -------------------------
    # Verificar tesoros (victoria inmediata)
    # -------------------------
    move    $a0, $s1
    jal     get_tesoros
    move    $t0, $v0        # tesoros usuario

    li      $t7, 3
    bge     $t0, $t7, gana_user

    move    $a0, $s2
    jal     get_tesoros
    move    $t1, $v0        # tesoros cpu

    bge     $t1, $t7, gana_cpu


    # -------------------------
    # 2) Verificar posiciones finales
    # -------------------------
    move    $a0, $s1
    jal     get_posicion
    move    $t0, $v0        # pos usuario

    move    $a0, $s2
    jal     get_posicion
    move    $t1, $v0        # pos cpu

    addi    $t2, $s0, -1    # última casilla index = N-1

    # usuario llego al final?
    bge     $t0, $t2, usuario_en_final

    # si usuario NO llegó, comprobar cpu
    bge     $t1, $t2, cpu_en_final

    # ninguno llegó -> seguir jugando
    li      $v0, 0
    j       fin_rules


# =============================================================
# usuario en posicion final
# =============================================================
usuario_en_final:
    # cpu llego también?
    bge     $t1, $t2, ambos_en_final

    # usuario llegó, cpu no.
    # cpu debe continuar hasta llegar al final.
    li      $v0, 4      # 4 = usuario en final (sin victoria por tesoros) -> cpu continúa
    j       fin_rules

# =============================================================
# cpu en posicion final
# =============================================================
cpu_en_final:
    # usuario no llego -> usuario debe continuar
    li      $v0, 5      # 5 = cpu en final (sin victoria por tesoros) -> usuario continúa
    j       fin_rules


# =============================================================
# ambos jugadores en posicion final
# =============================================================
ambos_en_final:
    # Ambos en final -> comparar dinero, tesoros (evaluar ganador final)
    move    $a0, $s1
    jal     get_dinero
    move    $t3, $v0

    move    $a0, $s2
    jal     get_dinero
    move    $t4, $v0

    bgt     $t3, $t4, gana_user
    blt     $t3, $t4, gana_cpu

    # Si empatan en dinero -> comparar tesoros
    move    $a0, $s1
    jal     get_tesoros
    move    $t5, $v0

    move    $a0, $s2
    jal     get_tesoros
    move    $t6, $v0

    bgt     $t5, $t6, gana_user
    blt     $t5, $t6, gana_cpu

    # Empate total
    li      $v0, 3
    j       fin_rules


# =============================================================
# Ganadores
# =============================================================
gana_user:
    li      $v0, 1
    j       fin_rules

gana_cpu:
    li      $v0, 2
    j       fin_rules


# =============================================================
# Restaurar registros y volver
# =============================================================
fin_rules:
    lw      $s2, 0($sp)
    lw      $s1, 4($sp)
    lw      $s0, 8($sp)
    lw      $ra, 12($sp)
    addi    $sp, $sp, 16

    jr      $ra