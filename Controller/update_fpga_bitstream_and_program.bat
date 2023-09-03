@echo off
cls
echo Converting TTF-file to header-file...
del bitstream.h > nul
..\Tools\vidorcvt\vidorcvt.exe < "..\FPGA\output_files\UltranetReceiver.ttf" > bitstream.h
echo Done.

echo Opening Arduino IDE...
"C:\Program Files\Arduino IDE\Arduino IDE.exe" Controller.ino
echo Done.
rem pause