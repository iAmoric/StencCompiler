	.text
main:
# b = _temp_0
lw $t0, _temp_0
sw $t0, _b

# a = _temp_1
lw $t0, _temp_1
sw $t0, _a

# _temp_4 = b - _temp_3
lw $t0, _b
lw $t1, _temp_3
sub $t0, $t0, $t1
sw $t0, _temp_4

# _temp_5 = _temp_2 * _temp_4
lw $t0, _temp_2
lw $t1, _temp_4
mul $t0, $t0, $t1
sw $t0, _temp_5

# _temp_6 = a + _temp_5
lw $t0, _a
lw $t1, _temp_5
add $t0, $t0, $t1
sw $t0, _temp_6

# b = _temp_6
lw $t0, _temp_6
sw $t0, _b

# print b
li $v0,1      # appel système pour afficher un entier
lw $a0, _b 	  # chargement de l'entier à afficher
syscall

# exit
li $v0,10
syscall

	.data
_a: .word 0
_b: .word 0
_temp_0: .word 4
_temp_1: .word 5
_temp_2: .word 2
_temp_3: .word 1
_temp_4: .word 0
_temp_5: .word 0
_temp_6: .word 0
_temp_7: .word 0
