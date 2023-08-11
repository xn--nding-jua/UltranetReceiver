@echo off
cls
echo Converting TTF-file to header-file...
del bitstream.h > nul
..\Tools\vidorcvt\vidorcvt.exe < "..\output_files\UltranetReceiver.ttf" > bitstream.h
echo Done.
rem pause