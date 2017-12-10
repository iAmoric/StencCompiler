.text
main:
		# a = _temp_0
		li $t0, 5
		sw $t0, _a

		# goto label3 if a == _temp_1
		lw $t0, _a
		li $t1, 6
		beq $t0, $t1, label3

		# goto label6
		j label6

	label3:
		# printf _temp_2
		li $v0, 4
		la $a0, __temp_2
		syscall

		# goto label6
		j label6

		# printf _temp_3
		li $v0, 4
		la $a0, __temp_3
		syscall

	label6:
		# printf _temp_6
		li $v0, 4
		la $a0, __temp_6
		syscall


		# exit
		li $v0,10
		syscall

.data
	_a: .word 0
	__temp_2: .asciiz "IF"
	__temp_3: .asciiz "ELSE"
	__temp_6: .asciiz "FIN"
