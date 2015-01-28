#ifndef _GBUNIT_MEMORY_MAP_H_
#define _GBUNIT_MEMORY_MAP_H_

#include "gbunit_stdint.h"
#include <stddef.h>
#include "compile_time_assert.h"

typedef union
{
    uint8_t all[0xA000 - 0x8000];
    struct
    {
        uint8_t tile_data   [0x9800 - 0x8000];
        uint8_t bg_map1     [0x9C00 - 0x9800];
        uint8_t bg_map2     [0xA000 - 0x9C00];
    } segments;
} vram_t;
compile_time_assert(offsetof(vram_t, all)                == 0);
compile_time_assert(offsetof(vram_t, segments)           == 0);
compile_time_assert(offsetof(vram_t, segments.tile_data) == 0x0000);
compile_time_assert(offsetof(vram_t, segments.bg_map1)   == 0x1800);
compile_time_assert(offsetof(vram_t, segments.bg_map2)   == 0x1C00);
compile_time_assert(  sizeof(vram_t)                     == 0x2000);

typedef union
{
    uint8_t all[0xFEA0 - 0xFE00];
    struct
    {
        uint8_t temp;
    } records[10];
} oam_t;
compile_time_assert(sizeof(oam_t) == 0xA0);

typedef union
{
    uint8_t all[0xFF80 - 0xFF00];
    struct
    {
    } registers;
} peripherals_t;

typedef union
{
    uint8_t all[0x1000];
    struct
    {
        uint8_t rom    [0x8000];
        vram_t vram;
        uint8_t eram   [0xC000 - 0xA000];
        uint8_t iram   [0xE000 - 0xC000];
        uint8_t unused0[0xFE00 - 0xE000];
        oam_t oam;
        uint8_t unused1[0xFF00 - 0xFEA0];
        peripherals_t peripherals;
        uint8_t stack [(0xFFFF - 0xFF80)];
        uint8_t unused2;
    } segments;
} memory_map_t;
compile_time_assert(offsetof(memory_map_t, all)                  == 0x0000);
compile_time_assert(offsetof(memory_map_t, segments.rom)         == 0x0000);
compile_time_assert(offsetof(memory_map_t, segments.vram)        == 0x8000);
compile_time_assert(offsetof(memory_map_t, segments.eram)        == 0xA000);
compile_time_assert(offsetof(memory_map_t, segments.iram)        == 0xC000);
compile_time_assert(offsetof(memory_map_t, segments.unused0)     == 0xE000);
compile_time_assert(offsetof(memory_map_t, segments.oam)         == 0xFE00);
compile_time_assert(offsetof(memory_map_t, segments.unused1)     == 0xFEA0);
compile_time_assert(offsetof(memory_map_t, segments.peripherals) == 0xFF00);
compile_time_assert(offsetof(memory_map_t, segments.stack)       == 0xFF80);
compile_time_assert(offsetof(memory_map_t, segments.unused2)     == 0xFFFF);
compile_time_assert(  sizeof(memory_map_t)                       == 0x10000);

typedef struct
{
    memory_map_t mem;
    uint16_t stack_ptr;
    uint8_t num_stack_items_to_verify;
} assert_memory_map_t;

#define VRAM_START                 (offsetof(memory_map_t, segments.vram))
#define VRAM_SIZE                  (offsetof(memory_map_t, segments.eram) - offsetof(memory_map_t, segments.vram))
#define ERAM_START                 (offsetof(memory_map_t, segments.eram))
#define ERAM_SIZE                  (offsetof(memory_map_t, segments.iram) - offsetof(memory_map_t, segments.eram))
#define IRAM_START                 (offsetof(memory_map_t, segments.iram))
#define IRAM_SIZE                  (offsetof(memory_map_t, segments.unused0) - offsetof(memory_map_t, segments.iram))
#define OAM_START                  (offsetof(memory_map_t, segments.oam))
#define OAM_SIZE                   (offsetof(memory_map_t, segments.unused1) - offsetof(memory_map_t, segments.oam))
#define PERIPHERALS_START          (offsetof(memory_map_t, segments.peripherals))
#define PERIPHERALS_SIZE           (offsetof(memory_map_t, segments.stack) - offsetof(memory_map_t, segments.peripherals))
#define TOP_OF_STACK               (offsetof(memory_map_t, segments.stack))
#define STACK_SIZE                 (offsetof(memory_map_t, segments.unused2) - offsetof(memory_map_t, segments.stack))
#define BOTTOM_OF_STACK            (TOP_OF_STACK + STACK_SIZE)

#endif // _GBUNIT_MEMORY_MAP_H_
