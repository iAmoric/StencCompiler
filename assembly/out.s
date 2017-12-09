.text
main:
		# a = _temp_0
		lw $t0, __temp_0
		sw $t0, _a

		# _temp_6 = _temp_4 + _temp_5
		lw $t0, __temp_4
		lw $t1, __temp_5
		add $t0, $t0, $t1
		sw $t0, __temp_6

		# _temp_8 = _temp_6 * _temp_2
		lw $t0, __temp_6
		lw $t1, __temp_2
		mul $t0, $t0, $t1
		sw $t0, __temp_8

		# _temp_9 = _temp_7 + _temp_8
		lw $t0, __temp_7
		lw $t1, __temp_8
		add $t0, $t0, $t1
		sw $t0, __temp_9

		# _temp_10 = _temp_9 * _temp_1
		lw $t0, __temp_9
		lw $t1, __temp_1
		mul $t0, $t0, $t1
		sw $t0, __temp_10

		# _temp_11 = a + _temp_10
		lw $t0, _a
		lw $t1, __temp_10
		add $t0, $t0, $t1
		sw $t0, __temp_11

		# _temp_12 = _temp_15 * _temp_11
		lw $t0, __temp_15
		lw $t1, __temp_11
		mul $t0, $t0, $t1
		sw $t0, __temp_12

		# _temp_13 = _temp_12 + @tab
		lw $t0, __temp_12
		la $t1, _tab
		add $t0, $t0, $t1
		sw $t0, __temp_13

		# valeur à l'adresse _temp_13
		lw $t0, __temp_13
		sw $t0, __temp_14

		# _temp_14 = _temp_16
		lw $t0, __temp_16
		sw $t0, __temp_14

		# _temp_19 = _temp_17 + _temp_18
		lw $t0, __temp_17
		lw $t1, __temp_18
		add $t0, $t0, $t1
		sw $t0, __temp_19

		# _temp_21 = _temp_19 * _temp_2
		lw $t0, __temp_19
		lw $t1, __temp_2
		mul $t0, $t0, $t1
		sw $t0, __temp_21

		# _temp_22 = _temp_20 + _temp_21
		lw $t0, __temp_20
		lw $t1, __temp_21
		add $t0, $t0, $t1
		sw $t0, __temp_22

		# _temp_23 = _temp_22 * _temp_1
		lw $t0, __temp_22
		lw $t1, __temp_1
		mul $t0, $t0, $t1
		sw $t0, __temp_23

		# _temp_24 = a + _temp_23
		lw $t0, _a
		lw $t1, __temp_23
		add $t0, $t0, $t1
		sw $t0, __temp_24

		# _temp_25 = _temp_28 * _temp_24
		lw $t0, __temp_28
		lw $t1, __temp_24
		mul $t0, $t0, $t1
		sw $t0, __temp_25

		# _temp_26 = _temp_25 + @tab
		lw $t0, __temp_25
		la $t1, _tab
		add $t0, $t0, $t1
		sw $t0, __temp_26

		# valeur à l'adresse _temp_26
		lw $t0, __temp_26
		sw $t0, __temp_27

		# i = _temp_27
		lw $t0, __temp_27
		sw $t0, _i

		# printi i
		li $v0, 1
		lw $a0, _i
		syscall

		# exit
		li $v0,10
		syscall

.data
	__temp_0: .word 0
	_a: .word 0
	__temp_1: .word 4
	__temp_2: .word 2
	__temp_3: .word 3
	_tab: .space 96
	__temp_4: .word 1
	__temp_5: .word 1
	__temp_6: .word 0
	__temp_7: .word 0
	__temp_8: .word 0
	__temp_9: .word 0
	__temp_10: .word 0
	__temp_11: .word 0
	__temp_12: .word 0
	__temp_13: .word 0
	__temp_14: .word 0
	__temp_15: .word 4
	__temp_16: .word 5
	_i: .word 0
	__temp_17: .word 1
	__temp_18: .word 1
	__temp_19: .word 0
	__temp_20: .word 0
	__temp_21: .word 0
	__temp_22: .word 0
	__temp_23: .word 0
	__temp_24: .word 0
	__temp_25: .word 0
	__temp_26: .word 0
	__temp_27: .word 0
	__temp_28: .word 4
	__temp_29: .word 0
