start	:	MOV R1, #0H
iter	:	MOV A, R1
			MOV R0, A
			MOV DPL, #LOW(nums)
			MOV DPH, #HIGH(nums)
			SETB P3.3
			SETB P3.4
			MOV A, R0
			INC R0
			MOVC A, @A+DPTR
			MOV P1, A
			CALL delay
			CLR P3.3
			MOV A, R0
			INC R0
			MOVC A, @A+DPTR
			MOV P1, A
			CALL delay
			CLR P3.4
			SETB P3.3
			MOV A, R0
			INC R0
			MOVC A, @A+DPTR
			MOV P1, A
			CALL delay
			CLR P3.3
			MOV A, R0
			INC R0
			MOVC A, @A+DPTR
			MOV P1, A
			CALL delay
			INC R1
			CJNE R1, #06H, iter	
			JMP start

delay	:	MOV R2, #25
loop	:	MOV R3, #10
			DJNZ R3,$
			DJNZ R2, loop
			RET

nums	:	DB 11111001B
			DB 10000000B
			DB 10000110B
			DB 11110000B
			DB 10110000B
			DB 10010010B
			DB 11000000B
			DB 10110000B
			DB 10010010B
			END
