
; --- hardware.asm --------------------------------------------------------

INCLUDE	"inc/hardware.inc"
INCLUDE	"inc/vars.inc"

SECTION	"Character XY Movement Table",HOME[$00] ; $28, $00 - $27

;	X Val		Y Val
DB	$00,$10,	$00,$00	; $0000 Right
DB	$FF,$F0,	$00,$00	; $0004 Left
DB	$00,$00,	$00,$00 ; $0008 ( Empty )
DB	$00,$00,	$FF,$F0	; $000C Up
DB	$00,$0B,	$FF,$F5	; $0010 Up-Right
DB	$FF,$F5,	$FF,$F5	; $0014 Up-Left
DB	$00,$00,	$00,$00 ; $0018 ( Empty )
DB	$00,$00,	$00,$10	; $001C Down 
DB	$00,$0B,	$00,$0B	; $0020 Down-Right
DB	$FF,$F5,	$00,$0B	; $0024 Down-Left


SECTION	"Free Space $20 - $3F",HOME[$28] ; Free Space $28 - $3F

DB	$00,$00,$00,$00,$00,$00,$00,$00
DB	$00,$00,$00,$00,$00,$00,$00,$00
DB	$00,$00,$00,$00,$00,$00,$00,$00

SECTION	"Memory, Setup, Interrupt, LCD, OAM, Joypad",HOME[$68] ; $78

; --- Clear Memory / Move Memory ------------------------------------------
	
clear_memory::
	xor	a			; hl = destination memory
	inc	b			; bc = data length
	inc	c
	jr	.skip
.loop
	ld	[hl+],a
.skip
	dec	c
	jp	nz,.loop
	dec	b
	jp	nz,.loop
	
	ret

load_memory::
	inc	b			; hl = destination memory
	inc	c			; de = source data
	jr	.skip		; bc = data length
.loop
	ld	a,[de]
	inc	de
	ld	[hl+],a
.skip
	dec	c
	jp	nz,.loop\@
	dec	b
	jp	nz,.loop\@
	
	ret

; --- Setup Hardware & Ram, Hardware Control Functions --------------------

setup_hardware::
	di						; Disable interrupts while setting up
	
	call stop_LCD			; Turn off the LCD while setting up
	
	ld	hl,_VRAM
	ld	bc,$2000
	call clear_memory		; clear VRAM from $8000 - $9FFF
	
	ld	hl,_RAM
	ld	bc,$2000
	call clear_memory		; clear RAM from $C000 - $DFFF
	
	ld	hl,int_array_vblank
	call clear_int_array	; setup vblank interrupt array
	
	ld	hl,int_array_timer
	call clear_int_array	; setup timer interrupt array
	
	ld	hl,_OAMRAM
	ld	bc,$00A0
	call clear_memory		; clear OAM from $FE00 - $FE9F

	ld	hl,_HW
	ld	bc,$0007
	call clear_memory		; clear RAM from $C000 - $DFFF

	xor a

	ld	[rSB],a				; $FF01 Serial Transfer Data
	ld	[rSC],a				; $FF02 Serial IO Control

	ld	[rTIMA],a			; $FF05 Timer Counter
	ld	[rTMA],a			; $FF06 Timer Modulo
	ld	[rTAC],a			; $FF07 Timer Control

	ld	[rIF],a				; $FF0F Interrupt Flag

	ld	[rAUDENA],a			; $FF26	Sound On / Off

	ld	[rSCY],a			; $FF42	Screen Scroll Y
	ld	[rSCX],a			; $FF43	Screen Scroll X

	ld	[rWY],a				; $FF4A	window Y position

	ld	a,%11100100 		; normal background palette
	ld	[rBGP],a			; set window and background palette
	ld	[rOBP0],a			; set object 0 palette
	ld	[rOBP1],a			; set object 1 palette
	
	ld	a,$07
	ld	[rWX],a				; set window X position to 7 (strange)
	
	ld	hl,_HRAM
	ld	bc,$007B			; save 2 addresses, ret from clear_memory & setup_hardware
	call clear_memory		; clear HRAM from $FF80 - $FFFE

	ret

; --- LCD Function --------------------------------------------------------

start_LCD::
	ld	[rLCDC],a			; put preloaded a into LCD control
	ret
	
stop_LCD::
.loop\@:
	ld	a,[rLY]				; load current refresh line
	cp	145
	jr	nz,.loop\@			; if its not 145, then loop
	
	xor	a
	ld	[rLCDC],a			; shut everything off
	ret

SECTION	"General Functions",HOME

; --- Handle Interrupt Functions ---------------------------------------

load_int_function::				; hl = interrupt array to load into
.loop\@:						; bc = function to add to array
	ld	a,[hl]
	inc	a
	cp	$01						; is this value empty?
	jp	z,.load\@				; if so, load
	inc	hl						; if not, increment three times because you
	inc	hl						; need room for call and the address
	inc	hl
	jp	.loop\@					; ...and loop
.load\@:
	ld	a,$CD					; load call command
	ld	[hl+],a					; $CD = 'call'
	ld	a,c
	ld	[hl+],a					; load last 8 bits of address
	ld	a,b
	ld	[hl],a					; load first 8 bits of address
	
	ret
	
delete_int_function:
	ld	a,[hl+]
	cp	$CD
	jp	nz,delete_int_function
	
	ld	a,[hl+]
	cp	c
	jp	nz,delete_int_function
	
	ld	a,[hl]
	cp	b
	jp	nz,delete_int_function
	
	dec hl
	dec hl
	
	ld	a,$00
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl],a
	
	ret
	
clear_int_array::				; hl = interrupt array to clear
	ld	d,int_array_length
	dec	d
	xor	a
.loop\@:
	ld	[hl+],a
	dec	d
	jp	nz,.loop\@
	ld	a,$D9
	ld	[hl],a
	
	ret

; --- Get Pressed Keys -------------------------------------------------

get_keys::
	ld	a,%00010000
	ld	[rP1],a				; select button keys			
	nop						; wait a few cycles
	nop
	nop
	nop
	nop
	nop
	ld	a,[rP1]
	and	%00001111			; keep the bits we want
	swap	a
	ld	b,a					; save bits in b
	ld	a,%00100000
	ld	[rP1],a				; select direction keys
	nop						; wait a few cycles
	nop
	nop
	nop
	nop
	nop
	ld	a,[rP1]
	and	%00001111			; keep the bits we want
	or	b					; combine with b
	cpl						; invert so 1 is pressed
	ld	[key_curr],a		; save current keypress
	ld	b,a					; put current keypress into b for comparison
	inc	b					; increment for correct comparison
	ld	a,[key_prev]		; put previous keypress into a for comparison
	inc	a					; increment for correct comparison
	cp	b					; compare
	jp	z,.noChange\@		; jump if no change
	ld	a,$01
	ld	[key_diff],a		; write to key_diff if there is a change
.noChange\@:
	ld	a,[key_curr]
	ld	[key_prev],a		; load previous keypress with current keypress
	ld	a,%00110000			; deselect all buttons
	ld	[rP1],a
	
	;and	%00001111		; reset if all keys are pressed
	;cp	%00001111			; figure ths out later...
	;jp	z,$150
	
	ret

; --- Count VBlanks ----------------------------------------------------

vblank_interrupt::
	di

	push af
	
	ld	a,[vblank_count]
	inc a
	ld	[vblank_count],a
	
	pop af
	
	reti
