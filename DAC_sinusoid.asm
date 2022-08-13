		CLR P0.7	; enable the DAC WR line
		MOV 30H, #128
		MOV 31H, #192
		MOV 32H, #238
		MOV 33H, #255
		MOV 34H, #238
		MOV 35H, #192
		MOV 36H, #128
		MOV 37H, #64
		MOV 38H, #17
		MOV 39H, #0
		MOV 3AH, #17
		MOV 3BH, #64
repeat:	MOV R0, #30H
loop:	MOV A, @R0
		MOV P1, A	; move data in the accumulator to the ADC inputs (on P1)
		CALL delay
		INC R0
		CJNE R0, #3CH, loop
		JMP repeat	; jump back to loop

delay:	MOV R1, #40
		DJNZ R1, $
		RET