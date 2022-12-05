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

// Zero score 
        ldx #$00
zeroscore:
        lda #$30
        sta score,x
        inx
        cpx #6
        bne zeroscore
        

// Initialize stuff

        lda #1
        sta scrollspeed+1
        lda #0
        sta levelpointer
        sta leveltime
        sta leveltime+1
        lda #8
        sta spawnlimit


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
        inx
        bne drawgamescreen

// Now setup the game attributes
        ldx #$00
setupattribs:
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
        bne setupattribs

// Backup the bottom map position to chartemp 

        ldx #$00
backuploop:
        lda mapdata+(18*40),x
        sta chartemp,x
        inx
        cpx #$50
        bne backuploop
       

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

        // Mask score panel to screen once
        
        jsr maskpanel

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
        lda #$22
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
     
        lda $d011
        and #$07
        ora #$70      
        ldx #$06
        dex
        bne *-1 
        sta $d011
       
        ldx #<gameirq4
        ldy #>gameirq4
        stx $0314
        sty $0315
        jmp $ea7e

gameirq4:
        asl $d019
        lda #split4
        sta $d012
       
        lda #$17
        sta $d011
       
         lda #1
        sta rt
        jsr musicplay
        ldx #<gameirq1
        ldy #>gameirq1
        stx $0314
        sty $0315
        
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
        
        jsr gamescroller
        jsr gameanimationandcontrol
        jsr gamecontrol
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
        jsr objtospr
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
scrollspeed:
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
        jsr pickobstacle
        rts


//Scroll segment 1 
scrollseg1:
        ldx #$27
scrolloop1:
        :ScrollRows(row10,rowtemp)
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
      
        dex
        bpl scrolloop1

        ldx #$27
getbackup:
        :ScrollRows(chartemp+40,row0)
        :ScrollRows(chartemp,chartemp+40)
        dex
        bpl getbackup
        rts

scrollseg2:
        ldx #$27
scrolloop2:
        :ScrollRows(row18,row19)
        :ScrollRows(row17,row18)
        :ScrollRows(row16,row17)
        :ScrollRows(row15,row16)
        :ScrollRows(row14,row15)
        :ScrollRows(row13,row14)
        :ScrollRows(row12,row13)
        :ScrollRows(row11,row12)
        :ScrollRows(rowtemp,row11)
        dex
        bpl scrolloop2

        ldx #$27
placenext:
        :ScrollRows(row18,chartemp)
        dex
        bpl placenext
        rts
 
 
      
// Select obstacle - before that can be 
// done, there must be a delay 

pickobstacle:
        inc spawntime
        lda spawntime
        cmp spawnlimit
        beq spawnobject
        cmp #1
        beq skipfill
        jmp filllane

filllane:
        ldy #$0f
blankout:
        lda #$00
        sta chartemp+$0c,y
        sta chartemp+$34,y
        dey
        bpl blankout
skipfill:
        rts

spawnobject:
        lda #$00
        sta spawntime
        jsr random5
        jsr random8
        jmp processspawn
        rts

        // Randomly select number between
        // 1 and 5 (charsets)
random5:
        ldx randpointer1
        lda randtable1,x
        sta sequence1
        inc randpointer1
        rts

        // Randomly select number between 1
        // and 8 (char position)
random8:
        ldx randpointer2
        lda randtable2,x
        sta sequence2
        inc randpointer2
        rts
        
        // Process the object 

processspawn:
        ldx sequence1
        lda char_top_left,x
        sta charsrc1+1
        lda char_top_right,x
        sta charsrc2+1
        lda char_bottom_left,x
        sta charsrc3+1
        lda char_bottom_right,x
        sta charsrc4+1

        // Process the object char position

        ldx sequence2
        lda top_left_lo,x
        sta chartgt1+1
        lda top_right_lo,x
        sta chartgt2+1
        lda bottom_left_lo,x
        sta chartgt3+1
        lda bottom_right_lo,x
        sta chartgt4+1
        
        // Active development of object

charsrc1:
       lda #$00
chartgt1:
       sta chartemp+$0c
charsrc2:
       lda #$00
chartgt2:
       sta chartemp+$0d
charsrc3:
       lda #$00
chartgt3:
       sta chartemp+$0c+40
charsrc4:
       lda #$00
chartgt4:
       sta chartemp+$0d+40
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
        
        lda #$98
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
        jsr sprcharcollision
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



// Custom sprite to charset collision detection

sprcharcollision:
testcollision:
        lda $d000
        sec
csmod1: sbc #$10
        sta zp
        lda $d010
        lsr
        lda zp
        ror
        lsr
        lsr
        sta zp+3
        lda $d001
        sec
csmod2: sbc #$2a
        lsr
        lsr
        lsr
        sta zp+4
        lda #<screen
        sta zp+1
        lda #>screen
        sta zp+2
        ldx zp+4
        beq checkchar
colloop:
        lda zp+1
        clc
        adc #$28
        sta zp+1
        lda zp+2
        adc #$00
        sta zp+2
        dex
        bne colloop

// Check char ID to ensure objects match

checkchar:
        ldy zp+3
        jsr checkapple
        jsr checkbanana
        jsr checkcherries
        jsr checkstrawberry
        jmp checkbomb

// Check if the player has collided into an apple


checkapple:
        ldy zp+3
        lda (zp+1),y
        cmp #apple_top_left
        beq removeappletopleft
        cmp #apple_top_right 
        beq removeappletopright
        rts

removeappletopleft:
        :ReplaceCharTopLeft(score_100_top_left, score_100_top_right, score_100_bottom_right, score_100_bottom_left)
        jmp score100pts
        
removeappletopright:
        :ReplaceCharTopRight(score_100_top_right, score_100_top_left, score_100_bottom_left, score_100_bottom_right)
        jmp score100pts

// Check if the player has collided into a banana

checkbanana:
        ldy zp+3
        lda (zp+1),y
        cmp #banana_top_left
        beq removebananatopleft
        cmp #banana_top_right
        beq removebananatopright
        rts

removebananatopleft:
        :ReplaceCharTopLeft(score_200_top_left, score_200_top_right, score_200_bottom_right, score_200_bottom_left)
        jmp score200pts

removebananatopright:
        :ReplaceCharTopRight(score_200_top_right, score_200_top_left, score_200_bottom_left, score_200_bottom_right)
        jmp score200pts

// Check if the player has collided into cherries

checkcherries:
         ldy zp+3
         lda (zp+1),y
         cmp #cherries_top_left
         beq removecherriestopleft
         cmp #cherries_top_right
         beq removecherriestopright
         rts

removecherriestopleft:
        :ReplaceCharTopLeft(score_300_top_left, score_300_top_right, score_300_bottom_right, score_300_bottom_left)
        jmp score300pts
removecherriestopright:
        :ReplaceCharTopRight(score_300_top_right, score_300_top_left, score_300_bottom_left, score_300_bottom_right) 
        jmp score300pts

// Check if the player has collided into a strawberry

checkstrawberry:
        ldy zp+3
        lda (zp+1),y
        cmp #strawberry_top_left
        beq removestrawberrytopleft
        cmp #strawberry_top_right
        beq removestrawberrytopright
        rts

removestrawberrytopleft:
        :ReplaceCharTopLeft(score_500_top_left, score_500_top_right, score_500_bottom_right, score_500_bottom_left)
        jmp score500pts
removestrawberrytopright:
        :ReplaceCharTopRight(score_500_top_right, score_500_top_left, score_500_bottom_left, score_500_bottom_right)
        jsr score500pts


// Finally check if the player has collided into a bomb

checkbomb:
        ldy zp+3
        lda (zp+1),y
        cmp #bomb_top_left
        beq removebombtopleft
        cmp #bomb_top_right
        beq removebombtopright
        rts

removebombtopleft:
        :ReplaceCharTopLeft(death_top_left, death_top_right, death_bottom_right, death_bottom_left)
        jmp destroyplayer
removebombtopright:
        :ReplaceCharTopRight(death_top_right, death_top_left, death_bottom_left, death_bottom_right)
        jmp destroyplayer
        
// Game control - Tests game timer and level status

gamecontrol:
        
        lda leveltime //Miliseconds
        
        cmp #$32 
        beq switchsecond
        inc leveltime
        rts
switchsecond:
        lda #0
        sta leveltime
        jsr scorein10
        lda leveltime+1
        cmp #31       // 30 seconds 
        beq switchtonextlevel
        inc leveltime+1
       
        rts

// New level, faster speed - less spawn time

switchtonextlevel:
        lda #0
        sta leveltime+1
        sta leveltime
        inc levelpointer
        lda #2
      //  sta ypos
        sta spawntime
        
        lda spawnlimit
        sec
        sbc #2
        cmp #2
        bcs skipdeduct
        lda #2
        sta spawnlimit
skipdeduct:

        inc scrollspeed+1
        lda scrollspeed+1
        cmp #9
        beq gamecomplete
        jmp maskpanel

gamecomplete:
        jmp tempwait // For now jumps to flashing border

// Mask score panel to screen RAM

maskpanel:
        lda levelpointer
        clc
        adc #$01
        eor #$30
        sta levelchars
        ldx #0
copyscorehi:
        lda score,x
        sta scorechars,x
        lda hiscore,x
        sta hiscorechars,x
        inx
        cpx #6
        bne copyscorehi
        rts

// Scoring points. (This is based on the type of fruit
// which the player has collected).

// Apple 100 points
// Banana 200 points
// Cherries 300 points
// Strawberry 500 points

score500pts:
        jsr scorein100
        jsr scorein100
score300pts:
        jsr scorein100
score200pts:
        jsr scorein100
score100pts:
        jsr scorein100
        rts

scorein100:
        inc score+3
        ldx #3
scoreloop1:
        lda score,x
        cmp #$3a
        bne score100ok
        lda #$30
        sta score,x
        inc score-1,x
score100ok:
        dex
        bne scoreloop1
        jmp maskpanel

// Score 10 points

scorein10:
        inc score+4
        ldx #4
scoreloop3:
        lda score,x
        cmp #$3a
        bne score10ok
        lda #$30
        sta score,x 
        inc score-1,x
score10ok:
        dex
        bne scoreloop3
        jmp maskpanel
        
// The player collided into a bomb. The game is
// now over.

destroyplayer:
        ldx #$00
updateattribs:
        ldy $0400,x
        lda attribs,y
        sta $d800,x
        ldy $0500,x
        lda attribs,y
        sta $d900,x
        ldy $0600,x
        lda attribs,y
        sta $da00,x
        ldy $06e8,x
        lda attribs,y
        sta $dae8,x
        inx
        bne updateattribs
        lda #0
        sta animpointer1
        sta animdelay
        
explosionloop:
        jsr synctimer
        jsr animateexploder
        jmp explosionloop

animateexploder:
        lda animdelay
        cmp #2
        beq doblast
        inc animdelay
        rts
doblast:
        lda #0
        sta animdelay
        ldx animpointer1
        lda explosionframe,x
        sta $07f8
        sta $07f9
        sta $07fa
        lda #$07
        sta $d027
        sta $d028
        sta $d029
        inx
        cpx #9
        beq explodeend
        inc animpointer1
        rts
explodeend:
        
        lda score
        sec
        lda hiscore+5
        sbc score+5
        lda hiscore+4
        sbc score+4
        lda hiscore+3
        sbc score+3
        lda hiscore+2
        sbc score+2
        lda hiscore+1
        sbc score+1
        lda hiscore
        sbc score
        bpl notnewhiscore

        ldx #$00
newhiscore:
        lda score,x
        sta hiscore,x
        inx
        cpx #$06
        bne newhiscore

notnewhiscore:

// Temporary game over routines

tempwait:
        inc $d020
        lda #16
        bit $dc00
        bne tempwait
        jmp $4000
        
        
// ### In game pointers ###

pointers:
rt:     .byte 0 // Sync Raster timer    
ypos:   .byte 0 // $D011 scroll control register    
animdelay: .byte 0
animpointer1: .byte 0
animpointer2: .byte 0
objpos: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
spawntime: .byte 0
spawnallowed: .byte 0
sequence1: .byte 0
sequence2: .byte 0
leveltime: .byte 0,0
levelpointer: .byte 0


pointersend:

// Random pointers - MUST NOT BE INITIALIZED
spawnlimit: .byte 8
randpointer1: .byte 0
randpointer2: .byte 0

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

// ### Random objects to spawn via table


// Obstacle objects (based on character set ID)

char_top_left:
        .byte apple_top_left            // Object ID 0
        .byte banana_top_left           // Object ID 1
        .byte cherries_top_left         // Object ID 2
        .byte strawberry_top_left       // Object ID 3
        .byte bomb_top_left             // Object ID 4

char_top_right:
        .byte apple_top_right
        .byte banana_top_right
        .byte cherries_top_right
        .byte strawberry_top_right
        .byte bomb_top_right

char_bottom_left:
        .byte apple_bottom_left
        .byte banana_bottom_left
        .byte cherries_bottom_left
        .byte strawberry_bottom_left
        .byte bomb_bottom_left

char_bottom_right:
        .byte apple_bottom_right
        .byte banana_bottom_right
        .byte cherries_bottom_right
        .byte strawberry_bottom_right
        .byte bomb_bottom_right

// Charset top left storage position possibilities

top_left_lo:
        .byte $0c,$0e,$10,$12,$14,$16,$18,$1a
top_right_lo:
        .byte $0d,$0f,$11,$13,$15,$17,$19,$1b
bottom_left_lo:
        .byte $34,$36,$38,$3a,$3c,$3e,$40,$42
bottom_right_lo:
        .byte $35,$37,$39,$3b,$3d,$3f,$41,$43

// Score pointers

score: .byte $30,$30,$30,$30,$30,$30
level: .byte $31
hiscore: .byte $30,$30,$30,$30,$30,$30

        * = $5000 "RANDOM VALUES BETWEEN 0 AND 5"
randtable1:
        .import c64 "c64/randgen5.prg"

        * = $5200 "RANDOM VALUES BETWEEN 0 AND 8"
randtable2:
        .import c64 "c64/randgen8.prg"

        

