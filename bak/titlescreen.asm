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

// ### TITLE SCREEN ###
        
        jsr stopints

        

        lda #0
        sta pagetime
        sta pagetime+1
        sta pagevalue
        sta firebutton
        sta $d015
        ldx #$00
clearfullscreen:
        lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $06e8,x
        lda #$09
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $da00,x
        inx
        bne clearfullscreen

        ldx #$00
copylogocolour:
        lda logocolour,x
        sta colour,x
        lda logocolour+40,x
        sta colour+40,x
        lda logocolour+80,x
        sta colour+80,x
        lda logocolour+120,x
        sta colour+120,x
        lda logocolour+160,x
        sta colour+160,x
        lda logocolour+200,x
        sta colour+200,x
        lda logocolour+240,x
        sta colour+240,x
        lda logocolour+280,x
        sta colour+280,x
        lda logocolour+320,x
        sta colour+320,x
        lda logocolour+360,x
        sta colour+360,x
        inx
        bne copylogocolour

//      setup the presline colour
        ldx #$00
setuplinecolour:        
        lda #$0d
        sta colour+440,x
        sta colour+480,x
        sta colour+520,x
        sta colour+560,x
        sta colour+600,x
        sta colour+640,x
        sta colour+680,x
        sta colour+720,x        
        sta colour+760,x
        sta colour+800,x
        sta colour+840,x
        sta colour+880,x
        sta colour+920,x
        inx
        cpx #$28
        bne setuplinecolour
        
        lda #$02
        sta $d022
        lda #$07
        sta $d023


        

        ldx #0
clearsprtitle:
        lda #$00
        sta objpos,x
        sta $d000,x
        inx     
        cpx #$10
        bne clearsprtitle

        lda #$00
        sta $d015
       
        lda #0
        sta $d017
        sta $d01b
        sta $d01d
        lda #$0d
        sta $d027
        sta $d028
        lda #$0b
        sta $d025
        lda #$01
        sta $d026
        lda #$42
        sta objpos
        clc
        adc #$0c
        sta objpos+2
        lda #$52
        sta objpos+1
        sta objpos+3
        
        // Onetime - Display the credits page

        jsr displaycredits
        
        ldx #<tirq1
        ldy #>tirq1
        lda #$7f
        stx $0314
        sty $0315
        sta $dc0d
        sta $dd0d
        lda $dc0d
        lda $dd0d
        lda #$22
        sta $d012
        lda #$1b
        sta $d011
        lda #$18
        sta $d016
        lda #$01
        sta $d019
        sta $d01a
        lda #titlemusic
        jsr musicinit
        cli
        jmp titleloop

// ### Title screen IRQ ###

tirq1:  asl $d019
        lda $dc0d
        sta $dd0d
        lda #$22
        sta $d012
        lda #1
        sta rt
        jsr musicplayer
        
        ldx #<tirq2
        ldy #>tirq2
        stx $0314
        sty $0315
        jmp $ea7e

tirq2:  asl $d019
        lda #$8a
        sta $d012
        lda #$3b
        ldx #$78
        ldy #$02
        sta $d011
        stx $d018
        sty $dd00
         
        ldx #<tirq3
        ldy #>tirq3
        stx $0314
        sty $0315
        jmp $ea7e 

tirq3:  asl $d019
        lda #$ea
        sta $d012
        lda #$1b
        ldx #$1c
        ldy #$03
        sta $d011
        stx $d018
        sty $dd00
        lda #$18
        sta $d016
       
        ldx #<tirq4
        ldy #>tirq4
        stx $0314
        sty $0315
        jmp $ea7e

tirq4:  asl $d019
        lda #$f8
        sta $d012
        ldx #<tirq1
        ldy #>tirq1
        stx $0314
        sty $0315
        jmp $ea7e

titleloop:
        jsr synctimer
        jsr pageflipper
        
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi titleloop
        bvc titleloop
        jmp game 


// Page flipper routine

pageflipper:
        inc pagetime
        lda pagetime
        beq nextrout
        rts
nextrout:
        lda pagetime+1
        cmp #$02
        beq readnextpage
        inc pagetime+1
        rts
readnextpage:
        lda #0
        sta pagetime
        sta pagetime+1
       
        lda pagevalue
        cmp #1
        beq showhiscoretable
        cmp #2 
        beq showicons
        cmp #3
        beq showinstructions
        
        jmp setupcredits
showhiscoretable:
        jmp displayhiscores
showicons:
        jmp displayicons
showinstructions:
        jmp displayinstructions
        

// Display credits
displaycredits:

setupcredits:
        ldx #$00
creditsloop:
        lda credits,x
        sta screen2+440,x
        lda credits+(1*40),x
        sta screen2+480,x
        lda credits+(2*40),x
        sta screen2+520,x
        lda credits+(3*40),x
        sta screen2+560,x
        lda credits+(4*40),x
        sta screen2+600,x
        lda credits+(5*40),x
        sta screen2+640,x
        lda credits+(6*40),x
        sta screen2+680,x
        lda credits+(7*40),x
        sta screen2+720,x
        lda credits+(8*40),x
        sta screen2+760,x
        lda credits+(9*40),x
        sta screen2+800,x
        lda credits+(10*40),x
        sta screen2+840,x
        lda credits+(11*40),x
        sta screen2+920,x
        inx
        cpx #$28
        bne creditsloop
        lda #1
        sta pagevalue
        rts

displayhiscores:
       
        ldx #$00
hiscoreloop:
        lda hiscoretable,x
        sta screen2+440,x
        lda hiscoretable+(1*40),x
        sta screen2+480,x
        lda hiscoretable+(2*40),x
        sta screen2+520,x
        lda hiscoretable+(3*40),x
        sta screen2+560,x
        lda hiscoretable+(4*40),x
        sta screen2+600,x
        lda hiscoretable+(5*40),x
        sta screen2+640,x
        lda hiscoretable+(6*40),x
        sta screen2+680,x
        lda hiscoretable+(7*40),x
        sta screen2+720,x
        lda hiscoretable+(8*40),x
        sta screen2+760,x
        lda hiscoretable+(9*40),x
        sta screen2+800,x
        lda hiscoretable+(10*40),x
        sta screen2+840,x
        lda hiscoretable+(11*40),x
        sta screen2+880,x
        inx
        cpx #$28
        bne hiscoreloop
        lda #2
        sta pagevalue
        rts

displayicons:
        ldx #$00
iconsloop:
        lda advancetable,x
        sta screen2+440,x
        lda advancetable+(1*40),x
        sta screen2+480,x
        lda advancetable+(2*40),x
        sta screen2+520,x
        lda advancetable+(3*40),x
        sta screen2+560,x
        lda advancetable+(4*40),x
        sta screen2+600,x
        lda advancetable+(5*40),x
        sta screen2+640,x
        lda advancetable+(6*40),x
        sta screen2+680,x
        lda advancetable+(7*40),x
        sta screen2+720,x
        lda advancetable+(8*40),x
        sta screen2+760,x
        lda advancetable+(9*40),x
        sta screen2+800,x
        lda advancetable+(10*40),x
        sta screen2+840,x
        lda advancetable+(11*40),x
        sta screen2+880,x
        
        inx
        cpx #$28
        bne iconsloop
        lda #3
        sta pagevalue
        rts

displayinstructions:

        ldx #$00
instructionsloop:
        lda instructions,x
        sta screen2+440,x
        lda instructions+(1*40),x
        sta screen2+480,x
        lda instructions+(2*40),x
        sta screen2+520,x
        lda instructions+(3*40),x
        sta screen2+560,x
        lda instructions+(4*40),x
        sta screen2+600,x
        lda instructions+(5*40),x
        sta screen2+640,x
        lda instructions+(6*40),x
        sta screen2+680,x
        lda instructions+(7*40),x
        sta screen2+720,x
        lda instructions+(8*40),x
        sta screen2+760,x
        lda instructions+(9*40),x
        sta screen2+800,x
        lda instructions+(10*40),x
        sta screen2+840,x
        lda instructions+(11*40),x
        sta screen2+880,x
        inx
        cpx #$28
        bne instructionsloop
        lda #0
        sta pagevalue
        rts

xpos:   .byte 0
pagetime: .byte 0,0
pagevalue: .byte 0
credits:
        // .text "0000000000111111111112222222223333333333"
        // .text "0123456789012345678901234567890123456789"

           .text "         £ 2022 the new dimension       "
           .text "  written for the csdb snake fun compo  "
           .text "                                        "
           .text "    programming, charset and music by   "
           .text "             richard bayliss            "
           .text "                                        "
           .text "  game graphics, logo and loader pic by "
           .text "         hugues (ax!s) poisseroux       "
           .text "                                        "
           .text "   plug your joystick into port 2 then  "
           .text "             press fire to play         "
           .text "                                        "
           .text "                                        "
           .text "                                        "
hiscoretable:
           .text "       todays explosive hi scores       "
           .text "                                        "
           .text "         01. "
hiscorestart:

name1:     .text "colubrid  - "
hiscore1:  .text "011000         "
           .text "         02. "
name2:     .text "cobra     - "
hiscore2:  .text "009900         "
           .text "         03. "
name3:     .text "rattler   - "
hiscore3:  .text "008800         "
           .text "         04. "
name4:     .text "adder     - "
hiscore4:  .text "007700         "
           .text "         05. "
name5:     .text "boa       - "
hiscore5:  .text "006600         "
           .text "         06. "
name6:     .text "viper     - "
hiscore6:  .text "005500         "
           .text "         07. "
name7:     .text "python    - "
hiscore7:  .text "004400         "
           .text "         08. "
name8:     .text "old world - "
hiscore8:  .text "003300         "
           .text "         09. "
name9:     .text "coachwhip - "
hiscore9:  .text "002200         "
           .text "         10. "
name10:    .text "boomslang - "
hiscore10: .text "001100 "
hiscoreend: 
           .text "        "
           .text "                                        "
instructions:
           .text "               how to play              "
           .text "                                        "
           .text " guide your snake safely through the    "
           .text " lane. eat as much fruit as you possibly"
           .text " can, but avoid touching bombs or your  "
           .text " snake will explode, ending the game.   "
           .text "                                        "
           .text " there are eight levels to complete, and"
           .text " each level will become more faster and "
           .text " much more harder.         good luck !!!"
           .text "                                        "
           .text "                                        "
           

advancetable:
           .import binary "c64/advancetable.bin"

           