@echo off

set sourcePath=KDEE_HiResPG.ttf
set targetPath=KDEE_HiResPG.h

if exist tempStream.ttf (
del tempStream.ttf
)

echo "Converting FPGA Bitstream..."
java ReverseByte %sourcePath% tempStream.ttf

if not exist tempStream.ttf (
echo "mError while converting!"
Pause
exit
)

if exist %targetPath% (
del %targetPath%
)

copy tempStream.ttf %targetPath%

if not exist %targetPath% (
echo "Error: Failed to replace bitstream!"
Pause
exit
)

echo "Successfully replaced bitstream!"

if exist tempStream.ttf (
del tempStream.ttf
)

timeout 1