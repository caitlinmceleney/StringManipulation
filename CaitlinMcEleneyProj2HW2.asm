##############################################################
# Homework #2
# name: Caitlin McEleney
##############################################################
.eqv PRINT_STRING 4
.macro print_string(%address)
	li $v0, 4
	la $a0, %address
	syscall 
.end_macro

.macro print_string_reg(%reg)
	li $v0, PRINT_STRING
	la $a0, 0(%reg)
	syscall 
.end_macro

.text

##############################
# PART 1 FUNCTIONS 
##############################

#Turn String into uppercase
toUpper:			#Input located at $a0
	move $t0, $a0		#store $a0 input into $t0
	
	loop:				#to capitalize
	lb $t1, ($t0)			#loads byte at $t0 location into $t1
	beq $t1, 0, exit		#if $t0 is 0, string is over
	blt $t1, 'a', not_lower		#if less than 'a', not lowercase
	bgt $t1, 'z', not_lower		#if greater than 'z', not lowercase
	sub $t1, $t1, 32		#if it is lowercase, subtract 32 for correct ASCII value
	sb $t1, ($t0)			#store new uppercase into $t1
	
	not_lower:			#when not lowercase (anymore)
	addi $t0, $t0, 1		#increment to next letter
	j loop
	
	exit:
	move $v0, $a0
	jr $ra	

length2Char:			#figuring out the number of characters to reach the give character
	move $t0, $a0			#loads the given string into $t0
	lb $t1, ($a1)			#loads the given character into $t1
	
	loopL2C:
	lb $t2, ($t0)			#loads the first byte into $t2
	beq $t2, 0, exitL2C		#if reaches end, breaks
	beq $t2, $t1, exitL2C		#if the character is equal to the char at the byte at $t1, breaks
	addi $t3, $t3, 1		#adds 1 to $t3 to increment counter
	addi $t0, $t0, 1		#increments to the next byte
	j loopL2C
	
	exitL2C:
	li $v0, 0
	move $v0, $t3
	jr $ra

strcmp:
	move $t0, $a0			#loads str1 into $t0
	move $t1, $a1			#loads str2 into $t1
	move $t2, $a2			#loads the length into $t2
			#sets equal counter ($t4) to 0 to count the equal characters
	li $t5, 0			#sets second return value to 0 - will return 1 if identical for given length or entirety
	li $t3, 0
	beq $t2, 0, loopStrcmp		#catch if $t2 is zero and continue
	
	strKeyLength:			#check to make sure that the length isn't bigger than actual length
	lb $t6, ($t0)
	lb $t7, ($t1)
	beq $t6, 0, lengthNull
	beq $t7, 0, lengthNull
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t3, $t3, 1
	j strKeyLength
	
	lengthNull:	
	bgt $t2, $t3, zeroOut 
	la $t0, ($a0)
	la $t1, ($a1)
	li $t4, 0

	loopStrcmp:
	#addi $t5, $t5, 1		#increments the length counter
	#beq $t5, $t2, exitStr		#if $t5(counter) > $t3, break
	lb $t6, 0($t0)			#loads the byte of str1 into $t6
	lb $t7, 0($t1)			#loads the byte of str2 into $t7
	beq $t7, $t6, ifEqual		#continue if the character at $t6 and $t7 are equal and NOT NULL
	#addi $t4, $t4, 1		#adds one to the equal counter 
	beq $t6, 0, exitStr		#if $t6 is null, break 
	beq $t7, 0, exitStr		#if $t7 is null, break
	#addi $t0, $t0, 1		#increments to the next byte of str1
	#addi $t1, $t1, 1		#increments to the next byte of str2
	j exitStr

	ifEqual:
	beq $t6, 0, exitStr1		#if $t6 is null, break
	addi $t4, $t4, 1		#adds one to the equal counter 
	addi $t0, $t0, 1		#increments to the next byte of str1
	addi $t1, $t1, 1		#increments to the next byte of str2
	addi $t5, $t5, 1		#increments the length counter
	beq $t5, $t2, exitStr1		#if $t5(counter) > $t3, break
	j loopStrcmp
	
	exitStr:
	#addi $t4, $t4, 1		#adds one to the equal counter 
	seq $v1, $t2, $t4		#if length and equal counter are equal, then set $v1 to 0
	#beq $v1, 0, minOne
	move $v0, $t5			#move number of equal to $v0
	jr $ra
	
	#minOne:
	#subi $t4, $t4, 1
	#move $v0, $t4
	#jr $ra
	
	exitStr1:
	li $v1, 1
	move $v0, $t4
	jr $ra
	
	zeroOut:
	li $v0, 0
	li $v1, 0
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

toMorse:
	move $t0, $a0			#move the string into $t0
	move $t1, $a1			#move the space into $t1
	move $t2, $a2			#move the given length int into $t2
	la $t3, MorseExclamation	#load the address of the MorseCode Array
	li $t4, 1			#length counter to determine the length of the Morse code
	blt $t2, 1, zeroMorse		#if length is less than one, exit with no output and 0
	
	loopToMorse:			#set a branch to add 'x' and increment
	lb $t5, ($t0)			#load the first byte of the string ($t0) into $t5
	addi $t0, $t0, 1		#increment to the next byte of the string for the next loop
	beq $t5, 0, contToMorse		#if $t5 is null (at the end) continue to check given length vs actual length
	blt $t5, '!', loopToMorse	#if less than '!', skip
	bgt $t5,'Z', loopToMorse	#if greater than 'Z', skip
	subi $t5, $t5, 33		#altering the ascii value to utilize the array (! = 0)
	move $t9, $t3			#load the word at address in $t6
	
	beq $t5, 0, innerLoopMorse
	
	arrayLoop:			#loop to find the array
	lb $t6, ($t9)			#load the first byte of the entire array
	beq $t6, 0, subNull		#if it is a null, skip to subNull
	addi $t9, $t9, 1		#increment #t9
	j arrayLoop
	
	subNull:
	subi $t5, $t5, 1		#subtract a null spot from $t5
	beq $t5, 0, addOne		#branch if it hits $t5
	addi $t9, $t9, 1		#increment $t9
	j arrayLoop
	
	addOne:
	addi $t9, $t9, 1		#add one more to $t9 to go to the next array location
	
	innerLoopMorse:
	lb $t1, ($t9)
	beq $t1, 0, addXloop		#load the $t9 byte into $t1
	addi $t4, $t4, 1
	bgt $t4, $t2, zeroMorse		#if length of the actual morse code is greater than given length, 0 all
	sb $t1, ($a1)
	addi $t9, $t9, 1		#increment the byte value of the morse code called from the array
	addi $a1, $a1, 1
	beq $t1, 0, addXloop		#if $t1 is null, break from the loop
	j innerLoopMorse
	
	addXloop:
	addi $t4, $t4, 1		#incrementing the length counter
	bgt $t4, $t2, zeroMorse		#if length of the actual morse code is greater than given length, 0 all
	li $t7, 0
	add $t7, $t7, 'x'
	sb $t7, ($a1)
	addi $a1, $a1, 1
	j loopToMorse
	
	contToMorse:
	beq $t4, 1, noX
	addi $t4, $t4, 1		#incrementing the length counter
	bgt $t4, $t2, zeroMorse		#if length of the actual morse code is greater than given length, 0 all
	li $t7, 'x'
	sb $t7, ($a1)
	noX:
	li $v1, 1			#passes all checks, $v1 = 1
	move $v0, $t4			#length counter into $v0
	jr $ra
	
	zeroMorse:		#length < 1 return 0s
	li $v0, 0
	blt $t4, 2, noLength
	subi $t4, $t4, 1
	move $v0, $t4
	noLength:
	li $v1, 0
	jr $ra


createKey:					
	subi $sp, $sp, 4
	sw $ra, ($sp)
	jal toUpper			#make the string all capitals
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	move $t0, $a0			#move the uppercase string into $t0
	li $t9, 0
	
	outerLoopKey:			#check that each letter is only used once
	lb $t2, ($t0)			#load the first byte of the string into $t2
	beq $t2, 0, keyEncrypt		#if the string is over, move to keyEncrypting
	addi $t0, $t0, 1 
	bgt $t2, 'Z', outerLoopKey
	blt $t2, 'A', outerLoopKey	#if it is > Z and < A, it shouldn't be added                 
	move $t1, $a1			#start at the first location of the address

	innerLoopKey:
	lb $t8, ($t1)			#load the first byte of the string into
	beq $t8, 0, noMatch		#if there is no match, add
	beq $t2, $t8, outerLoopKey	#if they are equal, don't save it
	addi $t1, $t1, 1		#increment to the next $t1 location
	j innerLoopKey			#a catch
	
	noMatch:
	sb $t2, ($t1)
	addi $t9, $t9, 1
	j outerLoopKey
	
	keyEncrypt:
	li $t3, 'A'			#load the first letter into $t3
	la $t1, ($a1)			#load the starting location into $t1

	outerLoopKeyEncrypt:		#put in all the other letters
	lb $t2, ($t1)			#load the first byte of the no repeat string
	beq $t2, 0, keyEnd
	addi $t1, $t1, 1		#increment $t1
	beq $t3, $t2, innerLoopKeyEncrypt
	j outerLoopKeyEncrypt
	
	innerLoopKeyEncrypt:
	addi $t3, $t3, 1		#move to the next letter
	move $t1, $a1			#start at beginning letter again
	j outerLoopKeyEncrypt
	
	keyEnd:
	sb $t3, ($t1)
	move $t1, $a1
	addi $t9, $t9, 1
	beq $t9, 26, exitKey
	j outerLoopKeyEncrypt

	exitKey:
	jr $ra

keyIndex:
	#la $a0, keyIndex_mcmsg		morse code string to compare
	#jal keyIndex
	subi $sp, $sp, 4
	sw $ra, ($sp)
	move $t0, $a0			#move the given morse key into $t0
	la $a1, FMorseCipherArray	#load the array into $t1
	li $t9, 0			#counter
	la $t3, checkKey		#location to save FMorseCipherArray 3 char
	
	checkMorseCipher:
	lb $t2, ($t0)		#load the first byte of the cipherArray into $t2
	#blt $t2, 'Z', noMatchstr
	#bgt $t2, 'A', noMatchstr
	sb $t2, ($t3)		#store the first byte into a new location
	addi $t0, $t0, 1	#increment $t1
	addi $t3, $t3, 1	#increment $t3 location
	addi $t9, $t9, 1	#increment check that it is to stop after 3 char
	blt $t9, 3, checkMorseCipher

	
	li $s5, 0
	la $a0, checkKey
	
	StringComp:
	la $a0, checkKey
	li $a2, 3
	#print_string_reg($a1)
	
	jal strcmp			#compare the strings
	
	beq $v0, 3, found
	addi $s5, $s5, 1
	addi $a1, $a1, 3
	lb $t4, ($a1)
	beq $t4, 0, noMatchstr
	j StringComp
	
	found:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	move $v0, $s5
	jr $ra
	
	noMatchstr:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	li $s5, -1
	move $v0, $s5
	jr $ra

FMCEncrypt:
	#Define your code here
	############################################
	# DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
	la $v0, FMorseCipherArray
	############################################
	jr $ra

##############################
# EXTRA CREDIT FUNCTIONS
##############################

FMCDecrypt:
	#Define your code here
	############################################
	# DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
	la $v0, FMorseCipherArray
	############################################
	jr $ra

fromMorse:
	#Define your code here
	jr $ra



.data

MorseCode: .word MorseExclamation, MorseDblQoute, MorseHashtag, Morse$, MorsePercent, MorseAmp, MorseSglQoute, MorseOParen, MorseCParen, MorseStar, MorsePlus, MorseComma, MorseDash, MorsePeriod, MorseFSlash, Morse0, Morse1,  Morse2, Morse3, Morse4, Morse5, Morse6, Morse7, Morse8, Morse9, MorseColon, MorseSemiColon, MorseLT, MorseEQ, MorseGT, MorseQuestion, MorseAt, MorseA, MorseB, MorseC, MorseD, MorseE, MorseF, MorseG, MorseH, MorseI, MorseJ, MorseK, MorseL, MorseM, MorseN, MorseO, MorseP, MorseQ, MorseR, MorseS, MorseT, MorseU, MorseV, MorseW, MorseX, MorseY, MorseZ 

MorseExclamation: .asciiz "-.-.--"
MorseDblQoute: .asciiz ".-..-."
MorseHashtag: .asciiz ""
Morse$: .asciiz ""
MorsePercent: .asciiz ""
MorseAmp: .asciiz ""
MorseSglQoute: .asciiz ".----."
MorseOParen: .asciiz "-.--."
MorseCParen: .asciiz "-.--.-"
MorseStar: .asciiz ""
MorsePlus: .asciiz ""
MorseComma: .asciiz "--..--"
MorseDash: .asciiz "-....-"
MorsePeriod: .asciiz ".-.-.-"
MorseFSlash: .asciiz ""
Morse0: .asciiz "-----"
Morse1: .asciiz ".----"
Morse2: .asciiz "..---"
Morse3: .asciiz "...--"
Morse4: .asciiz "....-"
Morse5: .asciiz "....."
Morse6: .asciiz "-...."
Morse7: .asciiz "--..."
Morse8: .asciiz "---.."
Morse9: .asciiz "----."
MorseColon: .asciiz "---..."
MorseSemiColon: .asciiz "-.-.-."
MorseLT: .asciiz ""
MorseEQ: .asciiz "-...-"
MorseGT: .asciiz ""
MorseQuestion: .asciiz "..--.."
MorseAt: .asciiz ".--.-."
MorseA: .asciiz ".-"
MorseB:	.asciiz "-..."
MorseC:	.asciiz "-.-."
MorseD:	.asciiz "-.."
MorseE:	.asciiz "."
MorseF:	.asciiz "..-."
MorseG:	.asciiz "--."
MorseH:	.asciiz "...."
MorseI:	.asciiz ".."
MorseJ:	.asciiz ".---"
MorseK:	.asciiz "-.-"
MorseL:	.asciiz ".-.."
MorseM:	.asciiz "--"
MorseN: .asciiz "-."
MorseO: .asciiz "---"
MorseP: .asciiz ".--."
MorseQ: .asciiz "--.-"
MorseR: .asciiz ".-."
MorseS: .asciiz "..."
MorseT: .asciiz "-"
MorseU: .asciiz "..-"
MorseV: .asciiz "...-"
MorseW: .asciiz ".--"
MorseX: .asciiz "-..-"
MorseY: .asciiz "-.--"
MorseZ: .asciiz "--.."

loopCheck1: .asciiz "1"
loopCheck2: .asciiz "2"


FMorseCipherArray: .asciiz ".....-..x.-..--.-x.x..x-.xx-..-.--.x--.-----x-x.-x--xxx..x.-x.xx-.x--x-xxx.xx-"

checkKey: .space 10

