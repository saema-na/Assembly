.data
outBuf:		.space	80		# char types
inBuf:		.space	80		# input string
st_prompt:	.asciiz	"Enter a new input string:\n"


.text		
		jal	clearInBuf		#add null terminators to out/inBuff
		jal	clearOutBuf

newline:
		jal	getline			# get input string
		li	$t0, 0			# i=0

loop:		bge	$t0, 80, dump		# if (i>=80) goto dump
		lb	$a0, inBuf($t0)		# key = inBuf[i]

		jal	lin_search		# $t3: returned type
		addi	$t3, $t3, 0x30
		sb	$t3, outBuf($t0)	# outBuf[i] = char(type)
		
		beq	$a0, '#', dump
		addi	$t0, $t0, 1
		b	loop
	
dump:		jal	printTypes
		jal	clearInBuf
		jal	clearOutBuf

		b newline		
		
		
####################
#
# getline()
#
####################
getline:

	la	$a0, st_prompt		# Prompt to enter a new line
	li	$v0, 4
	syscall

	la	$a0, inBuf		# read a new line
	li	$a1, 80	
	li	$v0, 8
	syscall

		jr	$ra

#####################
#
# lin_search
#	$a0 - search key
#	$t3 - returned numerical type
#
#####################
lin_search:
		li $s1, 0			#setting counter i = 0
	search_loop:	
		lb $t4, Tabchar($s1) 		# load Tabchar[i] into $t4

		beq $t4, 0x5c, exit		# if Tabchar[i] == end of Tabchar, go to exit
		beq $t4, $a0, charFound		# if Tabchar[i] == searchkey, go to charFound
		addi $s1, $s1, 8		# increment counter by 1 integer	
		b search_loop			# goto start of loop
	
	charFound:
		lw	$t3, Tabchar+4($s1)
		 
	exit:		
		jr	$ra
		
####################
#
# printTypes
#
####################
printTypes:	
		la $a0, outBuf				#load outBuf and print to console
		li $v0, 4
		syscall
	
		jr	$ra
		
clearInBuf:
		li $s4, 0
	loop_clearIn:
		beq $s4, 80, exit_clearIn		#exit loop if counter is at 80th element 
		sb $zero, inBuf($s4)		
		addi $s4, $s4, 1			#incrementing counter
		b loop_clearIn
		
	exit_clearIn:
		jr	$ra	
				
clearOutBuf:
		li $s4, 0
	loop_clearOut:
		beq $s4, 80, exit_clearOut		#exit loop if counter @ last element
		sb $zero, outBuf($s4)			#set outBuf[i] to null
		addi $s4, $s4, 1			#increment counter 
		b loop_clearOut
		
	exit_clearOut:	
		jr	$ra	
				
.data
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

	.word	0x5c, -1	# if you "\" as the end of char table
