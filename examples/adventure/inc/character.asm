
; --- graphics.asm --------------------------------------------------------

INCLUDE	"inc/graphics.inc"
INCLUDE	"inc/hardware.inc"
INCLUDE "inc/sprites.inc"
INCLUDE	"inc/vars.inc"

SECTION	"Character Functions",HOME

move_char::

	; check vblank count and make sure its a new vblank
	ld a,[char_vblank_mirror]
	ld b,a						; load char_movement_timer into b
	ld a,[vblank_count]			; load vblank_count into a
	cp b						; compare
	jr nz, .vblankContinue\@	; if not zero (new vblank) continue
	ret							; else, return
.vblankContinue\@

	; save new vblank_count for comparison next time
	ld a,[vblank_count]			; load vblank_count into a
	ld hl,char_vblank_mirror	; load char_movement_timer address into hl
	ld [hl],a					; load vblank_count into char_movement_timer

	; get current keys and cleanup
	ld	a,[key_curr]	; load current keys into a
	and	%00001111		; and with $0F to isolate the directional bits

	; make sure that some direction keys are pressed or return
	inc a					; increment a incase its 0 for comparison
	cp 1					; compare a with 1
	jr nz,.keyContinue\@	; if not zero (direction keys are pressed) continue
	ret						; else, return
.keyContinue\@
	dec a					; decrement a to fix value

	; multiply current keys by 4 to get correst offset for
	; char movement table located at $0000 
	sla a		; x2
	sla a		; x4

	; load hl with pointer to char movement table
	ld h,$00	; load table base
	ld l,a		; load table index

	; subtract 4 to get correct offset
	ld de,$FFFC	; 16bit add $FFFC so overflow will essentially subtract 4
	add hl,de	; add to hl to correct char movement table index

	; load char movement table X val into de & push
	ld a,[hl+]
	ld d,a		; load hi byte into d
	ld a,[hl+]
	ld e,a		; load lo byte into e
	push de		; push de to stack

	; load char movement table Y val into de & push
	ld a,[hl+]
	ld d,a		; load hi byte into d
	ld a,[hl]
	ld e,a		; load lo byte into d
	push de		; push de to stack

	; load current char_y_pos into de
	ld hl, char_screenPosition_y	; load char_y_pos address into hl
	ld a,[hl+]
	ld d,a		; load hi byte into d
	ld a,[hl]
	ld e,a		; load lo byte into e

	; add character movement table val with current char_y_pos
	pop hl		; pop char movement table y val into hl

	; -- HIT TEST ---------------------------------------------

	add hl,de	; add hl and char_y_pos

	push hl		; push new char_y_pos

	; load new val back into char_y_pos
	ld d,h
	ld e,l		; load hl into de

	ld hl, char_screenPosition_y	; load char_y_position address into hl

	ld a,d
	ld [hl+],a	; load d into hi byte
	ld a,e
	ld [hl],a	; load e into lo byte

	; load current char_x_pos into de
	ld hl, char_screenPosition_x	; load char_x_pos address into hl
	ld a,[hl+]
	ld d,a		; load hi byte into d
	ld a,[hl]
	ld e,a		; load lo byte into e

	; add character movement table val with current char_x_pos
	pop bc		; pop new char_y_pos into bc
	pop hl		; pop char movement table x val into hl

	; -- HIT TEST ---------------------------------------------

	add hl,de	; add hl and char_x_position
	
	; load new val back into char_x_pos
	ld d,h
	ld e,l				; load hl into de

	ld hl, char_screenPosition_x	; load char_x_position address into hl

	ld a,d
	ld [hl+],a	; load d into hi byte
	ld a,e
	ld [hl],a	; load e into lo byte

	; divide de by 16 to get correct x value
	srl d
	rr e	; /2
	srl d
	rr e	; /4
	srl d
	rr e	; /8
	srl d
	rr e	; /16

	; divide bc by 16 to get correct y value
	srl b
	rr c	; /2
	srl b
	rr c	; /4
	srl b
	rr c	; /8
	srl b
	rr c	; /16

	; update sprite position with b,c
	ld b,c
	ld c,e

	push bc ;

	xor a
	call update_sprite_position

	pop bc ;

	ld	a,[rSCY] ;
	; cpl
	add a,b

	ld [char_mapPosition_y],a

	srl a
	srl a
	srl a

	ld [char_mapTile_y],a

	ld	a,[rSCX] ;
	; cpl
	add a,c

	ld [char_mapPosition_x],a

	srl a
	srl a
	srl a

	ld [char_mapTile_x],a

	ret