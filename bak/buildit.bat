del *.prg
java -jar "c:\c64\tools\kickassembler\kickass.jar" snakevsbomb.asm
if not exist snakevsbomb.prg goto abort
rem c:\c64\tools\exomizer\win32\exomizer.exe sfx $4000 snakevsbomb.prg -o snakevsbomb.prg -x3
c:\c64\tools\tscrunch\tscrunch.exe -x $080d -b snakevsbomb.prg snakevsbomb.prg
c:\c64\tools\vice\x64.exe snakevsbomb.prg
abort