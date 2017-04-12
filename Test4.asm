		addi $1, $1, 1
		addi $2, $2, 2		#first counter
		addi $3, $3, 10		#second counter

loop1:	sub  $2, $2, $1		#decrement first counter
		add  $0, $0, $0		#random instruction
		add  $0, $0, $0		#random instruction
		bne  $2, $0, loop1
		
		sub $3, $3, $1		#decrement second counter
		addi $2, $2, 2		#reset first counter
		add  $0, $0, $0		#random instruction
		add  $0, $0, $0		#random instruction
		bne $3, $0, loop1
		
		addi $4, $4, 4		#end
