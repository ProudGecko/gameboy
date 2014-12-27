
; --- sprites.asm ---------------------------------------------------------

INCLUDE	"inc/hardware.inc"
INCLUDE	"inc/vars.inc"

; -------------------------------------------------------------------------

SECTION	"Sprite Functions",HOME

load_OAM_DMA::
	ld	hl,_HRAM		; Load OAM_DMA function into HRAM
	ld	de,OAM_DMA
	ld	bc,$0D

	jp load_memory

OAM_DMA::				; $0D bytes
	di
	
	push af
	
	ld	a,$C0
	ld	[rDMA], a
	ld	a,$28
loop\@:
	dec a
	jr	nz, loop\@
	
	pop af
	
	reti

; -------------------------------------------------------------------------

;	ld	a,$00					; sprite number
;	ld	b,$00					; tile address
;	ld	c,$00					; tile flags

update_sprite_attributes::
	sla a						; shift sprite number to the left twice
	sla a						; to get correct offset number
	ld	hl, OAM_mirror
	add a,l						; add number to OAM_mirror address
	
	inc hl
	inc hl
	
	ld	a,b
	ld	[hl+],a					; load tile address
	
	ld	a,c
	ld	[hl+],a					; load sprite flags
	
	ret

;	ld	a,$00					; sprite number
;	ld	b,$00					; y position
;	ld	c,$00					; x position

update_sprite_position::
	sla a						; shift sprite number to the right twice
	sla a						; to get correct offset number
	ld	hl,OAM_mirror
	add a,l						; add number to OAM_mirror address

	ld	a,b					
	add a,$10					; add correct offset to y value
	ld	[hl+],a					; load y value
	
	ld	a,c
	add a,$08					; add correct offset to x value
	ld	[hl+],a					; load x value
	
	ret
	
; b = y value
; c = x value
; d = tile number
; e = sprite flags

return_sprite_attributes::
	sla a						; shift sprite number to the left twice
	sla a						; to get correct offset number
	ld	hl,OAM_mirror
	add a,l						; add number to OAM_mirror address
	
	ld	a,[hl+]
	sub a,$10
	ld	b,a						; save y value
	
	ld	a,[hl+]
	sub a,$08
	ld	c,a						; save x value
	
	ld	a,[hl+]
	ld	d,a						; save tile number
	
	ld	a,[hl]
	ld	e,a						; save sprite flags
	
	ret