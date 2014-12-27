; gb.z80
; Standard GameBoy routines written by
; HeroZero/Oldskool 96-01-23
; Use them freely but do give me credit..
;
; Version history
; Started 96-01-23 with VBL, joypad and DMA routines.
; Added move and movec 96-06-18

do_dma	.equ	$ff80


; de=Destination
; hl=Source
; bc=How many bytes
; move is just a raw data move
; movec does an and $3f on the byte before moving
; which is usefull when moving text to the screen...

move
 ld	a,(hli)
 ld	(de),a
 inc	de
 dec	bc
 ld	a,b		; Are we done (is bc=0000??)
 or	c
 jr	nz, move
 ret

movec
 ld	a,(hli)
 and	$3f		; This is whats differs from the move routine
 ld	(de),a
 inc	de
 dec	bc
 ld	a,b
 or	c
 jr	nz, movec
 ret


waitvbl			; Wait for Vertical blank
 ldh	a,($40)
 add	a,a		; Is the screen turned off??
 ret	nc              ; If yes then exit..
notyet
 ldh	a,($44)		; $ff44=LCDC Y-Pos
 cp	$90		; $90 and bigger = in VBL
 jr	nz,notyet
 ret

; Get Keypad Button Status
; Can't remember where I ripped it from.
; The following bits are set if pressed.
;    $80 - Start   $8 - Down
;    $40 - Select  $4 - Up
;    $20 - B       $2 - Left
;    $10 - A       $1 - Right

getkeys
 ld	a,$20
 ldh	($00),a		;turn on P15
 ldh	a,($00)		;delay
 ldh	a,($00)

 cpl
 and	$0f
 swap	a
 ld	b,a

 ld	a,$10
 ldh	($00),a		;turn on P14
 ldh	a,($00)		;delay
 ldh	a,($00)
 ldh	a,($00)
 ldh	a,($00)
 ldh	a,($00)
 ldh	a,($00)

 cpl
 and	$0f
 or	b
 swap	a
 ret

initdma			; Transfer DMA routine to RAM
 ld	de,$ff80
 ld	hl,dmacode
 ld	bc,dmaend-dmacode
 call	move
 ret

dmacode			; Transfer sprite data from reg A pos. using DMA
 ldh	($46),a		; Start DMA
 ld	a,$28		; Wait for 160ns
dma_wait
 dec	a
 jr	nz,dma_wait
 ret
dmaend
