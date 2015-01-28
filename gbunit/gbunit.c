#include <stdio.h>
#include <string.h>
#include "stdint.h"
#include "gbunit.h"
#include "gboy.h"
#include "gboy_cpu.h"
#include "unity.h"
#include "unity_internals.h"

Uint8 addr_sp[0x10000];
long addr_sp_ptrs[16];
long chg_gam;
Uint32 gboy_mode; // Game Boy/Color Game Boy mode
FILE *boot_file = NULL;
char *file_path;
int gbddb = 0;
long gb_vbln_clks[2];
long gb_oam_clks[2];
long gb_hblank_clks[2];
long gb_vram_clks[2];
Uint32 fullscreen;
long lcd_vbln_hbln_ctrl;
Uint32 skip_next_frame;
long nb_spr;
long spr_cur_extr;

void rom_exec(int offset);

void gddb_main(int null_null, Uint8 *ptr_gboy_pc, Uint8 *ptr_op_rec)
{
}

void vid_start(void)
{
}

void vid_reset(void)
{
}

void snd_reset(void)
{
}

void snd_start(void)
{
}

void gddb_reset()
{
}

DECLSPEC void SDLCALL SDL_Quit(void)
{
}

void io_ctrl_wr(Uint8 io_off, Uint8 io_new)
{
}

Uint8 sgb_read()
{
    return 0;
}

void PushToGbStack(uint16_t value)
{
    regs_sets.regs[SP].UWord -= 2;

	Uint16 gb_addr = regs_sets.regs[SP].UWord;
	Uint8 *host_addr = (Uint8 *)(addr_sp_ptrs[gb_addr >> 12] + gb_addr);

	mem_wr(gb_addr    , (Uint8)value       , host_addr);
	mem_wr(gb_addr + 1, (Uint8)(value >> 8), host_addr + 1);
}

uint16_t PopFromGbStack()
{
	Uint16 gb_addr = regs_sets.regs[SP].UWord;
	Uint8 *host_addr = (Uint8 *)(addr_sp_ptrs[gb_addr>>12]+gb_addr);

	Uint16 val;
	val = ((Uint16)mem_rd(gb_addr+1, host_addr+1))<<8;
	val = ((Uint16)mem_rd(gb_addr, host_addr)) | val;

	regs_sets.regs[SP].UWord += 2;

	return val;
}

void ReadFromGbMemory(uint16_t gb_src, void * host_dest, int len)
{
    int loop_ctr;

    for(loop_ctr = 0; loop_ctr < len; loop_ctr++)
    {
        Uint8 *host_addr = (Uint8 *)(addr_sp_ptrs[gb_src >> 12] + gb_src);
        ((uint8_t *)host_dest)[loop_ctr] = mem_rd(gb_src++, host_addr);
    }
}

void WriteToGbMemory(const void * host_src, uint16_t gb_dest, int len)
{
    int loop_ctr;

    for(loop_ctr = 0; loop_ctr < len; loop_ctr++)
    {
        Uint8 *host_addr = (Uint8 *)(addr_sp_ptrs[gb_dest >> 12] + gb_dest);
        mem_wr(gb_dest++, ((uint8_t *)host_src)[loop_ctr], host_addr);
    }
}

/* RunROM - Runs the loaded ROM beginning at the given offset and returns once the
 *   outer most RET/RET C/RET NC/RET Z/RET NZ/RETI instruction is called which would
 *   normally return to a calling routine
 *
 * Parameters:
 *   offset - The offset into the ROM where execution should start
 *   *cpu_state - The initial CPU register setup
 *   *mem_state - The initial memory setup
 *
 * Returns:
 *   via *cpu_state - The final CPU register state
 *   via *mem_state - The final memory state
 */
void RunROM(uint16_t offset, cpu_image_t *cpu_state, memory_map_t *mem_state)
{
    // Setup memory map
    WriteToGbMemory(mem_state->segments.vram.all       , VRAM_START       , VRAM_SIZE);
    WriteToGbMemory(mem_state->segments.eram           , ERAM_START       , ERAM_SIZE);
    WriteToGbMemory(mem_state->segments.iram           , IRAM_START       , IRAM_SIZE);
    WriteToGbMemory(mem_state->segments.oam.all        , OAM_START        , OAM_SIZE);
    WriteToGbMemory(mem_state->segments.peripherals.all, PERIPHERALS_START, PERIPHERALS_SIZE);
    WriteToGbMemory(mem_state->segments.stack          , TOP_OF_STACK     , STACK_SIZE);

    // Setup registers
    regs_sets.regs[AF].UWord = cpu_state->regAF.word;
    regs_sets.regs[BC].UWord = cpu_state->regBC.word;
    regs_sets.regs[DE].UWord = cpu_state->regDE.word;
    regs_sets.regs[HL].UWord = cpu_state->regHL.word;
    regs_sets.regs[SP].UWord = cpu_state->regSP;

    PushToGbStack(RETURN_TO_GBUNIT_INDICATOR);

    // Setup PC and run ROM
	regs_sets.regs[PC].UWord = offset;
    rom_exec(offset);

    cpu_state->regAF.word = regs_sets.regs[AF].UWord;
    cpu_state->regBC.word = regs_sets.regs[BC].UWord;
    cpu_state->regDE.word = regs_sets.regs[DE].UWord;
    cpu_state->regHL.word = regs_sets.regs[HL].UWord;
    cpu_state->regSP      = regs_sets.regs[SP].UWord;

    ReadFromGbMemory(VRAM_START       , mem_state->segments.vram.all       , VRAM_SIZE);
    ReadFromGbMemory(ERAM_START       , mem_state->segments.eram           , ERAM_SIZE);
    ReadFromGbMemory(IRAM_START       , mem_state->segments.iram           , IRAM_SIZE);
    ReadFromGbMemory(OAM_START        , mem_state->segments.oam.all        , OAM_SIZE);
    ReadFromGbMemory(PERIPHERALS_START, mem_state->segments.peripherals.all, PERIPHERALS_SIZE);
    ReadFromGbMemory(TOP_OF_STACK     , mem_state->segments.stack          , STACK_SIZE);
}

assert_cpu_image_t Create_assert_cpu_image_t(void)
{
    assert_cpu_image_t image;

    memset(&image, 0, sizeof(image));

    return image;
}

assert_memory_map_t Create_assert_memory_map_t(void)
{
    assert_memory_map_t mem;

    memset(&mem, 0, sizeof(mem));

    mem.stack_ptr = BOTTOM_OF_STACK;        // Essentially the same as setting the stack pointer to zero.

    return mem;
}

void AssertEqual_assert_cpu_image_t(assert_cpu_image_t expected, assert_cpu_image_t actual, unsigned int line, const char *msg)
{
    char err_msg[1024];

    msg = (msg == NULL ? "" : msg);

    if (expected.assert_A)
    {
        snprintf(err_msg, sizeof(err_msg), "Register A mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regAF.regs.a, actual.state.regAF.regs.a, line, err_msg);
    }
    if (expected.assert_flags_all)
    {
        snprintf(err_msg, sizeof(err_msg), "Register F mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regAF.regs.flags.byte, actual.state.regAF.regs.flags.byte, line, err_msg);
    }

    if (expected.assert_B)
    {
        snprintf(err_msg, sizeof(err_msg), "Register B mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regBC.regs.b, actual.state.regBC.regs.b, line, err_msg);
    }
    if (expected.assert_C)
    {
        snprintf(err_msg, sizeof(err_msg), "Register C mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regBC.regs.c, actual.state.regBC.regs.c, line, err_msg);
    }

    if (expected.assert_D)
    {
        snprintf(err_msg, sizeof(err_msg), "Register D mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regDE.regs.d, actual.state.regDE.regs.d, line, err_msg);
    }
    if (expected.assert_E)
    {
        snprintf(err_msg, sizeof(err_msg), "Register E mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regDE.regs.e, actual.state.regDE.regs.e, line, err_msg);
    }

    if (expected.assert_H)
    {
        snprintf(err_msg, sizeof(err_msg), "Register H mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regHL.regs.h, actual.state.regHL.regs.h, line, err_msg);
    }
    if (expected.assert_H)
    {
        snprintf(err_msg, sizeof(err_msg), "Register L mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regHL.regs.l, actual.state.regHL.regs.l, line, err_msg);
    }

    if(expected.assert_PC)
    {
        snprintf(err_msg, sizeof(err_msg), "Program Counter mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regPC, actual.state.regPC, line, err_msg);
    }

    if (expected.assert_SP)
    {
        snprintf(err_msg, sizeof(err_msg), "Stack Pointer mismatch. %s", msg);
        UNITY_TEST_ASSERT_EQUAL_HEX16(expected.state.regSP, actual.state.regSP, line, err_msg);
    }
}

void AssertEqual_assert_memory_map_t(assert_memory_map_t expected, assert_memory_map_t actual, unsigned int line, const char *msg)
{
    char err_msg[1024];
    msg = (msg == NULL ? "" : msg);

    snprintf(err_msg, sizeof(err_msg), "VRAM tile data mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.mem.segments.vram.segments.tile_data, actual.mem.segments.vram.segments.tile_data, sizeof(actual.mem.segments.vram.segments.tile_data), line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "VRAM bg map 1 mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.mem.segments.vram.segments.bg_map1, actual.mem.segments.vram.segments.bg_map1, sizeof(actual.mem.segments.vram.segments.bg_map1), line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "VRAM bg map 2 mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.mem.segments.vram.segments.bg_map2, actual.mem.segments.vram.segments.bg_map2, sizeof(actual.mem.segments.vram.segments.bg_map2), line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "External RAM mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.mem.segments.eram           , actual.mem.segments.eram           , sizeof(actual.mem.segments.eram)       , line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "Internal RAM mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.mem.segments.iram           , actual.mem.segments.iram           , sizeof(actual.mem.segments.iram)       , line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "OAM mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.mem.segments.oam.all        , actual.mem.segments.oam.all        , sizeof(actual.mem.segments.oam)        , line, err_msg);

    // I'm not sure how useful this is.  For now it's disabled
    #if 0
    snprintf(err_msg, sizeof(err_msg), "Peripheral register mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.mem.segments.peripherals.all, actual.mem.segments.peripherals.all, sizeof(actual.mem.segments.peripherals), line, err_msg);
    #endif // 0

    if (expected.num_stack_items_to_verify > 0)
    {
    UNITY_TEST_ASSERT(expected.stack_ptr - (expected.num_stack_items_to_verify * 2) >= BOTTOM_OF_STACK, line, "Expected stack pointer and number of items to verify cause underflow of expected stack");
    UNITY_TEST_ASSERT(actual.stack_ptr - (expected.num_stack_items_to_verify * 2) >= BOTTOM_OF_STACK, line, "Actual stack pointer and expected number of items to verify cause underflow of actual stack");

    snprintf(err_msg, sizeof(err_msg), "Stack mismatch. SP = 0x%x. %s", expected.stack_ptr, msg);
    UNITY_TEST_ASSERT_EQUAL_HEX16_ARRAY(expected.mem.segments.stack + (expected.stack_ptr - TOP_OF_STACK),
                                       actual.mem.segments.stack +   (actual.stack_ptr - TOP_OF_STACK), expected.num_stack_items_to_verify, line, err_msg);
    }
}
