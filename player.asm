#		WORD : i 0
#		WORD : j 4
#		WORD: moves 8
#		WORD: gotKey 12
# 		TOTAL SIZE : 16 BYTES

.data
.include "resources/heroImage.s"
.include "resources/heroTest.data"

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
	

















