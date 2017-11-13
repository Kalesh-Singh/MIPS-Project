.data
	error_msg:		.asciiz 	"Invalid hexadecimal number." 
	prompt:			.asciiz 	"Please enter a 8-digit or smaller hexadecimal number: "
	char_a: 		.byte 		'a'
	char_g: 		.byte 		'g'	
	char_A: 		.byte 		'A'
	char_G:			.byte 		'G'
	char_0: 		.byte 		'0'
	char_colon: 		.byte 		':'
	user_input: 		.space 		 9	# we need 8 bytes to read in at most 8 characters and 1 for endline character
	valid_msg:		.asciiz 	"The character is a valid hex"
	decimal_value_msg:	.asciiz 	"The corresponding decimal value is: "
	decimal_result: 	.word 		0
	new_line_char: 		.byte 		10
	end_line_char: 		.byte 		0
	space_char: 		.byte 		32
.text
	main:	
		# Prompt the user for input
		li $v0, 4
		la $a0, prompt
		syscall

		# Get user input
		li $v0, 8			# Tells system to get user input from the keyboard as text
		la $a0, user_input
		li $a1, 9			# Tells the system the maximum number of bytes to read		
		syscall	
	
		# Calculate corresponding decimal value

		la $s0, user_input		# Store address of input string in $s0
	    	add $s1, $zero, $zero		# Initialize $s1 to zero it will be used to store the decimal result

# ------------------------------------------------------------

		# We will use $s3, $s4, $s5 to store the char codes of ' ', NUL and '\n' respectively.
		lb $s3, space_char
		lb $s4, end_line_char
		lb $s5, new_line_char

		addi $t7, $zero, 0              			# Initialize offset to zero
	
		# We will loop through the string to find the end of the input i.e. either NUL or '\n'
		Loop1:
			add $t0, $s0, $t7				# Increment the address
			lb $t6, 0($t0)					# Store the first char of $t0 to $t6
			beq $t6, $s4, EndOfString			# If current char is end_line_char -- > End of string
 			beq $t6, $s5, EndOfString			# If current char is new_line_char --> End of string
			addi $t7, $t7, 1				# Increment the offset
			j Loop1			
	
		EndOfString:
			add $t8, $zero, $t7              		# Set offset limit to $t7
		
		# We will loop through the string checking for leading spaces and find the start index
		addi $t7, $zero, 0                  			# Initialize offset to zero
		
		Loop2: 
			add $t0, $s0, $t7               		# Increment the address
            		lb $t6, 0($t0)                  		# Store the first char of $t0 to $t6
            		beq $t7, $t8, Invalid       			# If offset is offset limit -- > Invalid
            		bne $t6, $s3, EndIndex     			# If current char is not space  --> EndIndex
            		addi $t7, $t7, 1                		# Increment the offset
            		j Loop2
            		
		# NOTE: START INDEX --> $t7
		EndIndex:
			addi $t8, $t8, -1				# Inititalize offset to offset limit - 1


		# We will loop through the string in reverse checking for lagging spaces and find the end index
		Loop3:
            		add $t0, $s0, $t8               		# Increment the address
            		lb $t6, 0($t0)                  		# Store the first char of $t0 to $t6
            		bne $t6, $s3, InitializeIndices     	# If current char is not space  --> InitializeIndices
            		addi $t8, $t8, -1               		# Decrement the offset
            		j Loop3

		
#-------------------------------------------------------------
		# NOTE: END INDEX --> $t8

		InitializeIndices:
			add $a1, $zero, $t7				# Initialize offset to 0
			add $t1, $zero, $t8				# Set offset limit to 7
		
		jal PrintNewLine        				# Go to next line in output

		Loop4:
            		add $t0, $s0, $a1       				# Increment the address
			lb $a2, 0($t0)						# Stores the first char in $t0 to $a2

			# Do checks for valid character
			lb $t6, char_g						# Load character code for 'g' into $t6
			slt $t5, $a2, $t6					# Check if current char code is less than that of 'g'
			beq $t5, $zero, Invalid					# If not less than 'g' --> Invalid

			lb $t6, char_a						# Load character code for 'a' into $t6
			slt $t5, $a2, $t6					# Check if current char code is less than that of 'a'
			beq $t5, $zero, Between_a_and_f				# If not less than 'a' --> Between a & f

			lb $t6, char_G						# Load char code for 'G' into $t6
			slt $t5, $a2, $t6					# Check if current char code is less than that of 'G'
			beq $t5, $zero, Invalid					# If not less than 'G' --> Invalid

			lb $t6, char_A						# Load char code for 'A' into $t6
			slt $t5, $a2, $t6					# Check if current char code is less than that of 'A'
			beq $t5, $zero, Between_A_and_F				# If not less than 'A' --> Between A & F

			lb $t6, char_colon					# Load char code for ':' into $t6
			slt $t5, $a2, $t6					# Check if current char code is less than that of ':'
			beq $t5, $zero, Invalid					# If not less than ':' --> Invalid
			
			lb $t6, char_0						# Load char code for '0' into $t6
			slt $t5, $a2, $t6					# Check if current char code is less than than of '0'
			bne $t5, $zero, Invalid				# If less than '0' --> Invalid			

			# Else it is between 0 and 9
			lb $s2, char_0                  			# Set $s2 to char code of '0'
            		j Continue                      			# Continue


			Between_A_and_F:
				lb $s2, char_A          			# Set $s2 to char code of 'A'
                		addi $s2, $s2, -10      			# Subtract 10 from $s2 since 'A' = 10 in hex
                		j Continue              			# Continue
			
			Between_a_and_f:
				lb $s2, char_a					# Set $s2 to char code of 'a'
				addi $s2, $s2, -10				# Subtract 10 from $s2 since 'a' = 10 in hex 
				j Continue					# Continue
			
			Continue:
		 		jal AddDigit					# Call AddDigit
		 		beq $a1, $t1, PrintDec				# Exit Loop if $a0 == 7
				sll $s1, $s1, 4					# Shift $s1 left by 4
				addi $a1, $a1, 1				# Increse the offet
		 		j Loop4

		
		# Print decimal value

		PrintDec:
			li $v0, 4
			la $a0, decimal_value_msg
			syscall

			# Prints the decimal value of $s1
			sw $s1, decimal_result
			li $v0, 1
			lw $a0, decimal_result
			syscall
			j Exit

	
		# Else, if input is invalid print error_message
		Invalid:
			li $v0, 4
			la $a0, error_msg
			syscall
			j Exit

	
		# Exit the program
		Exit:
			li $v0, 10
			syscall

	AddDigit:
		# Adds the digit in $a2 to $s1
		# lb $t3, 0($t0)    		# Moved to within loop
		sub $a2, $a2, $s2
		or $s1, $s1, $a2
		# sll $s1, $s1, 4 		# Moved to within loop	
		jr $ra

	PrintNewLine:
		lb $a0, new_line_char
		li $v0, 11
		syscall
		jr $ra
