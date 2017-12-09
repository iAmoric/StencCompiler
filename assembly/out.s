.text
main:
		# i = _temp_0
		lw $t0, __temp_0
		sw $t0, _i

	label1:
		# goto label5 if i < N
		lw $t0 _i
		lw $t1 _N
		blt $t0, $t1, label5

		# goto label14
		j label14

	label3:
		# i = i + _temp_1
		lw $t0, _i
		lw $t1, __temp_1
		add $t0, $t0, $t1
		sw $t0, _i

		# goto label1
		j label1

	label5:
		# j = _temp_2
		lw $t0, __temp_2
		sw $t0, _j

	label6:
		# goto label10 if j < N
		lw $t0 _j
		lw $t1 _N
		blt $t0, $t1, label10

		# goto label13
		j label13

	label8:
		# j = j + _temp_3
		lw $t0, _j
		lw $t1, __temp_3
		add $t0, $t0, $t1
		sw $t0, _j

		# goto label6
		j label6

	label10:
		# printi j
		li $v0, 1
		lw $a0, _j
		syscall

		# printf _temp_4
		li $v0, 4
		la $a0, __temp_4
		syscall

		# goto label8
		j label8

	label13:
		# goto label3
		j label3

		# exit
		li $v0,10
		syscall

.data
	_N: .word 5
	_i: .word 0
	_j: .word 0
	__temp_0: .word 0
	__temp_1: .word 1
	__temp_2: .word 0
	__temp_3: .word 1
	__temp_4: .asciiz "\n"
	__temp_5: .word 13
	__temp_6: .word 10
	__temp_7: .word 6
	__temp_8: .word 8
	__temp_9: .word 14
	__temp_10: .word 5
	__temp_11: .word 1
	__temp_12: .word 3
