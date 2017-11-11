.data
	error_msg: .asciiz "Invalid hexadecimal number." 
.text

	# Get user input


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
