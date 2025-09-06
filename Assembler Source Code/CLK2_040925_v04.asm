; V04
;4/9/25   22:00
;
;  This version does the following:
;
;- CLK24 S .... (Setting of the clock) works. However, exit to DOS crashes and BOOTs :(
;- Detection of the clock, when once set (checked by looking at the BCD values @ 584F)
;- CLK24 Detects the clock when it is set
;- CLK24 O (Clock off) works. After stopping, CLK24 reports that the clock is not set. The clock needs to be set again.
;- CLK24 T (copy clock time to sw clock) results in error 2BH, but does copy the date & time to memory

;  Year before 79 is 21st century. 79~99 is 20th century. Model II was introduced in 1979.


;########################################################################
;#
;#	CLK2/CMD
;#	For setting and reading Dallas Semiconductor DS 1216E Smart Watch
;#	and DS1315 Phantom Clock Chip.
;#  Target system: TRS-80 Model II (and similar) under LS-DOS6.3
;#
;########################################################################
; Compiled with ZMAC     (http://48k.ca/zmac.html
;########################################################################
;	Syntax:
;	CLK2<CR>	 will show time and date when set
;	CLK2 T<CR>	 will copy the Clock time and date to the system time and date
;	CLK2 O<CR>	 turns the Clock off, for long term storage
;	CLK2 S hhmmssMMDDYYdm<CR> will set the time, date and day of the week
;	Where:	hh=Hours (00-23/00-12), mm=Minutes (00-59), ss=Seconds (00-59)
;			MM=Months (01-12), DD=Day of month (01-31), YY=Year (00-99)
;			d=Day of week (1=Sunday, 7=Saturday)
;			m=Mode: "A" = AM, "P" = PM, omit for 24 hour format.',CR
;			Year >= 79 results in 19xx
;			Year <79 results in 20xx
;
;########################################################################
;
;	'Copyright (C) 1987 by Duane M. Saylor'
;	'Copyright (C) 2025 by Ruud Broers for Model II support'
;   'Based on work by Duane S Saylor for Model 1, III and 4(P)
;
TRUE	EQU	-1
FALSE	EQU	0

;	Operating System equates
;
@DATE	EQU	12H
@TIME	EQU	13H
@FLAGS	EQU	65H
@DSPLY	EQU	10		;SuperVisory Call
;
;	Miscellaneous constants
;
LF	EQU	0AH		;Line Feed
CR	EQU	0DH		;Carriage Return
;
RSTPIN	EQU	00010000B	;Ignore reset pin (Pin 1 of SMW)
OSOFF	EQU	00100000B	;Bit 5 is high if not set. Oscillator OFF
OSCON	EQU	NOT(OSOFF) AND 0FFH			;  Oscillator ON
OSCRST	EQU	00110000B	;Turn watch off mask. Stops oscillator.
;
SWAP	MACRO			;Exchange nibbles
	RLCA
	RLCA
	RLCA
	RLCA
	ENDM
;
	ORG	5200H
;
START
	LD	(STACK$),SP	;Save the stack pointer
	LD	SP,STACK$	;Set up our own stack.
	LD	(BUFPTR),HL	;Save pointer to input buffer
SEARCH	CALL	GETCLK		;Get all of the info from the
				;SmartWatch
	JR	NZ,FOUND	;If SmartWatch found
	LD	HL,NOSWPR	;No SmartWatch is present
	JR	MSGEXT		;in the system
;
FOUND
	LD	C,A		;Save the watch status code.
	LD	HL,(BUFPTR)	;Get input pointer
	LD	A,(HL)		;Get command
	INC	HL		;Advance pointer
	AND	5FH		;Make it upper case.
	CP	'S'		;Command to set the
	JR	Z,SETTIM	;SmartWatch?
	LD	B,A		;Save the command for a while
	LD	A,C		;Get the status code
				;If the command was not the set command
	LD	HL,SWNSET	;then check to set that the
	CP	OSCON		;SmartWatch is already set, if
	JR	Z,MSGEXT	;if it is no set, then print an error
				;message, then the help message.
	LD	A,B		;Get back the users command.
	CP	'T'		;Set and show the time
	JR	Z,TELTIM	;Jump if yes
	CP	'O'		;Turn the SmartWatch off?
	JR	Z,TURNOFF	;Jump if yes
	CP	CR		;
	JR	Z,JUSTIM	;No parameter; Go show time, then back to DOS
HELP				;Print Help.
	LD	HL,HLPMSG	;Help message
MSGEXT
	LD	A,@DSPLY	;Print the string pointed to by HL
	RST	28H
TODOS	LD	SP,(STACK$)	; Restore stack
	LD	HL,0		;Allow to run from JCL
	RET
;---------------------------------------------------------------------
;
;Tell the Time and Set System Time
;
;---------------------------------------------------------------------
TELTIM	CALL	GETCLK		;Get the info from the SmartWatch
	CALL	SETDOS		;copy time/date to DOS fields
	JR	PRTTIM
JUSTIM	CALL	GETCLK
PRTTIM	CALL	ASCTIM		;Print out the time
	JP	MSGEXT		;on the way back to the
				;operating system.
;---------------------------------------------------------------------
;
;Turn off, the SmartWatch for long term storage.
;
;---------------------------------------------------------------------
TURNOFF	LD	A,(DAY)
	OR	OSCRST		;Turn the SmartWatch off
	LD	(DAY),A
	CALL	PUTCLK		;Write the info to the SmartWatch
	LD	HL,SWSOFF	;The SmartWatch is now off
	JP	MSGEXT

;---------------------------------------------------------------------
;
;	Get time from input buffer
;	Convert from ASCII to BCD and save in memory
;
;---------------------------------------------------------------------
SETTIM
	INC	HL		;Skip space
	CALL	ASCBCD		;Hours
	CP	23H+1		;Check for valid range
	JP	NC,HELP		;(We'll check 12 hours latter).
	LD	(HOUR),A
	CALL	ASCBCD		;Minutes
	CP	59H+1
	JP	NC,HELP
	LD	(MINUTE),A
	CALL	ASCBCD		;Seconds
	CP	59H+1
	JP	NC,HELP
	LD	(SECOND),A
	CALL	ASCBCD		;Month
	CP	12H+1
	JP	NC,HELP
	LD	(MONTH),A
	CALL	ASCBCD		;Day of month
	CP	31H+1
	JP	NC,HELP
	LD	(DATE),A
	CALL	ASCBCD		;Year
	CP	99H+1
	JP	NC,HELP
	LD	(YEAR),A
	LD	A,(HL)		;Days
	INC	HL
	CALL	ASCBIN		;Convert ASCII to Binary
	CP	7+1
	JP	NC,HELP
	OR	RSTPIN		;Ignore the reset pin (Pin #1)
	LD	(DAY),A
;
;AM-PM/12/24/ MODE
;
;	Bit 7 of the hours register is defined as the 12 or 24
;hour mode select bit.  When high, the 12 hour mode is selected.
;In the 12 hour mode, bit 5 is the AM/PM bit with logic high
;being PM.  In the 24 hour mode, bit 5 is the second 10 hours
;bit (00-23 hours).
;
;
	LD	A,(HL)		;'A'm, 'P'm or 24-hour
	AND	5FH		;Make it upper case.
	CP	0DH
	JR	Z,IS24HR	;Jump if it is 24 hour time.
	CP	'A'		;AM?
	JR	NZ,TRYPM
	LD	C,80H		;Yes: Set the 12-hour mode bit
	JR	IS12HR
;
TRYPM	CP	'P'		;PM?
	JP	NZ,HELP
	LD	C,0A0H		;Yes: Set the 12-hour, and the
				;PM mode bits.
IS12HR	LD	A,(HOUR)	;Now we'll check the 12 hour
	CP	12H+1		;time
	JP	NC,HELP
	OR	C		;Put the mode bits, and the hours
	LD	(HOUR),A 	;together, and save them.
;
IS24HR	CALL	PUTCLK		;Write all the info to the SmartWatch
	JP	TELTIM

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
;	Convert SmartWatch BCD info to ASCII time.
;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ASCTIM	LD	HL,TIMSTR$	;Point to the ASCII time.
	PUSH	HL		;Save buffer pointer
	LD	A,(DAY)
	AND	07H
	DEC	A
	LD	E,A
	LD	D,00H
	LD	HL,DAYTBL	;Day of Week Index Table
	ADD	HL,DE		;Table + 3 * (HL) = day index
	ADD	HL,DE
	ADD	HL,DE
	LD	C,(HL)		;Get length of day name
	LD	B,0		;BC is now length of day name
	INC	HL		;Advance to LSB of day name address
	LD	A,(HL)		;Get LSB of day name address
	INC	HL
	LD	H,(HL)		;Get MSB of day name address
	LD	L,A		;LSB of day name address to L
	POP	DE
	LDIR
	EX	DE,HL
	LD	(HL),','
	INC	HL
	LD	(HL),' '
	INC	HL
;
	PUSH	HL
	LD	A,(MONTH)
	CALL	BCD2BIN
	DEC	A
	LD	E,A
	LD	D,0
	LD	HL,MONTBL
	ADD	HL,DE
	ADD	HL,DE
	ADD	HL,DE
	LD	C,(HL)
	LD	B,0
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	POP	DE
	LDIR
	EX	DE,HL
	LD	(HL),' '
	INC	HL
;
	LD	A,(DATE)
	CALL	BCDASC
	LD	(HL),','
	INC	HL
	LD	(HL),' '
	INC	HL
	LD	A,(YEAR)	;get year to check if <79 (introduction of Model II)
	CP	079H		;in BCD
	JR	C,CENT20
CENT19	LD	(HL),'1'
	INC	HL
	LD	(HL),'9'
	JR	CENT
CENT20	LD	(HL),'2'
	INC	HL
	LD	(HL),'0'
CENT	INC	HL
;	LD	A,(YEAR)
	CALL	BCDASC
	LD	(HL),' '
	INC	HL
;
	LD	A,(HOUR)
	BIT	7,A		;12 or 24 time?
	JR	Z,MILTIM	;Jump if using 24 hour time.
;
	AND	1FH		;Strip unneeded bits, 12 hr mode.
;
MILTIM	AND	3FH		;Strip unneeded bits, 24 hr mode.
	CALL	BCDASC
	LD	(HL),':'
	INC	HL
	LD	A,(MINUTE)
	CALL	BCDASC
	LD	(HL),':'
	INC	HL
	LD	A,(SECOND)
	CALL	BCDASC
	LD	(HL),':'
	INC	HL
	LD	A,(FRACT)
	CALL	BCDASC
	LD	(HL),' '
	INC	HL
;
	LD	A,(HOUR)	;If in 24 mode
	BIT	7,A		;Then don't print
	JR	Z,NOAMPM
	LD	(HL),'A'	;Assume it's AM
	BIT	5,A		;Find if it is really
	JR	Z,WASAM		;AM.
	LD	(HL),'P'	;No it is PM
;
WASAM	INC	HL
	LD	(HL),'M'
	INC	HL
	LD	(HL),' '
	INC	HL
;
NOAMPM	LD	(HL),CR		;End marker for string print
	LD	HL,TIMSTR$	;Point to start of string
	RET			;Then back to caller
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
; Get the clock data and store in buffer
;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
GETCLK	CALL	ACCESS		;Select the clock, get 8
	LD	DE,FRACT	;bytes of data
	LD	B,8		;Number of bytes to read
GETLP	PUSH	BC		;Save count on stack
	CALL	RDCLK		;Read byte from SmartWatch
	LD	(DE),A		;Save it in the buffer
	INC	DE		;Advance pointer
	POP	BC		;Get count from stack
	DJNZ	GETLP		;Until done
	CALL	GETRAM		;Bring back the RAM
	LD	A,(DAY)		;Make sure there really is a
				;SmartWatch present.
	LD	HL,FRACT	;Point to BCD time.
	CP	0FFH		;All of the bits will be the same
	RET	Z		;if there is no SmartWatch.
	OR	A		;Return with the 'Z' flag set
	RET	Z		;If no SmartWatch is found.
;
	AND	OSOFF		;See if the SmartWatch has been set,
	CPL			;'0DFH' means that the SmartWatch is
	OR	A		;present but not set.
				;'0FFH', and the 'Z' flag clear, means
				;the SmartWatch is present and set.
	RET
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
; Put the clock data from the memory buffer to the SmartWatch
;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
PUTCLK
	CALL	ACCESS		;Select the SmartWatch
	LD	DE,FRACT	;Point to memory buffer
	LD	B,8		;Bytes to write to SmartWatch
PUTLP	PUSH	BC		;Save count on stack
	LD	A,(DE)		;Get byte
	CALL	WRTCLK		;Write it to SmartWatch
	INC	DE		;  and advance pointer
	POP	BC		;Get count from stack
	DJNZ	PUTLP		;Until done
	CALL	GETRAM		;Bring back the RAM
	RET

;************************************************************************
;
;	Enable SmartWatch for Reading or Writing
;
;************************************************************************
ACCESS	CALL	GETROM		;Bring the ROM into the map
;
;	Reset the SmartWatch by clocking through 65 single-bit
;	reads to flush any pending transfers.
;
	LD	HL,(BASE)	;Get Base address of rom
	LD	BC,4		;Point to address
	ADD	HL,BC		;  for bit reads
	LD	B,65
RESET	LD	A,(HL)
	DJNZ	RESET
;
;	Next, 64 consecutive write cycles are executed.  The 64
;	write cycles are used only to gain access to the SmartWatch.
;
	LD	B,02H		;Make two passes
UNLOCK	PUSH	BC
	LD	A,0C5H		;Begin the unlock sequence.
	CALL	WRTCLK		;The odds of this pattern being
	LD	A,3AH		;accidentally duplicated and
	CALL	WRTCLK		;causing inadvertent entry to
	LD	A,0A3H		;the SmartWatch is less than
	CALL	WRTCLK		;1 in 10^19
	LD	A,5CH
	CALL	WRTCLK
	POP	BC
	DJNZ	UNLOCK
	RET

;************************************************************************
;
;   Write data in A to the SmartWatch
;
;************************************************************************
WRTCLK
	EXX			;Save primary registers
	LD	HL,(BASE)	;Get Base address of SmartWatch
	LD	D,H		;and move it to DE
	LD	E,L
	INC	DE		;Point to location for write ones
	LD	B,08H		;We must deal with 8 bits at a time
	LD	C,A		;Move byte to C
RTCWR	RRC	C		;Is this bit a one or zero?
	JR	C,RTCWR1	;If bit is a 1
	LD	A,(HL)		;Write a zero by reading.
	JR	RTCWRL
;
RTCWR1	LD	A,(DE)		;Write a one by reading.
RTCWRL	DJNZ	RTCWR		;Until all 8 bits are output
	EXX			;Restore primary registers
	RET
;************************************************************************
;
;	Read data 1 bit at a time from the SmartWatch,
;	assemble data in A.
;
;************************************************************************
RDCLK
	EXX			;Save primary registers
	LD	HL,(BASE)	;Get Base address of SmartWatch
	LD	BC,4		;Offset to read bit address
	ADD	HL,BC		;HL now points to Read Bit address
	XOR	A		;Set all bits to zero.
	LD	B,08H		;8 bits make one byte
RTCRD	LD	C,(HL)
	BIT	0,C
	JR	Z,RDBITL	;Jump if the bit is
				;already zero.
	SET	0,A		;Set the bit.
RDBITL	RRCA			;Rotate right one bit.
	DJNZ	RTCRD		;Do all of the bits.
	EXX			;Restore primary registers
	RET

;************************************************************************
;
;	Bring the ROM into the memory map for access to SmartWatch
;
;************************************************************************
GETROM
	LD	A,@FLAGS
	RST	28H
	LD	A,(IY+14)	;Get opreg$
	LD	(OPREG$),A	;Save for later
	DI			;Can't be interrupted

	LD	A,00H		;To disable software RTC interrupt
	OUT	(0FFH),A
	LD	A,01H		;To ENABLE Model II boot rom
	OUT	(0F9H),A

	;
	RET
;************************************************************************
;
;	Restore RAM to the memory map for TRSDOS and LS-DOS access
;
;************************************************************************
GETRAM
;
	XOR	A		;Zero to DISABLE Model II boot ROM
	OUT	(0F9H),A	;and put RAM back
;	?? Is re-enabling the software RTC interrupt needed ??	

	EI			;Allow interrupts again
	RET

;************************************************************************
;
;	The following routine will set the time in TRSDOS or LS-DOS
;	operating system.
;
;************************************************************************
SETDOS
	LD	HL,TIMBUF$	;Location for time string
	LD	A,@TIME
	RST	28H
	PUSH	DE		;Pointer to system TIME$
	POP	IY
	LD	A,(HOUR)
	CALL	BCD2BIN
	LD	(IY+2),A	;Set new system hours
	LD	A,(MINUTE)
	CALL	BCD2BIN
	LD	(IY+1),A	;Set new system minutes
	LD	A,(SECOND)
	CALL	BCD2BIN
	LD	(IY),A		;Set new system seconds
;
	LD	HL,DATBUF$	;Location for date string
	LD	A,@DATE
	RST	28H
	PUSH	DE		;Pointer to system DATE$
	POP	IY
	LD	A,(MONTH)
	CALL	BCD2BIN
	LD	(IY+2),A	;Set new system month
	LD	A,(DATE)
	CALL	BCD2BIN
	LD	(IY+1),A	;Set new sytem date
	LD	A,(YEAR)
	CALL	BCD2BIN
	LD	(IY),A		;Set new sytem year
	RET

;***********************************************************************
;
;	Get time from input buffer and store in buffer
;	Convert from 2 ASCII digits to BCD byte.
;
;***********************************************************************
ASCBCD	LD	A,(HL)
	INC	HL
	SUB	30H		;Remove the ASCII bias
	CP	LF		;0->9?
	JP	NC,HELP		;If it is not, the print
				;the help message.
	SWAP			;Swap the nibbles
	AND	0F0H		;and do the other nibble
	LD	C,A		;Save this binary nibble
	LD	A,(HL)		;Do the same as above
	INC	HL
	SUB	30H
	CP	LF
	JP	NC,HELP
	OR	C		;Make the tow BCD digits,
				;one 8 bit binary value.
	RET
;***********************************************************************
;
;		BCD to binary converter
;
;This routine will convert an 8 bit BCD number (0-99) to binary.
;The routine returns with the binary number in the 'A' register.
;
;***********************************************************************
BCD2BIN	LD	E,A		;Save original byte
	AND	0FH
	LD	D,A		;Save low nibble.
	LD	A,E
	AND	0F0H		;Mask LSN
	RRCA			;x2
	LD	E,A
	RRCA			;x4
	RRCA			;x8
	ADD	A,E		;x10
	ADD	A,D		;Low nibble
	RET

;*****************************************************************
;
;	Convert BCD number to ASCII
;
;*****************************************************************
BCDASC	PUSH	AF
	SWAP			;Do the upper nibble first
	AND	0FH
	OR	30H		;Add in the ASCII bias.
	LD	(HL),A
	INC	HL
;
	POP	AF		;Now the lower nibble
	AND	0FH
	OR	30H
	LD	(HL),A
	INC	HL
	RET
;*****************************************************************
;
;	Convert ASCII number to Binary
;
;*****************************************************************
ASCBIN	SUB	30H
	JR	C,ASCBIN1
	CP	0AH
	RET	C
	SUB	07H
	CP	0AH
	JR	C,ASCBIN1
	CP	10H
	JR	NC,ASCBIN1
	RET
;
ASCBIN1	LD	A,' '
	RET

;
SWSOFF	DB	'* The SmartWatch is now turned off. *',CR
;
NOSWPR	DB	'* SmartWatch NOT found. *',CR
;
SWNSET	DB	'* The SmartWatch is not set. *',CR
;
HLPMSG	;	 1...5....1....5....2....5....3....5....4....5....5....5....6....5....7....5....8
	DB	'This program allows setting and reading the Clock of the Dallas Semiconductor ',LF
	DB	'DS1315 Phantom Clock and DS 1216E SmartWatch.',LF
;	DB	'in a TRS-80 Model II.',LF
	DB	'CLK2 T <CR> will copy the Clock time and date to the system date and time.',LF
	DB	'CLK2 O <CR> turns the Clock off, for long term storage.',LF
	DB	'CLK2 S hhmmssMMDDYYdm<CR> will set the time, date and day of the Clock.',LF,LF
	DB	'Where:',LF
	DB	'hh=Hours (00-23/00-12), mm=Minutes (00-59), ss=Seconds (00-59),',LF
	DB	'MM=Months (01-12), DD=Day of month (01-31), YY=Year (00-99),',LF
	DB	'd=Day of week (1=Sunday, 7=Saturday),',LF
	DB	'm=Mode: "A" = AM, "P" = PM, omit for 24 hour format.',CR
;
DAYTBL	DB	MON$-SUN$
	DW	SUN$
	DB	TUE$-MON$
	DW	MON$
	DB	WED$-TUE$
	DW	TUE$
	DB	THU$-WED$
	DW	WED$
	DB	FRI$-THU$
	DW	THU$
	DB	SAT$-FRI$
	DW	FRI$
	DB	DAYEND$-SAT$
	DW	SAT$
SUN$	DB	'Sunday'
MON$	DB	'Monday'
TUE$	DB	'Tuesday'
WED$	DB	'Wednesday'
THU$	DB	'Thursday'
FRI$	DB	'Friday'
SAT$	DB	'Saturday'
DAYEND$	EQU	$
;
MONTBL	DB	FEB$-JAN$
	DW	JAN$
	DB	MAR$-FEB$
	DW	FEB$
	DB	APR$-MAR$
	DW	MAR$
	DB	MAY$-APR$
	DW	APR$
	DB	JUN$-MAY$
	DW	MAY$
	DB	JUL$-JUN$
	DW	JUN$
	DB	AUG$-JUL$
	DW	JUL$
	DB	SEP$-AUG$
	DW	AUG$
	DB	OCT$-SEP$
	DW	SEP$
	DB	NOV$-OCT$
	DW	OCT$
	DB	DEC$-NOV$
	DW	NOV$
	DB	MONEND$-DEC$
	DW	DEC$
;
JAN$	DB	'January'
FEB$	DB	'February'
MAR$	DB	'March'
APR$	DB	'April'
MAY$	DB	'May'
JUN$	DB	'June'
JUL$	DB	'July'
AUG$	DB	'August'
SEP$	DB	'September'
OCT$	DB	'October'
NOV$	DB	'November'
DEC$	DB	'December'
MONEND$	EQU	$
;
BUFPTR	DW	0
BASE	DW	0000H
OPREG$	DB	00
FRACT	DB	0FFH	;values are filled in during seeking for the clock
SECOND	DB	0FFH	;When no clock present, values remain all 0FFH or become 00H
MINUTE	DB	0FFH
HOUR	DB	0FFH
DAY	DB	0FFH
DATE	DB	0FFH
MONTH	DB	0FFH
YEAR	DB	0FFH
TIMBUF$	DB	'hh:mm:ss'
DATBUF$	DB	'MM/DD/YY'
FREMSG	DB	'Copyright 1987 Duane M. Saylor',LF
	DB	'Copyright 2025, Ruud Broers',CR
	DB	'Version 04/09/2025',CR
TIMSTR$	DC	128,'S'
STACK$	DS	2
LSTADR	EQU	$
	END	START

