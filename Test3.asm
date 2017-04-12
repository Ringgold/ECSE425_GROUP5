# at first everything is 0	
		addi $1, $1, 20			#loop counter
		addi $2, $2, 1
		addi $10, $10, 2		#second loop counter


start:	sub  $1, $1, $2   		#decrease loop counter
		sw   $1, 0($1)			#store counter in memory
		addi $3, $3, 1			#random instruction
		addi $4, $4, 1			#random instruction
		addi $5, $5, 1  		#random instruction
		bne  $1, $0, start
		addi $6, $6, 1			#random instruction
		addi $7, $7, 1			#random instruction
		
end:    sub   $10, $10, $2		#decrease second loop counter
		addi  $8, $8, 20		#random instruction
		addi  $9, $9, 20		#random instruction
		addi  $1, $1, 10		#set counter to 10
		bne   $10, $0, start	#go back to start loop for 10 iterations
		
		addi $11, $11, 1		#end
		
		
		
		
		
		