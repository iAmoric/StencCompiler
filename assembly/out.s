.text
main:
		# a = _temp_0
		lw $t0, __temp_0
		sw $t0, _a

		# b = _temp_1
		lw $t0, __temp_1
		sw $t0, _b

		# goto label7 if a == _temp_2
		lw $t0 _a
		lw $t1 __temp_2
		beq $t0, $t1, label7

		# goto label4
		j label4

	label4:
		# goto label7 if b == _temp_3
		lw $t0 _b
		lw $t1 __temp_3
		beq $t0, $t1, label7

		# goto label6
		j label6

	label6:
		# goto label7
		j label7

	label7:
		# a = _temp_6
		lw $t0, __temp_6
		sw $t0, _a

		# goto label10 if a == _temp_9
		lw $t0 _a
		lw $t1 __temp_9
		beq $t0, $t1, label10

		# goto label12
		j label12

	label10:
		# goto label12
		j label12

		# b = a
		lw $t0, _a
		sw $t0, _b

	label12:
		# printf _temp_13
		li $v0, 4
		la $a0, __temp_13
		syscall

		# printi a
		li $v0, 1
		lw $a0, _a
		syscall

		# printf _temp_14
		li $v0, 4
		la $a0, __temp_14
		syscall

		# printi b
		li $v0, 1
		lw $a0, _b
		syscall

		# printf _temp_15
		li $v0, 4
		la $a0, __temp_15
		syscall

		# exit
		li $v0,10
		syscall

.data
	__temp_0: .word 8
	_a: .word 0
	__temp_1: .word 7
	_b: .word 0
	__temp_2: .word 7
	__temp_3: .word 8
	__temp_4: .word 4
	__temp_5: .word 6
	__temp_6: .word 7
	__temp_7: .word 7
	__temp_8: .word 8
	__temp_9: .word 7
	__temp_10: .word 10
	__temp_11: .word 11
	__temp_12: .word 12
	__temp_13: .asciiz "a = "
	__temp_14: .asciiz "\nb = "
	__temp_15: .asciiz "\n"
	__temp_16: .word 0
