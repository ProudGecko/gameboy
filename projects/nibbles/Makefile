
# Assembler path and flags
AS = motorgb
ASFLAGS = -v
CC = motorgb
CFLAGS = -v

# Linker path and flags
LD = xlink
LDFLAGS = -mnibbles.map -onibbles.gb -tg

VPATH = inc
#SFILES = nibbles.s border_tiles.s snake_body_tiles.s
INCFILES = border_tiles.inc snake_body_tiles.inc
OFILES = nibbles.o vars.o hardware.o border_tiles.o snake_body_tiles.o

all: nibbles

nibbles: $(OFILES)
	$(LD) $(LDFLAGS) $(OFILES)

$(OFILES): %.o: %.s
	$(AS) $(ASFLAGS) -o$@ $<

#$(OFILES): $(INCFILES)

clean:
	rm -f $(OFILES) core *~ result.gb result.sym

