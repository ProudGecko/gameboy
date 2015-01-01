gameboy
=======

Gameboy Homebrew Development

RGBDS Setup
-----------
Linux
   Build from source
   Install rgbasm, rblink, and rgfix to /usr/local/bin

Windows
   Unzip rgbds-0.0.2-windows.zip to C:\rgbds
   You should have a directory structure like follows:
      C:\rgbds>dir /B
      rgbasm.exe
      rgbasm.html
      rgbds.html
      rgbfix.exe
      rgbfix.html
      rgblib.exe
      rgblib.html
      rgblink.exe
      rgblink.html

   If when building a project with the Windows binaries you may
   get an error about an unrecognized -v option.  Simply remove
   this option from the CFLAGS and ASFLAGS variables.  This is
   the "verbose" option for the Linux build but isn't supported
   by the version of the Windows binaries provided.
