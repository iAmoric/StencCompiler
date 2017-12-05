.text
main:
		# b = _temp_0
		lw $t0, __temp_0
		sw $t0, _b

		# i = _temp_1
		lw $t0, __temp_1
		sw $t0, _i

	label2:
		# goto label7 if i < _temp_2
		lw $t0 _i
		lw $t1 __temp_2
		blt $t0, $t1, label7

		# goto label28
		j label28

	label4:
		# _temp_4 = i + _temp_3
		lw $t0, _i
		lw $t1, __temp_3
		add $t0, $t0, $t1
		sw $t0, __temp_4

		# i = _temp_4
		lw $t0, __temp_4
		sw $t0, _i

		# goto label2
		j label2

	label7:
		# goto label9 if i > _temp_5
		lw $t0 _i
		lw $t1 __temp_5
		bgt $t0, $t1, label9

		# goto label16
		j label16

	label9:
		# _temp_6 = b + i
		lw $t0, _b
		lw $t1, _i
		add $t0, $t0, $t1
		sw $t0, __temp_6

		# b = _temp_6
		lw $t0, __temp_6
		sw $t0, _b

		# printf _temp_7
		li $v0, 4
		la $a0, __temp_7
		syscall

		# printi b
		li $v0, 1
		lw $a0, _b
		syscall

		# printf _temp_8
		li $v0, 4
		la $a0, __temp_8
		syscall

		# goto label16
		j label16

		# c = _temp_9
		lw $t0, __temp_9
		sw $t0, _c

	label16:
		# goto label18 if c <= _temp_10
		lw $t0 _c
		lw $t1 __temp_10
		ble $t0, $t1, label18

		# goto label27
		j label27

	label18:
		# _temp_11 = b * c
		lw $t0, _b
		lw $t1, _c
		mul $t0, $t0, $t1
		sw $t0, __temp_11

		# _temp_12 = b + _temp_11
		lw $t0, _b
		lw $t1, __temp_11
		add $t0, $t0, $t1
		sw $t0, __temp_12

		# b = _temp_12
		lw $t0, __temp_12
		sw $t0, _b

		# _temp_14 = c + _temp_13
		lw $t0, _c
		lw $t1, __temp_13
		add $t0, $t0, $t1
		sw $t0, __temp_14

		# c = _temp_14
		lw $t0, __temp_14
		sw $t0, _c

		# printf _temp_15
		li $v0, 4
		la $a0, __temp_15
		syscall

		# printi b
		li $v0, 1
		lw $a0, _b
		syscall

		# printf _temp_16
		li $v0, 4
		la $a0, __temp_16
		syscall

		# goto label16
		j label16

	label27:
		# goto label4
		j label4

	label28:
		# printf _temp_26
		li $v0, 4
		la $a0, __temp_26
		syscall

		# printi b
		li $v0, 1
		lw $a0, _b
		syscall

		# printf _temp_27
		li $v0, 4
		la $a0, __temp_27
		syscall

		# exit
		li $v0,10
		syscall

.data
	_i: .word 0
	__temp_0: .word 5
	_b: .word 0
	__temp_1: .word 1
	__temp_2: .word 6
	__temp_3: .word 1
	__temp_4: .word 0
	__temp_5: .word 3
	__temp_6: .word 0
	__temp_7: .asciiz "b = "
	__temp_8: .asciiz "\n"
	__temp_9: .word 0
	_c: .word 0
	__temp_10: .word 5
	__temp_11: .word 0
	__temp_12: .word 0
	__temp_13: .word 1
	__temp_14: .word 0
	__temp_15: .asciiz "b = "
	__temp_16: .asciiz "\n"
	__temp_17: .word 18
	__temp_18: .word 16
	__temp_19: .word 27
	__temp_20: .word 9
	__temp_21: .word 16
	__temp_22: .word 28
	__temp_23: .word 7
	__temp_24: .word 2
	__temp_25: .word 4
	__temp_26: .asciiz "b = "
	__temp_27: .asciiz "\n"
	__temp_28: .word 0
