ORG 0				; reset vector
		JMP main		; jump to the main program

ORG 3				; external 0 interrupt vector
		LJMP ext0ISR		; jump to the external 0 ISR

ORG 0BH				; timer 0 interrupt vector
		JMP timer0ISR		; jump to timer 0 ISR

ORG 30H				; main program starts here
main:	setb IT0		; set external 0 interrupt as edge-activated
		setb EX0		; enable external 0 interrupt
		clr P0.7		; enable DAC WR line
		; initialise the display
		clr P0.3		; clear RS - indicates that instructions are being sent to the module
; function set - 8 bit display mode
		mov P1, #00111011B
; negative edge on E
		setb P0.2
		clr P0.2		; negative edge on E
		call delay		; wait for BF to clear

; entry mode set
; set to increment with no shift
		mov P1, #00000110B	
		setb P0.2	
		clr P0.2		; negative edge on E
		call delay		; wait for BF to clear

; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
		mov P1, #00001111B
		setb P0.2	
		clr P0.2		; negative edge on E
		call delay		; wait for BF to clear

; send data
		setb P0.3		; set RS - indicates that data is being sent to module
		mov TMOD, #1		; set timer 0 as 8-bit auto-reload interval timer
		mov TH0, #0FFH	; | put -50 into timer 0 high-byte - this reload value, 
   							; | with system clock of 12 MHz, will result in a timer 0 overflow every 50 us
		mov TL0, #0CEH	; | put the same value in the low byte to ensure the timer starts counting from 
   							; | 236 (256 - 50) rather than 0
		setb TR0			; start timer 0
		setb ET0			; enable timer 0 interrupt
		setb EA				; set the global interrupt enable bit
		JMP $				; jump back to the same line (ie: do nothing)

; timer 0 ISR - simply starts an ADC conversion
timer0ISR:clr P3.6		; clear ADC WR line
		setb P3.6		; then set it - this results in the required positive edge to start a conversion
		reti			; return from interrupt

; external 0 ISR - responds to the ADC conversion complete interrupt
ext0ISR:clr P0.3
		mov P1, #10000000B
		setb P0.2
		clr P0.2		; negative edge on E
		call wait		; wait for BF to clear
		setb P0.3
		clr P3.7		    ; clear the ADC RD line - this enables the data lines
		mov A, P2
		mov R3, #8
loop:	rlc A		
		jc check1	; take the data from the ADC on P2 and send it to LED
check0:	acall set0
		djnz R3, loop
		jmp next
check1:	acall set1
		djnz R3, loop
next:	setb P3.7		; disable the ADC data lines by setting RD
		CLR TF0
		mov TH0, #0FFH
		mov TL0, #0CEH
		reti			; return from interrupt

set1:	mov P1, #'1'
		setb P0.2		
		clr P0.2		; negative edge on E
		mov R0, #30
		djnz R0, $
		ret
set0:	mov P1, #'0'
		setb P0.2		
		clr P0.2		; negative edge on E
		mov R0, #30
		djnz R0, $
		ret

delay:	mov R0, #40
		djnz R0, $
		ret

wait:		mov R0, #30
			djnz R0, $
			ret
