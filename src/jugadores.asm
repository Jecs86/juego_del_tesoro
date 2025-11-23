# =============================================================
# jugadores.asm
#
# Módulo para gestionar el estado de los jugadores en el juego.
#
# Cada jugador tiene:
#   - posición (offset 0)
#   - dinero   (offset 4)
#   - tesoros  (offset 8)
#
# FUNCIONES:
#
#   inicializar_jugadores(user_ptr, cpu_ptr)
#       Pone todo en cero.
#
#   set_posicion(player_ptr, nueva_pos)
#   add_posicion(player_ptr, delta)
#
#   add_dinero(player_ptr, cantidad)
#
#   add_tesoro(player_ptr)
#
#   get_posicion(player_ptr) → $v0
#   get_dinero(player_ptr)   → $v0
#   get_tesoros(player_ptr)  → $v0
# =============================================================

        .text

# -------------------------------------------------------------
# inicializar_jugadores(user_ptr, cpu_ptr)
#
# Entrada:
#   $a0 = dirección de struct del usuario
#   $a1 = dirección de struct de la máquina
# -------------------------------------------------------------
        .globl inicializar_jugadores
inicializar_jugadores:

    # Guardar $ra
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)


    #############################
    # Inicializar usuario
    #############################
    li      $t0, 0

    sw      $t0, 0($a0)     # posición = 0
    sw      $t0, 4($a0)     # dinero = 0
    sw      $t0, 8($a0)     # tesoros = 0


    #############################
    # Inicializar máquina
    #############################
    sw      $t0, 0($a1)     # posicion = 0
    sw      $t0, 4($a1)     # dinero = 0
    sw      $t0, 8($a1)     # tesoros = 0


    # Restaurar $ra
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4

    jr      $ra


# -------------------------------------------------------------
# set_posicion(player_ptr, nueva_pos)
#
# Entrada:
#   $a0 = jugador
#   $a1 = nueva posición
# -------------------------------------------------------------
        .globl set_posicion
set_posicion:

    sw      $a1, 0($a0)
    jr      $ra


# -------------------------------------------------------------
# add_posicion(player_ptr, delta)
#
# Entrada:
#   $a0 = jugador
#   $a1 = valor a sumar
# -------------------------------------------------------------
        .globl add_posicion
add_posicion:

    # cargar posición actual
    lw      $t0, 0($a0)

    # sumar avance
    add     $t0, $t0, $a1

    # calcular N-1
    addi    $t1, $a2, -1

    # si t0 > N-1 → fijar límite
    bgt     $t0, $t1, limite
    beq     $t0, $zero, guardar

    # guardar posición válida
guardar:
    sw      $t0, 0($a0)
    jr      $ra

limite:
    sw      $t1, 0($a0)
    jr      $ra


# -------------------------------------------------------------
# add_dinero(player_ptr, cantidad)
#
# Entrada:
#   $a0 = jugador
#   $a1 = dinero a sumar
# -------------------------------------------------------------
        .globl add_dinero
add_dinero:

    lw      $t0, 4($a0)
    add     $t0, $t0, $a1
    sw      $t0, 4($a0)
    jr      $ra


# -------------------------------------------------------------
# add_tesoro(player_ptr)
#
# Entrada:
#   $a0 = jugador
# -------------------------------------------------------------
        .globl add_tesoro
add_tesoro:

    lw      $t0, 8($a0)
    addi    $t0, $t0, 1
    sw      $t0, 8($a0)
    jr      $ra


# -------------------------------------------------------------
# get_posicion(player_ptr) → $v0
# -------------------------------------------------------------
        .globl get_posicion
get_posicion:

    lw      $v0, 0($a0)
    jr      $ra


# -------------------------------------------------------------
# get_dinero(player_ptr) → $v0
# -------------------------------------------------------------
        .globl get_dinero
get_dinero:

    lw      $v0, 4($a0)
    jr      $ra


# -------------------------------------------------------------
# get_tesoros(player_ptr) → $v0
# -------------------------------------------------------------
        .globl get_tesoros
get_tesoros:

    lw      $v0, 8($a0)
    jr      $ra