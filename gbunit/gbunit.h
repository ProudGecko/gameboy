#ifndef _GBUNIT_H_
#define _GBUNIT_H_

#include <stdint.h>
#include "gbunit_memory_map.h"

#define RETURN_TO_GBUNIT_INDICATOR (0xFFFF)

typedef struct
{
    union
    {
        uint16_t word;
        struct
        {
            uint8_t a;
            union
            {
                uint8_t byte;
                struct
                {
                    uint8_t unused : 4;
                    uint8_t cy     : 1;
                    uint8_t h      : 1;
                    uint8_t n      : 1;
                    uint8_t z      : 1;
                } bits;
            } flags;
        } regs;
    } regAF;
    union
    {
        uint16_t word;
        struct
        {
            uint8_t b;
            uint8_t c;
        } regs;
    } regBC;
    union
    {
        uint16_t word;
        struct
        {
            uint8_t d;
            uint8_t e;
        } regs;
    } regDE;
    union
    {
        uint16_t word;
        struct
        {
            uint8_t h;
            uint8_t l;
        } regs;
    } regHL;
    uint16_t regPC;
    uint16_t regSP;
} cpu_image_t;



void PushToGbStack(uint16_t value);
uint16_t PopFromGbStack();
void ReadFromGbMemory(uint16_t gb_src, void * host_dest, int len);
void WriteToGbMemory(const void * host_src, uint16_t gb_dest, int len);
void RunROM(uint16_t offset, cpu_image_t *cpu_state, memory_map_t *mem_state);

void AssertEqual_cpu_image_t(cpu_image_t expected, cpu_image_t actual, unsigned int line, const char *msg);
void AssertEqual_memory_map_t(memory_map_t expected, memory_map_t actual, uint16_t stack_ptr, unsigned int line, const char *msg);

#endif // _GBUNIT_H_
