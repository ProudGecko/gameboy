SECTION "rom", HOME	; HOME = ROM Bank 0
; $0000 - $003F: RST handlers.
ret
REPT 7
    nop
ENDR
; $0008
ret
REPT 7
    nop
ENDR
; $0010
ret
REPT 7
    nop
ENDR
; $0018
ret
REPT 7
    nop
ENDR
; $0020
ret
REPT 7
    nop
ENDR
; $0028
ret
REPT 7
    nop
ENDR
; $0030
ret
REPT 7
    nop
ENDR
; $0038
ret
REPT 7
    nop
ENDR

; $0040 - $0067: Interrupt handlers.
jp draw
REPT 5
    nop
ENDR
; $0048
jp stat
REPT 5
    nop
ENDR
; $0050
jp timer
REPT 5
    nop
ENDR
; $0058
jp serial
REPT 5
    nop
ENDR
; $0060
jp joypad
REPT 5
    nop
ENDR

; $0068 - $00FF: Free space.
DS $98

; $0100 - $0103: Startup handler.
nop
jp main

; $0104 - $0133: The Nintendo Logo.
DB $CE, $ED, $66, $66, $CC, $0D, $00, $0B
DB $03, $73, $00, $83, $00, $0C, $00, $0D
DB $00, $08, $11, $1F, $88, $89, $00, $0E
DB $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
DB $BB, $BB, $67, $63, $6E, $0E, $EC, $CC
DB $DD, $DC, $99, $9F, $BB, $B9, $33, $3E

; $0134 - $013E: The title, in upper-case letters, followed by zeroes.
DB "BORING"
DS 6 ; padding

; $013F - $0142: The manufacturer code.
DS 4

; $0143: Gameboy Color compatibility flag.    
GBC_UNSUPPORTED EQU $00
DB GBC_UNSUPPORTED

; $0144 - $0145: "New" Licensee Code, a two character name.
DB "OK"

; $0146: Super Gameboy compatibility flag.
SGB_UNSUPPORTED EQU $00
DB SGB_UNSUPPORTED

; $0147: Cartridge type. Either no ROM or MBC5 is recommended.
CART_ROM_ONLY EQU $00
DB CART_ROM_ONLY

; $0148: Rom size.
ROM_32K EQU $00
DB ROM_32K

; $0149: Ram size.
RAM_NONE EQU $00
DB RAM_NONE

; $014A: Destination code.
DEST_INTERNATIONAL EQU $01
DB DEST_INTERNATIONAL

; $014B: Old licensee code.
; $33 indicates new licensee code will be used.
; $33 must be used for SGB games.
DB $33

; $014C: ROM version number
DB $00

; $014D: Header checksum.
; Assembler needs to patch this.
DB $FF

; $014E- $014F: Global checksum.
; Assembler needs to patch this.
DW $FACE

; $0150: Code!

; Defines
VRAM_OBJ_DATA_START     EQU $8000
VRAM_OBJ_DATA_END       EQU $97FF
VRAM_OBJ_DATA_LEN       EQU (VRAM_OBJ_DATA_END - VRAM_OBJ_DATA_END) + 1
VRAM_OBJ_DATA_START_HI  EQU ((VRAM_OBJ_DATA_START >> 8) & $00FF)
VRAM_OBJ_DATA_START_LO  EQU ((VRAM_OBJ_DATA_START >> 0) & $00FF)

VRAM_OBJ_LEN        EQU $10        ; Using 8x8 sprites. 2x for 8x16 sprites

OAM_START           EQU $FE00
OAM_END             EQU $FE9F
OAM_LEN             EQU (OAM_END - OAM_START) + 1

LCDC                EQU $FF40
LCDC_OBJ_FLAG       EQU (1 << 1)    ; 0 = Off, 1 = On
LCDC_OBJ_SIZE_FLAG  EQU (1 << 2)    ; 0 = 8x8, 1 = 16x16
LCDC_BG_MAP_FLAG    EQU (1 << 3)    ; 0 = $9800-$9BFF, 1 = $9C00-$9FFF
LCDC_BG_DATA_FLAG   EQU (1 << 4)    ; 0 = $8800-$97FF, 1 = $8000-$8FFF
LCDC_WINDOW_FLAG    EQU (1 << 5)    ; 0 = Off, 1 = On
LCDC_WINDOW_MAP_FLAG EQU (1 << 6)   ; 0 = $9800-$9BFF, 1 = $9C00-$9FFF
LCDC_CTRL_STOP_FLAG EQU (1 << 7)    ; 0 = LCDC Off, 1 = LCDC On

STAT                EQU $FF41
STAT_MODE           EQU ($3)        ; 0 = H-Blank. CPU may access VRAM or OAM
                                    ; 1 = V-Blank. CPU may access VRAM or OAM
                                    ; 2 = OAM in use. CPU may access VRAM
                                    ; 3 = VRAM and OAM in use.
STAT_MODE_VBLANK    EQU 2

STACK_BOTTOM        EQU $FFFE

SCREEN_ORIGIN_X     EQU $8
SCREEN_ORIGIN_Y     EQU $10

main:
    ld      sp, STACK_BOTTOM
    di      ; Disable interrupts for now

.wait_for_vblank:
    ldh     a, [STAT]
    and     2
    jr      nz, .wait_for_vblank
    ;ld      hl, STAT
    ;ld      a, STAT_MODE_VBLANK
    ;cp      [hl]
    ;jp      nz, .wait_for_vblank

    ld      hl, LCDC
    ld      [hl], 0 ; Keep LCD controller off while sprite is loaded

    ; Clear OAM
    ld      hl, OAM_START
    ld      a,  OAM_LEN
.clear_oam_loop
    ld      [hl], 0
    inc     hl
    dec     a
    jp      nz, .clear_oam_loop

    ; Load solid black 8x8 sprite into OBJ[0] memory
    ld      hl, VRAM_OBJ_DATA_START
    ld      a, VRAM_OBJ_LEN
.load_sprite_loop
    ld      [hl], $FF
    inc     hl
    dec     a
    jp      nz, .load_sprite_loop

    ; Setup OBJ[0] in OAM to be displayed in top-left corner
    ld      hl, OAM_START
    ld      [hl], SCREEN_ORIGIN_Y
    inc     hl
    ld      [hl], SCREEN_ORIGIN_X
    inc     hl
    ld      [hl], 0                 ; OBJ[0] code
    inc     hl
    ld      [hl], 0                 ; Palette 0, No H-flip, No V-flip, Priority to OBJ

    ; Enable LCDC and OBJ sprites
    ld      hl, LCDC
    ld      [hl], LCDC_OBJ_FLAG | LCDC_CTRL_STOP_FLAG      ; Enable OBJ sprites and LCD controller

    ei      ; Enable interrupts again
.loop:
    halt
    jr .loop

draw:
stat:
timer:
serial:
joypad:
    reti

