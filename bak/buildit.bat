del snakevsbomb.prg
java -jar "c:\c64\tools\kickassembler\kickass.jar" snakevsbomb.asm
if not exist snakebomb.prg goto abort
c:\c64\tools\tscrunch\tscrunch.exe -x $4000 -b snakevsbomb.prg snakevsbomb.prg
c:\c64\tools\vice\x64sc.exe snakevsbomb.prg
abort