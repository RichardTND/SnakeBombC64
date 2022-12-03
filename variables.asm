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

// ### VARIABLES ###

.const musicinit = $1000 // Music init address
.const musicplay = $1003 // Music play address
.const screen = $0400 // Screen RAM
.const colour = $d800 // Colour RAM

.var snakeanimdelay = $05 // Duration of snake sprite animation

.var stopzoneleft = $3a
.var stopzoneright = $72

// ## Raster variables ##

.var split1 = $22
.var split2 = $e0
.var split3 = $ea
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




