    push    { lr }
    push    { r4-r7 }

    ldr     r0, VarResult
    ldr     r6, VarGet
    bl      branchA

    mov     r1, #0 @ FALSE
    cmp     r0, r1
    beq     rng

    @ Load Easy Chat words stored in save
    ldr     r0, gSaveBlockWords
    mov     r1, #2
    
    ldrh    r2, [r0]
    add     r0, r1
    
    ldrh    r3, [r0]
    add     r2, r3
    add     r0, r1
    
    ldrh    r3, [r0]
    add     r2, r3
    add     r0, r1
    
    ldrh    r3, [r0]
    add     r2, r3
    
    mov     r0, r2   
    bl      skipRng
    
rng:
    ldr     r6, Random
    bl      branchA

skipRng:
    mov     r1, #165
    ldr     r6, __umodsi3
    bl      branchA
    
    @ Add selected egg index to EggMons offset
    ldr     r1, EggMons
    add     r0, r0 @ byte * 2 since species index is 16-bit
    add     r1, r0
    ldrh    r2, [r1]
    mov     r5, r2

    @ Gen 16-bit number for PID
    ldr     r6, Random
    bl      branchA

    @ Modulus 0x8000
    ldrh    r1, DaycareRandom @ 0xFFFE
    ldr     r6, __umodsi3
    bl      branchA
    mov     r4, r0 @ Store in r4 for later

    @ Repeat random call for PID
    ldr     r6, Random
    bl      branchA
    
    @ Bitwise OR to create 32-bit PID
    lsl     r0, #0x10
    orr     r0, r4
    add     r0, #1
    
    @ CreateMon
    add     sp, sp, #-16

    mov     r3, r0 @ Personality

    ldr     r0, gEnemyParty @ Mon address
    mov     r1, r5
    mov     r2, #1
    str     r2, [sp]
    str     r3, [sp, #4]
    mov     r2, #0
    str     r2, [sp, #8]
    str     r2, [sp, #12]
    mov     r2, #5
    mov     r3, #32
    ldr     r6, CreateMon
    bl      branchA

    add     sp, sp, #0x10

    ldr     r5, gEnemyParty
    add     r5, #100
    mov     r1, #0x20
    strb    r1, [r5]
    mov     r2, r5

    @ Set met location to Route 117
    ldr     r0, gEnemyParty
    mov     r1, #35 @ MON_DATA_MET_LOCATION
    ldr     r6, SetMonData
    bl      branchA
    
    @ Set nickname to sJapaneseEggNickname (タマゴ)
    ldr     r0, gEnemyParty
    mov     r1, #2 @ MON_DATA_NICKNAME
    ldr     r2, sJapaneseEggNickname
    ldr     r6, SetMonData
    bl      branchA

    mov     r1, #1
    strb    r1, [r5]
    mov     r2, r5

    @ Set language to LANGUAGE_JAPANESE (1)
    @ 0x2028F91
    ldr     r0, gEnemyParty
    mov     r1, #3 @ MON_DATA_LANGUAGE
    ldr     r6, SetMonData
    bl      branchA
    bl      skipBranchA

branchA:
    bx      r6

skipBranchA:
    mov     r1, #0
    strb    r1, [r5]
    mov     r2, r5

    @ Set met level to 0
    ldr     r0, gEnemyParty
    mov     r1, #36 @ MON_MET_LEVEL
    ldr     r6, SetMonData
    bl      branchB

    ldr     r7, gBaseStats
    mov     r0, #32
    mul     r0, r5
    add     r7, r0
    mov     r1, #16
    add     r7, r1
    ldrb    r2, [r7]

    ldr     r0, gEnemyParty
    mov     r1, #32 @ MON_DATA_FRIENDSHIP
    ldr     r6, SetMonData
    bl      branchB
    
    ldr     r0, gEnemyParty
    add     r0, #100
    mov     r1, #1
    strb    r1, [r0]
    mov     r2, r0

    @ Set mon to egg
    ldr     r0, gEnemyParty
    mov     r1, #45 @ MON_DATA_IS_EGG
    ldr     r6, SetMonData
    bl      branchB

    @@ EGG MOVES

    ldr     r0, gEnemyParty
    ldr     r1, gEnemyParty
    add     r1, #255 @ Offset to store egg movesfrom gEnemyParty
    mov     r4, r1 @ Store pointer for later
    ldr     r6, GetEggMoves
    bl      branchB

    push    { r0 } @ GetEggMoves returns number of moves, push it for later
    @ mov     r7, r0

    @ Random to roll 16-bit word
    ldr     r6, Random
    bl      branchA
    @ 2029001

    pop     { r1 } @ Pop number of egg moves to get random range
    @ mov     r1, r7
    sub     r1, #1
    ldr     r6, __umodsi3
    bl      branchB

    mov     r1, r4 @ Move array pointer to r1
    add     r0, r0 @ x2 move index, moves are 16-bit
    add     r0, r1 @ Add move index to array pointer
    mov     r4, r0 @ Store selected move address for later

    ldr     r0, gEnemyParty
    sub     r4, #1
    ldrh    r1, [r4]
    mov     r5, r1
    ldr     r6, GiveMoveToMon
    bl      branchB

    ldr     r1, GiveMonToMoveCmp
    cmp     r0, r1
    bne     giveMon

    ldr     r0, gEnemyParty
    mov     r1, r5
    ldr     r6, DeleteFirstMoveAndGiveMoveToMon

giveMon:
    ldr     r0, gEnemyParty
    ldr     r6, GiveMonToPlayer
    bl      branchB

    bl      exit

branchB:
    bx      r6

exit:
    pop     { r4 - r7 }
    pop     { pc }

.align
VarResult:
    .word 0x800D
VarGet:
    .long 0x08069255
gSaveBlockWords:
    .long 0x2028250
gEnemyParty: @ Temp location for egg generation
    .long 0x030045c0
gEggMoves:
    .long 0x082091dc
EggSpeciesOffset:
    .word 0x7D0
EggSpeciesIdBase:
    .word 0x4E20
EggMons:
    .long 0x02014800
Random:
    .long 0x08040e85
CreateMon:
    .long 0x0803a799
__umodsi3:
    .long 0x081e0f09
GiveMonToPlayer:
    .long 0x0803d91d
SetMonData:
    .long 0x0803d1fd
sJapaneseEggNickname:
    .long 0x08209ad4
DaycareRandom:
    .word 0xFFFE
GiveMonToMoveCmp:
    .word 0xFFFF
.align
gBaseStats: @ Base stat data (used for matching egg cycles for legality)
    .long 0x081fec34
GetEggMoves:
    .long 0x08041b1d
GiveMoveToMon:
    .long 0x0803b5dd
DeleteFirstMoveAndGiveMoveToMon:
    .long 0x0803b8d5
