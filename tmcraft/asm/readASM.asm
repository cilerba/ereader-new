@ Credit to blisy
    movs    r0, #30
    ldr     r1, ASMLocation
    ldr     r2, DoReadFlashWholeSection
    bx      r2

.align
ASMLocation:
    .long   0x02014800
DoReadFlashWholeSection:
.ifdef RUBY
    .ifdef BASE
        .long   0x08125bf9
    .endif
    .ifdef REV1
        .long   0x08125c19
    .endif
    .ifdef REV2
        .long   0x08125c19
    .endif
.endif
.ifdef SAPP
    .ifdef BASE
        .long   0x08125bf9
    .endif
    .ifdef REV1
        .long   0x08125c19
    .endif
    .ifdef REV2
        .long   0x08125c19
    .endif
.endif
