.text

lw $3, vgaStart($0)
lw $2, delayConst($0)

initializeProgram:

addi $21, $0, 0	#init bird dY
addi $23, $0, 1280 #init bird Y
addi $22, $0, 120	#reset pipes
addi $20, $0, 0
addi $24, $0, 60
addi $25, $0, 40
addi $26, $0, 50

jal delay		#NEED THIS DONT KNOW WHY
j begin

#FUNCTION blankScreen----------------------------------------------
#Clears the screen faster
#---------------------------
blankScreen:
addi $9, $3, 15360
addi $8, $3, 0

blankLoop:
sw $0, 0($8)
sw $0, 1($8)
sw $0, 2($8)
sw $0, 3($8)
sw $0, 4($8)
sw $0, 5($8)
sw $0, 6($8)
sw $0, 7($8)
addi $8, $8, 8
blt $8, $9, blankLoop

jr $31
#FUNCTION END------------------------------------------------

###########################################################################################
# Fill stage with color, blank
fillColor:
		add $28, $0, $31		# back up $31
		
		addi $16, $0, 0
		addi $17, $0, 0
		addi $18, $0, 128
		addi $19, $0, 128
		addi  $6, $0, 0
		
		jal drawRect			# fill screen 
		
		add $31, $0, $28
		jr $31
###########################################################################################

#FUNCTION delay----------------------------------------------
#Delays for roughly 100ms
#---------------------------
delay:
addi $8, $2, 0
delayLoop:
addi $8, $8, -1
bne $0, $8, delayLoop
jr $31
#FUNCTION END------------------------------------------------

#FUNCTION drawPixel------------------------------------------
#Draws the pixel at x = $4, y = $5, color = $6
#---------------------------
drawPixel:
sll $8, $5, 7
add $8, $8, $4				#Add X offset to $8
#sll $8, $8, 2				#FOR MARS$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
add $8, $8, $3				#Add VGA offset
sw $6, 0($8)				#Draw the pixel

jr $31
#FUNCTION END------------------------------------------------

#FUNCTION drawRect------------------------------------------
#Draws the rectangle at x=16, y=17, w=18, h=19, color=6
#---------------------------
drawRect:
addi $30, $31, 0	#back up the RA

add $9, $16, $18	#calc end X
add $10, $17, $19	#calc end Y

addi $4, $16, 0	#load cur X
addi $5, $17, 0	#load cur Y

drawLoop:
jal drawPixel
addi $4, $4, 1
blt $4, $9, drawLoop

addi $5, $5, 1
addi $4, $16, 0	#load cur X
blt $5, $10, drawLoop

addi $31, $30, 0	#Load back the RA
jr $31
#FUNCTION END------------------------------------------------

###########################################################################################

drawPlayer:
	add $28, $0, $31		# back up $31
	
	lw $8, 1000($0)
	nop
	nop
	nop
	blt $8, $0, upBoost

	j doneBoost
upBoost:
	addi $21, $0, -80

doneBoost:

	addi $21, $21, 10		#increase down accel

	addi $8, $0, 200
	blt $21, $8, skipLowerCap
	addi $21, $8, 0

skipLowerCap: 

	add $23, $23, $21		#make bird fall

	

	sra $17, $23, 6			#Set Y to a scaled down version
	addi $15, $17, 0		#copy reg

	addi $16, $0, 10		# X coord
	addi $18, $0, 5		# W
	addi $19, $0, 5		# H
	addi $6, $0, 0x1		# Color

	jal drawRect
	
	add $31, $0, $28
	jr $31

###########################################################################################
# Draw pipe from x at $16 gap at $19
drawPipe:
		add $28, $0, $31 	# back up $31
		
		addi $17, $0, 0
		addi $18, $0, 10	#CONST, PIPE WIDTH
		addi $6, $0, 0x02

		jal drawRect
		
		addi $17, $19, 20	#CONST, GAP HEIGHT!!!!!!!!!
		addi $19, $0, 127	#Make H 127
		sub $19, $19, $17	#Subtract gap

		jal drawRect

		add $31, $0, $28
		jr $31

###########################################################################################
# Draw all pipes from x at $4 in top left corner in color $5
drawAllPipe:
		add $27, $0, $31 	#BACK IT UP

		addi $22, $22, -1	#CONST, pipe moving back in X
		
		addi $16, $22, 0
		addi $8, $0, 0x7F	#Load constant to and with
		and $16, $16, $8
		addi $19, $24, 0

		bne $16, $0, endRand
		add $24, $24, $20
		and $24, $24, $8

	endRand:

		jal checkGameEnd

		jal drawPipe
			
		addi $16, $22, 43
		addi $8, $0, 0x7F	#Load constant to and with
		and $16, $16, $8
		addi $19, $25, 0

		jal checkGameEnd

		jal drawPipe

		addi $16, $22, 86
		addi $8, $0, 0x7F	#Load constant to and with
		and $16, $16, $8
		addi $19, $26, 0

		jal checkGameEnd

		jal drawPipe
		
		add $31, $0, $27
		jr $31

#CHECK END#######################################
checkGameEnd:
	#dont need to store RA since we're not coming back if we jump

	#given current X, are we even in range
	addi $8, $16, -15
	blt $0, $8, checkGameEndReturn	#check if too far

	#blt $16, $0, checkGameEndReturn #check if too close

	blt $15, $19, gameEnd #check collision on top


	addi $8, $19, 15
	blt $8, $15, gameEnd

checkGameEndReturn:	
	jr $31

################################################
#Game finished due to collision
gameEnd:
	addi $10, $0, 800

gameEndLoop:
	jal blankScreen
	addi $10, $10, -1
	bne $0, $10, gameEndLoop

	j initializeProgram

begin:

jal blankScreen
jal drawAllPipe
jal drawPlayer
jal delay
addi $20, $20, 1	#keep score

j begin


quit:
j quit

.data
delayConst:  .word 0x00018000
vgaStart:  .word 0x40000000

#delayConst: .word 1000					#FOR MARS$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#vgaStart: .word 0x10010000				#FOR MARS$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$