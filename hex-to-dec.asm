.data
	error_msg:	.asciiz "Invalid hexadecimal number." 
	prompt:		.asciiz "Please enter a 8-digit or smaller hexadecimal number: "
	char_a: .byte 'a'
	char_g: .byte 'g'	
	char_A: .byte 'A'
	char_G:	.byte 'G'
	char_0: .byte '0'
	char_colon: .byte ':'
	user_input: .space 9	# we need 8 bytes to read in at most 8 characters and 1 for endline character
	valid_msg:	.asciiz "The character is a valid hex"
	new_line: .asciiz "/n"
	decimal_value_msg:	.asciiz "The corresponding decimal value is: "
	decimal_result: .word 0
.text
	main:
		# Prompt the user for input
		li $v0, 4
		la $a0, prompt
		syscall

		# Get user input
		li $v0, 8		# Tells system to get user input from the keyboard as text
		la $a0, user_input
		li $a1, 9		# Tells the system the maximum number of bytes to read		
		syscall	

		# Validate user input

	
		# If input is valid, calculate corresponding decimal value

		la $s0, user_input		# Store address of input string in $s0
	    add $s1, $zero, $zero	# Initialize $s1 to zero it will be used to store the decimal result
		lb $s2, char_0			# Initialize the $s2 to the char value of '0'
		addi $a1, $zero, 0		# Initialize offset to 0
		addi $t1, $zero, 7		# Set offset limit to 7
		
		jal PrintNewLine        # Go to next line in output

		Loop:
            add $t0, $s0, $a1       	# Increment the address
			lb $a2, 0($t0)				# Stores the first char in $t0 to $a2

			# Do checks for valid character

		 	jal AddDigit				# Call AddDigit
		 	beq $a1, $t1, PrintDec		# Exit Loop if $a0 == 7
			sll $s1, $s1, 4				# Shift $s1 left by 4
			addi $a1, $a1, 1			# Increse the offet
		 	j Loop

		
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

	
		# Else, if input is invalid print error_message
			# li $v0, 4
			# la $a0, error_msg
			# syscall

	
		# Exit the program
			li $v0, 10
			syscall

	AddDigit:
		# Adds the digit in $a2 to $s1
		# lb $t3, 0($t0)
		# sub $t3, $t3, $s2
		# sub $a2, $a2, $s2
		or $s1, $s1, $a2
		# sll $s1, $s1, 4 		# Moved to within loop	
		jr $ra

	PrintNewLine:
		la $a0, new_line
		li $v0, 4
		syscall
		jr $ra
