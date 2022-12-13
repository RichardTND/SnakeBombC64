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
// ### HI SCORE DETECTION ###



// Low and high byte tables representing hi scores and names

hslo:           .byte <hiscore1
                .byte <hiscore2
                .byte <hiscore3
                .byte <hiscore4
                .byte <hiscore5
                .byte <hiscore6
                .byte <hiscore7
                .byte <hiscore8
                .byte <hiscore9
                .byte <hiscore10
                .byte 0
hshi:           .byte >hiscore1
                .byte >hiscore2
                .byte >hiscore3
                .byte >hiscore4
                .byte >hiscore5
                .byte >hiscore6
                .byte >hiscore7
                .byte >hiscore8
                .byte >hiscore9
                .byte >hiscore10
                .byte 0
nmlo:           .byte <name1
                .byte <name2
                .byte <name3
                .byte <name4
                .byte <name5
                .byte <name6
                .byte <name7
                .byte <name8
                .byte <name9
                .byte <name10
                .byte 0
nmhi:           .byte >name1
                .byte >name2
                .byte >name3
                .byte >name4
                .byte >name5
                .byte >name6
                .byte >name7
                .byte >name8
                .byte >name9
                .byte >name10
                .byte 0

name:       .text "         "
nameend:
                *=$8100 "HI SCORE CODE"
hiscorereader:  // Switch off all IRQs first
                lda #0
                sta $d015
                sta $d020
                sta $d021
                jsr stopints
                lda #$02
                sta $d022
                lda #$07
                sta $d023
                lda #0
                sta $02

                // Init starting letter char
                lda #1
                sta letterchar
                lda #0
                sta namefinished
                sta firebutton

// Setup hi score table directives
// and place them into zeropages

                ldx #$00
nextone:
                lda hslo,x
                sta $c1
                lda hshi,x
                sta $c2

                ldy #$00
scoreget:       lda score,y
scorecmp:       cmp ($c1),y
                bcc posdown
                beq nextdigit
                bcs posfound
nextdigit:     
                iny
                cpy #scorelen
                bne scoreget
                beq posfound
posdown:        
                inx
                cpx #listlen
                bne nextone
                beq nohiscore
posfound:
                stx $02
                cpx #listlen-1
                beq lastscore

                ldx #listlen-1
copynext:       
                lda hslo,x
                sta $c1
                lda hshi,x
                sta $c2
                lda nmlo,x
                sta $ac
                lda nmhi,x
                sta $ad
                dex
                lda hslo,x
                sta $c3
                lda hshi,x
                sta $c4
                lda nmlo,x
                sta $ae
                lda nmhi,x
                sta $af

                ldy #scorelen-1
copyscore:
                lda ($c3),y
                sta ($c1),y
                dey
                bpl copyscore
                lda ($c3),y
                sta ($c1),y
                dey
                bpl copyscore
                cpx $02
                bne copynext

                ldy #namelen-1
copyname:       lda ($ae),y
                sta ($ac),y
                dey
                bpl copyname

lastscore:      ldx $02
                lda hslo,x
                sta $c1
                lda hshi,x
                sta $c2
                lda nmlo,x
                sta $ac
                lda nmhi,x
                sta $ad
                jmp nameentry
placenewscore:  
                ldy #scorelen-1
putscore:
                lda score,y
                sta ($c1),y
                dey
                bpl putscore

                ldy #namelen-1
putname:        lda name,y
                sta ($ac),y
                dey
                bpl putname
nohiscore:
                jmp titlescreen
                
                        
           


                jmp titlescreen

// Main name entry, simply display the 
// name entry screen 
nameentry:
                ldx #$00
drawhiscorescreen:
                lda himatrix,x
                sta screen,x
                lda himatrix+$100,x
                sta screen+$100,x
                lda himatrix+$200,x
                sta screen+$200,x
                lda himatrix+$2e8,x
                sta screen+$2e8,x
                ldy himatrix,x
                lda attribs,y
                sta colour,x
                ldy himatrix+$100,x
                lda attribs,y
                sta colour+$100,x
                ldy himatrix+$200,x
                lda attribs,y
                sta colour+$200,x
                ldy himatrix+$2e8,x
                lda attribs,y
                sta colour+$2e8,x
                inx
                bne drawhiscorescreen

                lda #$1c
                sta $d018

                lda #$18
                sta $d016

                // Clear out the player's name

                ldx #$00
clearname:      lda #$20
                sta name,x
                inx
                cpx #$09
                bne clearname

                // Reset position of the player
                // name so that the very first
                // column gets read on new entry

                lda #<name
                sta namesm+1
                lda #>name
                sta namesm+2

// Setup a single IRQ raster interrupt player
// exclusively for the hi score name entry 
// routine.

                ldx #<hiirq
                ldy #>hiirq
                lda #$7f
                stx $0314
                sty $0315
                sta $dc0d
                sta $dd0d
                lda $dc0d
                lda $dd0d
                lda #$2e
                sta $d012
                lda #$1b
                sta $d011
                lda #$01
                sta $d019
                sta $d01a
        
                // Initialise title music for hi score
                lda #titlemusic
                jsr musicinit
                cli

// Main name entry loop routine

nameentryloop:
                jsr synctimer

                // Display name on screen

                ldx #$00
showname:       lda name,x
                sta screen+(20*40)+16,x
                lda #$0b
                sta colour+(20*40)+16,x
                inx
                cpx #9
                bne showname
        
                // Check if name input is finished

                lda namefinished
                bne stopnameentry
                jsr joycheck
                jmp nameentryloop
stopnameentry:
                jmp placenewscore

// Joystick control name entry check routine

joycheck:       lda letterchar
namesm:         sta name
                lda joydelay
                cmp #6
                beq joyhiok
                inc joydelay
                rts

joyhiok:        lda #0
                sta joydelay

                // Check joystick direction up

hiup:           lda #1
                bit $dc00
                beq lettergoesup
                jmp hidown
lettergoesup:   jmp letterup

hidown:         lda #2
                bit $dc00
                beq lettergoesdown
                jmp hifire
lettergoesdown: jmp letterdown

hifire:         lda $dc00
                lsr
                lsr
                lsr
                lsr
                lsr
                bit firebutton
                ror firebutton
                bmi nohijoy
                bvc nohijoy
                jmp select
nohijoy:        rts

                // Letter increments to next character
letterup:       inc letterchar
                lda letterchar
                cmp #27
                beq makeupendchar
                cmp #33
                beq achar
                rts
makeupendchar:  lda #30
                sta letterchar
                rts
autospace:      lda #32
                sta letterchar
                rts
achar:          lda #1
                sta letterchar
                rts

                // Letter goes down
letterdown:     dec letterchar
                lda letterchar
                beq spacechar
                lda letterchar
                cmp #29
                beq zchar
                rts
spacechar:      lda #32
                sta letterchar
                rts
zchar:          lda #26
                sta letterchar
                rts

// Char selected check for TICK or CROSS
// character. Otherwise switch to the next
// char position until rached past ninth 
// column 

select:         lda #0
                sta firebutton
                lda letterchar
checkdeletechar:
                cmp #31
                bne checkendchar
                lda namesm+1
                cmp #<name
                beq donotgoback
                dec namesm+1
                jsr housekeep
donotgoback:    rts

checkendchar:   cmp #30
                bne charisok
                lda #32
                sta letterchar
                jmp finishednow

charisok:       inc namesm+1
                lda namesm+1
                cmp #<name+9
                beq finishednow
hinofire:       rts
finishednow:    jsr housekeep
                lda #1
                sta namefinished
                rts

                // Name house keeping routine

housekeep:      ldx #$00
clearcharsn:    lda name,x
                cmp #30
                beq cleanup
                cmp #31
                beq cleanup
                jmp skipcleanup
cleanup:        lda #$20
                sta name,x
skipcleanup:    inx
                cpx #9
                bne clearcharsn
                rts

// IRQ raster interrupt for HI SCORE entry

hiirq:          asl $d019
                lda $dc0d
                sta $dd0d
                lda #$f8
                sta $d012
                lda #1
                sta rt
                jsr musicplayer
                jmp $ea7e

// Hi score pointers

joydelay:       .byte 0
letterchar:     .byte 1
namefinished:   .byte 0

                
        

