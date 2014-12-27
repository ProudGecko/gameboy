
; --- graphics.asm --------------------------------------------------------

INCLUDE	"inc/graphics.inc"
INCLUDE	"inc/hardware.inc"
INCLUDE	"inc/vars.inc"

SECTION	"Graphics Functions",HOME

; --- Tile Functions ------------------------------------------------------

; load a squared off background at $8000
; skipping the extra scrollable space so its just
; the necessary space to fill one screen
	
load_background_8000::
	ld	a,$00				; hl = destination memory
	ld	b,$02				; de = source data
	ld	c,$69				; bc = data length
	jp	.skip\@
.loop\@:

	push	af
	
	ld	a,[de]
	inc de
	ld	[hl+],a
	
	pop	af
	
	inc	a
	cp	$14
	jr	nz,.skip\@
	
	push de
	
	ld	de,$000C
	add	hl,de
	
	pop	de
	
	ld	a,$00
.skip\@:
	dec	c
	jp	nz,.loop\@
	dec	b
	jp	nz,.loop\@
	
	ret

; load a squared off background at $8800, adding $80 where
; necessary so the tiles line up correctly

load_background_8800::
	ld	a,$00				; hl = destination memory
	ld	b,$02				; de = source data
	ld	c,$69				; bc = data length
	jp	.skip\@
.loop\@:

	push	af
	push	bc
	
	ld	b,$80
	
	ld	a,[de]
	add a,b
	inc de
	ld	[hl+],a
	
	pop	bc
	pop	af
	
	inc	a
	cp	$14
	jp	nz,.skip\@
	push de
	ld	de,$000C
	add	hl,de
	pop	de
	ld	a,$00
.skip\@:
	dec	c
	jp	nz,.loop\@
	dec	b
	jp	nz,.loop\@
	
	ret
	
set_tile_pointer:
	inc b
	inc c
	ld	de,$0020
	
	dec b
	jp z,.y_check\@
.x_loop\@:
	inc hl
	dec b
	jp nz,.x_loop\@
.y_check\@:
	dec c
	jp z,.return\@
.y_loop\@:
	add hl,de
	dec c
	jp nz,.y_loop\@
.return\@:

	ret

; --- Fade Functions ------------------------------------------------------

fade_in::
	ld	a,$00
	ld	[timer_overflow_count],a	; reset timer_counter for use
.loop_1:
	ld	a,[timer_overflow_count]
	cp	b						; compare with b, if less then loop
	jp	nz,.loop_1
	
	ld	a, %01000000
	ld	[rBGP],a				; fade in step 1
	
	ld	a,$00
	ld	[timer_overflow_count],a		; reset timer_counter for use
.loop_2:
	ld	a,[timer_overflow_count]
	cp	b						; compare with b, if less then loop
	jp	nz,.loop_2
	
	ld	a, %10010000
	ld	[rBGP],a				; fade in step 2
	
	ld	a,$00
	ld	[timer_overflow_count],a		; reset timer_counter for use
.loop_3:
	ld	a,[timer_overflow_count]
	cp	b						; compare with be, if less then loop
	jp	nz,.loop_3
	
	ld	a, %11100100
	ld	[rBGP],a				; fade in step 3, normal color palette
	
	ld	a,$00
	ld	[timer_overflow_count],a		; reset timer counter
	
	ret
	
fade_out::
	ld	a,$00
	ld	[timer_overflow_count],a		; reset timer counter for use
	
	ld	c,$03					; number of fade steps
.loop:
	ld	a,[timer_overflow_count]
	cp	b						; compare with b, if less then loop
	jp	nz,.loop

	ld	a,[rBGP]				; load current background palette
	sla	a
	sla	a						; shift left twice, lose bit 6 and 7
	ld	[rBGP],a				; load new background palette
	
	ld	a,$00
	ld	[timer_overflow_count],a		; reset timer counter for use
	
	dec	c						; decrement c, number of fade steps
	jp	nz,.loop
	
	ret