; Define the timer variables for the digital clock
		onesec equ 60H
		tensec equ 61H
		onemin equ 62H
		tenmin equ 63H

		setb EA
		setb ET0

; put data in RAM
		mov 30H, #'0'
		mov 31H, #'1'
		mov 32H, #'2'
		mov 33H, #'3'
		mov 34H, #'4'
		mov 35H, #'5'
		mov 36H, #'6'
		mov 37H, #'7'
		mov 38H, #'8'
		mov 39H, #'9'

		mov TMOD, #01H	; Timer 0 Mode 1

; initialise the display
		clr P2.0		; clear RS - indicates that instructions are being sent to the module
; function set - 8 bit display mode
		mov P1, #00111011B
; negative edge on E
		setb P2.2
		clr P2.2		; negative edge on E
		call wait		; wait for BF to clear

; entry mode set
; set to increment with no shift
		mov P1, #00000110B	
		setb P2.2
		clr P2.2		; negative edge on E
		call wait		; wait for BF to clear

; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
		mov P1, #00001111B
		setb P2.2
		clr P2.2		; negative edge on E
		call wait		; wait for BF to clear


		mov R0, #30H
; send data
		setb P2.0		; set RS - indicates that data is being sent to module
loop:	mov onesec, #30H
		mov tensec, #30H
		mov onemin, #30H
		mov tenmin, #30H
inner:	call delay
		acall display
; Update routine for the digital clock
		inc onesec				; Increment of the one's position of the second
		mov R0, onesec
		cjne R0, #3AH, inner  ; Checking whether the one's position has exceeded 9
		mov onesec, #30H	  ; If the one's position of the second has exceeded 9,
		inc tensec			  ; then reset it to 0 and increment the ten's position
		mov R0, tensec		  ; of second
		cjne R0, #36H, inner  ; If the ten's position of second has reached 6, then
		mov tensec, #30H	  ; reset it to 0 and increment the one's position of 
		inc onemin			  ; minute
		mov R0, onemin
		cjne R0, #3AH, inner
		mov onemin, #30H
		inc tenmin
		mov R0, tenmin
		cjne R0, #36H, inner
		sjmp $

display:mov R0,	tenmin
		mov P1, @R0
		setb P2.2		
		clr P2.2		; negative edge on E
		call wait		; wait for BF to clear
		mov R0, onemin
		mov P1, @R0
		setb P2.2		
		clr P2.2		; negative edge on E
		call wait		; wait for BF to clear
		mov R0, tensec
		mov P1, @R0
		setb P2.2		
		clr P2.2		; negative edge on E
		call wait		; wait for BF to clear
		mov R0, onesec
		mov P1, @R0
		setb P2.2		
		clr P2.2		; negative edge on E
		call wait		; wait for BF to clear
		clr P2.0
		mov P1, #10000000B
		setb P2.2
		clr P2.2		; negative edge on E
		call wait		; wait for BF to clear
		setb P2.0
		ret
			
; Delay routine using timer interrupt
delay:	mov TH0, #0FFH
		mov TL0, #00H
		setb TR0
		jnb TF0, $
		clr TR0
		clr TF0
		ret

wait:	mov R0, #50
		djnz R0, $
		ret


