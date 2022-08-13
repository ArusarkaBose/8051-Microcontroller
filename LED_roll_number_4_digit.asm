start	:	SETB P3.3
			SETB P3.4
			MOV P1, #11111001B
			CALL delay
			CLR P3.3
			MOV P1, #10000000B
			CALL delay
			CLR P3.4
			SETB P3.3
			MOV P1, #10000110B
			CALL delay
			CLR P3.3
			MOV P1, #11000110B
			CALL delay
			JMP start

delay	:	MOV R0, #25
loop	:	MOV R1, #10
			DJNZ R1,$
			DJNZ R0, loop
			RET
