; Define the timer variables for both the digital clock and the stopwatch, as well as the 
; start, stop and switch variables
			org 0000H
			onesec equ 60H
			tensec equ 61H
			onemin equ 62H
			tenmin equ 63H
			onesecst equ 70H
			tensecst equ 71H
			oneminst equ 72H
			tenminst equ 73H
			switch equ P2.5
			start equ P2.7
			stop equ P2.6
			ljmp main

; The ISR for the Timer 0 interrupt. The Timer 0 interrupt is used to update and display
; the time of the stopwatch. The main operations are written at another part of the code 
; memory in order to avoid overspilling into the ISR for the Timer 1.
; At the end of routine, the Timer is re-initialized
			org 000BH
			acall auxil
			mov TH0, #0F9H
			mov TL0, #00H
			jnb switch, ret0		; If the switch is not active, then stop the Timer 0
			clr TR0
ret0	:	reti

; The ISR for the Timer 1 interrupt. The ISR contains the display and the update routines
; for the digital clock. If the switch for mode change to stopwatch is on, then the display
; routine for the digital clock won't be called.
; At the end of the routine, the Timer 1 is re-initialized
			org 001BH
			jnb switch, skip
			acall display
skip	:	acall update
			mov TH1, #0FCH
			mov TL1, #00H
			reti

; The display and update routines for the stopwatch, to be called from the ISR for Timer 0.
; If the switch for the stopwatch is on (the corresponding bit is not set), then the 
; stopwatch variables are reset to 0.
auxil	:	jnb switch, oper
			sjmp stopped
streset	:	mov onesecst, #30H
			mov tensecst, #30H
			mov oneminst, #30H
			mov tenminst, #30H
oper	:	jnb start, streset    ; If the start button has been pressed then reset the 
			acall displayst		  ; stopwatch to 0.
			jnb stop, stopped     ; If the stop button has been pressed then don't update the
			acall updatest		  ; stopwatch variables
stopped	:	ret

; The main snippet
			org 0045H
main	:	mov 30H, #0C0H 		  ; The look-up table is created for displaying various digits
			mov 31H, #0F9H		  ; on the LEDs
			mov 32H, #0A4H
			mov 33H, #0B0H
			mov 34H, #99H
			mov 35H, #92H
			mov 36H, #82H
			mov 37H, #0F8H
			mov 38H, #80H
			mov 39H, #98H

			mov TMOD, #11H        ; Use mode 1 (16-bit timer) for both the Timer 0 and Timer 1
			mov TH0, #0F9H
			mov TH1, #0FCH
			mov IE, #8AH 		  ; Enable the Timer 0 and Timer 1 interrupts
			setb TR1			  ; Start the Timer 1
			mov R0, #30H
loop	:	mov onesec, #30H  	  ; Initialize the variables
			mov tensec, #30H
			mov onemin, #30H
			mov tenmin, #30H
			mov onesecst, #30H
			mov tensecst, #30H
			mov oneminst, #30H
			mov tenminst, #30H
body	:	jb switch, last		  ; If the switch is off, then don't start Timer 0. Stay in 
			setb TR0  			  ; this check loop for the entire duration of the program
last	:	sjmp body			  ; since the ISRs take care of the other functions

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

; Update routine for the stopwatch
updatest:	inc onesecst
			mov R0, onesecst
			cjne R0, #3AH, returnst
			mov onesecst, #30H
			inc tensecst
			mov R0, tensecst
			cjne R0, #36H, returnst
			mov tensecst, #30H
			inc oneminst
			mov R0, oneminst
			cjne R0, #3AH, returnst
			mov oneminst, #30H
			inc tenminst
			mov R0, tenminst
			cjne R0, #36H, returnst
returnst:	ret

; The display routine for the digital clock where the individual LEDs are selected in a 
; sequential fashion and the corresponding variable is used to update that LED
display	:	clr P3.3
			clr P3.4
			mov R0,	onesec
			mov P1, @R0
			acall delay
			mov P1, #0FFH
			setb P3.3
			mov R0, tensec
			mov P1, @R0
			acall delay
			mov P1, #0FFH
			setb P3.4
			clr P3.3
			mov R0, onemin
			mov P1, @R0
			acall delay
			mov P1, #0FFH
			setb P3.3
			mov R0, tenmin
			mov P1, @R0
			acall delay
			mov P1, #0FFH
			ret

; Display routine for the stopwatch
displayst	:	clr P3.3
			clr P3.4
			mov R0,	onesecst
			mov P1, @R0
			acall delay
			mov P1, #0FFH
			setb P3.3
			mov R0, tensecst
			mov P1, @R0
			acall delay
			mov P1, #0FFH
			setb P3.4
			clr P3.3
			mov R0, oneminst
			mov P1, @R0
			acall delay
			mov P1, #0FFH
			setb P3.3
			mov R0, tenminst
			mov P1, @R0
			acall delay
			mov P1, #0FFH
			ret

; Delay routine using loop
delay	:	mov R4, #50
			djnz R4, $
			ret


