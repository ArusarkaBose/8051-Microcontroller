; Defining the variables for storing the different positions of the mm-ss format of time
onesec equ 60H
tensec equ 61H
onemin equ 62H
tenmin equ 63H
; Defining the start and stop switches to control the stopwatch
stop equ P2.6
start equ P2.7

; The EA and ET0 pins must be enabled for the timer interrupt routines to work
setb EA
setb ET0

; Creating the look-up table for displaying various digits on the 7-segment display
mov 30H, #0C0H
mov 31H, #0F9H
mov 32H, #0A4H
mov 33H, #0B0H
mov 34H, #99H
mov 35H, #92H
mov 36H, #82H
mov 37H, #0F8H
mov 38H, #80H
mov 39H, #98H

; Loading the Timer 0 in Mode 1
mov TMOD, #01H

mov R0, #30H   ; Intialization of the register which is to be used later in the code
loop	:	setb stop
			; Initializing the time variables with 0
			mov onesec, #30H
			mov tensec, #30H
			mov onemin, #30H
			mov tenmin, #30H
inner	:	acall display         ; Calls the display routine
			inc onesec            ; Increment of the one's position of the second
			mov R0, onesec
			cjne R0, #3AH, inner  ; Checking whether the one's position has exceeded 9
			mov onesec, #30H      ; If the one's position of the second has exceeded 9,
			inc tensec 			  ; then reset it to 0 and increment the ten's position
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
			sjmp $	              ; Pause the watch after reaching 59:59

; The display routine where the individual LEDs are selected in a sequential fashion and
; and the corresponding variable is used to update that LED
display	:	clr P3.3
			clr P3.4
			mov R0,	onesec
			mov P1, @R0
			acall delay      ; Call the delay routine
			mov P1, #0FFH    ; Blank the LED by setting all the bits of P1
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
			jnb start, loop     ; If the start button is pressed then go back to initialization
			jnb stop, display	; and reset all variables to 0, whereas, if the stop button is
			ret					; pressed then keep displaying the same time without updating
			

; The delay routine is created using the Timer 0
delay	:	mov TH0, #0FFH      ; Store the appropriate values in the registers as per the 
			mov TL0, #00H		; length of the delay required
			setb TR0   			; Start the Timer 0
			jnb TF0, $			; Check whether the Timer 0 flag is set and stay in the same
			clr TR0				; line until the flag is set
			clr TF0
			ret


