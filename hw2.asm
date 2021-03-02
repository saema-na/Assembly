.data
inBuf:		.space	80
st_prompt:	.asciiz	"Enter a new string:\n"
tokTab:		.word	0:30	# 10-entry token table
curTok:		.word	0,0
error_prompt:	.asciiz "Error"

.text
newline:	jal	getline
		
		li 	$t7, 0			# counter i=0
		li 	$t5, 0			# counter j=0
		la	$s1, Q0			#address of state Q0 into $s1
		li	$s0, 1			# $s0 =1
		
nextState:	lw	$s2, 0($s1)		#load $s1[0] into $s2
		jalr	$v1, $s2	   
				
		sll	$s0, $s0, 2
		add	$s1, $s1, $s0	
		sra	$s0, $s0, 2
		
		lw	$s1, 0($s1)
		b	nextState

doneState:
		jal	printTokTab
		jal	clearInBuf
		jal	clearTokTab
		b	newline
		

#################################
#		curChar = get next char
#		T = chType(curChar)
#		T = $s0
#################################
ACT1:
		lb 	$a0, inBuf($t7)		#$a0 = curChar
		add 	$t7, $t7, 1		# i++
		jal 	lin_search		#obtain charType of curChar
		move	 $s0, $v0		# T = chType(curChar)
			
		jr	$v1
		
		
#################################
# 	curTok=curChar	
# 	TokSpace=7						
#################################
ACT2:
		sb $a0, curTok			#store first byte from curTok to $a0
		li $s7, 7			# $s7 = tokSpace	
		
		jr	$v1
		
#################################	
#	curTok = curTok + curChar
# 	TokSpace=TokSpace-1 		
#################################		
ACT3:
		subi $t9, $s7, 8		# $t9 = tokSpace - 8 bytes
		sb $a0, curTok($t9)		#store curTok[$t9] in $a0
		subi $s7, $s7, 1		#tokSpace--

		jr	$v1
				
#################################
#		Save curTok into tokTab
#################################																
ACT4:

	lb $a0, curTok				#load first byte curTok into $a0
	b lin_search				
	lw $a1, curTok				#load 4 bytes of curTok into $a1
	sw $a1, tokTab($t5)			#store $a1 into tokTab[$t5]
	
	li $a3, 4				#$a3 = 4
	lw $a1, curTok($a3)			#$a1 = curTok[4]
	addi $t5, $t5, 4			#$t5 = $t5+4
	sw $a1, tokTab($t5)			#tokTab[$t5] = $a1
	
	addi $t5, $t5, 4			# $t5 = $t5 +4
	sw $v0, tokTab($t5)			#tokTab[$t5] = $v0

	addi $t5, $t5, 4			#$t5 = $t5+4

	jr	$v1	
					
					
RETURN:
	
		b	doneState
				

ERROR:		
		la	$a0, error_prompt	# load error_prompt
		li	$v0, 4			#print prompt
		syscall
		b	doneState



#################################
#	Clearing input buffer
#################################
clearInBuf:
		li $s4, 0			# i=0
	loop_clearIn:
		beq $s4, 80, exit_clearIn	# if i == 80 goto exit_clearIn 
		sb $zero, inBuf($s4)		# inBuf[i] = NULL/0
		addi $s4, $s4, 1		# incrementing counter
		b loop_clearIn
		
	exit_clearIn:
		jr	$ra
				
						
#################################
#	Printing Token Table
#################################
printTokTab:
		li $s5, 0			#i=0
	loop_printTok:
		beq $s5, $t5, exit_printTok	#if i at end of toktab goto exit_printTok
		li $v0, 4			#print token
		la $a0, tokTab($s5)
		syscall
			
		addi $s5, $s5, 8		#increment i to point to token type in entry
		li $v0, 4
		la $a0, tokTab($s5)
		syscall				#print token type
			
		addi $s5, $s5, 4		#increment i to next entry
		b loop_printTok						
							

	exit_printTok:
		jr	$ra
	
#####################
#		Set all entries in TokenTable to NULL/zero			
#####################		
clearTokTab:
		li $t5, 0				# i=0
	loop_clearTok:
		bge $t5, 120, exit_clearTok		# exit loop if counter is at last element
		sw $zero, tokTab($t5)			# clear first 4 bytes
		sw $zero, tokTab+4($t5)			# clear second 4 bytes
		sw $zero, tokTab+8($t5)			# clear third 4 bytes
		addi	$t5, $t5, 12			# increment to next entry
		b loop_clearTok	
	
	exit_clearTok:
		jr	$ra

#####################
#
# getline
#
####################
getline: 
	la	$a0, st_prompt				# Prompt to enter a new line
	li	$v0, 4					#prepare system to print st_prompt
	syscall

	la	$a0, inBuf				# read a new line, $a0= address of inBuf
	li	$a1, 80					#max number of chars to read
	li	$v0, 8					#reading string	
	syscall

	jr	$ra


#####################
#
# lin_search
#	$a0 - search key
#	$v0 - returned numerical type
#
#####################
lin_search:
		li $s1, 0				#setting counter i = 0
	search_loop:	
		lb $t4, Tabchar($s1) 			# load Tabchar[i] into $t4

		beq $t4, 0x5c, exit			# if Tabchar[i] == end of Tabchar, goto exit
		beq $t4, $a0, charFound			# if Tabchar[i] == searchkey, goto charFound
		addi $s1, $s1, 8			# increment counter to next entry in Tabchar	
		b search_loop				# goto search_loop
	
	charFound:
		lw	$v0, Tabchar+4($s1)		# $t3 = character type from Tabchar
		 
	exit:		
		jr	$ra						
												

.data
stateTab:
Q0:     .word  ACT1
        .word  Q1   # T1
        .word  Q1   # T2
        .word  Q1   # T3
        .word  Q1   # T4
        .word  Q1   # T5
        .word  Q1   # T6
        .word  Q11  # T7


Q1:     .word  ACT2
        .word  Q2   # T1
        .word  Q5   # T2
        .word  Q3   # T3
        .word  Q3   # T4
        .word  Q0   # T5
        .word  Q4   # T6
        .word  Q11  # T7


Q2:     .word  ACT1
        .word  Q6   # T1
        .word  Q7   # T2
        .word  Q7   # T3
        .word  Q7   # T4
        .word  Q7   # T5
        .word  Q7   # T6
        .word  Q11  # T7


Q3:     .word  ACT4
        .word  Q0   # T1
        .word  Q0   # T2
        .word  Q0   # T3
        .word  Q0   # T4
        .word  Q0   # T5
        .word  Q0   # T6
        .word  Q11  # T7


Q4:     .word  ACT4
        .word  Q10  # T1
        .word  Q10  # T2
        .word  Q10  # T3
        .word  Q10  # T4
        .word  Q10  # T5
        .word  Q10  # T6
        .word  Q11  # T7

Q5:     .word  ACT1
        .word  Q8   # T1
        .word  Q8   # T2
        .word  Q9   # T3
        .word  Q9   # T4
        .word  Q9   # T5
        .word  Q9   # T6
        .word  Q11  # T7


Q6:     .word  ACT3
        .word  Q2   # T1
        .word  Q2   # T2
        .word  Q2   # T3
        .word  Q2   # T4
        .word  Q2   # T5
        .word  Q2   # T6
        .word  Q11  # T7


Q7:     .word  ACT4
        .word  Q1   # T1
        .word  Q1   # T2
        .word  Q1   # T3
        .word  Q1   # T4
        .word  Q1   # T5
        .word  Q1   # T6
        .word  Q11  # T7


Q8:     .word  ACT3
        .word  Q5   # T1
        .word  Q5   # T2
        .word  Q5   # T3
        .word  Q5   # T4
        .word  Q5   # T5
        .word  Q5   # T6
        .word  Q11  # T7


Q9:     .word  ACT4
        .word  Q1  # T1
        .word  Q1  # T2
        .word  Q1  # T3
        .word  Q1  # T4
        .word  Q1  # T5
        .word  Q1  # T6
        .word  Q11 # T7


Q10:	.word	RETURN
        .word  Q10  # T1
        .word  Q10  # T2
        .word  Q10  # T3
        .word  Q10  # T4
        .word  Q10  # T5
        .word  Q10  # T6
        .word  Q11  # T7


Q11:    .word  ERROR 
	.word  Q4  # T1
	.word  Q4  # T2
	.word  Q4  # T3
	.word  Q4  # T4
	.word  Q4  # T5
	.word  Q4  # T6
	.word  Q4  # T7


Tabchar: 	
	.word 	0x0a, 6		# LF
	.word 	' ', 5
 	.word 	'#', 6
	.word 	'$', 4
	.word 	'(', 4 
	.word 	')', 4 
	.word 	'*', 3 
	.word 	'+', 3 
	.word 	',', 4 
	.word 	'-', 3 
	.word 	'.', 4 
	.word 	'/', 3 

	.word 	'0', 1
	.word 	'1', 1 
	.word 	'2', 1 
	.word 	'3', 1 
	.word 	'4', 1 
	.word 	'5', 1 
	.word 	'6', 1 
	.word 	'7', 1 
	.word 	'8', 1 
	.word 	'9', 1 


	.word 	':', 4 


	.word 	'A', 2
	.word 	'B', 2 
	.word 	'C', 2 
	.word 	'D', 2 
	.word 	'E', 2 
	.word 	'F', 2 
	.word 	'G', 2 
	.word 	'H', 2 
	.word 	'I', 2 
	.word 	'J', 2 
	.word 	'K', 2
	.word 	'L', 2 
	.word 	'M', 2 
	.word 	'N', 2 
	.word 	'O', 2 
	.word 	'P', 2 
	.word 	'Q', 2 
	.word 	'R', 2 
	.word 	'S', 2 
	.word 	'T', 2 
	.word 	'U', 2
	.word 	'V', 2 
	.word 	'W', 2 
	.word 	'X', 2 
	.word 	'Y', 2
	.word 	'Z', 2

	.word 	'a', 2 
	.word 	'b', 2 
	.word 	'c', 2 
	.word 	'd', 2 
	.word 	'e', 2 
	.word 	'f', 2 
	.word 	'g', 2 
	.word 	'h', 2 
	.word 	'i', 2 
	.word 	'j', 2 
	.word 	'k', 2
	.word 	'l', 2 
	.word 	'm', 2 
	.word 	'n', 2 
	.word 	'o', 2 
	.word 	'p', 2 
	.word 	'q', 2 
	.word 	'r', 2 
	.word 	's', 2 
	.word 	't', 2 
	.word 	'u', 2
	.word 	'v', 2 
	.word 	'w', 2 
	.word 	'x', 2 
	.word 	'y', 2
	.word 	'z', 2
	.word	0x5c, -1	# if you ‘\’ as the end of char table
