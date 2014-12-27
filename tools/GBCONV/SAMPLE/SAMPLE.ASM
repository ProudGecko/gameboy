; HeroZero/Oldskool GFX converter for GB sample
; 96-06-22

.org $0000		; Yes, this one is needed when using tasm

; Set all irq vectors to do nothing.
.org $0040		; VBlank IRQ
 reti			; Do nothing
.org $0048		; LCDC Status IRQ
 reti			; Do nothing
.org $0050		; Timer Owerflow
 reti			; Do nothing
.org $0058		; Serial Transfear Completion
 reti			; Do nothing
.org $0060		; Hmm, this is a wierd on
reti			; Do nothing :)
; Irqs done..

.org $0100
.db $00,$c3,$50,$01,$ce,$ed,$66,$66,$cc,$0d,$00,$0b,$03,$73,$00,$83
.db $00,$0c,$00,$0d,$00,$08,$11,$1f,$88,$89,$00,$0e,$dc,$cc,$6e,$e6
.db $dd,$dd,$d9,$99,$bb,$bb,$67,$63,$6e,$0e,$ec,$cc,$dd,$dc,$99,$9f
.db $bb,$b9,$33,$3e	; Standard Nintendo DO NOT CHANGE...
.db "HEROZERO GFX-CON"	; Cart name   16bytes
.db $00,$00,$00		; Not used
.db $00			; Cart type   ROM Only
.db $00			; ROM Size    32k
.db $00			; RAM Size     0k
.db $de,$ad		; Maker ID    $dead=DiESEL Soft
.db $01			; Version     =1
.db $ff			; Complement check
.db $ff,$ff		; Cheksum Lets fix thoose later..


; This is $0150
 di			; Disable IRQs
 ld	sp,$d900	; Put the stack somewere

 ld	a,%00000000	; No IRQs at all
 ldh	($ff),a

 sub	a		; Misc standard init things..
 ldh	($41),a		; LCDC Status
 ldh	($42),a		; Screen scroll Y=0
 ldh	($43),a		; Screen scroll X=0

 call	waitvbl		; Must be in VBL before turning the screen off.
 ld	a,%00010001	; LCD Controller = Off (No picture on screen)
			; WindowBank = $9800 (Not used)
			; Window = OFF
			; BG Chr = $8000
			; BG Bank= $9800
			; OBJ    = 8x8
			; OBJ    = Off
			; BG     = On
 ldh	($40),a

 call	nor_col		; Normal palette
 call 	move_char	; Move the charset to $8000
 call	move_text	; Move the text to $9800

 ld	a,%10010001	; LCD Controller = On  BG = On  Sprites = Off
 ldh	($40),a

mainloop
 jp	mainloop	; Put your own cool things here!!!




nor_col
 ld	a,%11100100	; Sets the colors to normal palette
 ldh	($47),a		; For LCD screen
 ldh	($48),a		; Sprite palette 0
 ldh	($48),a		; Sprite palette 1

 ret

move_char
 ld	de,$8000	; Destination
 ld	hl,font		; Source
 ld	bc,$07c0	; number of bytes to move
 call	move
 ret

move_text
 ld	de,$9800
 ld	hl,the_text
 ld	bc,$0140	; =32x10=10 first rows (the symbol thing)
 call	move		; Normal binary move
 ld	bc,$0100	; =32 chars x 8 rows=$100
 call	movec		; move as chars
 ret

#include "gb.asm"

font
#include "gbfont.asm"


; $20 is a normal space and the ugly "3d" symbol starts at char $40

the_text
.db		"                    "
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$40,$41,$42,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$43,$44,$45,$46,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$47,$48,$49,$4a,$4b,$20,$20,$20,$20,$20,$20,$20,$20,$20
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$4c,$4d,$4e,$4f,$50,$51,$20,$20,$20,$20,$20,$20,$20,$20
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$52,$53,$54,$55,$56,$57,$58,$20,$20,$20,$20,$20,$20,$20
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$59,$5a,$5b,$5c,$5d,$5e,$5f,$60,$20,$20,$20,$20,$20,$20
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$61,$62,$63,$64,$65,$66,$67,$68,$69,$20,$20,$20,$20,$20
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$6a,$6b,$6c,$6d,$6e,$6f,$70,$71,$72,$20,$20,$20,$20,$20
.org $+$0c
.db $20,$20,$20,$20,$20,$20,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$20,$20,$20,$20,$20
.org $+$0c
.db		"--------------------"
.org $+$0c
.db		"OK, HERE IT IS.     "
.org $+$0c
.db		"A PCX-->GAMEBOY GFX "
.org $+$0c
.db		"CONVERTER FOR MS-DOS"
.org $+$0c
.db		"--------------------"
.org $+$0c
.db		"HAVE FUN !!!        "
.org $+$0c
.db		"                    "
.org $+$0c
.db		"         HZ/OLDSKOOL"


.block $8000-$		; pad to $8000 with zeros
.end			; Done.
; End of HeroZero/Oldskool GFX Converter sample...
