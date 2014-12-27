OUTPUT = boring_background

# Assembler path and flags
AS = motorgb
ASFLAGS = -v
CC = motorgb
CFLAGS = -v

# Linker path and flags
LD = xlink
LDFLAGS = -m$(OUTPUT).map -o$(OUTPUT).gb -tg

# ROM fixer path and flags
FIX = xgbfix
FIXFLAGS = -v -p $(OUTPUT).gb

VPATH = inc
INCFILES = 
OFILES = boring_background.o

all: $(OUTPUT)

$(OUTPUT): $(OFILES)
	$(LD) $(LDFLAGS) $(OFILES)
	$(FIX) $(FIXFLAGS)

$(OFILES): %.o: %.s
	$(AS) $(ASFLAGS) -o$@ $<

#$(OFILES): $(INCFILES)

clean:
	rm -f $(OFILES) core *~ $(OUTPUT).gb $(OUTPUT).sym

