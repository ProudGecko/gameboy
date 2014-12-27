; --- Includes ------------------------------------------------------------

INCLUDE "inc/vars.inc"
INCLUDE "inc/hardware.inc"
INCLUDE "inc/border_tiles.inc"
INCLUDE "inc/snake_body_tiles.inc"

; --- Data Tables ---------------------------------------------------------

;SECTION "Data & Sine Tables",DATA[$4000]

; --- Interrupt Vectors ---------------------------------------------------

SECTION "Interrupt Vector $40", HOME[$40]		; VBlank Interrupt
	jp int_array_vblank
	ret
SECTION	"Interrupt Vector $48", HOME[$48]		; LCD LY Interrupt
	ret
SECTION	"Interrupt Vector $50", HOME[$50]		; Timer Interrupt
	jp int_array_timer
	ret
SECTION	"Interrupt Vector $58", HOME[$58]		; Serial Interrupt
	ret
SECTION	"Interrupt Vector $60", HOME[$60]		; Joypad Interrupt
	ret
SECTION	"Program Header", HOME[$100]
	nop
	jp	program_start

; --- Header --------------------------------------------------------------

DB $00,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
DB $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
DB $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

DB	"Gameboy Program"	; $134 - Cartridge Name (15 bytes)
DB	$00			; $143 - GBC Flag (80 = Both / C0 = GBC Only)
DW	$0000			; $144 - Licensee Code
DB	$00			; $146 - SGB Flag (00 = No SGB / 03 = SGB)							
DB	ROM_MBC5_RAM		; $147 - Cart type
DB	ROM_SIZE_32KBYTE	; $148 - ROM Size
DB	RAM_SIZE_8KBYTE		; $149 - RAM Size
DB	$01			; $14a - Destination code (00 = Jap / 01 = non Jap)
DB	$33			; $14b - Old licensee code (stays $33)
DB	$00			; $14c - Mask ROM version (Program Version Number)
DB	$00			; $14d - Header Checksum (important)
DW	$0000			; $14e - Global Checksum (not used by GB)

; --- Program Start -------------------------------------------------------

SECTION "Program Start", HOME[$150]

program_start:

	ld sp, $FFFF		; Setup stack pointer, highest position +1

	call setup_hardware	; Setup hardware, return with LCD and Sound OFF

	ld	a,%00000101
	ld	[rIE],a		; Set active interrupts : VBlank, Timer	
	
	; --- Setup OAM DMA

	;call load_OAM_DMA			; Move OAM_DMA function into HRAM

	ld	hl,int_array_vblank
	ld	bc,vblank_interrupt
	call load_int_function		; Load OAM_DMA address into vblank interrupt array

	;ld	bc,OAM_DMA
	;call load_int_function		; Load OAM_DMA address into vblank interrupt array

	; --- Load Tiles into VRAM

	;ld	hl,_VRAM0
	;ld	bc,$0050
	;ld	de,simple_tiles
	;call load_memory

	; -- Load Tilemaps

	;ld	hl,_SCRN0
	;ld	de,simple_tilemap
	;call load_background_8000

	; --- Setup Sprites

	ld	a,$00					; sprite number
	ld	b,$01					; tile address
	ld	c,$00					; tile flags
	;call update_sprite_attributes

	ld	a,$00					; sprite number
	ld	b,$00					; y position
	ld	c,$00					; x position
	;call update_sprite_position

	; --- Enable Things

	ld a,%10010011
	call start_LCD		; Turn LCD ON

	ei			; Enable Interrupts

; --- Main Loop -----------------------------------------------------------

main_loop:						; Loop forever
	nop

	call get_keys

	;call move_char
	
	jp main_loop
