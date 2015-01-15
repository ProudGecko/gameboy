#include "unity.h"
#include "gboy.h"
#include "gbunit.h"
#include "func_offsets.h"
#include <stdio.h>

FILE *rom_file;

int start_vm();
void shutdown_vm(void);
void rom_exec(int);

void setUp(void)
{
    rom_file = fopen("/home/schambda/Projects/gameboy/projects/background_string/background_string.gb", "r");
    start_vm();
}

void tearDown(void)
{
    shutdown_vm();
}

void testWriteVRAM(void)
{
    cpu_image_t initial_state, final_state;

    memset(&initial_state, 0, sizeof(initial_state));

    final_state = RunROM(WriteVRAM, initial_state);
    AssertEqual_cpu_image_t(initial_state, final_state, __LINE__, NULL);
}

void testWriteStringToVRAM(void)
{
    cpu_image_t initial_state, final_state;

    memset(&initial_state, 0, sizeof(initial_state));

    final_state = RunROM(WriteStringToVRAM, initial_state);
    AssertEqual_cpu_image_t(initial_state, final_state, __LINE__, NULL);
}

void test_cpu_image_assert(void)
{
    cpu_image_t expected;
    cpu_image_t actual;

    expected.regAF.word = 0x1234;
    actual.regAF.word = 0x3412;

    AssertEqual_cpu_image_t(expected, actual, __LINE__, NULL);
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
