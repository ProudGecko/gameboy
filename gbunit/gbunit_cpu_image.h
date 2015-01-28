#ifndef _GBUNIT_CPU_IMAGE_H_
#define _GBUNIT_CPU_IMAGE_H_

#include "gbunit_stdint.h"

typedef struct
{
    union
    {
        uint16_t word;
        struct
        {
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
            uint8_t a;
        } regs;
    } regAF;
    union
    {
        uint16_t word;
        struct
        {
            uint8_t c;
            uint8_t b;
        } regs;
    } regBC;
    union
    {
        uint16_t word;
        struct
        {
            uint8_t e;
            uint8_t d;
        } regs;
    } regDE;
    union
    {
        uint16_t word;
        struct
        {
            uint8_t l;
            uint8_t h;
        } regs;
    } regHL;
    uint16_t regPC;
    uint16_t regSP;
} cpu_image_t;

typedef struct
{
    cpu_image_t state;
    bool_t assert_A;
    bool_t assert_flags_all;
    bool_t assert_flag_CY;
    bool_t assert_flag_H;
    bool_t assert_flag_N;
    bool_t assert_flag_Z;
    bool_t assert_B;
    bool_t assert_C;
    bool_t assert_D;
    bool_t assert_E;
    bool_t assert_H;
    bool_t assert_L;
    bool_t assert_PC;
    bool_t assert_SP;
} assert_cpu_image_t;

#endif // _GBUNIT_CPU_IMAGE_H_
