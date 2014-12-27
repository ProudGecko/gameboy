
@echo off

set project_name=adventure
set bgb=c:\Dropbox\retrodev\gameboy\emulators\bgb.exe

C:\windows\system32\taskkill /IM bgb.exe /F
del %project_name%.gb

path=c:\Dropbox\retrodev\gameboy\projects\bin\

rgbasm	-ocharacter.o	inc/character.asm
rgbasm	-ographics.o	inc/graphics.asm
rgbasm	-ohardware.o	inc/hardware.asm
rgbasm	-osprites.o		inc/sprites.asm
rgbasm	-otimer.o		inc/timer.asm
rgbasm	-ovars.o		inc/vars.asm

rgbasm	-o%project_name%.o %project_name%.asm

echo [Objects]			>  LINK
echo character.o		>> LINK
echo graphics.o			>> LINK
echo hardware.o			>> LINK
echo sprites.o			>> LINK
echo timer.o			>> LINK
echo vars.o				>> LINK
echo %project_name%.o	>> LINK
echo [Output]			>> LINK
echo %project_name%.gb	>> LINK

echo LINKING...

xlink LINK

echo FIXING...

rgbfix -p -v %project_name%.gb

del character.o
del graphics.o
del hardware.o
del sprites.o
del timer.o
del vars.o
del %project_name%.o
del LINK

START %bgb% %project_name%.gb