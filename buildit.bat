del snakebomb.prg
java -jar "c:\c64\tools\kickassembler\kickass.jar" snakebomb.asm
if not exist snakebomb.prg goto abort
c:\c64\tools\vice\x64sc.exe snakebomb.prg
abort