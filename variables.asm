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

// ### VARIABLES ###

.var zp = $70 //Zeropage collision

.const musicinit = $9000 // Music init address
.const musicplay = $9003 // Music play address
.const sfxplay = $9006

.const screen = $0400 // Screen RAM
.const screen2 = $0428
.const colour = $d800 // Colour RAM
.const logocolour = $5800 
.var snakeanimdelay = $05 // Duration of snake sprite animation

.var stopzoneleft = $3a
.var stopzoneright = $72

.var leveltimelimit = $f4

// ## Raster variables ##

.var split1 = $22
.var split2 = $d0
.var split3 = $da
.var split4 = $fa

// ## Scrolling screen row ##

.label row0 = screen
.label row1 = screen+40
.label row2 = screen+80
.label row3 = screen+120
.label row4 = screen+160
.label row5 = screen+200
.label row6 = screen+240
.label row7 = screen+280
.label row8 = screen+320
.label row9 = screen+360
.label row10 = screen+400
.label row11 = screen+440
.label row12 = screen+480
.label row13 = screen+520
.label row14 = screen+560
.label row15 = screen+600
.label row16 = screen+640
.label row17 = screen+680
.label row18 = screen+720 
.label row19 = screen+760 
.label row20 = screen+800
.label row21 = screen+840
.label row22 = screen+880
.label row23 = screen+920
.label rowtemp = $c000
.label chartemp = $c100

// ID values for characters to spawn

.var apple_top_left = 91
.var apple_top_right = 92
.var apple_bottom_left = 93
.var apple_bottom_right = 94

.var banana_top_left = 95
.var banana_top_right = 96
.var banana_bottom_left = 97
.var banana_bottom_right = 98

.var cherries_top_left = 99
.var cherries_top_right = 100
.var cherries_bottom_left = 101
.var cherries_bottom_right = 102

.var strawberry_top_left = 103
.var strawberry_top_right = 104
.var strawberry_bottom_left = 105
.var strawberry_bottom_right = 106

.var bomb_top_left = 107
.var bomb_top_right = 108
.var bomb_bottom_left = 109
.var bomb_bottom_right = 110

.var score_100_top_left = 115
.var score_100_top_right = 116
.var score_100_bottom_left = 117
.var score_100_bottom_right = 118

.var score_200_top_left = 119
.var score_200_top_right = 120
.var score_200_bottom_left = 121
.var score_200_bottom_right = 122

.var score_300_top_left = 123
.var score_300_top_right = 124
.var score_300_bottom_left = 125
.var score_300_bottom_right = 126

.var score_500_top_left = 127
.var score_500_top_right = 128
.var score_500_bottom_left = 129
.var score_500_bottom_right = 130

.var death_top_left = 131
.var death_top_right = 132
.var death_bottom_left = 133
.var death_bottom_right = 134

// Status panel

.const scorechars = $0776 // Score masking
.const levelchars = $0788 // Level masxking (possibly single char)
.const hiscorechars = $0792 // Hi score chars

// Sprite values (Letters)

.var letterG = $94
.var letterE = $95
.var letterT = $96 
.var letterR = $97
.var letterA = $98
.var letterD = $99
.var letterY = $9a
.var letterM = $9b
.var letterO = $9c
.var letterV = $9d
.var letterW = $9e
.var letterN = $9f
.var letterL = $a0

// In game music parameters

.var titlemusic = $00
.var gamemusic = $01
.var getreadyjingle = $02
.var gameoverjingle = $03
.var welldonejingle = $04
.var hiscoremusic = $05

// Bomb animation parameters

.const bombcharsrc = $3000+(135*8)
.const bombchartgt = $3000+(108*8)

// Sprite copy for title screen

.const vssprite1 = $2740
.const vssprite2 = $2840

// Hi score data

.var scorelen = 6
.var namelen = 9
.var listlen = 10

.label scoretext = score

