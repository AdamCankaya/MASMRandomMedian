TITLE Adam's Awesome Array Sorting Program			(Homework5.asm)

; Program Description:  A program that requests the user enter an integer [10,200] and 
;						then generates that number of random terms, stores them in an array,
;						displays them, sorts them in descending order, calculates and displays
;						the median value and then displays the sorted list.
; Author: Adam Cankaya
; Date Due:  Mar 2, 2014
; Last Modification Date: Feb 28, 2014

 INCLUDE Irvine32.inc
 
 ; CONSTANTS 
 	min		=	10	; lower limit for request
	max		=	200	; upper limit for request
	lo		=	100	; lower limit for random integer range
	hi		=	999	; upper limit for random integer range

 .data
 ; VARIABLES
	; Arrays
		randArray	DWORD	max		DUP(?)
		count		DWORD	0
		range		DWORD	0			; range used for RandomRange
		
	; User input
		buffer		BYTE	21	DUP(0)	; input buffer
		byteCount	DWORD	0			; holds counter
		userName	DWORD	0			; name entered by user
		request		DWORD	0			; number of terms user wants generated

	; Program output text
		intro_0		BYTE	"Hello ", 0
		intro_1		BYTE	"Welcome to Adam Cankaya's CS 271 Homework 5 program, written in MASM!", 0
		prompt_1	BYTE	"What is your name?", 0
		intro_2		BYTE	", nice to meet you.", 0
		intro_3		BYTE	"Enter an integer 10 to 200 inclusive and I will generate and sort that value of random numbers: ", 0
		intro_5		BYTE	"Here we go...", 0
		data_1		BYTE	"You entered: ", 0
		comma		BYTE	", ", 0
		theTab		BYTE	"     ", 0
		array_0		BYTE	"Array[", 0
		array_1		BYTE	"] = ", 0
		req_0		BYTE	"Request is: ", 0
		count_0		BYTE	"Count is: ", 0
		sort_00		BYTE	"Comparing ", 0
		and_0		BYTE	" and ", 0
		sort_0		BYTE	" >= ", 0
		sort_2		BYTE	" : exchanging", 0
		med_0		BYTE	"The median is: ", 0
		error_1		BYTE	"I'm sorry, you entered a number that isn't an integer between 10 and 200 inclusive. Please try again.", 0
		exit_0		BYTE	"Goodbye ", 0
		exit_1		BYTE	"Thanks for playing with me!", 0
		odd0		BYTE	"odd", 0
		even0		BYTE	"even", 0
		
		listTitleRand	BYTE	"The unsorted array of random numbers: ", 0	; title of random array
		listTitleSort	BYTE	"The sorted array of random numbers: ", 0	; title of sorted array

	; Loop and calculation variables

.code

main PROC
	; initializes random seed based on system clock
	call	Randomize
	
	; prints instructions, requests user name and greets them by name
	call	introduction		
	
	; requests user enter number of terms to generate
	push	OFFSET	request
	call	getData
	
	; fills array with random terms
	push	OFFSET randArray
	push	request
	call	fillArray
	
	; prints out all terms from random array
	push	OFFSET	randArray
	push	request
	push	OFFSET	listTitleRand
	call	displayList
	
	; sort array in descending order
	push	OFFSET	randArray
	push	request
	call	sortList

	; calculates and prints the median value
	push	OFFSET	randArray
	push	request
	call	displayMedian

	; prints out all terms from sorted array
	push	OFFSET	randArray
	push	request
	push	OFFSET	listTitleSort
	call	displayList

	; says goodbye to user by name
	call	farewell

	exit						; exit to operating system
main ENDP

; Procedure to ask user for their name and greet them using it
; receives: none
; returns: saves user name input to userName and prints greetings using user's name
; preconditions: global variables intro_0, intro_1, intro_2, prompt_1, userName, byteCount
; registers changed: edx, ecx
introduction	PROC
	; Display Program title and author's name
		mov		edx, OFFSET intro_1			
		call	WriteString
		call	CrLf

	; Prompt user to enter their name
		mov		edx, OFFSET prompt_1
		call	WriteString

	; Read in user's name
		mov		edx, OFFSET buffer
		mov		ecx, SIZEOF	buffer
		call	ReadString
		mov		userName, edx
		mov		byteCount, eax
	
	; Greet user using their name
		mov		edx, OFFSET intro_0
		call	WriteString			; print 'Hello'
		mov		edx, userName
		call	WriteString			; print user's name
		mov		edx, OFFSET intro_2
		call	WriteString
		call	CrLf

	ret
introduction	ENDP

; Procedure to ask user to enter an integer 10 to 200 inclusive
; receives: @request
; returns: sets request based on user input
; preconditions: global variables intro_3, error_1, request
; registers changed: edx, eax, ebx, ebp
getData		PROC
	push	ebp					; set up stack frame
	mov		ebp, esp

	startPrompt:
		; get an integer for <request>
		call	Crlf
		mov		ebx, [ebp+8]		; put @request into ebx
		mov		edx, OFFSET intro_3	; Prompt user to enter a number [10-200]
		call	WriteString
		call	ReadInt
		call	CrLf

		; Validate input is integer [10-200]
		cmp		eax, 10
		jl		Reprompt	; reprompt if < 10
		cmp		eax, 200
		jg		Reprompt	; reprompt if > 200

		mov		[ebx], eax	; else store user input at address in ebx
		pop		ebp
		ret		4

	Reprompt:
		mov		edx, OFFSET error_1
		call	WriteString
		call	Crlf
		jmp		startPrompt
getData		ENDP

; Procedure to generate random numbers and store them in an array
; Reference: Some code from Lecture 19 slides
; receives: request, @randArray
; returns:	fills <randArray> of size <count> with random terms
; preconditions: global variable request, randArray, count, range,
;				 Irvine library, global constants hi, lo
; registers changed: ecx, esi, eax, ebx, edi, ebp
fillArray		PROC

	mov		eax, hi
	sub		eax, lo			; set eax = hi - lo
	inc		eax				; set eax = hi - lo + 1
	mov		range, eax		; sets range = hi - lo + 1
	
	push	ebp				; set up stack frame
	mov		ebp, esp	
	mov		edi, [ebp+12]	; @randArray in edi
	mov		ecx, [ebp+8]	; value of request in ecx

	FillLoop:
		mov		eax, range
		call	RandomRange		; result in eax
		add		eax, lo			; add lo to result
		mov		[edi], eax		; puts result in edi
		add		edi, 4			; advances edi to next array entry

		loop FillLoop			; loops until count in ecx is zero

	pop		ebp
	ret		8
fillArray		ENDP

; Procedure to print out each term in an array of integers
; Reference: Some code from Lecture 20 slides
; receives: @list, request, @listTitle
; returns: prints out each term in array
; preconditions: global variables list, request, listTitle, theTab
; registers changed: ebp, esi, ecx, edx, eax, 
displayList		PROC
	push 	ebp
	mov		ebp, esp
	
	mov		esi, [ebp+16]	; @list in esi
	mov		ecx, [ebp+12]	; value of request in ecx
	mov		edx, [ebp+8]	; @listTitle in edx
	
	; Print list title in edx
	call	WriteString
	call	Crlf
	
	PrintListStart:
		mov		eax, [esi]
		call	WriteDec				; prints array value
		mov		edx, OFFSET theTab
		call	WriteString				; prints "     "
		add 	esi, 4 					; next element

		loop 	PrintListStart			; loops until count is dec to 0
	
		call	Crlf

		pop		ebp
		ret		12
displayList		ENDP

; Procedure to bubble sort an array in descending order
; Reference: Used code from Irvine Chapter 9.5
; receives: @randArray, request
; returns: sorts <randArray> descending
; preconditions: global variables randArray, request
; registers changed: ebp, esi, ecx, eax
sortList	PROC
	push 	ebp
	mov		ebp, esp
	mov		esi, [ebp+12]	; @randArray in esi
	mov		ecx, [ebp+8]	; value of request in ecx

	dec 	ecx 			; decrement count by 1
	
	L1:
		push 	ecx 			; save outer loop count
		mov 	esi, [ebp+12] 	; point to first value
		
	L2: 
		mov 	eax, [esi] 		; get array value
		cmp 	[esi+4], eax 	; compare a pair of values
		jl 		L3 				; if [ESI+4] < [ESI], no exchange
		xchg 	eax, [esi+4] 	; else exchange the pair	
		mov 	[esi], eax

	L3: 
		add 	esi, 4 			; move both pointers forward
		loop 	L2 				; inner loop
		pop 	ecx 			; retrieve outer loop count
		loop 	L1 				; else repeat outer loop
	
	L4:
		pop		ebp
		ret		8
sortList	ENDP

; Procedure to calculate and print the median value
; receives: @randArray, request
; returns: prints median value
; preconditions: global variables randArray, request, req_0, even0, odd0, med_0
; registers changed: ebp, esi, ecx, ebx, eax, edx
displayMedian PROC
	push 	ebp
	mov		ebp, esp
	mov		esi, [ebp+12]	; @randArray in esi
	mov		ecx, [ebp+8]	; value of request in ecx
	
	; Check if request is odd/even
	mov		ebx, 2
	cdq
	mov		eax, ecx
	cdq
	div		ebx				; divide request by 2
	cmp		edx, 0	
	jne		oddReq			; if rem != 0 then request is odd
			
	; request is even and median is average of two midpoints
	call	Crlf
	mov		edx, OFFSET req_0	; print "Request is: "
	call	WriteString
	mov		edx, OFFSET even0	; print "even"
	call	WriteString
	call	Crlf
	mov		edx, OFFSET med_0
	call	WriteString			; print "The median is: "
	
			mov		eax, [ebp+8]	; value of request in eax
			mov		ebx, 2
			cdq
			div		ebx				; eax = request / 2 rounded down
			mov		ebx, 4			; ebx = 4 bytes
			mul		ebx				; eax = 4 bytes * (request/2 rounded down)
			add		esi, eax
				
			; get second term of midpoint
			mov		ebx, [esi]
			mov		ecx, ebx		; get second value
				
			; get first term of midpoint
			sub		eax, 4			; move index back one
			sub		esi, 4
			mov		ebx, [esi]		; get first term value
			add		ecx, ebx		; add it to second term value

			; average the sum
			mov		eax, ecx
			mov		ebx, 2
			cdq
			div		ebx

	call	WriteDec			; print median value in eax
	call	Crlf
	call	Crlf
	
	pop ebp
	ret 8
	
	;else request is odd and median is midpoint
	oddReq:	
			call	Crlf
			mov		edx, OFFSET req_0	; print "Request is: "
			call	WriteString	
			mov		edx, OFFSET odd0	; print "odd"
			call	WriteString
			call	Crlf
		mov		edx, OFFSET med_0
		call	WriteString		; print "The median is: "
		
			mov		eax, [ebp+8]	; value of request in eax
			mov		ebx, 2
			cdq
			div		ebx				; eax = request / 2 rounded down
			mov		ebx, 4			; ebx = 4 bytes
			mul		ebx				; eax = 4 bytes * (request/2 rounded down)
			add		esi, eax		; advance array index

		mov     eax, [esi]			; get value of element in eax
		call	WriteDec			; print median value in eax
		call	Crlf
		call	Crlf

		pop	ebp
		ret 8
displayMedian ENDP

; Procedure to say goodbye to user by name
; receives: none
; returns: prints goodbye message
; preconditions: global variables exit_0, userName, comma, exit_1
; registers changed: edx
farewell		PROC
	; Display parting message that includes user's name
		call	CrLf
		call	CrLf
		mov		edx, OFFSET exit_0		
		call	WriteString
		mov		edx, userName
		call	WriteString
		mov		edx, OFFSET comma
		call	WriteString
		mov		edx, OFFSET exit_1
		call	WriteString
		call	CrLf
		call	CrLf
		call	WaitMsg
	ret
farewell		ENDP

END main