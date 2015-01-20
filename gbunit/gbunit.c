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

void AssertEqual_cpu_image_t(cpu_image_t expected, cpu_image_t actual, unsigned int line, const char *msg)
{
    char err_msg[1024];

    msg = (msg == NULL ? "" : msg);

    snprintf(err_msg, sizeof(err_msg), "Register pair AF mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX16(expected.regAF.word, actual.regAF.word, line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "Register pair BC mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX16(expected.regBC.word, actual.regBC.word, line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "Register pair DE mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX16(expected.regDE.word, actual.regDE.word, line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "Register pair HL mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX16(expected.regHL.word, actual.regHL.word, line, err_msg);

    // Comparing PC is disabled because it doesn't really make sense to compare this register in unit tests
    //snprintf(err_msg, sizeof(err_msg), "Program Counter mismatch. %s", msg);
    //UNITY_TEST_ASSERT_EQUAL_HEX16(expected.regPC, actual.regPC, line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "Stack Pointer mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX16(expected.regSP, actual.regSP, line, err_msg);
}

void AssertEqual_memory_map_t(memory_map_t expected, memory_map_t actual, uint16_t stack_ptr, unsigned int line, const char *msg)
{
    char err_msg[1024];
    int stack_depth = BOTTOM_OF_STACK - stack_ptr + 1;
    stack_ptr -= TOP_OF_STACK;
    msg = (msg == NULL ? "" : msg);

    snprintf(err_msg, sizeof(err_msg), "VRAM mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.segments.vram.all       , actual.segments.vram.all       , sizeof(actual.segments.vram)       , line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "External RAM mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.segments.eram           , actual.segments.eram           , sizeof(actual.segments.eram)       , line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "Internal RAM mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.segments.iram           , actual.segments.iram           , sizeof(actual.segments.iram)       , line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "OAM mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.segments.oam.all        , actual.segments.oam.all        , sizeof(actual.segments.oam)        , line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "Peripheral register mismatch. %s", msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.segments.peripherals.all, actual.segments.peripherals.all, sizeof(actual.segments.peripherals), line, err_msg);

    snprintf(err_msg, sizeof(err_msg), "Stack mismatch. SP = 0x%x. %s", (stack_ptr + TOP_OF_STACK), msg);
    UNITY_TEST_ASSERT_EQUAL_HEX8_ARRAY(expected.segments.stack + stack_ptr, actual.segments.stack + stack_ptr, stack_depth, line, err_msg);
}
