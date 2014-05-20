@echo off
SET THEFILE=C:\Users\Maerksch\Documents\Berufsschule\CoYOT(e)\bin\CoYOTe-win64(x86_64).exe
echo Linking %THEFILE%
C:\lazarus\fpc\2.6.4\bin\x86_64-win64\ld.exe -b pei-x86-64  --gc-sections  -s --subsystem windows --entry=_WinMainCRTStartup    -o "C:\Users\Maerksch\Documents\Berufsschule\CoYOT(e)\bin\CoYOTe-win64(x86_64).exe" "C:\Users\Maerksch\Documents\Berufsschule\CoYOT(e)\bin\link.res"
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end
