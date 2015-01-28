#include "unity.h"
#include "gboy.h"
#include "gbunit.h"
#include "func_offsets.h"
#include <stdio.h>
#include <string.h>

FILE *rom_file;
assert_cpu_image_t actual_state, expected_state;
assert_memory_map_t actual_mem, expected_mem;

int start_vm();
void shutdown_vm(void);
void rom_exec(int);

void setUp(void)
{
    actual_state = Create_assert_cpu_image_t();
    expected_state = Create_assert_cpu_image_t();

    actual_mem = Create_assert_memory_map_t();
    expected_mem = Create_assert_memory_map_t();

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
    RunROM(WriteVRAM, &actual_state.state, &actual_mem.mem);
    AssertEqual_assert_cpu_image_t(expected_state, actual_state, __LINE__, NULL);
}

void testWriteStringToVRAM(void)
{
    char * expected_string = "HELLO,WORLD";
    uint8_t expected_string_len = (uint8_t)strlen(expected_string);
    uint8_t ii;

    actual_state.state.regDE.word   = StringToWrite;
    actual_state.state.regHL.word   = offsetof(memory_map_t, segments.vram.segments.bg_map1);
    actual_state.state.regBC.regs.b = expected_string_len;

    for(ii = 0; ii < expected_string_len; ii++)
    {
        expected_mem.mem.segments.vram.segments.bg_map1[ii] = expected_string[ii] - 0x1F;
    }

    RunROM(WriteStringToVRAM, &actual_state.state, &actual_mem.mem);

    AssertEqual_assert_memory_map_t(expected_mem, actual_mem, __LINE__, NULL);
    AssertEqual_assert_cpu_image_t(expected_state, actual_state, __LINE__, NULL);
}

void test_cpu_image_assert(void)
{
    assert_cpu_image_t assert_expected, assert_actual;
    cpu_image_t expected, actual;

    memset(&expected, 0, sizeof(expected));
    memset(&actual  , 0, sizeof(actual));

    assert_expected = Create_assert_cpu_image_t();
    assert_actual = Create_assert_cpu_image_t();

    assert_expected.state.regAF.word = 0x1234;
    assert_expected.assert_A = TRUE;

    assert_actual.state.regAF.word = 0x3412;

    AssertEqual_assert_cpu_image_t(assert_expected, assert_actual, __LINE__, NULL);
}

void test_memory_map_assert(void)
{
    assert_memory_map_t expected, actual;

    expected = Create_assert_memory_map_t();
    actual = Create_assert_memory_map_t();

    expected.mem.all[BOTTOM_OF_STACK - 1] = 0x34;
    expected.mem.all[BOTTOM_OF_STACK - 0] = 0x12;

    actual.mem.all[BOTTOM_OF_STACK - 1] = 0x34;
    actual.mem.all[BOTTOM_OF_STACK - 0] = 0x34;

    AssertEqual_assert_memory_map_t(expected, actual, __LINE__, NULL);
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
