		clr P0.7	; enable the DAC WR line
loop:	mov P1, A	; move data in the accumulator to the ADC inputs (on P1)
		add A, #8	; increase accumulator by 8
plus:	jmp loop	; jump back to loop