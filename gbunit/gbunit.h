#ifndef _GBUNIT_H_
#define _GBUNIT_H_

#include <stdint.h>
#include "gbunit_cpu_image.h"
#include "gbunit_memory_map.h"

#define RETURN_TO_GBUNIT_INDICATOR (0xFFFF)

void PushToGbStack(uint16_t value);
uint16_t PopFromGbStack();
void ReadFromGbMemory(uint16_t gb_src, void * host_dest, int len);
void WriteToGbMemory(const void * host_src, uint16_t gb_dest, int len);
void RunROM(uint16_t offset, cpu_image_t *cpu_state, memory_map_t *mem_state);

void AssertEqual_assert_cpu_image_t(assert_cpu_image_t expected, assert_cpu_image_t actual, unsigned int line, const char *msg);
void AssertEqual_assert_memory_map_t(assert_memory_map_t expected, assert_memory_map_t actual, unsigned int line, const char *msg);

assert_cpu_image_t Create_assert_cpu_image_t(void);
assert_memory_map_t Create_assert_memory_map_t(void);

#endif // _GBUNIT_H_
