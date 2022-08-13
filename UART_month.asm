mov r1,#30h
mov r2,#1
start:

	MOV R0, #1		; clear R0 - the first key is key0
    MOV P0,#0FFH
	; scan row0
	SETB P0.3		; set row3
	CLR P0.0		; clear row0
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
				; | (because the pressed key was found and its number is in  R0)

	; scan row1
	SETB P0.0		; set row0
	CLR P0.1		; clear row1
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
				; | (because the pressed key was found and its number is in  R0)

	; scan row2
	SETB P0.1		; set row1
	CLR P0.2		; clear row2
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
				; | (because the pressed key was found and its number is in  R0)

	; scan row3
	SETB P0.2		; set row2
	CLR P0.3		; clear row3
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
				; | (because the pressed key was found and its number is in  R0)


finish:
    clr f0
    cjne r2,#0,start

    mov a,30h

    cjne a,#1,is_feb
    mov dptr,#jan

is_feb:
    cjne a,#2,is_mar
    mov dptr,#feb

is_mar:
    cjne a,#3,is_apr
    mov dptr,#mar

is_apr:
    cjne a,#4,is_may
    mov dptr,#apr

is_may:
    cjne a,#5,is_jun
    mov dptr,#may

is_jun:
    cjne a,#6,is_jul
    mov dptr,#jun

is_jul:
    cjne a,#7,is_aug
    mov dptr,#jul

is_aug:
    cjne a,#8,is_sep
    mov dptr,#aug

is_sep:
    cjne a,#9,is_oct
    mov dptr,#sep

is_oct:
    cjne a,#10,is_nov
    mov dptr,#oct

is_nov:
    cjne a,#11,is_dec
    mov dptr,#nov

is_dec:
	cjne a,#12,continue
    mov dptr,#decem

continue:
mov r1,#40h

loop_get:   clr a
        movc a,@a+dptr
        jz finish_retrieve
        mov @r1,a
        inc dptr
        inc r1
        jmp loop_get

finish_retrieve:
    

    CLR SM0			; |
	SETB SM1		; | put serial port in 8-bit UART mode

	MOV A, PCON		; |
	SETB ACC.7		; |
	MOV PCON, A		; | set SMOD in PCON to double baud rate

	MOV TMOD, #20H		; put timer 1 in 8-bit auto-reload interval timing mode
	MOV TH1, #-13		; put -13 in timer 1 high byte (timer will overflow every 13 us)
	MOV TL1, #-13		; put same value in low byte so when timer is first started it will overflow after 13 us
	SETB TR1		; start timer 1


	;MOV 52H, #0		; null-terminate the data (when the accumulator contains 0, no more data to be sent)
	MOV R0, #40H		; put data start address in R0
again:
	MOV A, @R0		; move from location pointed to by R0 to the accumulator
	cjne a,#'@',continue1	; if the accumulator contains @, no more data to be sent, jump to finish
    sjmp finish1
continue1:
	;MOV C, P		; otherwise, move parity bit to the carry
	;MOV ACC.7, C		; and move the carry to the accumulator MSB
	MOV SBUF, A		; move data to be sent to the serial port
	INC R0			; increment R0 to point at next byte of data to be sent
	JNB TI, $		; wait for TI to be set, indicating serial port has finished sending byte
	CLR TI			; clear TI
	JMP again		; send next byte
finish1:


	MOV R1, #60H		; put data start address in R1
    SETB REN		; enable serial port receiver
again2:
	JNB RI, $		; wait for byte to be received
	CLR RI			; clear the RI flag
	MOV A, SBUF		; move received byte to A
	CJNE A, #0DH, skip2	; compare it with 0DH - if it's not, skip next instruction
	JMP finish2		; if it is the terminating character, jump to the end of the program
skip2:
	MOV @R1, A		; move from A to location pointed to by R1
	INC R1			; increment R1 to point at next location where data will be stored
	JMP again2		; jump back to waiting for next byte
finish2:
    MOV @R1, #'@'		; move from A to location pointed to by R1
	
	
RS Equ P1.3
E  Equ P1.2
; R/W* is hardwired to 0V, therefore it is always in write mode
main:
        clr RS ; RS=0 - Instruction register is selected.
                ; Stores instruction codes, e.g., clear display...

        call FuncSet ; Function set

        call DispCon ; Display on/off control

        call EntryMode ; Entry mode set (4-bit mode)
; Send data
        setb RS ; RS=1 - Data register is selected.
                ; Send data to data register to be displayed.

        mov r1, #60h

loop:   clr a
        mov a,@r1
        cjne a,#'@',continue3	; if the accumulator contains @, no more data to be sent, jump to finish
    sjmp finish3
continue3:
        call SendChar
        inc r1
        jmp loop

finish3: jmp finish3

FuncSet: 
        clr p1.7      ; |
        clr p1.6      ; |
        setb p1.5     ; | bit 5=1
        clr p1.4      ; | (DB4)DL=0 - puts LCD module into 4-bit mode

        call Pulse

        Call Delay ; wait for BF to clear

        Call Pulse 

        setb p1.7 ; P1.7=1 (N) - 2 lines 
        clr p1.6
        clr p1.5
        clr p1.4

        call Pulse

        call Delay
Ret

; The display is turned on, the cursor is turned on
DispCon: 
        clr p1.7    ; |
        clr p1.6    ; |
        clr p1.5    ; |
        clr p1.4    ; | high nibble set (0H - hex)

        call Pulse

        setb p1.7   ; |
        setb p1.6   ; |Sets entire display ON
        setb p1.6   ; |Cursor ON
        setb p1.4   ; |Cursor blinking ON

        call Pulse

        call Delay ; wait for BF to clear
Ret

;    Set to increment the address by one and cursor shifted to the right
EntryMode:
        clr p1.7   ; |P1.7=0
        clr p1.6   ; |P1.6=0
        clr p1.5   ; |P1.5=0
        clr p1.4   ; |P1.4=0

        call Pulse

        clr p1.7   ; |P1.7=0
        setb p1.6  ; |P1.6=1
        setb p1.5  ; |P1.5=1
        clr p1.4   ; |P1.4=0

        call Pulse

        call Delay ; wait for BF to clear
Ret


Pulse:
        setb E ; |*P1.2 is connected to 'E' pin of LCD module*
        clr E  ; | negative edge on E
Ret

SendChar:
        mov c,acc.7  ; |
        mov p1.7,c   ; |
        mov c,acc.6  ; |
        mov p1.6,c   ; |
        mov c,acc.5  ; |
        mov p1.5,c   ; |
        mov c,acc.4  ; |
        mov p1.4,c   ; | high nibble set

        call Pulse

        mov c,acc.3  ; |
        mov p1.7,c   ; |
        mov c,acc.2  ; |
        mov p1.6,c   ; |
        mov c,acc.1  ; |
        mov p1.5,c   ; |
        mov c,acc.0  ; |
        mov p1.4,c   ; | low nibble set

        call Pulse

        call Delay   ; wait for BF to clear
Ret

Delay:
        mov r0,#50
        djnz r0,$
Ret





; column-scan subroutine

colScan:
	JNB P0.4, gotKey	; if col0 is cleared - key found
	INC R0			; otherwise move to next key
	JNB P0.5, gotKey	; if col1 is cleared - key found
	INC R0			; otherwise move to next key
	JNB P0.6, gotKey	; if col2 is cleared - key found
	INC R0			; otherwise move to next key

    
	RET			; return from subroutine - key not found

gotKey:
	SETB F0			; key found - set F0
    mov a,r0
    mov @r1,a
    inc r1
    dec r2

    clr p1.7
    mov r3,#1

    loop1:
        mov r4,#01h
        djnz r4, $
        djnz r3, loop1
        setb p1.7
	RET

jan:    DB 'J','a','n','u','a','r','y','@',0
feb:    DB 'F','e','b','r','u','a','r','y','@',0
mar:    DB 'M','a','r','c','h','@',0
apr:    DB 'A','p','r','i','l','@',0
may:    DB 'M','a','y','@',0
jun:    DB 'J','u','n','e','@',0
jul:    DB 'J','u','l','y','@',0
aug:    DB 'A','u','g','u','s','t','@',0
sep:    DB 'S','e','p','t','e','m','b','e','r','@',0
oct:    DB 'O','c','t','o','b','e','r','@',0
nov:    DB 'N','o','v','e','m','b','e','r','@',0
decem:    DB 'D','e','c','e','m','b','e','r','@',0