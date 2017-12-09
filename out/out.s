.text
main:
		# i = _temp_0
		li $t0, 0
		sw $t0, _i

	label1:
		# goto label5 if i < HEIGHT
		lw $t0, _i
		li $t1, 20
		blt $t0, $t1, label5

		# goto label18
		j label18

	label3:
		# i = i + _temp_1
		lw $t0, _i
		li $t1, 1
		add $t0, $t0, $t1
		sw $t0, _i

		# goto label1
		j label1

	label5:
		# j = _temp_2
		li $t0, 0
		sw $t0, _j

	label6:
		# goto label10 if j < WIDTH
		lw $t0, _j
		li $t1, 20
		blt $t0, $t1, label10

		# goto label17
		j label17

	label8:
		# j = j + _temp_3
		lw $t0, _j
		li $t1, 1
		add $t0, $t0, $t1
		sw $t0, _j

		# goto label6
		j label6

	label10:
		# _temp_4 = i * WIDTH
		lw $t0, _i
		li $t1, 20
		mul $t0, $t0, $t1
		sw $t0, __temp_4

		# _temp_5 = j + _temp_4
		lw $t0, _j
		lw $t1, __temp_4
		add $t0, $t0, $t1
		sw $t0, __temp_5

		# _temp_6 = _temp_8 * _temp_5
		li $t0, 4
		lw $t1, __temp_5
		mul $t0, $t0, $t1
		sw $t0, __temp_6

		# _temp_7 = _temp_6 + @tab
		lw $t0, __temp_6
		la $t1, _tab
		add $t0, $t0, $t1
		sw $t0, __temp_7

		# _temp_9 = j + i
		lw $t0, _j
		lw $t1, _i
		add $t0, $t0, $t1
		sw $t0, __temp_9

		# ecrire _temp_9 à l'adresse _temp_7
		lw $t0, __temp_9
		lw $t1, __temp_7
		sw $t0, ($t1)

		# goto label8
		j label8

	label17:
		# goto label3
		j label3

	label18:
		# _temp_20 = _temp_18 * WIDTH
		li $t0, 3
		li $t1, 20
		mul $t0, $t0, $t1
		sw $t0, __temp_20

		# _temp_21 = _temp_19 + _temp_20
		li $t0, 7
		lw $t1, __temp_20
		add $t0, $t0, $t1
		sw $t0, __temp_21

		# _temp_22 = _temp_25 * _temp_21
		li $t0, 4
		lw $t1, __temp_21
		mul $t0, $t0, $t1
		sw $t0, __temp_22

		# _temp_23 = _temp_22 + @tab
		lw $t0, __temp_22
		la $t1, _tab
		add $t0, $t0, $t1
		sw $t0, __temp_23

		#lire _temp_23 et stocker dans _temp_24
		lw $t0, __temp_23
		lw $t0, ($t0)
		sw $t0, __temp_24

		# x = _temp_24
		lw $t0, __temp_24
		sw $t0, _x

		# goto label26 if x != _temp_26
		lw $t0, _x
		li $t1, 10
		bne $t0, $t1, label26

		# goto label29
		j label29

	label26:
		# printf _temp_27
		li $v0, 4
		la $a0, __temp_27
		syscall

		# goto label29
		j label29

		# printf _temp_28
		li $v0, 4
		la $a0, __temp_28
		syscall

	label29:
		# printi x
		li $v0, 1
		lw $a0, _x
		syscall


		# exit
		li $v0,10
		syscall

.data
	_tab: .space 1600
	_i: .word 0
	_j: .word 0
	_x: .word 0
	__temp_4: .word 0
	__temp_5: .word 0
	__temp_6: .word 0
	__temp_7: .word 0
	__temp_9: .word 0
	__temp_20: .word 0
	__temp_21: .word 0
	__temp_22: .word 0
	__temp_23: .word 0
	__temp_24: .word 0
	__temp_27: .asciiz "ERREUR\n"
	__temp_28: .asciiz "OK\n"
