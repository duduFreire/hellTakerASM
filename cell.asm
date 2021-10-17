#		BYTE : i 0
#		BYTE : j 1
#		BYTE: size 2 
#		BYTE: hasTreasure 3
#		BYTE: hasKey 4
#		BYTE: hasBlock 5
#		BYTE: hasSpike 6
#		BYTE: spikeAlternates 7
#		BYTE: hasMonster 8
#		BYTE: hasPlayer 9
#		BYTE: isGoal 10
#		BYTE: isWalkable 11
#		BYTE: mapPart 12
# 		TOTAL SIZE : 13 BYTES

.text
	

# a0 = this
# a1 = i
# a2 = j
# a3 = info
cell_initialize:
	sb a1, 0(a0)
	sb a2, 1(a0)
	li t0, 28
	sb t0, 2(a0)
	
	# Set all flags except mapPart to false.
	sb zero, 3(a0)
	sw zero, 4(a0)
	sw zero, 8(a0)
	li t0, 1
	sb t0, 12(a0)
	
	li t1, 'p'
	bne a3, t1, cell_intiialize_if1
	sb t0, 9(a0)
	sb t0, 11(a0)
	
	cell_intiialize_if1:
	li t1, 'g'
	bne a3, t1, cell_intiialize_if2
	sb t0, 10(a0)
	
	cell_intiialize_if2:
	li t1, 's'
	bne a3, t1, cell_intiialize_if3
	sb t0, 6(a0)
	sb t0, 11(a0)
	
	cell_intiialize_if3:
	li t1, 'a'
	bne a3, t1, cell_intiialize_if4
	sb t0, 6(a0)
	sb t0, 11(a0)
	sb t0, 7(a0)
	
	cell_intiialize_if4:
	li t1, 'm'
	bne a3, t1, cell_intiialize_if5
	sb t0, 8(a0)
	
	cell_intiialize_if5:
	li t1, 'b'
	bne a3, t1, cell_intiialize_if6
	sb t0, 5(a0)
	
	cell_intiialize_if6:
	li t1, 'k'
	bne a3, t1, cell_intiialize_if7
	sb t0, 4(a0)
	sb t0, 11(a0)
	
	cell_intiialize_if7:
	li t1, 't'
	bne a3, t1, cell_intiialize_if8
	sb t0, 3(a0)
	
	cell_intiialize_if8:
	li t1, 'w'
	bne a3, t1, cell_intiialize_if9
	sb t0, 11(a0)
	
	cell_intiialize_if9:
	li t1, 'z'
	bne a3, t1, cell_intiialize_if10
	sb t0, 5(a0)
	sb t0, 6(a0)
	
	cell_intiialize_if10:
	li t1, '0'
	bne a3, t1, cell_intiialize_if11
	sb zero, 12(a0)
	
	cell_intiialize_if11:
	ret
	
# Draws rectangle with sides w and h at coordinate x, y with color "color".
# a0 = x, a1 = y, a2 = w, a3 = h, a4 = color, a5 = frame
# t0 = startAdress
# t1 = columnCounter 
# t2 = lineCounter
cell_drawRect:
	# t0 = frame == 0 ? 0xFF0 : 00xFF1
	li t0, 0xFF0
	add t0, t0, a5
	slli t0, t0, 20
	
	# t0 = screen + x
	add t0, t0, a0
	
	# t1 = 320 * y
	li t1, 320 
	mul t1, t1, a1
	# t0 = screen + x + 320*y
	add t0, t0, t1 
	
	mv t1, zero
	mv t2, zero
	cell_drawRect_loop:
	sw a4, 0(t0)
	addi t0, t0, 4 
	
	addi t1, t1, 4
	blt t1, a2, cell_drawRect_loop
	
	addi t2, t2, 1
	beq t2, a3, cell_drawRect_exit
	
	addi t0, t0, 320 
	sub t0, t0, a2
	mv t1, zero
	
	j cell_drawRect_loop
	
	cell_drawRect_exit:
	ret

# a0 = this
# t1 = this.j*this.size
# t2 = this.i*this.size
cell_display:
	# t0 =  mapPart
	lbu t0, 12(a0)
	
	# if !mapPart: ret
	beq t0, zero, cell_display_if1
	
	# t1 = size
	lbu t1, 2(a0)
	# t2 = i
	lbu t2, 0(a0)
	# t2 = i * size
	mul t2, t2, t1 
	# t3 = j
	lbu t3, 1(a0)
	# t1 = j * size
	mul t1, t1, t3
	
	# t3 = this
	mv t3, a0
	mv a0, t2
	mv a1, t1
	li a4, 0x4c4c4c4c
	lbu a2, 2(t3)
	mv a3, a2
	mv t3, ra
	call cell_drawRect
	mv ra, t3
	
	cell_display_if1:
	ret
	
	
