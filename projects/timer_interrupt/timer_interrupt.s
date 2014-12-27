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
DB "BUTTON"
DS 5 ; padding

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

INCLUDE "smiley.inc"

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

OBJ_PAL0            EQU $FF48
OBJ_PAL0_DEFAULT    EQU $E4

CONTROLLER              EQU $FF00
CONTROLLER_DPAD_RIGHT   EQU (1 << 0)
CONTROLLER_DPAD_LEFT    EQU (1 << 1)
CONTROLLER_DPAD_UP      EQU (1 << 2)
CONTROLLER_DPAD_DOWN    EQU (1 << 3)
CONTROLLER_BUTTON_A     EQU (1 << 0)
CONTROLLER_BUTTON_B     EQU (1 << 1)
CONTROLLER_BUTTON_SELECT EQU (1 << 2)
CONTROLLER_BUTTON_START EQU (1 << 3)
CONTROLLER_SEL_DPAD     EQU (1 << 5)
CONTROLLER_SEL_BUTTONS  EQU (1 << 4)
CONTROLLER_SEL_NONE     EQU CONTROLLER_SEL_DPAD | CONTROLLER_SEL_BUTTONS

TIMER_COUNTER           EQU $FF05
TIMER_COUNTER_RELOAD    EQU $B0
TIMER_MODULO            EQU $FF06
TIMER_CONTROL           EQU $FF07
TIMER_CONTROL_4KHZ      EQU 0
TIMER_CONTROL_262KHZ    EQU 1
TIMER_CONTROL_66KHZ     EQU 2
TIMER_CONTROL_16KHZ     EQU 3
TIMER_CONTROL_START     EQU (1 << 2)

INT_REQUEST             EQU $FF0F
INT_ENABLE              EQU $FFFF
INT_TIMER_OVERFLOW      EQU (1 << 2)

WAIT_FOR_VBLANK: MACRO
.wait_for_vblank\@:
    ldh     a, [STAT]
    and     2
    jr      nz, .wait_for_vblank\@
ENDM

CLEAR_OAM: MACRO
    ld      hl, OAM_START
    ld      a,  OAM_LEN
.clear_oam_loop\@
    ld      [hl], 0
    inc     hl
    dec     a
    jp      nz, .clear_oam_loop\@
ENDM

; Reads the controller (d-pad and buttons) state
; Register Returns:
;   B - The d-pad state is in the high nibble, the buttons in the low nibble
; Register Used:
;   A - Intermediate value storage
ReadController:
    ld      a, CONTROLLER_SEL_DPAD          ; Setup controller matrix to read d-pad state
    ld      [CONTROLLER], a
    REPT 2                                  ; 2 reads comes from Nintendo recommendation
    ld      a, [CONTROLLER]                 ; Read d-pad state twice to make sure it's stable
    ENDR
    and     $0F                             ; Mask off matrix select bits
    swap    a                               ; Move d-pad state to upper nibble
    ld      b, a                            ; Keep d-pad state in F while reading button state

    ld      a, CONTROLLER_SEL_BUTTONS       ; Setup controller matrix to read d-pad state
    ld      [CONTROLLER], a
    REPT 6                                  ; 6 reads comes from Nintendo recommendation
    ld      a, [CONTROLLER]                 ; Read in button state 6 times to make sure it's stable
    ENDR
    and     $0F                             ; Mask off matrix select bits
    or      b                               ; OR in d-pad state into upper nibble
    xor     $FF                             ; Flip polarity so that 1 indicates button pressed
    ld      b, a
    ld      a, CONTROLLER_SEL_NONE          ; Reset controller matrix to high state
    ld      [CONTROLLER], a
    ret

; Updates the smiley location based on controller state
; Register Parameters:
;   B - controller state
; Register Used:
;   A - Intermediate value storage
UpdateSprite:
    push    hl                              ; Preserve caller's HL
    ld      hl, OAM_START                   ; Point to first entry in OAM where Smiley Y-coord is located

    WAIT_FOR_VBLANK                         ; Wait for VBlank to ensure safe access to OAM

    ; Check up first
    ld      a, CONTROLLER_DPAD_UP << 4
    and     b
    cp      CONTROLLER_DPAD_UP << 4
    jp      nz, .check_down\@               ; If up not pressed check down 
    dec     [hl]                            ; Move smiley up

.check_down\@
    ld      a, CONTROLLER_DPAD_DOWN << 4
    and     b
    cp      CONTROLLER_DPAD_DOWN << 4
    jp      nz, .check_right\@              ; If down not pressed check right 
    inc     [hl]                            ; Move smiley down

.check_right\@
    inc     hl                              ; Advance pointer to X-coord 
    ld      a, CONTROLLER_DPAD_RIGHT << 4
    and     b
    cp      CONTROLLER_DPAD_RIGHT << 4
    jp      nz, .check_left\@               ; If right not pressed check left
    inc     [hl]                            ; Move smiley right

.check_left\@
    ld      a, CONTROLLER_DPAD_LEFT << 4
    and     b
    cp      CONTROLLER_DPAD_LEFT << 4
    jp      nz, .check_a\@                  ; If left not pressed check button a
    dec     [hl]                            ; Move smiley left

.check_a\@
    inc     hl                              ; Advance pointer to H-flip and V-flip option
    inc     hl
    ld      a, CONTROLLER_BUTTON_A
    and     b
    cp      CONTROLLER_BUTTON_A
    jp      nz, .check_b\@                  ; If a not pressed check b
    set     6, [HL]                         ; Flip smiley vertical

.check_b\@
    ld      a, CONTROLLER_BUTTON_B
    and     b
    cp      CONTROLLER_BUTTON_B
    jp      nz, .return\@                   ; If left not pressed all done
    res     6, [HL]                         ; Flip smiley back to normal

.return\@
    pop     hl                              ; Restore caller's HL
    ret

; Waits for VBlank then copies data to VRAM
; Register Parameters:
;   DE - source address
;   HL - VRAM destination address
;   A  - length
WriteVRAM:
.loop\@
    ld      a, [de]
    ldi     [hl], a             ; Writes value in A to [hl] and increments hl
    inc     de 
    dec     b
    ret     z                   ; Return if done copying
    jp      .loop\@             ; Since we did't return to the caller there must
                                ; be more data to write

main:
    ld      sp, STACK_BOTTOM
    di      ; Disable interrupts for now

    WAIT_FOR_VBLANK

    ld      hl, LCDC
    ld      [hl], 0 ; Keep LCD controller off while sprite is loaded

    CLEAR_OAM

    ; Load smiley 8x8 sprite into OBJ[0] memory
    ld      hl, VRAM_OBJ_DATA_START
    ld      b, VRAM_OBJ_LEN
    ld      de, Smiley
    call    WriteVRAM

    ; Setup OBJ[0] in OAM to be displayed in top-left corner
    ld      hl, OAM_START
    ld      [hl], SCREEN_ORIGIN_Y
    inc     hl
    ld      [hl], SCREEN_ORIGIN_X
    inc     hl
    ld      [hl], 0                 ; OBJ[0] code
    inc     hl
    ld      [hl], 0                 ; Palette 0, No H-flip, No V-flip, Priority to OBJ

    ; Setup OBJ palette 0
    ld     hl, OBJ_PAL0
    ld     [hl], OBJ_PAL0_DEFAULT


    ; Enable LCDC and OBJ sprites
    ld      hl, LCDC
    ld      [hl], LCDC_OBJ_FLAG | LCDC_CTRL_STOP_FLAG      ; Enable OBJ sprites and LCD controller

    ; Setup timer
    ld      a, INT_TIMER_OVERFLOW
    ld      [INT_ENABLE], a
    ld      a, TIMER_COUNTER_RELOAD
    ld      [TIMER_COUNTER], a
    ld      a, TIMER_CONTROL_262KHZ
    ld      [TIMER_CONTROL], a
    ld      a, TIMER_CONTROL_START
    ld      [TIMER_CONTROL], a

    ei      ; Enable interrupts again
.loop\@:
    ;halt       ; Not sure if I need this since interrupts aren't being used
    call    ReadController
    call    UpdateSprite

    halt                                ; Halt until timer interrupt fires
    jr .loop\@

draw:
    reti
stat:
    reti
timer:
    ld      a, TIMER_COUNTER_RELOAD
    ld      [TIMER_COUNTER], a
    reti
serial:
    reti
joypad:
    reti

