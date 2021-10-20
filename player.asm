#		WORD : i 0
#		WORD : j 4
#		WORD: moves 8
#		WORD: gotKey 12
# 		TOTAL SIZE : 16 BYTES

.data
.include "resources/heroImage.s"

.text

# a0 = this
# a1 = i
# a2 = j
# a3 = moves
player_initialize:
	# this.i = i
	sw a1, 0(a0)
	# this.j = j
	sw a2, 4(a0)
	# this.moves = moves
	sw a3, 8(a0)
	# gotKey = false
	sw zero, 12(a0)
	
	ret

# a0 = this 
# a1 = key
player_move:
	# setup stack
	addi sp, sp, -12
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw a1, 8(sp)

	# if key == 'w'
	li t0, 'w'
	bne a1, t0, player_move_notW
	
	# t0 = newJ = this.j-1
	lw t0, 4(a0)
	addi t0, t0, -1
	
	# if newJ >= 0
	blt t0, zero, player_move_ret
	
	# t1 = grid.cells
	la t1, grid
	lw t1, 8(t1)
	# t2 = 10 * newJ
	li t2, 10
	mul t2, t2, t0 
	# t3 = 4 * (this.i + 10 * newJ)
	lw t3, 0(a0)
	add t3, t3, t2
	li t2, 4 
	mul t3, t3, t2
	
	# t1 = newCell = cells[i][newJ]
	add t1, t1, t3
	lw t1, 0(t1)
	
	# if newCell.isWalkable
	lbu t2, 11(t1)
	beq t2, zero, player_move_ifw1
	
	# newCell.hasPlayer = true
	li t4, 1
	sb t4, 9(t1)
	
	# t4 = grid.cells[i][j]
	addi t3, t3, 40
	la t4, grid
	lw t4, 8(t4)
	add t4, t4, t3
	lw t4, 0(t4)
	# grid.cells[i][j].hasPlayer = false
	sb zero, 9(t4)
	# j = newJ
	lw t3, 4(sp)
	sw t0, 4(t3)
	
	# push grid.cells[i][j]
	addi, sp, sp, -4 
	sw t4, 0(sp)
	
	# Display new cell.
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop grid.cells[i][j]
	lw t4, 0(sp)
	addi, sp, sp, 4
	
	# Erase old cell.
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw a0, 4(sp)
	lw t2, 8(a0)
	addi t2, t2, -1
	sw t2, 8(a0)
	
	j player_move_callUpdateGrid
	
	
	player_move_ifw1:
	
	# if newCell.hasMonster or newCell.hasBlock
	lbu t2, 8(t1)
	bne t2, zero, player_move_if_monsterOrBlock
	
	lbu t2, 5(t1)
	beq t2, zero, player_move_ret
	
	player_move_if_monsterOrBlock:
	# t2 = newJ - 1
	addi t2, t0, -1
	# if newJ-1 >= 0
	blt t2, zero, player_move_ret
	
	# t3 = 10*(newJ-1)
	li t3, 10
	mul t3, t3, t2 
	# t4 = newI = i
	lw t4, 4(sp)
	lw t4, 0(t4)
	# t3 = newI + 10*(newJ-1)
	add t3, t3, t4 
	li t4, 4
	# t3 = 4 * (newI + 10*(newJ-1))
	mul t3, t3, t4
	
	# t4 = grid.cells[newI][newJ-1]
	la t4, grid 
	lw t4, 8(t4)
	add t4, t4, t3 
	lw t4, 0(t4)
	
	# if grid.cells[newI][newJ-1].isWalkable
	lbu t3, 11(t4)
	beq t3, zero, player_move_ifw3
	
	# if newCell.hasMonster
	lbu t3, 8(t1)
	beq t3, zero, player_move_block
	
	li t0, 1
	
	# grid.cells[oldI][oldJ].hasMonster = false
	sb zero, 8(t1)
	# grid.cells[oldI][oldJ].isWalkable = true
	sb t0, 11(t1)
	
	# push t4
	addi sp, sp, -4
	sw t4, 0(sp)
	
	# Erase old monster
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop t4
	lw t4, 0(sp)
	addi sp, sp, 4
	
	li t0, 4
	# grid.cells[newI][newJ-1].hasMonster = true
	sb t0, 8(t4)
	# grid.cells[newI][newJ-1].isWalkable = false
	sb zero, 11(t4)
	
	# Draw new monster
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_ifw3:
	# if newCell.hasMonster
	lbu t3, 8(t1)
	beq t3, zero, player_move_ret
	
	# newCell.hasMonster = false
	sb zero, 8(t1)
	# newCell.isWalkable = true
	li t0, 1
	sb t0, 11(t1)
	
	# Erase monster.
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_block:
	
	li t0, 1
	
	# grid.cells[oldI][oldJ].hasBlock = false
	sb zero, 5(t1)
	# grid.cells[oldI][oldJ].isWalkable = true
	sb t0, 11(t1)
	
	# push t4
	addi sp, sp, -4
	sw t4, 0(sp)
	
	# Erase old block
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop t4
	lw t4, 0(sp)
	addi sp, sp, 4
	
	li t0, 4
	# grid.cells[newI][newJ-1].hasBlock = true
	sb t0, 5(t4)
	# grid.cells[newI][newJ-1].isWalkable = false
	sb zero, 11(t4)
	
	# Draw new block
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_notW:
	# if key == 's'
	li t0, 's'
	bne a1, t0, player_move_notS
	
	# t0 = newJ = this.j+1
	lw t0, 4(a0)
	addi t0, t0, 1
	
	# if newJ < 7
	li t1, 7
	bge t0, t1, player_move_ret
	
	# t1 = grid.cells
	la t1, grid
	lw t1, 8(t1)
	# t2 = 10 * newJ
	li t2, 10
	mul t2, t2, t0 
	# t3 = 4 * (this.i + 10 * newJ)
	lw t3, 0(a0)
	add t3, t3, t2
	li t2, 4 
	mul t3, t3, t2
	
	# t1 = newCell = cells[i][newJ]
	add t1, t1, t3
	lw t1, 0(t1)
	
	# if newCell.isWalkable
	lbu t2, 11(t1)
	beq t2, zero, player_move_ifs1
	
	# newCell.hasPlayer = true
	li t4, 1
	sb t4, 9(t1)
	
	# t4 = grid.cells[i][j]
	addi t3, t3, -40
	la t4, grid
	lw t4, 8(t4)
	add t4, t4, t3
	lw t4, 0(t4)
	# grid.cells[i][j].hasPlayer = false
	sb zero, 9(t4)
	# j = newJ
	lw t3, 4(sp)
	sw t0, 4(t3)
	
	# push grid.cells[i][j]
	addi, sp, sp, -4 
	sw t4, 0(sp)
	
	# Display new cell.
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop grid.cells[i][j]
	lw t4, 0(sp)
	addi, sp, sp, 4
	
	# Erase old cell.
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw a0, 4(sp)
	lw t2, 8(a0)
	addi t2, t2, -1
	sw t2, 8(a0)
	
	j player_move_callUpdateGrid
	
	
	player_move_ifs1:
	
	# if newCell.hasMonster or newCell.hasBlock
	lbu t2, 8(t1)
	bne t2, zero, player_move_ifS_monsterOrBlock
	
	lbu t2, 5(t1)
	beq t2, zero, player_move_ret
	
	player_move_ifS_monsterOrBlock:
	# t2 = newJ + 1
	addi t2, t0, 1
	# if newJ+1 < 7
	li t5, 7
	bge t2, t5, player_move_ifS3
	
	# t3 = 10*(newJ+1)
	li t3, 10
	mul t3, t3, t2 
	# t4 = newI = i
	lw t4, 4(sp)
	lw t4, 0(t4)
	# t3 = newI + 10*(newJ+1)
	add t3, t3, t4 
	li t4, 4
	# t3 = 4 * (newI + 10*(newJ+1))
	mul t3, t3, t4
	
	# t4 = grid.cells[newI][newJ+1]
	la t4, grid 
	lw t4, 8(t4)
	add t4, t4, t3 
	lw t4, 0(t4)
	
	# if grid.cells[newI][newJ+1].isWalkable
	lbu t3, 11(t4)
	beq t3, zero, player_move_ifS3
	
	# if newCell.hasMonster
	lbu t3, 8(t1)
	beq t3, zero, player_move_ifS_block
	
	li t0, 1
	
	# grid.cells[oldI][oldJ].hasMonster = false
	sb zero, 8(t1)
	# grid.cells[oldI][oldJ].isWalkable = true
	sb t0, 11(t1)
	
	# push t4
	addi sp, sp, -4
	sw t4, 0(sp)
	
	# Erase old monster
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop t4
	lw t4, 0(sp)
	addi sp, sp, 4
	
	li t0, 4
	# grid.cells[newI][newJ+1].hasMonster = true
	sb t0, 8(t4)
	# grid.cells[newI][newJ+1].isWalkable = false
	sb zero, 11(t4)
	
	# Draw new monster
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_ifS3:
	# if newCell.hasMonster
	lbu t3, 8(t1)
	beq t3, zero, player_move_ret
	
	# newCell.hasMonster = false
	sb zero, 8(t1)
	# newCell.isWalkable = true
	li t0, 1
	sb t0, 11(t1)
	
	# Erase monster.
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_ifS_block:
	
	li t0, 1
	
	# grid.cells[oldI][oldJ].hasBlock = false
	sb zero, 5(t1)
	# grid.cells[oldI][oldJ].isWalkable = true
	sb t0, 11(t1)
	
	# push t4
	addi sp, sp, -4
	sw t4, 0(sp)
	
	# Erase old block
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop t4
	lw t4, 0(sp)
	addi sp, sp, 4
	
	li t0, 4
	# grid.cells[newI][newJ+1].hasBlock = true
	sb t0, 5(t4)
	# grid.cells[newI][newJ+1].isWalkable = false
	sb zero, 11(t4)
	
	# Draw new block
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_notS:
	
	# if key == 'd'
	li t0, 'd'
	bne a1, t0, player_move_notD
	
	# t0 = newI = this.i+1
	lw t0, 0(a0)
	addi t0, t0, 1
	
	# if newI < 10
	li t1, 10
	bge t0, t1, player_move_ret
	
	# t1 = grid.cells
	la t1, grid
	lw t1, 8(t1)
	# t2 = 10 * this.j
	li t2, 10
	lw t3, 4(a0)
	mul t2, t2, t3 
	# t3 = 4 * (newI + 10 * this.j)
	add t3, t0, t2
	li t2, 4 
	mul t3, t3, t2
	
	# t1 = newCell = cells[newI][this.j]
	add t1, t1, t3
	lw t1, 0(t1)
	
	# if newCell.isWalkable
	lbu t2, 11(t1)
	beq t2, zero, player_move_ifD1
	
	# newCell.hasPlayer = true
	li t4, 1
	sb t4, 9(t1)
	
	# t4 = grid.cells[i][j]
	addi t3, t3, -4
	la t4, grid
	lw t4, 8(t4)
	add t4, t4, t3
	lw t4, 0(t4)
	# grid.cells[i][j].hasPlayer = false
	sb zero, 9(t4)
	# i = newI
	lw t3, 4(sp)
	sw t0, 0(t3)
	
	# push grid.cells[i][j]
	addi, sp, sp, -4 
	sw t4, 0(sp)
	
	# Display new cell.
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop grid.cells[i][j]
	lw t4, 0(sp)
	addi, sp, sp, 4
	
	# Erase old cell.
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw a0, 4(sp)
	lw t2, 8(a0)
	addi t2, t2, -1
	sw t2, 8(a0)
	
	j player_move_callUpdateGrid
	
	
	player_move_ifD1:
	
	# if newCell.hasMonster or newCell.hasBlock
	lbu t2, 8(t1)
	bne t2, zero, player_move_ifD_monsterOrBlock
	
	lbu t2, 5(t1)
	beq t2, zero, player_move_ret
	
	player_move_ifD_monsterOrBlock:
	# t2 = newI + 1
	addi t2, t0, 1
	# if newI+1 < 10
	li t5, 10
	bge t2, t5, player_move_ret
	
	# t3 = 10 * this.j = 10 * newJ
	lw t4, 4(sp)
	lw t4, 4(t4)
	li t3, 10
	mul t3, t3, t4
	# t4 = newI+1
	addi t4, t0, 1
	# t3 = newI+1 + 10 * newJ
	add t3, t3, t4 
	li t4, 4
	# t3 = 4 * (newI + 1 + 10*newJ)
	mul t3, t3, t4
	
	# t4 = grid.cells[newI+1][newJ]
	la t4, grid 
	lw t4, 8(t4)
	add t4, t4, t3 
	lw t4, 0(t4)
	
	
	# if grid.cells[newI+1][newJ].isWalkable
	lbu t3, 11(t4)
	beq t3, zero, player_move_ifD3
	
	# if newCell.hasMonster
	lbu t3, 8(t1)
	beq t3, zero, player_move_ifD_block
	
	li t0, 1
	
	# grid.cells[oldI][oldJ].hasMonster = false
	sb zero, 8(t1)
	# grid.cells[oldI][oldJ].isWalkable = true
	sb t0, 11(t1)
	
	# push t4
	addi sp, sp, -4
	sw t4, 0(sp)
	
	# Erase old monster
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop t4
	lw t4, 0(sp)
	addi sp, sp, 4
	
	li t0, 4
	# grid.cells[newI+1][newJ].hasMonster = true
	sb t0, 8(t4)
	# grid.cells[newI+1][newJ].isWalkable = false
	sb zero, 11(t4)
	
	# Draw new monster
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_ifD3:
	# if newCell.hasMonster
	lbu t3, 8(t1)
	beq t3, zero, player_move_ret
	
	# newCell.hasMonster = false
	sb zero, 8(t1)
	# newCell.isWalkable = true
	li t0, 1
	sb t0, 11(t1)
	
	# Erase monster.
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_ifD_block:
	
	li t0, 1
	
	# grid.cells[oldI][oldJ].hasBlock = false
	sb zero, 5(t1)
	# grid.cells[oldI][oldJ].isWalkable = true
	sb t0, 11(t1)
	
	# push t4
	addi sp, sp, -4
	sw t4, 0(sp)
	
	# Erase old block
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop t4
	lw t4, 0(sp)
	addi sp, sp, 4
	
	li t0, 4
	# grid.cells[newI+1][newJ].hasBlock = true
	sb t0, 5(t4)
	# grid.cells[newI+1][newJ].isWalkable = false
	sb zero, 11(t4)
	
	# Draw new block
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	
	player_move_notD:
	
	# if key == 'a'
	li t0, 'a'
	bne a1, t0, player_move_ret
	
	# t0 = newI = this.i-1
	lw t0, 0(a0)
	addi t0, t0, -1
	
	# if newI >= 0
	blt t0, zero, player_move_ret
	
	# t1 = grid.cells
	la t1, grid
	lw t1, 8(t1)
	# t2 = 10 * this.j
	li t2, 10
	lw t3, 4(a0)
	mul t2, t2, t3 
	# t3 = 4 * (newI + 10 * this.j)
	add t3, t0, t2
	li t2, 4 
	mul t3, t3, t2
	
	# t1 = newCell = cells[newI][this.j]
	add t1, t1, t3
	lw t1, 0(t1)
	
	# if newCell.isWalkable
	lbu t2, 11(t1)
	beq t2, zero, player_move_ifA1
	
	# newCell.hasPlayer = true
	li t4, 1
	sb t4, 9(t1)
	
	# t4 = grid.cells[i][j]
	addi t3, t3, 4
	la t4, grid
	lw t4, 8(t4)
	add t4, t4, t3
	lw t4, 0(t4)
	# grid.cells[i][j].hasPlayer = false
	sb zero, 9(t4)
	# i = newI
	lw t3, 4(sp)
	sw t0, 0(t3)
	
	# push grid.cells[i][j]
	addi, sp, sp, -4 
	sw t4, 0(sp)
	
	# Display new cell.
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop grid.cells[i][j]
	lw t4, 0(sp)
	addi, sp, sp, 4
	
	# Erase old cell.
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw a0, 4(sp)
	lw t2, 8(a0)
	addi t2, t2, -1
	sw t2, 8(a0)
	
	j player_move_callUpdateGrid
	
	
	player_move_ifA1:
	
	# if newCell.hasMonster or newCell.hasBlock
	lbu t2, 8(t1)
	bne t2, zero, player_move_ifA_monsterOrBlock
	
	lbu t2, 5(t1)
	beq t2, zero, player_move_ret
	
	player_move_ifA_monsterOrBlock:
	# t2 = newI - 1
	addi t2, t0, -1
	# if newI-1 >= 0
	blt t2, zero, player_move_ret
	
	# t3 = 10 * this.j = 10 * newJ
	lw t4, 4(sp)
	lw t4, 4(t4)
	li t3, 10
	mul t3, t3, t4
	# t4 = newI-1
	addi t4, t0, -1
	# t3 = newI-1 + 10 * newJ
	add t3, t3, t4 
	li t4, 4
	# t3 = 4 * (newI - 1 + 10*newJ)
	mul t3, t3, t4
	
	# t4 = grid.cells[newI-1][newJ]
	la t4, grid 
	lw t4, 8(t4)
	add t4, t4, t3 
	lw t4, 0(t4)
	
	
	# if grid.cells[newI-1][newJ].isWalkable
	lbu t3, 11(t4)
	beq t3, zero, player_move_ifA3
	
	# if newCell.hasMonster
	lbu t3, 8(t1)
	beq t3, zero, player_move_ifA_block
	
	li t0, 1
	
	# grid.cells[oldI][oldJ].hasMonster = false
	sb zero, 8(t1)
	# grid.cells[oldI][oldJ].isWalkable = true
	sb t0, 11(t1)
	
	# push t4
	addi sp, sp, -4
	sw t4, 0(sp)
	
	# Erase old monster
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop t4
	lw t4, 0(sp)
	addi sp, sp, 4
	
	li t0, 4
	# grid.cells[newI+1][newJ].hasMonster = true
	sb t0, 8(t4)
	# grid.cells[newI+1][newJ].isWalkable = false
	sb zero, 11(t4)
	
	# Draw new monster
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_ifA3:
	# if newCell.hasMonster
	lbu t3, 8(t1)
	beq t3, zero, player_move_ret
	
	# newCell.hasMonster = false
	sb zero, 8(t1)
	# newCell.isWalkable = true
	li t0, 1
	sb t0, 11(t1)
	
	# Erase monster.
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_ifA_block:
	
	li t0, 1
	
	# grid.cells[oldI][oldJ].hasBlock = false
	sb zero, 5(t1)
	# grid.cells[oldI][oldJ].isWalkable = true
	sb t0, 11(t1)
	
	# push t4
	addi sp, sp, -4
	sw t4, 0(sp)
	
	# Erase old block
	mv a0, t1
	mv a1, s0
	call cell_display
	
	# pop t4
	lw t4, 0(sp)
	addi sp, sp, 4
	
	li t0, 4
	# grid.cells[newI-1][newJ].hasBlock = true
	sb t0, 5(t4)
	# grid.cells[newI-1][newJ].isWalkable = false
	sb zero, 11(t4)
	
	# Draw new block
	mv a0, t4
	mv a1, s0
	call cell_display
	
	# this.moves--
	lw t0, 4(sp)
	lw t1, 8(t0)
	addi t1, t1, -1
	sw t1, 4(sp)
	
	j player_move_callUpdateGrid
	
	player_move_callUpdateGrid:
	la a0, grid
	call grid_update 
	
	player_move_ret:
	
	lw ra, 0(sp)
	addi sp, sp, 12
	ret

# a0 = this
# a1 = frame
player_display:
	# t0 = size
	li t0, 28
	
	# t1 = frame 
	mv t1, a1
	
	# a1 = i * size
	lw a1, 0(a0)
	mul a1, a1, t0
	
	# a2 = j * size 
	lw a2, 4(a0)
	mul a2, a2, t0
	
	# a0 = heroImage
	la a0, heroTest
	
	# a3 = frame 
	mv a3, t1
	
	# Save return address and call drawImage.
	addi sp, sp, -4
	sw ra, 0(sp)
	call drawImage
	lw ra, 0(sp)
	addi sp, sp, 4 
	
	
	ret
