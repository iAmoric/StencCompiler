.text
main:
		# a = _temp_0
		lw $t0, __temp_0
		sw $t0, _a

		# b = _temp_1
		lw $t0, __temp_1
		sw $t0, _b

		# _temp_2 = b + a
		lw $t0, _b
		lw $t1, _a
		add $t0, $t0, $t1
		sw $t0, __temp_2

		# b = _temp_2
		lw $t0, __temp_2
		sw $t0, _b

		# exit
		li $v0,10
		syscall

.data
	_N: .word 15
	__temp_0: .word 3
	_a: .word 0
	_b: .word 0
	__temp_1: .word 5
	__temp_2: .word 0
