TITLE Project 6     (Proj6_willge.asm)

; Author: Genevieve Will
; Last Modified: 12/5/2021
; OSU email address: willge@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                 Due Date: 12/5/2021
; Description: Program that prompts user for 10 signed numbers, then displays the numbers, sum and average 
;				as well as intro message and instructions and a goodbye message. 
;				Program includes macros mGetString that takes user input and reads it as a string value. 
;				Includes macro mDisplayString that displays string at given memory location
;				Includes procedure of ReadVal that takes user input using mGetString macro and converts input 
;				from string to an integer value after validating user input. 
;				Includes procedure WriteVal that converts integer value to a string of ascii digits and uses
;				mDisplayString to display numeric value. 
;				Includes displayArray procedure to display array of numbers given using WriteVal procedure
;				Includes sumArray procedure to calculate sum and average and displays them using WriteVal procedure.


INCLUDE Irvine32.inc

; Macro that prompts user to give a number, then reads it as a string
; preconditions: none
; postconditions: ecx, edx are changed
; receives: prompt, inputString
; returns: 
mGetString	MACRO	prompt, inputString		
	push	ecx
	push	edx
	
	mDisplayString prompt
	mov		edx, inputString								; move destination string to edx
	mov		ecx, 300										; size of inputString
	call	ReadString										; read the string user gives
	
	pop		edx					
	pop		ecx
ENDM


; Macro to display string located in specified memory address
; preconditions: stringLocation is passed
; postcondition: edx is changed
; receives: stringLocation
; returns: 
mDisplayString	MACRO	stringLocation
	push	edx
	
	mov		edx, stringLocation
	call	WriteString
	
	pop		edx
ENDM



.data

	intro1			BYTE		"Programming Assignment 6: String Primitives and Macros!", 0
	intro2			BYTE		"Written by: Genevieve Will", 0
	instruct1		BYTE		"Please provide 10 signed decimal integers", 0
	instruct2		BYTE		"Each number needs to be small enough to fit inside a 32 bit register. After you have finished ", 0
	instruct3		BYTE		"inputting the numbers, a list of the integers, their sum and their average number will be displayed", 0
	numPrompt		BYTE		"Please enter a signed number: ", 0
	error			BYTE		"ERROR: You did not enter a signed integer number or your number was too big.", 0
	arrayDisplay		BYTE		"You entered the following numbers:", 0
	sumDisplay		BYTE		"The sum of these numbers is: ", 0
	avgDisplay		BYTE		"The average is: ", 0
	goodbyeMsg		BYTE		"Thanks for visiting, see you soon!", 0
	spaces			BYTE		"  ", 0
	input			BYTE		300 DUP(0)       
	array			SDWORD		10	DUP(?)
	sum			SDWORD		?       
	average			SDWORD		? 
	output			byte		10 DUP(0)		
	
.code
main PROC
	;introduction
		push	OFFSET	intro1
		push	OFFSET	intro2
		push	OFFSET	instruct1
		push	OFFSET	instruct2
		push	OFFSET	instruct3
		call	introduction
								
		mov		edi, OFFSET array							;the address of the array
		mov		ecx, 10										;counter for input loop

	;loop for getting user input	
_gettingNumbers:
			push	OFFSET error							;error message
			push	OFFSET numPrompt						;prompt string
			push	edi
			push	OFFSET input							;input string
			call	ReadVal
			add		edi, 4
			loop	_gettingNumbers
	
		;display  the array
		push	OFFSET spaces
		push	OFFSET output
		push	OFFSET arrayDisplay
		push	OFFSET array
		call	displayArray

		;display the sum of the array and average
		push	OFFSET output
		push	OFFSET avgDisplay	
		push	OFFSET sumDisplay
		push	OFFSET array
		call	sumArray

		;display goodbye message
		push	OFFSET	goodbyeMsg
		call	goodbye

	exit	; exit to operating system
main ENDP


; Procedure to introduce the program
; preconditions: Strings for introduction and instructions are passed
; postconditions: edx is changed
; recieves: Five strings
; returns: 
introduction PROC

		push	ebp
		mov		ebp, esp

		mDisplayString [ebp + 24]							;display title of program
		call	CrLf
		mDisplayString [ebp + 20]							;display written by
		call	CrLf
		mDisplayString [ebp + 16]							;display instructions for program
		call	CrLf
		mDisplayString [ebp + 12]							;display further instructions for program
		call	CrLf
		mDisplayString [ebp + 8]							;display more instructions for program
		call	CrLf
		call	CrLf

		pop		ebp
		ret		24
introduction ENDP



; Procedure to recieve the input of numbers in string form from users,
; then converts string to numeric value
; preconditions: strings for error and prompt and arrays to hold strings  are passed
; postconditions: edx, eax, ebx, ecx, ebp, edi are changed
; receives: error message, output, prompt, array, input
; returns: the output 
ReadVal PROC
		push	ebp
		mov		ebp, esp
		push	ecx

_getValue:
		mGetString [ebp + 16], [ebp + 8]					;call mGetString macro passing numPrompt and input string

		mov		esi, [ebp + 8]
		mov		eax, 0				
		mov		ebx, 10					
		mov		ecx, 0										;total number
		mov		edx, 0										;number initialize
		cld

_validate:
		lodsb
		cmp		al, 0										;check for end of string
		je		_endOfInput
		cmp		al, 45										;check for negative in string
		je		_negValidate
		cmp		al, 43
		je		_posValidate
		cmp		al, 48										;check if below 48 for 0
		jl		_error
		cmp		al, 57										;check if above 57 for 9
		jg		_error
		inc		ecx
		jmp		_validate

_posValidate:
		lodsb
		cmp		al, 0										;check for end of string
		je		_posendOfInput
		cmp		al, 48										;check if below 48 for 0
		jl		_error
		cmp		al, 57										;check if above 57 for 9
		jg		_error
_posValidate1:
		inc		ecx
		jmp		_posValidate

_posEndOfInput:
		cmp		ecx, 10										;check if number too large
		jg		_error
		cmp		ecx, 0										;check if no value was entered
		je		_error
		mov		esi, [ebp + 8]
		mov		eax, 0
		lodsb
		
_posStringToInt:
		lodsb
		cmp		al, 0										;the string is in the end or not
		je		_finished
		sub		al, 48
		push	eax
		mov		eax, edx
		mov		ebx, 10
		imul	ebx
		jc		_pop				
		mov		edx, eax
		pop		eax
		add		edx, eax
		jc		_error										;check for overflow
		jnc		_posStringToInt
		
_endOfInput:
		cmp		ecx, 10										;check if number too large
		jg		_error
		cmp		ecx, 0										;check if no value was entered
		je		_error
		mov		esi, [ebp + 8]
		mov		eax, 0
		
_stringToInt:
		lodsb	
		cmp		al, 0										;the string is in the end or not
		je		_finished
		sub		al, 48
		push	eax
		mov		eax, edx
		mov		ebx, 10
		imul	ebx
		jc		_pop				
		mov		edx, eax
		pop		eax
		add		edx, eax
		jc		_error										;check for overflow
		jnc		_stringToInt

_negValidate:
		lodsb
		cmp		al, 0										;check for end of string
		je		_negEndOfInput
		cmp		al, 48										;check if below 48 for 0
		jl		_error
		cmp		al, 57										;check if above 57 for 9
		jg		_error
		inc		ecx
		jmp		_negValidate

_negEndOfInput:
		cmp		ecx, 10										;check if number too large
		jg		_error
		cmp		ecx, 0										;check if no value was entered
		je		_error
		mov		esi, [ebp + 8]
		mov		eax, 0
		lodsb

_negative:
		lodsb
		cmp		al, 0										;check if end of string
		je		_finishedNeg
		sub		al, 48

		push	eax
		mov		eax, edx
		mov		ebx, 10
		imul	ebx
		jc		_pop						
		mov		edx, eax
		pop		eax
		add		edx, eax
		jc		_error										;check for overflow
		jnc		_negative
		
_pop:
		pop		eax

_error:
		push	edx
		mDisplayString [ebp +20]							;error message
		call	CrLf
		pop		edx
		jmp		_getValue

_finished:		
		mov		ebx, [ebp + 12]
		mov		[ebx], edx
		pop		ecx
		pop		ebp
		ret		16

_finishedNeg:
		neg		edx
		mov		ebx, [ebp + 12]
		mov		[ebx], edx
		pop		ecx
		pop		ebp
		ret		16
ReadVal ENDP


; introduction: accept a 32 bit signed int and display the corresponding ASCII representation on the console
; preconditions: number string to be converted is passed
; postconditions: ebp, eax, ebx, ecx, edx are changed
; receives: number, output string
; returns: none
WriteVal PROC
		push	ebp						
		mov		ebp, esp					
		pushad							
										
		mov		eax, [ebp+12]								;number
		mov		edi, [ebp+8]								;output string	
		mov		ecx, 0	
		cmp		eax, 0
		jl		_neg
		jmp		_convertString

_neg:
		neg		eax
		push	edx
		mov		edx, OFFSET 45								
		push	edx
		mDisplayString esp									;displays - before negative numbers
		pop		edx
		pop		edx		

_convertString:
			mov		edx, 0	
			mov		ebx, 10
			div		ebx
			mov		ebx, edx
			add		ebx, 48									; transfer to ascii
			push	ebx
			inc		ecx
			cmp		eax, 0
			je		_complete
			jmp		_convertString
		
_complete:
		pop		eax
		stosb							
		dec		ecx
		cmp		ecx, 0
		je		_display
		jmp		_complete

_display:
		mov		eax, 0
		stosb												;add 0 to the end of the string
		mov edx, [ebp+8]				
		mDisplayString edx

		popad												;restore all registers
		pop ebp												;restore stack
		ret 8 					
WriteVal ENDP


; Procedure to display the array of numbers that were entered
; preconditions: array to be displayed and intro string is passed
; postconditions: edx, esi ebx, eax, ecx
; receives: the array to be displayed
; returns: none
displayArray PROC
		push	ebp
		mov		ebp,esp
		mov		edx, [ebp + 12]								;arrayDisplay  string
		mov		esi, [ebp + 8]								;the address of the first element in the array
		mov		ecx, 10										;the numbers in array
		
		call	CrLf
		mDisplayString	edx									;display array intro string
		call	CrLf

_displayNum:
		mov		eax, [esi]
		push	eax
		push	[ebp + 16]
		call	WriteVal									;call WriteVal to convert to string and display
		mDisplayString	[ebp + 20]							;display spaces between numbers
		
		add		esi, 4
		loop	_displayNum


		call	CrLf
		pop		ebp
		ret		16
		
displayArray ENDP


; Procedure to sum the array and get the average number
; preconditions: array to be summed and intro strings are passed
; postconditions: ebp, eax, ebx, ecx, edx, esi are changed
; receives: number array, output string
; returns: sum and average
sumArray PROC
		push	ebp
		mov		ebp,esp
		mov		edx, [ebp + 12]								;sumDisplay  string
		mov		esi, [ebp + 8]								;the address of the first element in the array
		mov		ecx, 10										;the numbers in the array
		mov		eax, 0

		mDisplayString	edx									;display string for sum intro

_summing:
			mov		ebx, [esi]								;move value in array to ebx
			add		eax, ebx								;add value
			add		esi, 4									;move to next value in array
			loop	_summing

	;Show Sum value
		push	eax
		push	[ebp + 20]
		call	WriteVal									;display sum value
		call	CrLf
		cmp		eax, 0
		jl		_negSum

	;Show average value
		mov		edx, [ebp + 16]
		mDisplayString edx									;display string for average intro
		mov		edx, 0
		mov		ebx, 10
		div		ebx											;divide by 10 for average

		push	eax
		push	[ebp + 20]
		call	WriteVal									;display average value
		call	CrLf
		jmp		_end

_negSum:
		neg		eax
		mov		edx, [ebp + 16]
		mDisplayString edx									;dsiplay string for average intro
		mov		edx, 0
		mov		ebx, 10
		div		ebx
		neg		eax
		push	eax
		push	[ebp + 20]
		call	WriteVal									;display average value
		call	CrLf

_end:
		pop		ebp
		ret		16
sumArray ENDP

; Procedure to display goodbye message
; preconditions: string is passed
; postconditions: ebp
; receives: goodbye string
; returns: none
goodbye PROC
		push	ebp
		mov		ebp,esp

		call	CrLf
		mDisplayString	[ebp + 8]							;display goodbye message		
		call	CrLf

		pop		ebp
		ret		4
goodbye ENDP




END main
