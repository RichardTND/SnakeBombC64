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

// ### GAME CODE ###


// Kill off any existing gameirqs (This game will only
// use Kernal routines, since higher memory is NOT
// going to be used for this game.

        jsr stopints // Stop interrupts

// Initialize all of the game pointers

        ldx #$00
zeropointers:
        lda #$00
        sta pointers,x
        inx
        cpx #pointersend-pointers
        bne zeropointers

// Draw the game screen:

        ldx #$00
drawgamescreen:
        lda mapdata,x
        sta screen,x
        lda mapdata+$100,x
        sta screen+$100,x
        lda mapdata+$200,x
        sta screen+$200,x
        lda mapdata+$2e8,x
        sta screen+$2e8,x

// Now setup the game attributes

        ldy mapdata,x
        lda attribs,y
        sta colour,x
        ldy mapdata+$100,x
        lda attribs,y
        sta colour+$100,x
        ldy mapdata+$200,x
        lda attribs,y
        sta colour+$200,x
        ldy mapdata+$2e8,x
        lda attribs,y
        sta colour+$2e8,x
        inx
        bne drawgamescreen
       

        lda #$18 // Multicolour mode 
        sta $d016
        lda #$1c // Charset at $3000
        sta $d018

        // Set game charset multicolours RED and YELLOW

        lda #$02
        sta $d022
        lda #$07
        sta $d023


        jsr setupplayer

        ldx #$fb
        txs
// Setup game gameirq interrupts

        ldx #<gameirq1
        ldy #>gameirq1
        lda #$7f
        stx $0314
        sty $0315
        sta $dc0d
        sta $dd0d
        lda $dc0d
        lda $dd0d
        lda #$32
        sta $d012
        lda #$ff
        sta $d019
        sta $d01a
        lda #$1b
        sta $d011
        lda #$00
        jsr musicinit
        cli
        jmp gameloop

gameirq1:   // Raster split 1
        asl $d019
        lda $dc0d
        sta $dd0d
        lda #split1
        sta $d012
        ldx #<gameirq2
        ldy #>gameirq2
        stx $0314
        sty $0315
        jmp $ea7e

gameirq2:   // Raster split 2

        asl $d019
        lda #split2
        sta $d012
        lda ypos
        ora #$10
        sta $d011
        ldx #<gameirq3
        ldy #>gameirq3
        stx $0314
        sty $0315
        jmp $ea7e

gameirq3:
        asl $d019
        lda #split3
        sta $d012
        lda #$7f
        sta $d011
        lda #1
        sta rt
        ldx #<gameirq4
        ldy #>gameirq4
        stx $0314
        sty $0315
        jmp $ea7e

gameirq4:
        asl $d019
        lda #split4
        sta $d012

        lda #$1f
        sta $d011
        ldx #<gameirq1
        ldy #>gameirq1
        stx $0314
        sty $0315
        jsr musicplay
        jmp $ea7e

// SUBROUTINE: Stop interrupts playing 
        
stopints:

        sei
        lda #$00
        sta $d020
        sta $d021
        ldx #$31
        ldy #$ea
        lda #$7f
        stx $0314
        sty $0315
        sta $dc0d
        sta $dd0d
        lda $dc0d
        lda $dd0d
        lda #$ff
        sta $d019
        sta $d01a
        
        ldx #$00
clearsid:
        lda #$00
        sta $d400,x
        inx 
        cpx #$18
        bne clearsid 
        rts         

// ### Main game loop ###

gameloop:
        jsr synctimer
        jsr objtospr
        jsr gamescroller
        jsr gameanimationandcontrol
        jmp gameloop

gameanimationandcontrol:
        jsr animatesnake
        jsr playercontroller
        rts

// Sync raster time
// (Also linked with title screen and hi score name
// entry code)

synctimer:
        lda #0
        sta rt
        cmp rt
        beq *-3
        rts

// Object position to VIC sprite position

objtospr:
        ldx #$00
loop:   lda objpos+1,x
        sta $d001,x
        lda objpos,x
        asl
        ror $d010
        sta $d000,x
        inx
        inx
        cpx #$10
        bne loop
        rts

// Game scroller, scroll wraparound routine 

gamescroller:
        lda ypos
        and #$07
        clc
        adc #$01
        tax
        and #$07
        sta ypos
        txa
        adc #$f8 
        bcs dohardscroll
       
        rts
dohardscroll:
         
        jsr scrollseg1
        jsr scrollseg2
        rts

// Scrolling macro

        .macro ScrollRows(_row1, _row2){
        lda _row1,x
        sta _row2,x
}

//Scroll segment 1 
scrollseg1:
        ldx #$27
scrolloop1:
        :ScrollRows(row12,rowtemp)
        :ScrollRows(row11,row12)
        :ScrollRows(row10,row11)
        :ScrollRows(row9,row10)
        :ScrollRows(row8,row9)
        :ScrollRows(row7,row8)
        :ScrollRows(row6,row7)
        :ScrollRows(row5,row6)
        :ScrollRows(row4,row5)
        :ScrollRows(row3,row4)
        :ScrollRows(row2,row3)
        :ScrollRows(row1,row2)
        :ScrollRows(row0,row1)
        :ScrollRows(row19,row0)
        dex
        bpl scrolloop1
        rts
scrollseg2:
        ldx #$27
scrolloop2:
       
        :ScrollRows(row20,row21)
        :ScrollRows(row19,row20)
        :ScrollRows(row18,row19)
        :ScrollRows(row17,row18)
        :ScrollRows(row16,row17)
        :ScrollRows(row15,row16)
        :ScrollRows(row14,row15)
        :ScrollRows(row13,row14)
        :ScrollRows(rowtemp,row13)
        dex
        bpl scrolloop2
        rts
        
// Init routines - Setup player sprite

setupplayer:
        lda snakehead
        ldx snakebody
        ldy snaketail
        sta $07f8
        stx $07f9
        sty $07fa

        lda #$56
        sta objpos
        sta objpos+2
        sta objpos+4
        
        lda #$a0
        clc
        sta objpos+1
        adc #$12
        sta objpos+3
        adc #$12
        sta objpos+5

        lda #%00000111
        sta $d015
        sta $d01c

        lda #0
        sta $d017
        sta $d01d
        sta $d01b

        lda #$09
        ldx #$01
        ldy #$05
        sta $d025
        stx $d026
        sty $d027
        sty $d028        
        sty $d029
        rts
        
// Animation of snake

animatesnake:
        lda animdelay
        cmp #6
        beq dosnakeanim
        inc animdelay
        rts
dosnakeanim:
        lda #$00
        sta animdelay
        jsr animhead
        jsr animbodyandtail
        rts

        // Animate the snake's head
animhead:
        ldx animpointer1
        lda snakeheadframe,x
        sta $07f8 // Snake head hardware frame
        inx
        cpx #6
        beq resetsnakeheadanim
        inc animpointer1
        rts
resetsnakeheadanim:
        ldx #0
        stx animpointer1
        rts

        // Animate the snake's body and tail
animbodyandtail:
        ldx animpointer2
        lda snakebodyframe,x
        sta $07f9
        lda snaketailframe,x
        sta $07fa
        inx
        cpx #4
        beq resetsnakebodytailanim
        inc animpointer2
        rts

resetsnakebodytailanim:
        ldx #0
        stx animpointer2
        rts

// ### Player controller ###
// This controls the main player joystick functions

playercontroller:
        lda #4
        bit $dc00
        bne notleft
        lda objpos
        sec
        sbc #2
        cmp #stopzoneleft
        bcs updatesnakepos
        lda #stopzoneleft
updatesnakepos:
        sta objpos
        sta objpos+2
        sta objpos+4
nocontrol:
        rts
notleft:
        lda #8
        bit $dc00
        bne nocontrol
        lda objpos
        clc
        adc #2
        cmp #stopzoneright 
        bcc updatesnakepos
        lda #stopzoneright
        jmp updatesnakepos


// ### In game pointers ###

pointers:
rt:     .byte 0 // Sync Raster timer    
ypos:   .byte 0 // $D011 scroll control register    
animdelay: .byte 0
animpointer1: .byte 0
animpointer2: .byte 0
objpos: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
pointersend:

// Sprite animation frames

snakehead: .byte $80
snakebody: .byte $84
snaketail: .byte $88
explosion: .byte $83 
letterG: .byte $94
letterE: .byte $95
letterT: .byte $96 
letterR: .byte $97
letterA: .byte $98
letterD: .byte $99
letterY: .byte $9a
letterM: .byte $9b
letterO: .byte $9c
letterV: .byte $9d
letterW: .byte $9e
letterN: .byte $9f
letterL: .byte $a0

// Animation frames for snake
// (6 frames)

snakeheadframe:
        .byte $80,$81,$82,$83
        .byte $82,$81

// Snake body (4 frames)

snakebodyframe:
        .byte $84,$85,$86,$87

// Snake tail (4 frames)

snaketailframe:
        .byte $88,$89,$8a,$89

// Explosion (9 frames)

explosionframe:
        .byte $8b,$8c,$8d,$8e,$8f
        .byte $90,$91,$92,$93
