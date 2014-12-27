OUTPUT = write_vram_func

# Assembler path and flags
AS = rgbasm 
ASFLAGS = -v
CC = rgbasm 
CFLAGS = -v

# Linker path and flags
LD = rgblink
LDFLAGS = -m$(OUTPUT).map -n$(OUTPUT).sym -o$(OUTPUT).gb

# ROM fixer path and flags
FIX = rgbfix 
FIXFLAGS = -v -p0 $(OUTPUT).gb

VPATH = inc
#SFILES = empty.s
INCFILES = smiley.inc
OFILES = write_vram_func.o smiley.o

all: $(OUTPUT)

$(OUTPUT): $(OFILES)
	$(LD) $(LDFLAGS) $(OFILES)
	$(FIX) $(FIXFLAGS)

$(OFILES): %.o: %.s
	$(AS) $(ASFLAGS) -o$@ $<

#$(OFILES): $(INCFILES)

clean:
	rm -f $(OFILES) core *~ $(OUTPUT).gb $(OUTPUT).sym

