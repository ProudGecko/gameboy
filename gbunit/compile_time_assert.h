#ifndef _COMPILE_TIME_ASSERT_H_
#define _COMPILE_TIME_ASSERT_H_

/* This macro was obtained from www.embedded.com.  To fully understand the magic
 * of how it works, see this site for further details:
 * http://www.eetimes.com/discussion/programming-pointers/4025549/Catching-errors-early-with-compile-time-assertions
 *
 * Basically, most compilers (Keil and Visual Studio included) don't allow you
 * to have preprocessor directives that use "sizeof" and "offsetof", as in:
 * #if (sizeof(my_structure_t) != 10)
 *    #error "bad structure size"
 * #endif
 * Other compilers (like Borland) allow you to do such things.
 *
 * Since some compilers' preprocessors don't support it, this is a trick to
 * get the same effect, without adding code to your project and
 * without allocating storage in memory to your project.
 *
 * This assertion macro can also be used with enums, since some preprocessors
 * (Keil, PIC, and Visual Studio included, Borland excluded) can't use enums in #if checks.
 * This macro saves us from having to turn the enum values into #define values.
 *
 * Note that for compilers that allow "0" to be a legal array size (like the PIC
 * compiler), then you instead probably need a "-1" instead of a "0" in the code below.
 * Since Keil allows negative array sizes like "-1", but does not allow array
 * sizes of 0, we use "0" below for Keil instead of "-1".
 *
 * Once we have this setup, we can do checks like:
 *    compile_time_assert(offsetof(std_table_07_t, STD_T07_Proc_Parm) == 3);
 *    compile_time_assert(sizeof(std_table_07_t) == 11);
 *
 * This helps us guarantee that the structure is as desired, accounting for
 * things like padding bytes, etc. that the compiler may sneak in.
 *
 * A disadvantage of this method is that when the assertion is false,
 * the error message the compiler gives you is a bit cryptic as in this (for the Keil compiler):
 * ".\LG\RAM_DATA.H(903): error C136: invalid dimension size: [0]".
 * and this for the PIC compiler:
 * "./LG/ram_data.h:903: error: size of array `assertion' is negative".
 * and this for the Visual Studio compiler (when using the "0" method):
 * "\lg\ram_data.h(903): error C2466: cannot allocate an array of constant size 0".
 * and this for the Visual Studio compiler (when using the "-1" method):
 * "ram_data.h(903): error C2118: negative subscript".
 * While the error message it gives may not be the best possible, at least it
 * gives you the line number of the failure.
 *
 * Note that the Keil compiler works only if you use the "0" method.  It doesn't work with the "-1" method.
 * Note that the PIC compiler works only if you use the "-1" method.  It doesn't work with the "0" method.
 * Note that the Visual Studio compiler works if you use either the "0" or "-1" method.
 *
 * Lint notes:
 * "-save" is used to save the current lint error settings.
 * "-e18"  is used to prevent this macro from giving this message:  "Error 18: Symbol 'assertion' redeclared (size) conflicts with line X".
 * "-e506" is used to prevent this macro from giving this message:  "Warning 506: Constant value Boolean".
 * "-e507" is used to prevent this macro from giving this message:  "Warning 507: Size incompatibility, converting 3 byte pointer to 2 byte integral".  Note:  this happens on the Keil compiler for some structure offset checks.
 * "-esym(752, assertion)" is used to prevent this macro from giving this message:  "Info 752: local declarator 'assertion' not referenced".
 * "-e762" is used to prevent this macro from giving this message:  "Info 762: Redundantly declared symbol 'assertion' previously declared at line X".
 * "-restore" is used to restore the last saved lint error settings.
 *
 * Notes regarding "-e18":
 * My guess why the above message is sometimes generated when using this macro
 * in lint, is because lint doesn't know about how we PACK() structures, so some
 * assert's maybe fail since they expand to an unpacked size in lint, which doesn't match
 * our hard-coded packed size checks, which makes the array size 0 (or -1), instead
 * of making the array size match all assert's that pass (which get an array size of 1).
 *
 * Notes regarding "-e19":
 * If we disable compile_time_assert() for lint completely, then an assert like:
 * "compile_time_assert(sizeof(my_structure_t) == 4);"
 * turns into this after the pre-processor runs:
 * ";"
 * Having just a single semicolon causes lint to see either:
 * - 2 semicolons in a row (one for the last valid statement and 1 left behind from the pre-processed assert.
 * or
 * - a single semicolon by itself, doing nothing.
 * When that happens lint gives messages like this for each assert (since it just seems the dummy semicolon):
 * "LG\ram_data.h(239:83): Error 19: Useless Declaration"
 * which lint defines as:
 * "A type appeared by itself without an associated variable, and the type was not a struct
 * and not a union and not an enum.  A double semi-colon can cause this as in:  int x;;"
 * Thus, to prevent that useless warning, we use -e19 when asserts are turned off in lint.
 *
 * Notes about why asserts are turned off in lint:
 * If a large enough number of asserts are used, lint will give an error message
 * like this (and then lint stops giving error messages about the rest of the code):
 * "LG\eemap.h(2370:83): Error 302: Exceeded available memory".
 * We want all of our code linted, so we don't want it to stop because memory runs out.
 * I think that the asserts cause a whole bunch of symbols to be added to lint's
 * search tree (when it searches if symbols are unused, etc.).  This causes lint to
 * allocate memory for all those symbols.  If you watch the Windows Task Manager and
 * look at the "Processes" tab, you see that when you lint see the dummy extern variable
 * from the assert, the "memory" tab showing the memory usage of the lint task slowly
 * goes up as it runs, using massive amounts of memory.  If it reaches 2GB, then it
 * stops and produces the Error 19 message noted above.  This happens because on
 * 32-bit Windows machines, you obviously have up to 4GB (2^32) of memory.
 * For each process, 32-bit Windows allocates only half of that (i.e. 2GB) for
 * virtual memory for each process for user mode (i.e. the programs you run),
 * while the other 2GB is always reserved for kernel memory (i.e. not your programs,
 * but rather drivers, the kernel, the Windows OS, etc.).
 * When lint uses tons of memory because of the asserts, if it finally reaches
 * the 2GB limit of 32-bit Windows, it gives up and stops.
 * To prevent tons of memory usage (and the stopping when it reaches 2GB), we turn
 * off the asserts for lint (since they don't add much value in lint anyways).
 * The asserts still exist in Visual Studio and in the embedded compiler (which
 * do add value since they make sure the assert is true for each compiler that
 * the code runs on).
 * When asserts are turned off in lint, lint only uses ~20MB (for example) of
 * virtual memory instead of 2GB.  When it uses tons of memory for the asserts,
 * your computer probably uses virtual memory on disk and thus swaps physical memory
 * to disk and thus writes up to 2GB to disk each time it runs (depending on how
 * much physical RAM you have).  Writing to disk is super slow, and thus makes
 * lint run very slow on a large project (for example, it might take 130 seconds
 * instead of 26 seconds).  Thus, we turn the asserts off for the lint build.
 */
#if (defined(DISABLE_COMPILE_ASSERTS) || defined(LINT_BUILD))
   #define compile_time_assert(cond) /*lint -save -e19 */  /*lint -restore */
#else
   #if 0
      // for the Keil compiler and the Visual Studio compiler.
      #define compile_time_assert(cond)         /*lint -save -e18 -e506 -e507 -esym(752, assertion) -e762 */ extern char assertion[(cond) ? 1 :  0] /*lint -restore */
   #else
      // for the PIC compiler, the Visual Studio compiler, and the GCC.
      #define compile_time_assert(cond)         /*lint -save -e18 -e506 -e507 -esym(752, assertion) -e762 */ extern char assertion[(cond) ? 1 : -1] /*lint -restore */
   #endif
#endif

#endif // _COMPILE_TIME_ASSERT_H_
