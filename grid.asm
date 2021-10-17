#		WORD : width 0
#		WORD : height 4
#		WORD: cells 8
#		WORD: player 12
#		WORD: goalI 16
#		WORD: goalJ 20
# 		TOTAL SIZE : 24 BYTES

.include "player.asm"
.include "cell.asm"

.text

# a0 = this
# a1 = levelString
# a2 = moves
# t3 = i
grid_initialize:
	mv t0, a0
	mv t1, a1
	mv t2, a2
	
	# width = 10
	li t3, 10
	sb t3, 0(t0)
	
	# height = 7
	li t3, 7
	sb t3, 4(t0)
	
	# Allocate 70*4 = 280 bytes for this.cells
	li a7, 9
	li a0, 280
	ecall 
	sw a0, 8(t0)
	
	mv t3, zero
	grid_initialize_loop:
	# Allocates 12 bytes for cell
	li a7, 9
	li a0, 12
	ecall 
	
	# cells[i] = cell
	lw t4, 8(t0)
	li t6, 4
	mul t5, t3, t6
	add t4, t4, t5
	sw a0, 0(t4)
	
	# Setting up first cell argument
	lb t5, 0(t0)
	rem t4, t3, t5
	mv a1, t4
	addi sp, sp, -8
	sb t4, 0(sp)
	
	# Setting up second cell argument
	divu t4, t3, t5
	mv a2, t4
	sb t4, 4(sp)
	
	# Setting up third cell argument
	add t4, t1, t3
	lb t4, 0(t4)
	mv a3, t4
	
	# Setup stack to initialize cell.
	addi sp, sp, -16
	sw ra, 12(sp)
	sw t2, 8(sp)
	sw t1, 4(sp)
	sw t0, 0(sp)
	call cell_initialize
	lw t0, 0(sp)
	lw t1, 4(sp)
	lw t2, 8(sp)
	lw ra, 12(sp)
	addi, sp, sp, 16
	
	# checking if levelString[i] == 'p'
	add t4, t1, t3
	lb t4, 0(t4)
	li t5, 'p'
	bne t4, t5, grid_intialize_if1
	
	lb a1, 0(sp)
	lb a2, 4(sp)
	
	# Allocates 4 bytes for player
	li a7, 9
	li a0, 4
	ecall
	sw a0, 12(t0)
	
	# Setup stack to initialize player.
	addi sp, sp, -16
	sw ra, 12(sp)
	sw t2, 8(sp)
	sw t1, 4(sp)
	sw t0, 0(sp)
	call player_initialize
	lw t0, 0(sp)
	lw t1, 4(sp)
	lw t2, 8(sp)
	lw ra, 12(sp)
	addi, sp, sp, 16
	
	grid_intialize_if1:

	# checking if levelString[i] == 'g'
	add t4, t1, t3
	lb t4, 0(t4)
	li t5, 'g'
	bne t4, t5, grid_intialize_if2
	
	# this.goalI = this.getI(i);this.goalJ = this.getJ(i)
	lb t4, 0(sp)
	sb t4, 16(t0)
	lb t4, 4(sp)
	sb t4, 20(t0)
	
	grid_intialize_if2:
	
	addi t3, t3, 1
	add t4, t1, t3
	lb t4, 0(t4)
	bne t4, zero, grid_initialize_loop
	
	ret 
	
	
	
	
