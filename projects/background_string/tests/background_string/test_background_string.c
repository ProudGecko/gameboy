#include "unity.h"
#include "gboy.h"
#include "gbunit.h"
#include "func_offsets.h"
#include <stdio.h>
#include <string.h>

FILE *rom_file;
cpu_image_t actual_state, expected_state;
memory_map_t actual_mem, expected_mem;

int start_vm();
void shutdown_vm(void);
void rom_exec(int);

void setUp(void)
{
    memset(&actual_state, 0, sizeof(actual_state));
    memset(&expected_state, 0, sizeof(expected_state));
    memset(&actual_mem, 0, sizeof(actual_mem));
    memset(&expected_mem, 0, sizeof(expected_mem));
    rom_file = fopen("/home/schambda/Projects/gameboy/projects/background_string/background_string.gb", "rb");
    TEST_ASSERT_NOT_NULL_MESSAGE(rom_file, "Unable to open ROM file");
    start_vm();
}

void tearDown(void)
{
    shutdown_vm();
}

void testWriteVRAM(void)
{
    RunROM(WriteVRAM, &actual_state, &actual_mem);
    AssertEqual_cpu_image_t(expected_state, actual_state, __LINE__, NULL);
}

void testWriteStringToVRAM(void)
{
    char * expected_string = "HELLO,WORLD";
    uint8_t expected_string_len = (uint8_t)strlen(expected_string);
    uint8_t ii;

    actual_state.regDE.word   = StringToWrite;
    actual_state.regHL.word   = offsetof(memory_map_t, segments.vram.segments.bg_map1);
    actual_state.regBC.regs.b = expected_string_len;

    for(ii = 0; ii < expected_string_len; ii++)
    {
        expected_mem.segments.vram.segments.bg_map1[ii] = expected_string[ii] - 0x1F;
    }

    RunROM(WriteStringToVRAM, &actual_state, &actual_mem);

    AssertEqual_memory_map_t(expected_mem, actual_mem, BOTTOM_OF_STACK, __LINE__, NULL);
    //AssertEqual_cpu_image_t(expected_state, actual_state, __LINE__, NULL);
}

void test_cpu_image_assert(void)
{
    cpu_image_t expected, actual;

    memset(&expected, 0, sizeof(expected));
    memset(&actual  , 0, sizeof(actual));

    expected.regAF.word = 0x1234;
    actual.regAF.word = 0x3412;

    AssertEqual_cpu_image_t(expected, actual, __LINE__, NULL);
}

void test_memory_map_assert(void)
{
    memory_map_t expected, actual;

    memset(&expected, 0, sizeof(expected));
    memset(&actual  , 0, sizeof(actual));

    expected.all[BOTTOM_OF_STACK - 1] = 0x34;
    expected.all[BOTTOM_OF_STACK - 0] = 0x12;

    actual.all[BOTTOM_OF_STACK - 1] = 0x34;
    actual.all[BOTTOM_OF_STACK - 0] = 0x34;

    AssertEqual_memory_map_t(expected, actual, BOTTOM_OF_STACK - 1, __LINE__, NULL);
}

void test_memory_access_routines(void)
{
    uint16_t expected = 0x1234;
    uint16_t actual;

    PushToGbStack(expected);
    actual = PopFromGbStack();

    TEST_ASSERT_EQUAL(expected, actual);

    PushToGbStack(expected);
    ReadFromGbMemory(0xFFFC, &actual, 2);
    TEST_ASSERT_EQUAL(expected, actual);

    expected = 0x4567;
    WriteToGbMemory(&expected, 0xFFFC, 2);
    actual = PopFromGbStack();
    TEST_ASSERT_EQUAL(expected, actual);
}
