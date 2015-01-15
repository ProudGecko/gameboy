#ifndef _GBUNIT_H_
#define _GBUNIT_H_

#define RETURN_TO_GBUNIT_INDICATOR (0xFFFF)
#define TOP_OF_STACK               (0xFF80)
#define BOTTOM_OF_STACK            (0xFFFE)
#define STACK_BYTE_SIZE            (BOTTOM_OF_STACK - TOP_OF_STACK)
#define STACK_WORD_SIZE            (STACK_BYTE_SIZE / 2)

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
    uint16_t Stack[STACK_WORD_SIZE];
} cpu_image_t;

void PushToGbStack(uint16_t value);
uint16_t PopFromGbStack();
void ReadFromGbMemory(uint16_t gb_src, uint8_t * host_dest, int len);
void WriteToGbMemory(uint8_t * host_src, uint16_t gb_dest, int len);
cpu_image_t RunROM(uint16_t offset, cpu_image_t cpu_state);

void AssertEqual_cpu_image_t(cpu_image_t expected, cpu_image_t actual, unsigned int line, const char *msg);

#endif // _GBUNIT_H_
