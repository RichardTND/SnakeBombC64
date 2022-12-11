// ******************************
//         SNAKE vs BOMB
//         -------------
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
        
BasicUpstart2(setup)

        *=$080d "One time code setup"


setup:  lda $d012
        cmp $d012
        beq *-3
        bmi setup
        cmp #$20
        bcc setntsc
        lda #1
        sta system
        lda #$31
        sta leveltimelimit

        jmp main
setntsc: 
        lda #0
        sta system
        lda #$41
        sta leveltimelimit
        
main:   lda #$36
        sta $01
        jmp titlescreen

// ### Import music data ###

        *=$1000 "TITLE SCREEN CODE"
titlescreen:
        .import source "titlescreen.asm"

        *=$1d00 "Sprite sinus table"
sinustable: .byte 49,48,48,47,47,46
      .byte 46,45,45,44,44,43
      .byte 43,43,42,42,42,41
      .byte 41,41,41,41,40,40
      .byte 40,40,40,40,40,40
      .byte 40,40,40,40,40,40
      .byte 41,41,41,41,42,42
      .byte 42,42,43,43,43,44
      .byte 44,45,45,46,46,47
      .byte 47,48,48,49,50,50
      .byte 51,51,52,53,54,54
      .byte 55,56,57,57,58,59
      .byte 60,61,61,62,63,64
      .byte 65,66,67,67,68,69
      .byte 70,71,72,73,74,75
      .byte 76,77,78,79,79,80
      .byte 81,82,83,84,85,86
      .byte 87,88,89,90,90,91
      .byte 92,93,94,95,96,96
      .byte 97,98,99,100,100,101
      .byte 102,103,103,104,105,105
      .byte 106,107,107,108,108,109
      .byte 109,110,110,111,111,112
      .byte 112,113,113,113,114,114
      .byte 114,115,115,115,115,115
      .byte 116,116,116,116,116,116
      .byte 116,116,116,116,116,116
      .byte 116,116,115,115,115,115
      .byte 114,114,114,114,113,113
      .byte 113,112,112,111,111,110
      .byte 110,109,109,108,108,107
      .byte 106,106,105,105,104,103
      .byte 102,102,101,100,99,99
      .byte 98,97,96,95,95,94
      .byte 93,92,91,90,89,89
      .byte 88,87,86,85,84,83
      .byte 82,81,80,79,78,77
      .byte 77,76,75,74,73,72
      .byte 71,70,69,68,67,66
      .byte 66,65,64,63,62,61
      .byte 60,60,59,58,57,56
      .byte 56,55,54,53,53,52
      .byte 51,51,50,49
        
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
        *=$5800 "LOGO BITMAP DATA"
        .import c64 "c64/snakelogo.prg"

// ### Import all music data (Goat Tracker Ultra V1.4.1)        
        *=$9000 "ALL MUSIC DATA AND PLAYER"
        .import c64 "c64/music.prg"


