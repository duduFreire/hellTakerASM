.include "usefulMacros"

.text
j main

.data
grid: .word 0,0,0,0,0,0

.include "resources/introScreen.s"
.include "resources/heroAnimation.s"
.include "levels.asm"
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


handleInput:

main:
	la a0, introScreen
	#jal drawFullImage
	
	# Espera o usuário clicar uma tecla pra iniciar o  jogo.
	j start
	introScreenLoop:
	li t1,0xFF200000
	lw t0,0(t1)	
	andi t0,t0,0x0001		
   	beq t0,zero,introScreenLoop
	j start
	
	start:
	#call clearScreen
	
	# Initialize grid with level 1 and 23 moves.
	la a0, grid 
	la t0, levels
	addi t0, t0, 4
	mv a1, t0
	li a2, 23
	call grid_initialize
	
	# Display all cells.
	# t0 = baseAddress
	# t1 = finalAddress
	la t0, grid
	lw t0, 8(t0)
	
	addi t1, t0, 280
	displayCells_loop:
	addi sp, sp, -8
	sw t0, 0(sp)
	sw t1, 4(sp)
	
	lw a0, 0(t0)
	call cell_display
	
	lw t0, 0(sp)
	lw t1, 4(sp)
	addi sp, sp, 8
	
	addi t0, t0, 4
	blt t0, t1, displayCells_loop
	
	
	
	
	
	
	
	exitProg
