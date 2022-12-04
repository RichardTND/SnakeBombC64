// ******************************
//            SNAKE BOMB
//            ----------
//
//        By Richard Bayliss
//
//  Written in CBMPRGStudio V4.0
//    and Kick Assembler V5.2
//
//   (C) 2022 The New Dimension
// *******************************

// ### MAIN PROJECT SOURCE ###

// ### Variables and macros ###

        .import source "variables.asm"
        .import source "macros.asm"
        
BasicUpstart2(game)

// ### Title screen scrolltext ###

        *=$0900 "SCROLLTEXT"
scrolltext:
        .import text "c64/scrolltext.txt"

// ### Import music data ###

        *=$1000 "MUSIC"
musicdata:
        .import c64 "c64/music.prg"

// ### Import game sprite data ###

        *=$2000 "SPRITES"
        .import binary "c64/gamesprites.bin"

// ### Import game character graphics

        *=$3000 "CHARSET"
        .import binary "c64/gamecharset.bin"

// ### Import game screen graphics 

        *=$3800 "GAME SCREEN"
mapdata:
        .import binary "c64/gamemap.bin"

// ### Import game screen attributes 
        *=$3c00 "GAME CHAR ATTRIBUTES"
attribs:
        .import binary "c64/gameattribs.bin"

// ### Main Game code
        *=$4000 "GAME CODE"
game:
        .import source "gamecode.asm"

// ### Import game logo bitmap
        *=$6000 "LOGO BITMAP DATA"
        .import binary "c64/Logo.kla"

        


