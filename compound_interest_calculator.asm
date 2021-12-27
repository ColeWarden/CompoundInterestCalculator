# ############################################################### #
# Compund Interest Calculator                                     #
# Cole Warden                                                     #
# ############################################################### #   
 
.data

NEW_LINE:			.asciiz "\n"
MSG_LEAVING_PROGRAM:.asciiz "Leaving Program..."

ERR_INTEREST:		.asciiz "Invalid interest rate (0.0 to 1.0): "

MSG_PRINCIPAL: 		.asciiz "Enter the principal amount: "
MSG_INTEREST:		.asciiz "Enter interest rate: "
MSG_TARGET_BALANCE: .asciiz "Enter target balance: "
MSG_YEARS:	     	.asciiz "Enter number of last years you would like to see (-1 = all years): "

ANNUAL_INTEREST_MAX_VALUE: .float 1.0

ZERO_FLOAT:			.float 0.0
CURRENT_PRINCIPAL:	.asciiz ": Balance = $"
CURRENT_YEAR:		.asciiz "Year "

MSG_TOTAL_PRE:		.asciiz "It will take "
MSG_TOTAL_POST:		.asciiz " years."

.text
.globl main

main:
		# $f0 - utility/input from user
		# $f1 - calculation float(used in calculate_loan)
		# $f2 - principal
		# $f3 - interest rate
		# $f4 - target balance
		
		# $s0 - counter
		# $s1 - years inputted to see
		# $s2 - total years
		
		jal get_principal
		jal get_interest
		jal get_target_balance
		jal get_years
		
		li $s0, 0
		jal recursive_loop
		
		jr $31
		

# $f0 is float inputted
# $f12 is the print float register
#bc1t = If true
#bc1f = If false

get_principal:	
        li  $v0, 4               # Print MSG_PRINCIPAL
		la  $a0, MSG_PRINCIPAL     
        syscall
		li  $v0, 6       		 # Get float (into $f2)
		syscall
		mov.s $f2, $f0			 # Save float to f2 register
		
		jr $ra

get_interest:
        li  $v0, 4               # Print MSG_INTEREST
		la  $a0, MSG_INTEREST    
        syscall
		li  $v0, 6       		 # Get float (into $f3)
		syscall
		mov.s $f3, $f0			 # Save float to f3 register
		
		lwc1 $f0, ZERO_FLOAT				# If input < 0.0:
		c.lt.s $f3, $f0		# Compare
		bc1t error_interest
		
		lwc1 $f0, ANNUAL_INTEREST_MAX_VALUE	# If input > ANNUAL_INTEREST_MAX_VALUE:
		c.lt.s $f0, $f3		# Compare
		bc1t error_interest
		
		jr $ra

error_interest:
		li  $v0, 4               # Print Error
		la  $a0, ERR_INTEREST 
		syscall
		li  $v0, 4               # New line
		la  $a0, NEW_LINE
		syscall
		
		j get_interest
		
get_target_balance:	
        li  $v0, 4               # Print MSG_TARGET_BALANCE
		la  $a0, MSG_TARGET_BALANCE    
        syscall
		li  $v0, 6       		 # Get float (into $f4)
		syscall
		mov.s $f4, $f0			 # Save float to f4 register
		
		jr $ra

get_years:	
        li  $v0, 4               # Print MSG_YEARS
		la  $a0, MSG_YEARS    
        syscall
		li  $v0, 5       		 # Get int (into $v0)
		syscall
		move $s1, $v0			 # Save int to s1 register
		
		li $s2, -1
		bge $s2, $s1, error_years	# If input < 0:
		
		add $s1, $s1, 1
		
		jr $ra

error_years:
		li $s2, 1000000000
		move $s1, $s2
		jr $ra


recursive_loop:
		add $s0, $s0, 1
		
		mov.s $f0, $f2	
		mul.s $f2, $f2, $f3		# F1 calucltion register = (principal * interest)
		add.s $f2, $f0, $f2		# F1 += principal
		
		subu $sp, $sp, 12
		
		sw $ra, 0($sp)			# Return address
		swc1 $f2, 4($sp)		# Principal
		sw $s0, 8($sp)			# Year Count
		
		c.nge.s $f2, $f4
		bc1f skip
		
		jal	recursive_loop
		
		lw $s0, 8($sp)			# Year Count	
		lwc1 $f2, 4($sp)		# Principal
		lw $ra, 0($sp)			# Return address
		
		addu $sp, $sp, 12
		
		li $s3, 1				# Subtract 1 from years to see
		sub $s1, $s1, $s3
		
		li $s3, 0
		bgt $s1, 0, print_years	# If greater than 0, show years
		
		jr $ra


skip:
		move $s2, $s0
		jr $ra


print_years:
		li  $v0, 4               # New line
		la  $a0, NEW_LINE        
		syscall
		
		li  $v0, 4               # Current year
		la  $a0, CURRENT_YEAR        
		syscall

		move $a0, $s0			# Year amount
		li $v0, 1				
		syscall
		
		li  $v0, 4               # New line
		la  $a0, CURRENT_PRINCIPAL        
		syscall
		
		mov.s $f12, $f2			# Print remaining amount
		li $v0, 2				
		syscall
		
		move $a0, $s1			# Year amount
		li $v0, 1				
		syscall
		
		jr $ra

exit_program:
		li  $v0, 4               # New line
		la  $a0, NEW_LINE
		syscall
		
		li  $v0, 4              # MSG_TOTAL_PRE
		la  $a0, MSG_TOTAL_PRE        
		syscall
			
		move $a0, $s2			# Total Years
		li $v0, 1				
		syscall
		
		li  $v0, 4              # MSG_TOTAL_POST
		la  $a0, MSG_TOTAL_POST       
		syscall
		
		li  $v0, 4              # New line
		la  $a0, NEW_LINE        
		syscall
		
		li  $v0, 4              # Print Leaving Program msg
		la  $a0, MSG_LEAVING_PROGRAM       
		syscall
		
        jr $31
