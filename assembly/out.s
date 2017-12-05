.text
main:
		# i = _temp_0
		lw $t0, __temp_0
		sw $t0, _i

	label1:
		# goto label3 if i > _temp_1
		lw $t0 _i
		lw $t1 __temp_1
		bgt $t0, $t1, label3

		# goto label8
		j label8

	label3:
		# _temp_3 = i - _temp_2
		lw $t0, _i
		lw $t1, __temp_2
		sub $t0, $t0, $t1
		sw $t0, __temp_3

		# i = _temp_3
		lw $t0, __temp_3
		sw $t0, _i

		# printi i
		li $v0, 1
		lw $a0, _i
		syscall

		# printf _temp_4
		li $v0, 4
		la $a0, __temp_4
		syscall

		# goto label1
		j label1

	label8:
		# exit
		li $v0,10
		syscall

.data
	__temp_0: .word 8
	_i: .word 0
	__temp_1: .word 0
	__temp_2: .word 1
	__temp_3: .word 0
	__temp_4: .asciiz "\n"
	__temp_5: .word 3
	__temp_6: .word 1
	__temp_7: .word 8
	__temp_8: .word 0
