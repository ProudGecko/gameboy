
; --- timer.asm -----------------------------------------------------------

INCLUDE	"inc/graphics.inc"
INCLUDE	"inc/hardware.inc"
INCLUDE	"inc/vars.inc"

; --- Timer Functions -----------------------------------------------------

SECTION	"Timer Functions",HOME

timer_interrupt::
	di

	push af
	
	ld	a,[timer_overflow_count]
	inc a
	ld	[timer_overflow_count],a
	
	pop af
	
	reti

wait_timer_counts::
	ld	a,$00
	ld	[timer_overflow_count],a	; reset timer counter for use
.loop:
	ld	a,[timer_overflow_count]
	cp	b							; compare with b, if less then loop
	jp	nz,.loop
	
	ret