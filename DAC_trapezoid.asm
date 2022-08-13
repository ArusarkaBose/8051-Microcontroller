		clr P0.7	; enable the DAC WR line
		mov A, #0H
rise:	add A, #5
		mov R3, #60
		mov P1, A	; move data in the accumulator to the ADC inputs (on P1)
		cjne A, #255, rise ; jump back to loop
		acall short_d
fall:	subb A, #5
		mov P1, A	; move data in the accumulator to the ADC inputs (on P1)
		cjne A, #0, fall  ; jump back to loop
		acall long_d
		jmp rise		

short_d:	mov R0, #40
inner:		mov R1, #20
			djnz R1, $
			djnz R0, inner
			ret

long_d:		mov R0, #50
inner_2:	mov R1, #20
			djnz R1, $
			djnz R0, inner_2
			ret
