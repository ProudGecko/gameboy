
; --- vars.inc ------------------------------------------------------------

IF !DEF (__vars)
__vars SET 1

; --- Static Equates ------------------------------------------------------

int_array_length	EQU		40

; -------------------------------------------------------------------------

GLOBAL OAM_mirror

GLOBAL int_array_vblank
GLOBAL int_array_timer

GLOBAL timer_overflow_count
GLOBAL vblank_count

GLOBAL key_prev
GLOBAL key_curr
GLOBAL key_diff

GLOBAL char_vblank_mirror

GLOBAL char_screenPosition_x
GLOBAL char_screenPosition_y

GLOBAL char_mapPosition_x
GLOBAL char_mapPosition_y

GLOBAL char_mapTile_x
GLOBAL char_mapTile_y

GLOBAL char_tileOffset_x
GLOBAL char_tileOFfset_y

ENDC