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

// ### MACRO CODE ###

// Game screen scrolling macro

.macro ScrollRows(_row1, _row2){
        lda _row1,x
        sta _row2,x
}

// Macro that replaces gobbled object from the top left

.macro ReplaceCharTopLeft (tl, tr, br, bl) {

        lda #tl
        sta (zp+1),y
        iny
        lda #tr
        sta (zp+1),y
        tya
        clc
        adc #$28
        tay
        lda #br 
        sta (zp+1),y
        dey
        lda #bl
        sta (zp+1),y
}

// Macro that replaces gobble object from the top right 

.macro ReplaceCharTopRight (tr, tl, bl, br) {

        lda #tr
        sta (zp+1),y
        dey
        lda #tl
        sta (zp+1),y
        tya
        clc
        adc #$28
        tay
        lda #bl
        sta (zp+1),y
        iny
        lda #br
        sta (zp+1),y
}

