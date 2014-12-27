
; --- vars.asm ------------------------------------------------------------

INCLUDE	"inc/hardware.inc"
INCLUDE	"inc/vars.inc"

; --- Work RAM Variable Definitions ---------------------------------------

SECTION "WRAM",BSS[$C000]

OAM_mirror::			DS 160	; Low work RAM vars for holding sprite attributes
								; to be copied to OAM using DMA during VBlank
								; $A0 = 160 = 40 sprites x 4 attributes
								; X position, Y position, Tile Number, Attributes

int_array_vblank::		DS int_array_length	; $C0A0 / 40 bytes = 13 addresses
int_array_timer::		DS int_array_length	; $C0C8 / 40 bytes = 13 addresses

timer_overflow_count::	DS 1	; $C0F0 - Counts the number of timer overflows
vblank_count::			DS 1	; $C0F1

key_prev::				DS 1	; $C0F2 - Contains a byte representing the keys
								; pressed durring the last call of get_keys
								; from graphics.asm

key_curr::				DS 1	; $C0F3 - Contains a byte representing the keys
								; pressed durring the current call of get_keys
								; from graphics.asm

key_diff::				DS 1	; $C0F4 - Set if key_prev and key_curr are different

char_vblank_mirror::	DS 1	; $C0F5

char_screenPosition_x::	DS 2	; $C0F6
char_screenPosition_y::	DS 2	; $C0F8

char_mapPosition_x::	DS 1	; $C0FA
char_mapPosition_y::	DS 1	; $C0FB

char_mapTile_x::		DS 1	; $C0FC
char_mapTile_y::		DS 1	; $C0FD

char_tileOffset_x::		DS 1	; $C0FE
char_tileOffset_y::		DS 1	; $C0FF