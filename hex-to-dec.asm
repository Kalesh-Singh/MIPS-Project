.data
	error_msg:	.asciiz "Invalid hexadecimal number." 
	input_str:	.space 8 	# we need 8 bytes to read in at most 8 ascii characters
	prompt:		.asciiz "Please enter a 8-digit or smaller hexadecimal number: "
.text
	main:

	# Get user input
		li $v0, 8		# Tells system to get user input from the keyboard as text
		la $a0, input_str
		li $a1, 8		# Tells the system the maximum number of bytes to read		
	

	# Validate user input

	
	# If input is valid, calculate corresponding decimal value


	# Print decimal value	

	
	# Else, if input is invalid print error_message
		li $v0, 4
		la $a0, error_msg
		syscall

	
	# Exit the program
		li $v0, 10
		syscall
