digits Equ 20h
check Equ 50h

;R0 stores the location of data
;R1 stores the number of digits we have already to be transmitted.

setup:
	MOV R0, #20h; This is the address of location where data is stored
	MOV check, #0; If check is zero, new digit can be read.
	MOV DPL, #LOW(NUMS);	Digits are stored in Program Memory
	MOV DPH, #HIGH(NUMS);

start:

	MOV R2, #0		; clear R2 - the first key is key0

	; scan row0
	SETB P0.3		; set row3
	CLR P0.0		; clear row0
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
				; | (because the pressed key was found and its number is in  R2)

	; scan row1
	SETB P0.0		; set row0
	CLR P0.1		; clear row1
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
				; | (because the pressed key was found and its number is in  R2)

	; scan row2
	SETB P0.1		; set row1
	CLR P0.2		; clear row2
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
				; | (because the pressed key was found and its number is in  R2)

	; scan row3
	SETB P0.2		; set row2
	CLR P0.3		; clear row3
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
				; | (because the pressed key was found and its number is in  R2)

	;If we reach here, it means, we have pulled up the switch atleast for one cycle
	;Hence we can move zero in check.
	MOV check,#0;
	JMP start		; | go back to scan row 0
				; | (this is why row3 is set at the start of the program
				; | - when the program jumps back to start, row3 has just been scanned)

finish:
;	JMP $			; program execution arrives here when key is found - do nothing
	CLR F0; One of the digits is recieved, can be sent ahead
	MOV A, check;
	CJNE A,#0,start; If checkloop is 1, the previous digit is still continuing. 
	MOV A, R2;	Move the recetly captured digit to location
	MOV @R0, A; 
	INC R0; Move the pointer to next location in RAM
	MOV check, #1; The key is found, now, unless the button is left open, we will not read next digit.
	CJNE R0, #28h,start; If the key is larger, then jump. 

Tx: ; The complete sending and setup of transmission
	
	Tx_setup:
    CLR SM0			; |
	SETB SM1		; | put serial port in 8-bit UART mode

	MOV A, PCON		; |
	SETB ACC.7		; |
	MOV PCON, A		; | set SMOD in PCON to double baud rate

	MOV TMOD, #20H		; put timer 1 in 8-bit auto-reload interval timing mode
	MOV TH1, #-13		; put -13 in timer 1 high byte (timer will overflow every 13 us)
	MOV TL1, #-13		; put same value in low byte so when timer is first started it will overflow after 13 us
	SETB TR1		; start timer 1
	CLR TI;			;Init condition for Ti.
	MOV R1, #20h;

	;Run this on Even Parity
	Tx_loop:
		MOV A,@R1;
		MOVC A,@A+DPTR; Convert the keypad digits to actual keys of the keypad.
		
		MOV SBUF, A;
		INC R1;
		MOV A, R1;
		MOV B, R0;
		;INC B;
		JNB TI, $; Wait here till the complete byte is sent
		CLR TI; 
		CJNE A, B, Tx_loop;
Rx:
	
	Rx_setup:
		CLR SM0			; |
		SETB SM1		; | put serial port in 8-bit UART mode

		SETB REN		; enable serial port receiver

		MOV A, PCON		; |
		SETB ACC.7		; |
		MOV PCON, A		; | set SMOD in PCON to double baud rate

		MOV TMOD, #20H		; put timer 1 in 8-bit auto-reload interval timing mode
		MOV TH1, #-13		; put -13 in timer 1 high byte (timer will overflow every 13 us)
		MOV TL1, #-13		; put same value in low byte so when timer is first started it will overflow after 13 us
		SETB TR1		; start timer 1
		MOV R1, #30H		; put data start address in R1

	Rx_loop:
		JNB RI, $		; wait for byte to be received
		CLR RI			; clear the RI flag
		MOV A, SBUF		; move received byte to A
		MOV @R1, A;
		INC R1;
		CJNE R1, #38h,Rx_loop; 8 Digits for DOB.
		JMP LCD; Move to Displaying data on LCD.

colScan:
	JNB P0.4, gotKey	; if col0 is cleared - key found
	INC R2			; otherwise move to next key
	JNB P0.5, gotKey	; if col1 is cleared - key found
	INC R2			; otherwise move to next key
	JNB P0.6, gotKey	; if col2 is cleared - key found
	INC R2			; otherwise move to next key
	RET			; return from subroutine - key not found
gotKey:
	SETB F0			; key found - set F0
	RET			; and return from subroutine


LCD:
	RS Equ P1.3
	E  Equ P1.2

	Display_Setup: 
		CLR RS ; Instructions shall be written to the Display.
		
		Fourbit_mode:  ;To set Display in 4bit mode
			CLR P1.7		; |
			CLR P1.6		; |
			SETB P1.5		; |
			CLR P1.4		; | high nibble set

			SETB P1.2		; |
			CLR P1.2		; | negative edge on E

			CALL delay		; wait for BF to clear	
						; function set sent for first time - tells module to go into 4-bit mode
		; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

			SETB P1.2		; |
			CLR P1.2		; | negative edge on E
						; same function set high nibble sent a second time

			SETB P1.7		; low nibble set (only P1.7 needed to be changed)

			SETB P1.2		; |
			CLR P1.2		; | negative edge on E
						; function set low nibble sent
			CALL delay		; wait for BF to clear

			; The Display is not set into 4 bit mode ie data is sent as a set of nibbles

		Display_ON_OFF_CON: ; TO turn on Display and Cursor
			CLR P1.7		; |
			CLR P1.6		; |
			CLR P1.5		; |
			CLR P1.4		; | high nibble set			
			CALL neg_edge   ; High nibble sent

			SETB P1.7		; |
			SETB P1.6		; | Display ON
			SETB P1.5		; |	Cursor ON
			CLR P1.4		; | Cursor Blinking OFF			
			CALL neg_edge   ; Low Nibble sent			

			CALL delay
		Display_Entry_mode_set:	;Increment Data RAM by one address and shift cursor after displaying each character
			CLR P1.7		; |
			CLR P1.6		; |
			CLR P1.5		; |
			CLR P1.4		; | high nibble set			
			CALL neg_edge   ; High nibble sent

			CLR P1.7		; |
			SETB P1.6		; | 
			SETB P1.5		; |	
			CLR P1.4		; | 			
			CALL neg_edge   ; Low Nibble sent			

			CALL delay

		SETB RS; We can write data instead of commands now


	LCD_main:
		MOV R0, #30h; Start displaying from here
			lcd_LOOP: 
				MOV A, @R0;
				call sendCharacter
				inc R0;
				CJNE R0, #38h, lcd_loop;
				
END:
	JMP $; This is the end of the program
; column-scan subroutine

DISPLAY_RESET: ;Resetting the DDRAM pointer to the zero resets the Cursor
	CLR RS; Get into Command mode
	;0X80 + Address is the address, (0,0) is 0X00, (1,0) is 0X40. Coloumn increments with 1
	
	SETB P1.7 ;
	CLR P1.6;
	CLR P1.5;
	CLR P1.4;	
	CALL neg_edge; High Nibble sent 

	CLR P1.7 ;
	CLR P1.6;
	CLR P1.5;
	CLR P1.4;	
	CALL neg_edge; Low Nibble sent 

	CALL delay;

	SETB RS; Reset back to Data mode

	RET;


sendCharacter: ; Subroutine to send data to Character to LCD.
	MOV C, ACC.7		; |
	MOV P1.7, C		; |
	MOV C, ACC.6		; |
	MOV P1.6, C		; |
	MOV C, ACC.5		; |
	MOV P1.5, C		; |
	MOV C, ACC.4		; |
	MOV P1.4, C		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C		; |
	MOV C, ACC.2		; |
	MOV P1.6, C		; |
	MOV C, ACC.1		; |
	MOV P1.5, C		; |
	MOV C, ACC.0		; |
	MOV P1.4, C		; | low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET

delay:	; Delay 
	MOV R6, #50
	DJNZ R6, $; 
	RET

delay_long:
		loop1_:	MOV R6, #20; Variable for loop2 Should be 
		loop2_:	MOV R7, #250 ; Variable for loop 3, should be 1000
			loop3_: 	DJNZ R7, loop3_;	Stay here till R7 does not become zero
		DJNZ R6, loop2_;	
		RET; 
neg_edge: 
	SETB E;
	CLR E;
	RET; 

NUMS: 
	DB '0','1','2','3', '4', '5', '6', '7', '8', '9';