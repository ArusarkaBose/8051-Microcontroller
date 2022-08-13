; Length of one voltage division = Length of 2.36 time divisons
; For an angle of 30 degrees, the waveform must span 20.40 time divisions
; For an angle of 60 degrees, the waveform must span 6.8 time divisions
		clr P0.7	; enable the DAC WR line
		mov A, #0FFH
loop:	mov P1, A	; move data in the accumulator to the ADC inputs (on P1)
	;	subb A, #2	; decrease accumulator by 2 for a slope of 30
		subb A, #6  ; decrease accumulator by 6 for a slope of 60
plus:	jmp loop	; jump back to loop