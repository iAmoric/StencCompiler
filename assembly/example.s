.text
main:
# calcul de 3+2
lw $t0,temp2    # chargement de 3 dans le registre t0
lw $t1,temp3    # chargement de 2 dans le registre t1
add $t0,$t0,$t1 # t0 = t0 + t1
sw $t0,temp5    # écriture du résultat en mémoire à l'adresse dont le label est temp5
# transfert du résultat de temp5 à temp6 ( E -> ( E ) )
lw $t0,temp5
sw $t0,temp6
# calcul de 2*(3+2)
lw $t0,temp1
lw $t1,temp6
mul $t0,$t0,$t1
sw $t0,temp7
# calcul de 2*(3+2)+1
lw $t0,temp7
lw $t1,temp4
add $t0,$t0,$t1
sw $t0,temp8
# affichage du rÃ©sultat
li $v0,4      # appel système pour afficher une chaine
la $a0,str    # chargement de l'adresse de la chaine
syscall       # affichage de la chaine
li $v0,1      # appel système pour afficher un entier
lw $a0, temp8 # chargement de l'entier à afficher
syscall       # affichage
# exit
li $v0,10     # on sort proprement du programme
syscall

.data
temp1: .word 2 # 2 est stocké en mémoire à l'adresse dont le label est temp2
temp2: .word 3
temp3: .word 2
temp4: .word 1
temp5: .word 0
temp6: .word 0
temp7: .word 0
temp8: .word 0
