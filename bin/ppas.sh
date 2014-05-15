#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /home/philip/projects/CoYOT(e)/bin/CoYOTe-linux(x86_64)
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2   -s -L. -o "/home/philip/projects/CoYOT(e)/bin/CoYOTe-linux(x86_64)" "/home/philip/projects/CoYOT(e)/bin/link.res"
if [ $? != 0 ]; then DoExitLink /home/philip/projects/CoYOT(e)/bin/CoYOTe-linux(x86_64); fi
IFS=$OFS
