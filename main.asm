.include "usefulMacros"
.include "MACROSv21.s"

.text
j mainMenu

.data
grid: .word 0,0,0,0,0,0,0
currentLevel: .byte 0

.include "resources/introScreen.s"
.include "levels.asm"
.include "SYSTEMv21.s"
.include "grid.asm"
.include "mathFunctions"
.text
.include "screenFunctions"



# Draws an image with base address a0, fills the entire screen.
drawFullImage:
	li t0, 0xFF000000
	li t1, 0xFF012C00
	mv t2, zero
	addi a0, a0, 8
	
	drawFullImage_Loop:
		beq t0, t1, drawFullImage_break
		add t3, t2, a0
		lw t3, 0(t3)
		sw t3, 0(t0)
		
		addi t2, t2, 4
		addi t0, t0, 4
		j drawFullImage_Loop
	
	drawFullImage_break:
	ret

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
	
	li t1, 0xFF200000	          # carrega o endereço de controle do KDMMIO
	lw t0, 0(t1)			      # Le bit de Controle Teclado
	andi t0, t0,0x0001		      # mascara o bit menos significativo
   	beq t0, zero,handleInput_ret  # Se não há tecla pressionada então vai para FIM
  	lw t2, 4(t1)  			      # le o valor da tecla tecla
	
	# If esc is pressed exit program
	li t0, 27
	beq t2, t0, mainExit
	
	# if 'o' is pressed go to next level
	li t0, 'o'
	bne t2, t0,handleInput_notO
	j dialogueSuccess
	
	handleInput_notO:
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
	
dialogueScreen:
	# Set a0 to correct image and draw image
	la a0, dialogueImages
	li t0, 76808
	lbu t1, currentLevel
	mul t0, t0, t1
	add a0, a0, t0
	call drawFullImage
	
	la a0, winSound
	li a1, 121
	call playSong
	
	dialogueScreen_loop:
	
	li t1, 0xFF200000	               # carrega o endereço de controle do KDMMIO
	lw t0, 0(t1)			           # Le bit de Controle Teclado
	andi t0, t0,0x0001		           # mascara o bit menos significativo
   	beq t0, zero, dialogueScreen_loop  # Se não há tecla pressionada então vai para
  	lw t2, 4(t1)  			           # le o valor da tecla tecla
  	
  	# if key == '1'
  	li t1, '1'
  	beq t1, t2, dialogueScreen_isKey
  	
  	# if key == '2'
  	li t1, '2'
  	bne t1, t2, dialogueScreen_loop
  	
  	dialogueScreen_isKey:
  	# t0 = correct key
  	la t0,correctKeys
  	lbu t1, currentLevel
  	add t0, t0, t1
  	lbu t0, 0(t0)
  	
  	# if key is correct go to success screen
  	beq t0, t2, dialogueSuccess
  	# if key is incorrect die
  	j deathScreen
  	
	
	
	j dialogueScreen_loop
	
victoryRoutine:	
	la a0, victoryScreen
	call drawFullImage
	
	la a0, winSong
	li a1, 81
	call playSong
	
	dialogueSuccess_victoryLoop:
	
	li t1, 0xFF200000	                       # carrega o endereço de controle do KDMMIO
	lw t0, 0(t1)			                   # Le bit de Controle Teclado
	andi t0, t0,0x0001		           		   # mascara o bit menos significativo
   	beq t0, zero, dialogueSuccess_victoryLoop  # Se não há tecla pressionada então vai para
  	lw t2, 4(t1)  			           		   # le o valor da tecla tecla
  	
  	li t0, '2'
  	beq t2, t0, mainExit
  	li t0, '1'
  	beq t2, t0, mainMenu
	
	j dialogueSuccess_victoryLoop
	

mainMenu:
	la a0, mainMenuImage
	call drawFullImage
	
	# play menu song
	la a0, menuSong
	li a1, 24
	call playSong
	
	mainMenu_loop:
	li t1, 0xFF200000	                       # carrega o endereço de controle do KDMMIO
	lw t0, 0(t1)			                   # Le bit de Controle Teclado
	andi t0, t0,0x0001		           		   # mascara o bit menos significativo
   	beq t0, zero, mainMenu_loop  			   # Se não há tecla pressionada então vai para
  	lw t2, 4(t1)  			           		   # le o valor da tecla tecla
  	
  	
	li t0, '1'
	bne t2, t0, mainMenu_not1
	
	la t0, currentLevel
	sb zero, 0(t0)
	j main
	
	
	mainMenu_not1:
	li t0, '2'
	beq t2, t0, chapterSelect
	
	j mainMenu_loop 
	
chapterSelect:
	la a0, chapterSelectImage
	call drawFullImage
	
	chapterSelect_loop:
	li t1, 0xFF200000	                       # carrega o endereço de controle do KDMMIO
	lw t0, 0(t1)			                   # Le bit de Controle Teclado
	andi t0, t0,0x0001		           		   # mascara o bit menos significativo
   	beq t0, zero, chapterSelect_loop  			   # Se não há tecla pressionada então vai para
  	lw t2, 4(t1)  			           		   # le o valor da tecla tecla
  	
  	li t0, '1'
  	bne t2, t0, chapterSelect_not1
  	
  	li t0, 0
  	la t2, currentLevel
  	sb t0, 0(t2)
  	j main
  	
  	chapterSelect_not1:
  	li t0, '2'
  	bne t2, t0, chapterSelect_not2
  	
  	li t0, 1
  	la t2, currentLevel
  	sb t0, 0(t2)
  	j main
  	
  	chapterSelect_not2:
  	li t0, '3'
  	bne t2, t0, chapterSelect_not3
  	
  	li t0, 2
  	la t2, currentLevel
  	sb t0, 0(t2)
  	j main
  	
  	chapterSelect_not3:
  	li t0, '4'
  	bne t2, t0, chapterSelect_not4
  	
  	li t0, 3
  	la t2, currentLevel
  	sb t0, 0(t2)
  	j main
  	
  	chapterSelect_not4:
  	li t0, '5'
  	bne t2, t0, chapterSelect_loop
  	
  	li t0, 4
  	la t2, currentLevel
  	sb t0, 0(t2)
  	j main
  	

	
dialogueSuccess:
	# check if game is finished.
	lbu t0, currentLevel
	li t1, 4
	beq t0, t1, victoryRoutine
	
	# Set a0 to correct image and draw image
	la a0, successImages
	li t0, 76808
	lbu t1, currentLevel
	mul t0, t0, t1
	add a0, a0, t0
	call drawFullImage
	
	dialogueSuccess_loop:
	
	li t1, 0xFF200000	               # carrega o endereço de controle do KDMMIO
	lw t0, 0(t1)			           # Le bit de Controle Teclado
	andi t0, t0,0x0001		           # mascara o bit menos significativo
   	beq t0, zero, dialogueSuccess_loop  # Se não há tecla pressionada então loopa
   	
   	# currentLevel++
   	lbu t0, currentLevel
   	addi t0, t0, 1
   	la t1, currentLevel
   	sb t0, 0(t1)
   	
   	call clearScreen
   	
   	j main
	

deathScreen:
	la a0, badEndImage
	call drawFullImage
	
	
	# Play death sound
	la a0, deathSound
	li a1, 68
	call playSong
	
	deathScreen_loop:
	
	li t1, 0xFF200000	               # carrega o endereço de controle do KDMMIO
	lw t0, 0(t1)			           # Le bit de Controle Teclado
	andi t0, t0,0x0001		           # mascara o bit menos significativo
   	beq t0, zero, deathScreen_loop  # Se não há tecla pressionada então loopa
   	
	call clearScreen
	
	j main

# a0 = song array
# a1 = instrument
playSong:
	addi sp, sp, -4
	sw ra, 0(sp)

	# t0 = i = 0
	mv t0, zero
	
	# t2 = length*8
	mv t2, a0
	lw t2, 0(a0)
	li t1, 8
	mul t2, t2, t1
	
	# t3 = instrument
	mv t3, a1
	
	# t4 = song array notes
	mv t4, a0
	addi t4, t4, 4
	
	playSong_loop:
	# t5 = pitch address
	# t6 = pitch
	add t5, t4, t0
	lw t6, 0(t5)
	
	# a0 = pitch
	mv a0, t6
	# a1 = duration
	lw t6, 4(t5)
	mv a1, t6
	# a2 = instrument
	mv a2, t3
	# a3 = volume = 127
	li a3, 127
	
	# play sound
	li a7, 31
	ecall
	
	# wait for note to play
	mv a0, a1
	li a7, 32
	ecall
	
	addi t0, t0, 8
	
	beq t0, t2, playSong_end
	
	# if key is pressed return
	li t6, 0xFF200000	                       # carrega o endereço de controle do KDMMIO
	lw t5, 0(t6)			                   # Le bit de Controle Teclado
	andi t5, t5,0x0001		           		   # mascara o bit menos significativo
   	bne t5, zero, playSong_end  			   # Se não há tecla pressionada então retorna
	
	j playSong_loop
	
	playSong_end:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	

  	

# s0 = frame
main:
	# frame = 0
	mv s0, zero
	
	call clearScreen
	
  	# Initialize grid with currentLevel.
	la a0, grid 
	la a1, levels
	li t0, 71
	lbu t1, currentLevel
	mul t0, t0, t1
	add a1, a1, t0
	la a2, movesLabel
	add a2, a2, t1
	lbu a2, 0(a2)
	call grid_initialize
	
	
	# Display cells at frame 0.
	li a0, 0
	call displayCells
	
	li t0,0xFF200604
	sw s0, 0(t0)
	mainLoop:
	
	call handleInput
	
	j mainLoop
	
	
	
	mainExit:
	exitProg
