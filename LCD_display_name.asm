; put data in RAM
		mov 30H, #'A'
		mov 31H, #'R'
		mov 32H, #'U'
		mov 33H, #'S'
		mov 34H, #'A'
		mov 35H, #'R'
		mov 36H, #'K'
		mov 37H, #'A'
		mov 38H, #0		; end of data marker

; initialise the display
		clr P2.0		; clear RS - indicates that instructions are being sent to the module
; function set - 8 bit display mode
		mov P1, #00111011B
; negative edge on E
		setb P2.2
		clr P2.2		; negative edge on E
		call delay		; wait for BF to clear

; entry mode set
; set to increment with no shift
		mov P1, #00000110B	
		setb P2.2
		clr P2.2		; negative edge on E
		call delay		; wait for BF to clear

; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
		mov P1, #00001111B
		setb P2.2
		clr P2.2		; negative edge on E
		call delay		; wait for BF to clear

; send data
		setb P2.0		; set RS - indicates that data is being sent to module
		mov R1, #30H	; data to be sent to LCD is stored in RAM, starting at location 30H
loop:	mov A, @R1		; move data pointed to by R1 to A
		jz finish		; if A is 0, then end of data has been reached - jump out of loop
		call send		; send data in A to LCD module
		inc R1			; point to next piece of data
		jmp loop		; repeat
finish:	sjmp $

send:	mov P1, A
		setb P2.2		
		clr P2.2		; negative edge on E
		call delay		; wait for BF to clear
		ret
delay:	mov R0, #50
		djnz R0, $
		ret
