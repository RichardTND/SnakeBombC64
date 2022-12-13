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

 
        lda #251
        sta $0328
        jsr stopints // Stop interrupts
        lda #$98+40
        sta blackchr1+1
        lda #$48+40
        sta blackchr2+1
        lda #$10
        sta ypos

        ldx #$00
copyhiscore:
        lda hiscore1,x
        sta hiscore,x   
        inx 
        cpx #$06
        bne copyhiscore

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
        lda #$01
        sta $d019
        sta $d01a
        lda #$1b
        sta $d011
        lda #getreadyjingle
        jsr musicinit
        cli
        
// Main GET READY loop (Get Ready sprites)

        lda #$00        // Switch off sprites
        sta $d015
        
        ldx #$00
clearspriterange:
        lda #$00
        sta $d000,x
        sta objpos,x
        inx
        cpx #$10
        bne clearspriterange

        // Setup the GET READY sprites 

        ldx #$00
setupgetreadysprites:
        lda getreadysprites,x
        sta $07f8,x
        inx
        cpx #8
        bne setupgetreadysprites

        ldx #$00
positiongetready:
        lda getreadypos,x
        sta objpos,x
        inx
        cpx #$10
        bne positiongetready
        lda #1
        sta $d027
        
        // Main loop for GET READY scene
        lda #$ff
        sta $d015
        sta $d01c
        lda #$00
        sta firebutton
getreadyloop:
        jsr synctimer
        jsr spriteflashroutine
        inc randpointer1
        inc randpointer2
        
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi getreadyloop
        bvc getreadyloop
        
        lda #0
        sta firebutton
        
        ldx #$00
clearspritesaway:
        sta $d000,x
        sta objpos,x
        inx
        cpx #16
        bne clearspritesaway
        jsr setupplayer
        lda #gamemusic
        jsr musicinit
        lda #$10
        sta ypos
        jmp gameloop
        

gameirq1:   // Raster split 1
        asl $d019
        lda $dc0d
        sta $dd0d

        lda #split1
        sta $d012
        lda #$02
        sta $d022
        lda #$07
        sta $d023

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
        sta $d011 
        lda #$ff
        sta $d015
        ldx #<gameirq3
        ldy #>gameirq3
        stx $0314
        sty $0315
        jmp $ea7e

gameirq3:    // Raster split 3
        asl $d019
        lda #split3
        sta $d012
        lda #$7f
        sta $d011
        lda #0
        sta $d015
        lda #$0e
        sta $d022
        lda #$01
        sta $d023
        lda #1
        sta rt
        ldx #<gameirq4
        ldy #>gameirq4
        stx $0314
        sty $0315
        jmp $ea7e

gameirq4:       // Raster split 4
        
        asl $d019
        lda #split4
        sta $d012
        
        lda #$1f
        sta $d011
        ldx #<gameirq1
        ldy #>gameirq1
        stx $0314
        sty $0315
        jsr musicplayer
        jmp $ea7e

// SUBROUTINE: Stop interrupts playing 
        
stopints:

        sei
        lda #$00
        sta $d020
        sta $d021
        ldx #$31
        ldy #$ea
        lda #$81
        stx $0314
        sty $0315
        sta $dc0d
        sta $dd0d
        lda $dc0d
        lda $dd0d
        lda #$00
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
        jsr animbombs
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
         
        clc
scrollspeed:
        adc #$01
        
        sta ypos
        lda ypos
        cmp #$18 
        bcs dohardscroll
       
        rts
dohardscroll:
        lda #$10
        sta ypos

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
        jsr randomizer
        sta randpointer1
        ldx randpointer1
        lda randtable1,x
        sta sequence1
        
        rts

        // Randomly select number between 1
        // and 8 (char position)
random8:
        
        jsr randomizer
        sta randpointer2
        ldx randpointer2
        lda randtable2,x
        sta sequence2
        
        rts

randomizer:
        lda rand+1
        sta rtemp
        lda rand
        asl
        rol rtemp
        asl
        rol rtemp
        clc
        adc rand
        pha
        lda rtemp
        adc rand+1
        sta rand+1
        pla
        adc #$11
        sta rand
        lda rand+1
        adc #$36
        sta rand+1
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
        
        lda #$94
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

        lda #$00
        sta hwsprx+1
        lda #$01
        sta hwspry+1
        lda #1
        sta issnakehead
        jsr readcollider
        lda #$02
        sta hwsprx+1
        lda #$03
        sta hwspry+1
        lda #0
        sta issnakehead
        jsr readcollider
        lda #$04
        sta hwsprx+1
        lda #$05
        sta hwspry+1
        lda #0
        sta issnakehead
        
readcollider:
hwsprx: lda $d000
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
hwspry: lda $d001
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
        lda issnakehead
        beq onlycheckbomb
        jsr checkapple
        jsr checkbanana
        jsr checkcherries
        jsr checkstrawberry
onlycheckbomb:
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
        jsr playapplesfx
        jmp score100pts
        
removeappletopright:
        :ReplaceCharTopRight(score_100_top_right, score_100_top_left, score_100_bottom_left, score_100_bottom_right)
        jsr playapplesfx
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
        jsr playbananasfx
        jmp score200pts

removebananatopright:
        :ReplaceCharTopRight(score_200_top_right, score_200_top_left, score_200_bottom_left, score_200_bottom_right)
        jsr playbananasfx
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
        jsr playcherriessfx
        jmp score300pts
removecherriestopright:
        :ReplaceCharTopRight(score_300_top_right, score_300_top_left, score_300_bottom_left, score_300_bottom_right) 
        jsr playcherriessfx
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
        jsr playstrawberrysfx
        jmp score500pts
removestrawberrytopright:
        :ReplaceCharTopRight(score_500_top_right, score_500_top_left, score_500_bottom_left, score_500_bottom_right)
        jsr playstrawberrysfx
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
        jsr playbombsfx
        jmp destroyplayer
removebombtopright:
        :ReplaceCharTopRight(death_top_right, death_top_left, death_bottom_left, death_bottom_right)
        jsr playbombsfx
        jmp destroyplayer
        
// Game control - Tests game timer and level status

gamecontrol:
        
        lda leveltime //Miliseconds
        
        cmp leveltimelimit
        beq switchsecond
        inc leveltime
        rts
switchsecond:
        lda #0
        sta leveltime
        jsr scorein10
        lda leveltime+1
        cmp #40     // 40 seconds 
        beq switchtonextlevel
        inc leveltime+1
        jsr deductcounter
        rts

        // Counter deduction ... The bar above and below the score panel
        // should represent the amount of time before the level moves up 
        // one position.

deductcounter:
        
        dec blackchr1+1
        dec blackchr2+1

        ldx #$00
black:  lda #$08
blackchr1:
        sta $db98+40
blackchr2:
        sta $db48+40
        inx
        cpx #$28
        bne black
        rts

// New level, faster speed - less spawn time

switchtonextlevel:
        lda #0
        sta leveltime+1
        sta leveltime
        inc levelpointer
      
        
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
        jsr playlevelupsfx
        ldx #$27
restorecounter:
        lda #$09
        sta $db48,x
        sta $db98,x
        dex
        bpl restorecounter
        lda #$98+40
        sta blackchr1+1
        lda #$48+40
        sta blackchr2+1
        jsr filllane
        jmp maskpanel


// Game completed ... Stop the scroll and make the snake leave the 
// game screen.

gamecomplete:
        
gcloop1:        
        jsr synctimer
        jsr animatesnake
        jsr movesnakeoutofscene
        
        jmp gcloop1
        // Move sprites upwards slowly, until all sprites have 
        // left the screen.

// Move snake out of scene

movesnakeoutofscene:
        lda objpos+1
        sec
        sbc #2
        cmp #$0c
        bcs setupheadout
        lda #$00
        sta objpos
setupheadout:
        sta objpos+1
        lda objpos+3
        sec
        sbc #2
        cmp #$0c
        bcs setupbodyout
        lda #$00
        sta objpos+2
setupbodyout:
        sta objpos+3
        lda objpos+5
        sec
        sbc #2
        cmp #$0c
        bcs setuptailout
        jmp processwelldone
setuptailout:
        sta objpos+5
        rts

// Process the well DONE sprites
processwelldone:
        jsr checkforhiscore
        jsr maskpanel

        lda #$ff
        sta $d015
        sta $d01c

        ldx #$00
transferwelldone:
        lda welldonesprites,x
        sta $07f8,x
        inx
        cpx #$08
        bne transferwelldone

        ldx #$00
setwelldonepos:
        lda welldonepos,x
        sta objpos,x
        inx
        cpx #$10
        bne setwelldonepos
        
        lda #welldonejingle
        jsr musicinit
        
        jmp gameoverloop

        // Setup the WELL DONE jingle


gameoverloop:
        jsr synctimer
        jsr spriteflashroutine
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi gameoverloop
        bvc gameoverloop

        jmp hiscorereader // Temporary jump after pressing fire
        

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
        jsr colourexplosion
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
        jsr checkforhiscore
// Display game over sprites

        ldx #$00
removespritesforgo:
        lda #$00
        sta $d000,x
        sta objpos,x
        inx
        cpx #$10
        bne removespritesforgo
        lda #$ff
        sta $d015
        sta $d01c

        ldx #$00
setupgameoversprites:
        lda gameoversprites,x
        sta $07f8,x
        inx
        cpx #$08
        bne setupgameoversprites

        ldx #$00
posgameover:
        lda gameoverpos,x
        sta objpos,x
        inx
        cpx #$10
        bne posgameover
        lda #gameoverjingle
        jsr musicinit
        jsr checkforhiscore
        jmp gameoverloop

        
colourexplosion:

// Screen explosion routine (while the snake explodes)        

        ldx explpointer
        lda screenexptbl,x
        sta $d021
        inx
        cpx #14
        beq setlastbyte
        inc explpointer
        rts
setlastbyte:
        ldx #13
        stx explpointer
        rts
// Flash routine for GET READY, GAME OVER and WELL DONE sprites

spriteflashroutine:

        lda spriteflashdelay
        cmp #1
        beq spriteflashok
        inc spriteflashdelay
        rts
spriteflashok:
        lda #$00                 
        sta spriteflashdelay
        ldx spriteflashpointer
        lda spriteflashtable,x
        sta $d027
        sta $d028
        sta $d029
        sta $d02a
        sta $d02b
        sta $d02c
        sta $d02d
        sta $d02e
        inx
        cpx #spriteflashend-spriteflashtable
        beq finishedflash
        inc spriteflashpointer
        rts
finishedflash:
        ldx #0
        stx spriteflashpointer
        rts

// Charset animation

animbombs:
        lda charanimdelay
        cmp #4
        beq docharanim
        inc charanimdelay
        rts
docharanim:
        lda #0
        sta charanimdelay
        ldx #$00
bombloop1:
        lda bombcharsrc,x
        sta bombcharsrc+(7*8),x
        inx
        cpx #$08
        bne bombloop1
        ldx  #$00
bombloop2:
        lda bombcharsrc+8,x
        sta bombcharsrc,x
        inx
        cpx #$38
        bne bombloop2
        ldx #$00
bombloop3:
        lda bombcharsrc,x
        sta bombchartgt,x
        inx
        cpx #8
        bne bombloop3
        rts

// ### Sound effects player ###

playapplesfx:
        lda #<snakeapplessfx
        ldy #>snakeapplessfx
        ldx #7
        jsr sfxplay
        rts

playbananasfx:
        lda #<snakebananasfx
        ldy #>snakebananasfx
        ldx #7
        jsr sfxplay
        rts

playcherriessfx:
        lda #<snakecherriessfx
        ldy #>snakecherriessfx
        ldx #7
        jsr sfxplay
        rts

playstrawberrysfx:
        lda #<snakestrawberrysfx
        ldy #>snakestrawberrysfx
        ldx #7
        jsr sfxplay
        rts

playbombsfx:
        lda #<bombsfx
        ldy #>bombsfx
        ldx #7
        jsr sfxplay
        rts

playlevelupsfx:
        lda #<levelupsfx
        ldy #>levelupsfx
        ldx #7
        jsr sfxplay
        rts

// Last but not least, game music player 


// PAL/NTSC music speed check

musicplayer:
       
        
        lda system
        cmp #1
        beq pal
        inc ntsctimer
        lda ntsctimer
        cmp #6
        beq resetntsctimer
pal:    jsr musicplay
        rts
resetntsctimer:
        lda #0
        sta ntsctimer
        rts


// Check for new hi score in game
checkforhiscore:
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
        rts

        .import source "pointers.asm"