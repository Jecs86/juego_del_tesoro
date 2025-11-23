# =============================================================
# input.asm
# Módulo de entrada y validación del usuario.
#
# FUNCIONES:
#
#   leer_entero()
#       Retorna en $v0 un entero ingresado por teclado.
#
#   leer_entero_validado(min, max)
#       Entradas:
#           $a0 = valor mínimo permitido
#           $a1 = valor máximo permitido
#       Salida:
#           $v0 = entero válido dentro de [min, max]
# =============================================================

        .text

# -------------------------------------------------------------
# leer_entero()
#   Lee un entero ingresado por teclado
#   y devuelve el valor en $v0
# -------------------------------------------------------------
        .globl leer_entero
leer_entero:

    li      $v0, 5      # syscall leer entero
    syscall             # entero queda en $v0
    jr      $ra


# -------------------------------------------------------------
# leer_entero_validado(min, max)
#
# Entradas:
#   $a0 = min
#   $a1 = max
#
# Salida:
#   $v0 = entero dentro de [min, max]
# -------------------------------------------------------------
        .globl leer_entero_validado
leer_entero_validado:

    # Guardar $ra porque esta función hace jal
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    move $t0, $a0 # guardar $a0

validar_loop:

    # Leer número
    jal     leer_entero
    move    $t1, $v0       # t1 = valor ingresado

    # Comparar con min ($t0)
    blt     $t1, $t0, mensaje_error

    # Comparar con max ($a1)
    bgt     $t1, $a1, mensaje_error

    # Si llega aquí, el número es válido
    move    $v0, $t1

    # Restaurar $ra
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4

    jr      $ra


# Imprime mensaje de error y vuelve a solicitar el dato
mensaje_error:

    li      $v0, 4
    la      $a0, err_msg
    syscall

    j       validar_loop


# -------------------------------------------------------------
# Datos
# -------------------------------------------------------------
        .data

err_msg:    .asciiz "Valor no válido. Intente nuevamente: "
