; Define the timer variables for both the digital clock and the stopwatch, as well as the 
; start, stop and switch variables
			org 0000H
			onesec equ 60H
			tensec equ 61H
			onemin equ 62H
			tenmin equ 63H
			switch equ P2.5
			name equ P2.6      ; Variable indicates whether name is being displayed
			ljmp main

; The ISR for the Timer 0 interrupt. The ISR contains the display and the update routines
; for the digital clock. If the switch for mode change is off, then the display
; routine for the digital clock won't be called.
; At the end of the routine, the Timer 0 is re-initialized
			org 000BH
			jb switch, skip
			setb P2.6
			clr P2.0
			mov P1, #00000001B
			setb P2.2
			clr P2.2		; negative edge on E
			call lwait		; wait for BF to clea
			setb P2.0
			acall display
skip	:	acall update
			mov TH0, #0FCH
			mov TL0, #00H
			reti

; The main snippet
			org 0030H
main	:	mov 30H, #'0'
			mov 31H, #'1'
			mov 32H, #'2'
			mov 33H, #'3'
			mov 34H, #'4'
			mov 35H, #'5'
			mov 36H, #'6'
			mov 37H, #'7'
			mov 38H, #'8'
			mov 39H, #'9'
			mov 70H, #'A'
			mov 71H, #'R'
			mov 72H, #'U'
			mov 73H, #'S'
			mov 74H, #'A'
			mov 75H, #'R'
			mov 76H, #'K'
			mov 77H, #'A'
			mov 78H, #0		; end of data marker

			mov TMOD, #01H        ; Use mode 1 (16-bit timer) for both the Timer 0 and Timer 1
			mov TH0, #0F9H
			mov IE, #82H
			setb TR0
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
loop	:	mov onesec, #30H  	  ; Initialize the variables
			mov tensec, #30H
			mov onemin, #30H
			mov tenmin, #30H
body	:	jnb switch, last		  ; If the switch is off, then call name display
			jnb name, last 
			setb P2.0				  ; Stay in this check loop for the entire duration of the 
			acall ds_name  		  	  ; program since the ISRs take care of the other functions
last	:	sjmp body			      

; Update routine for the digital clock
update	:	inc onesec			  ; Increment of the one's position of the second
			mov R0, onesec
			cjne R0, #3AH, return ; Checking whether the one's position has exceeded 9
			mov onesec, #30H	  ; If the one's position of the second has exceeded 9,
			inc tensec			  ; then reset it to 0 and increment the ten's position
			mov R0, tensec		  ; of second
			cjne R0, #36H, return ; If the ten's position of second has reached 6, then
			mov tensec, #30H	  ; reset it to 0 and increment the one's position of 
			inc onemin			  ; minute
			mov R0, onemin
			cjne R0, #3AH, return
			mov onemin, #30H
			inc tenmin
			mov R0, tenmin
			cjne R0, #36H, return
return	:	ret

; The display routine for the digital clock
display	:	mov R0,	tenmin
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

ds_name	:	; send data
			setb P2.0		; set RS - indicates that data is being sent to module
			mov R1, #70H	; data to be sent to LCD is stored in RAM, starting at location 30H
rec:		mov A, @R1		; move data pointed to by R1 to A
			jz finish		; if A is 0, then end of data has been reached - jump out of loop
			call send		; send data in A to LCD module
			inc R1			; point to next piece of data
			jmp rec 		; repeat
finish:		clr name
			ret

send	:	mov P1, A
			setb P2.2		
			clr P2.2		; negative edge on E
			call delay		; wait for BF to clear
			ret

; Delay routine using loop
delay	:	mov R4, #50
			djnz R4, $
			ret

wait	:	mov R0, #50
			djnz R0, $
			ret

lwait	:	mov R0, #50
in_loop	:	mov R3, #42
			djnz R3, $
			djnz R0, in_loop
			ret
