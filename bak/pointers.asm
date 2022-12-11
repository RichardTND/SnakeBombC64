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

// ### In game pointers ###

ypos:   .byte 0 // $D011 scroll control register   
system: .byte 0
ntsctimer: .byte 0

pointers:
rt:     .byte 0 // Sync Raster timer    
firebutton: .byte 0 
animdelay: .byte 0
animpointer1: .byte 0
animpointer2: .byte 0
charanimdelay: .byte 0
objpos: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
spawntime: .byte 0
spawnallowed: .byte 0
sequence1: .byte 0
sequence2: .byte 0
leveltime: .byte 0,0
levelpointer: .byte 0
spriteflashpointer: .byte 0
spriteflashdelay:   .byte 0
explpointer: .byte 0
pointersend:
rtemp: .byte 0
rand: .byte $51,$51

// Random pointers - MUST NOT BE INITIALIZED
spawnlimit: .byte 8
randpointer1: .byte 0
randpointer2: .byte 0

// Sprite animation frames

snakehead: .byte $80
snakebody: .byte $84
snaketail: .byte $88
explosion: .byte $83 


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

// ## Lettered sprites ##

getreadysprites:
        .byte letterG
        .byte letterE
        .byte letterT

        .byte letterR
        .byte letterE
        .byte letterA
        .byte letterD
        .byte letterY

gameoversprites:
        .byte letterG
        .byte letterA
        .byte letterM
        .byte letterE

        .byte letterO
        .byte letterV
        .byte letterE
        .byte letterR

welldonesprites:
        .byte letterW
        .byte letterE
        .byte letterL
        .byte letterL
        
        .byte letterD
        .byte letterO
        .byte letterN
        .byte letterE

// Sprite flash colour table

spriteflashtable:
        .byte $06,$09,$02,$0b,$04,$08,$0c,$0e,$0a,$03,$0f,$07,$0d,$01
        .byte $0d,$07,$0f,$03,$0a,$0e,$0c,$08,$04,$0b,$02,$09
spriteflashend:

// Sprite positions for routines

getreadypos:
        .byte $46,$68,$56,$68,$66,$68,$36,$88
        .byte $46,$88,$56,$88,$66,$88,$76,$88

gameoverpos:
welldonepos:
        .byte $3e,$68,$4e,$68,$5e,$68,$6e,$68
        .byte $3e,$88,$4e,$88,$5e,$88,$6e,$88
        
// Bomb screen explosion colour table

screenexptbl:
        .byte $09,$02,$08,$0a,$0f,$07,$01,$07,$0f,$0a,$08,$02,$09,$00


        

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


        * = $5000 "256 byte value tables between 1 and 5"
randtable1:
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4
        .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0

        * = $5200 "256 byte tables between 1 and 8"
        
randtable2:
        .byte 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3
        .byte 4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
        .byte 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3
        .byte 4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
        .byte 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3
        .byte 4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
        .byte 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3
        .byte 4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
        .byte 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3
        .byte 4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
        .byte 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3
        .byte 4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
        .byte 0,1,2,3,4,5,6,70,1,2,3,4,5,6,7,0
        

        * = $5400 "SOUND EFFECTS TABLES"
snakeapplessfx:
        .byte $0E,$00,$08,$B0,$41,$B2,$B4,$B6,$B7,$B8,$BA,$BC,$BE,$C0,$C2,$C4
        .byte $C8,$CA,$00

snakebananasfx:
        .byte $0E,$00,$08,$D0,$41,$CC,$C8,$C4,$C0,$BC,$B8,$B4,$B8,$BC,$C0,$C4
        .byte $C8,$CC,$00

snakecherriessfx:
        .byte $0E,$00,$08,$C0,$41,$C0,$C4,$CC,$C8,$C8,$CC,$C4,$C0,$C8,$C0,$00

snakestrawberrysfx:
        .byte $0E,$00,$08,$AC,$41,$B0,$B4,$B7,$AC,$B0,$B4,$B7,$AC,$B0,$B4,$B7
        .byte $AC,$B0,$B4,$B7,$00

bombsfx:
       .byte $0E,$EE,$08,$AF,$41,$DF,$81,$AD,$41,$AB,$A9,$CF,$81,$CF,$CF,$CF
       .byte $00

levelupsfx:
        .byte $0E,$EE,$08,$B0,$41,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$B9
        .byte $BA,$BB,$BC,$BD,$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$B9
        .byte $BA,$BB,$BC,$BD,$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$B9
        .byte $BA,$BB,$BC,$BD,$00

