.text
main:
		# b = _temp_0
		lw $t0, __temp_0
		sw $t0, _b

		# _temp_2 = b + _temp_1
		lw $t0, _b
		lw $t1, __temp_1
		add $t0, $t0, $t1
		sw $t0, __temp_2

		# _temp_4 = _temp_2 / _temp_3
		lw $t0, __temp_2
		lw $t1, __temp_3
		div $t0, $t0, $t1
		sw $t0, __temp_4

		# c = _temp_4
		lw $t0, __temp_4
		sw $t0, _c

		# printi c
		li $v0, 1
		lw $a0, _c
		syscall

		# goto label6
		j label6

	label6:
		# goto label7
		j label7

	label7:
		# goto label8
		j label8

	label8:
		# goto label9
		j label9

	label9:
		# a = _temp_5
		lw $t0, __temp_5
		sw $t0, _a

		# printi a
		li $v0, 1
		lw $a0, _a
		syscall

		# exit
		li $v0,10
		syscall

.data
	_a: .word 0
	__temp_0: .word 5
	_b: .word 0
	__temp_1: .word 5
	__temp_2: .word 0
	__temp_3: .word 2
	__temp_4: .word 0
	_c: .word 0
	__temp_5: .word 3
	__temp_6: .word 9
	__temp_7: .word 10
	__temp_8: .word 8
	__temp_9: .word 10
	__temp_10: .word 7
	__temp_11: .word 10
	__temp_12: .word 6
	__temp_13: .word 10
	__temp_14: .word 0
