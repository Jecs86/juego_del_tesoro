# =====================================================
# random.asm
# Módulo de generación de números aleatorios para
# el Juego de los Tesoros.
#
# FUNCIONES:
#
#   random_in_range(start, end)
#       Entrada:
#           $a0 = inicio del rango   (por ejemplo 5)
#           $a1 = final del rango    (por ejemplo 12)
#       Salida:
#           $v0 = número aleatorio entre [start, end]
#
#   random_dado()
#       Retorna en $v0 un número entre 1 y 6
#
#   random_dinero()
#       Retorna en $v0 un número entre 10 y 100
#
# Notas:
#   - Usa syscall 42 (MARS) --> devuelve random en $a0
#   - Se maneja correctamente $ra para evitar saltos incorrectos.
# =====================================================

        .text

# -----------------------------------------------------
#  random_in_range
#  Genera un número aleatorio dentro de un rango.
#
#  Esta función NO llama a otras funciones, por lo tanto
#  NO necesita guardar $ra.
# -----------------------------------------------------
        .globl random_in_range
random_in_range:

    # Guardar inicio en $t1 para usarlo luego
    move    $t1, $a0           # t1 = start

    # Calcular tamaño del rango (end - start + 1)
    sub     $t0, $a1, $a0      # t0 = end - start
    addi    $t0, $t0, 1        # t0 = (end - start + 1)

    # Llamar a syscall 42 en rango [0, t0)
    li      $v0, 42
    move    $a1, $t0           # límite del rango
    syscall                     # devuelve resultado en $a0

    # Ajustar al rango real: random + start
    add     $v0, $a0, $t1

    jr      $ra


# -----------------------------------------------------
#  random_dado
#  Genera un número aleatorio entre 1 y 6
#  Esta función SÍ llama a random_in_range, por lo que
#  debe guardar y restaurar $ra.
# -----------------------------------------------------
        .globl random_dado
random_dado:

    # Guardar $ra en la pila
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    # Llamar random_in_range(1, 6)
    li      $a0, 1
    li      $a1, 6
    jal     random_in_range

    # Restaurar $ra
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4

    jr      $ra


# -----------------------------------------------------
#  random_dinero
#  Genera un número aleatorio entre 10 y 100
#  También llama a random_in_range, así que debe
#  proteger $ra.
# -----------------------------------------------------
        .globl random_dinero
random_dinero:

    # Guardar $ra en la pila
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    # Llamar random_in_range(10, 100)
    li      $a0, 10
    li      $a1, 100
    jal     random_in_range

    # Restaurar $ra
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4

    jr      $ra

