		addi $1, $1, 1			
		addi $2, $2, 2		#counter 1
		addi $3, $3, 2		#counter 2
		addi $4, $4, 2		#counter 3	
		addi $5, $5, 2		#counter 4
		
one: 	sub $2, $2, $1  	#decrement counter
		add $6, $6, $1		#random instruction
		add $7, $7, $1		#random instruction
		bne $2, $0, one
		
two: 	sub $3, $3, $1		#decrement counter
		add $6, $6, $1		#random instruction
		add $7, $7, $1		#random instruction
		bne $3, $0, two
		
three: 	sub $4, $4, $1		#decrement counter
		add $6, $6, $1		#random instruction
		add $7, $7, $1		#random instruction
		bne $4, $0, three	
		
four: 	sub $5, $5, $1		#decrement counter
		add $6, $6, $1		#random instruction
		add $7, $7, $1		#random instruction
		bne $5, $0, four
		
		add $8, $8, $1		#end