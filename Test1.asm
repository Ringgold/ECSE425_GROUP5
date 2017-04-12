	addi $1, $1, 20			#loop counter
	addi $2, $2, 1			


start:	sub  $1, $1, $2   #decrease loop counter
		sw   $1, 0($1)		#store counter in memory
		addi $3, $3, 1		#random instruction
		addi $4, $4, 1		#random instruction
		addi $5, $5, 1  	#random instruction
		bne  $1, $0, start
		
		addi $6, $6, 1		#random instruction
		addi $7, $7, 1		#random instruction
		
end:    addi  $8, $8, 20		#end of program
		addi  $9, $9, 20		#end of program
