onesec equ 60H
tensec equ 61H
onemin equ 62H
tenmin equ 63H

setb EA
setb ET0

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

mov TMOD, #01H

mov R0, #30H
loop	:	mov onesec, #30H
			mov tensec, #30H
			mov onemin, #30H
			mov tenmin, #30H
inner	:	acall display
			inc onesec
			mov R0, onesec
			cjne R0, #3AH, inner
			mov onesec, #30H
			inc tensec
			mov R0, tensec
			cjne R0, #36H, inner
			mov tensec, #30H
			inc onemin
			mov R0, onemin
			cjne R0, #3AH, inner
			mov onemin, #30H
			inc tenmin
			mov R0, tenmin
			cjne R0, #36H, inner
			sjmp $

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
			

delay	:	mov TH0, #0FFH
			mov TL0, #00H
			setb TR0
			jnb TF0, $
			clr TR0
			clr TF0
			ret


