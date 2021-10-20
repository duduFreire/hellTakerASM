.include "usefulMacros"
.include "MACROSv21.s"

.text
j main

.data
grid: .word 0,0,0,0,0,0
currentLevel: .byte 0
playingGame: .byte 0

.include "resources/introScreen.s"
.include "levels.asm"
.include "SYSTEMv21.s"
.include "grid.asm"
.text
.include "screenFunctions"



# Draws an image with base address a0, fills the entire screen.
drawFullImage:
	li t0, 0xFF000000
	li t1, 0xFF012C00
	mv t2, zero
	addi a0, a0, 8
	
	drawFullImage$Loop:
		beq t0, t1, drawFullImage$break
		add t3, t2, a0
		lb t3, 0(t3)
		sb t3, 0(t0)
		
		addi t2, t2, 1
		addi t0, t0, 1
		j drawFullImage$Loop
	
	drawFullImage$break:
	jr ra

# Paints screen with black.	
clearScreen:
	li t0, 0xFF000000 
	li t1, 0xFF012C00
	
	clearScreen_loop:
	sw zero, 0(t0)
	addi t0, t0, 4 
	
	blt t0, t1, clearScreen_loop
	
	
	ret

	
# Draws image with base address a0, at (a1, a2) in frame a3.
# t0 = base adress
# t1 = image adress
# t2 = line counter
# t3 = column counter
# t4 = width
# t5 = height
drawImage:
	li t0, 0xFF0
	add t0, t0, a3 
	slli t0, t0, 20
	add t0, t0, a1
	
	li t1, 320
	mul t1, t1, a2 
	add t0, t0, t1
	
	addi t1, a0, 8
	
	mv t2, zero
	mv t3, zero 
	
	lw t4, 0(a0)
	lw t5, 4(a0)
	
drawImage_linha:
	lw t6, 0(t1)
	sw t6, 0(t0)
	
	addi t0, t0, 4
	addi t1, t1, 4
	addi t3, t3, 4
	
	blt t3, t4, drawImage_linha
	
	addi t0, t0, 320
	sub t0, t0, t4
	
	mv t3, zero
	addi t2, t2, 1
	blt t2, t5, drawImage_linha
	
	jr ra

# Display all cells at frame a0.
# a0 = frame
# t0 = baseAddress
# t1 = finalAddress
displayCells:
	# Save ra and a0 at stack.
	addi sp, sp, -16
	sw ra, 0(sp)
	sw a0, 4(sp)

	# t0 = grid.cells
	la t0, grid
	lw t0, 8(t0)
	
	# t1 = grid.cells + 70 * 4
	addi t1, t0, 280
	displayCells_loop:
	# a0 = grid.cells[i]
	lw a0, 0(t0)
	# a1 = frame
	lw a1, 4(sp)
	
	# Saving t0 and t1 in the stack
	sw t0, 8(sp)
	sw t1, 12(sp)
	
	# cell.display(frame)
	call cell_display
	
	# Restore t0 and t1
	lw t0, 8(sp)
	lw t1, 12(sp)

	# Increment t0 and exit or continue loop.
	addi t0, t0, 4
	blt t0, t1, displayCells_loop
	
	# Recover ra and sp and return.
	lw ra, 0(sp)
	addi sp, sp, 16
	ret


handleInput:
	# push ra
	addi sp, sp, -4
	sw ra, 0(sp)
	
	li t1, 0xFF200000	# carrega o endereço de controle do KDMMIO
	lw t0, 0(t1)			    # Le bit de Controle Teclado
	andi t0, t0,0x0001		# mascara o bit menos significativo
   	beq t0, zero,handleInput_ret   	   	# Se não há tecla pressionada então vai para FIM
  	lw t2, 4(t1)  			# le o valor da tecla tecla
	
	# If esc is pressed exit program
	li t0, 27
	beq t2, t0, mainExit
	
	# a0 = this
	la a0, grid
	lw a0, 12(a0)
	# a1 = key
	mv a1, t2
	
	call player_move
	
	
	handleInput_ret:
	# pop ra
	lw ra, 0(sp)
	addi sp, sp, 4
	
	ret

# s0 = frame
main:
	# frame = 1
	li s0, 1
	
	# Initialize grid with level 1 and 23 moves.
	la a0, grid 
	la a1, levels
	la a2, movesLabel
	lb a2, 0(a2)
	call grid_initialize
	
	# Display cells at frames 0 and 1.
	#li a0, 0
	#call displayCells
	li a0, 1
	call displayCells
	
	mainLoop:
	
	call handleInput
	
	# Show frame
	li t0,0xFF200604
	sw s0, 0(t0)
	
	# Alternate frame
	#xori s0, s0, 1
	
	j mainLoop
	
	
	
	mainExit:
	exitProg