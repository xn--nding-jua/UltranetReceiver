@echo off
cls
echo Converting TTF-file to header-file...
del bitstream.h > nul
..\Tools\vidorcvt\vidorcvt.exe < "..\output_files\UltranetReceiver.ttf" > bitstream.h
echo Done.

echo Opening Arduino IDE...
"C:\Program Files\Arduino IDE\Arduino IDE.exe" FPGA_Loader.ino
echo Done.
rem pause