#		WORD : width 0
#		WORD : height 4
#		WORD: cells 8
#		WORD: player 12
#		WORD: goalI 16
#		WORD: goalJ 20
#		WORD: hasWon 24
# 		TOTAL SIZE : 28 BYTES

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
	sw t3, 0(t0)
	
	# height = 7
	li t3, 7
	sw t3, 4(t0)
	
	# Allocate 70*4 = 280 bytes for this.cells
	li a7, 9
	li a0, 280
	ecall 
	sw a0, 8(t0)
	
	mv t3, zero
	grid_initialize_loop:
	# Allocates 13 bytes for cell
	li a7, 9
	li a0, 13
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
	sw t4, 0(sp)
	
	# Setting up second cell argument
	divu t4, t3, t5
	mv a2, t4
	sw t4, 4(sp)
	
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
	
	# Allocates 16 bytes for player
	li a7, 9
	li a0, 16
	ecall
	sw a0, 12(t0)
	
	# a3 = moves
	mv a3, t2
	
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
	lw t4, 0(sp)
	sw t4, 16(t0)
	lw t4, 4(sp)
	sw t4, 20(t0)
	
	grid_intialize_if2:
	
	addi sp, sp, 8
	addi t3, t3, 1
	add t4, t1, t3
	lb t4, 0(t4)
	bne t4, zero, grid_initialize_loop
	
	ret 

# a0 = this
# s1 = i
# s2 = this.cells
grid_update:
	# push ra
	addi sp, sp, -4
	sw ra, 0(sp)
	
	# Check if dead
	la t0, grid
	lw t0, 12(t0)
	lw t0, 8(t0)
	blt t0, zero, deathScreen

	# s2 = this.cells
	lw s2, 8(a0)
	
	# i = 0
	mv s1, zero
	grid_update_loop:
	# t0 = cell = this.cells[i]
	li t0, 4
	mul t0, s1, t0
	add t0, s2, t0
	lw t0, 0(t0)
	
	# if cell.hasMonster && cell.hasSpike
	lbu t1, 8(t0)
	beq t1, zero, grid_update_notKillMonster
	
	lbu t1, 6(t0)
	beq t1, zero, grid_update_notKillMonster
	
	# cell.hasMonster = false
	sb zero, 8(t0)
	# cell.isWalkable = true
	li t1, 1
	sb t1, 11(t0)
	
	# Update cell and return
	mv a0, t0
	mv a1, s0
	call cell_display
	j grid_update_continue
	
	grid_update_notKillMonster:
	
	# if cell.hasPlayer
	lbu t1, 9(t0)
	beq t1, zero, grid_update_notHasPlayer
	
	# if cell.hasKey
	lbu t1, 4(t0)
	beq t1, zero, grid_update_notHasKey
	
	# t1 = grid.player
	la t1, grid
	lw t1, 12(t1)
	# grid.player.gotKey = true
	li t2, 1
	sb t2, 12(t1)
	# cell.hasKey = false
	sb zero, 4(t0)
	
	# Erase key and return
	mv a0, t0
	mv a1, s0
	call cell_display
	j grid_update_continue
	
	grid_update_notHasKey:
	
	# if cell.hasSpike
	lbu t1, 6(t0)
	beq t1, zero, grid_update_notHasSpike
	
	# t1 = grid.player
	la t1, grid
	lw t1, 12(t1)
	# t2 = grid.player.moves-1
	lw t2, 8(t1)
	addi t2, t2, -1
	# grid.player.moves-- and return
	sw t2, 8(t1)
	j grid_update_continue
	
	grid_update_notHasSpike:
	# if cell.hasTreasure
	lbu t1, 3(t0)
	beq t1, zero, grid_update_break
	
	# cell.hasTreasure = false
	sb zero, 3(t0)
	
	# Erase treasure; continue
	mv a0, t0
	mv a1, s0
	call cell_display
	
	j grid_update_continue
	
	
	grid_update_notHasPlayer:
	
	# t1 = grid.player
	la t1, grid
	lw t1, 12(t1)
	# if grid.player.gotKey
	lbu t1, 12(t1)
	beq t1, zero, grid_update_continue
	
	# if cell.hasTreasure
	lbu t1, 3(t0)
	beq t1, zero, grid_update_continue
	
	# cell.isWalkable = true
	li t1, 1
	sb t1, 11(t0)
	
	
	grid_update_continue:
	addi, s1, s1, 1
	li t0, 70
	blt s1, t0, grid_update_loop
	
	
	grid_update_break:
	
	# t0 = this.player
	la t0, grid
	lw t0, 12(t0)
	
	# t1 = this.player.movers
	lw t1, 8(t0)
	blt t1, zero, grid_update_killPlayer
	
	# t1 = this.player.i
	lw t1, 0(t0)
	# t2 = this.goalI
	la t3, grid
	lw t2, 16(t3)
	# t1 = abs(this.player.i-this.goalI)
	sub a0, t1, t2
	call abs
	mv t1, a0
	
	# t2 = this.player.i
	lw t2, 4(t0)
	# t3 = goalJ
	lw t3, 20(t3)
	sub a0, t2, t3
	mv t6, t1
	call abs
	mv t1, t6
	add t1, t1, a0
	addi t1, t1, -1
	
	# if abs(this.player.i - this.goalI) + abs(this.player.j - this.goalJ) == 1
	bne t1, zero, grid_update_printMoves
	
	# t3 = this
	la t3, grid
	# this.hasWon = true
	li t1, 1
	sw t1, 24(t3)
	
	# Go to dialogue
	j dialogueScreen
	
	j grid_update_printMoves
	
	
	grid_update_killPlayer:
	
	grid_update_printMoves:
	# Print "MOVES:"
	.data 
	movesString: .string "MOVES:"
	.text
	la a0, movesString
	li a1, 5
	mv a4, s0
	li a3, 0x00FF
	li a2, 220
	li a7, 104
	ecall
	
	
	li a1, 57
	# Check if moves < 10
	la a0, grid
	lw a0, 12(a0)
	lw a0, 8(a0)
	
	li t0, 10
	bge a0, t0, not_pad_zero
	
	# Print 0
	mv t0, a0
	mv a0, zero
	li a1, 57
	li a2, 220
	li a3, 0x00FF
	mv a4, s0
	li a7, 101
	ecall
	mv a0, t0
	
	li a1, 65
	not_pad_zero:
	# Print moves
	li a2, 220
	li a3, 0x00FF
	mv a4, s0
	li a7, 101
	ecall
	
	la a0, moveSound
	li a1, 120
	call playSong
	
	
	# pop ra and return
	lw ra, 0(sp)
	addi, sp, sp, 4
	ret

	
	
	
