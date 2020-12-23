
; initialize char map
HOOT = $30
ALPHABET EQUS "\"0123456789:->*^abABCDEFGHIJKLMNOPQRSTUVWXYZ\""
letter EQUS "strsub(ALPHABET, HOOT - $2F, 1)"

CHARMAP " ", $DF
REPT strlen(ALPHABET) - 1
CHARMAP letter, HOOT
HOOT = HOOT + 1
ENDR

PURGE HOOT

; attempts to optimize loading into a if n8 = 0
LD_A: MACRO
IF \1 == 0
    xor a
ELSE
    ld a, \1
ENDC
ENDM

; ==============================================
; Uses `A` as an index to a vector table.
; - Parameters: `vector table`, `A` = index
; - Outputs:  `HL` = pointer to jump to
; - Destroys: `AF`, `DE`
; ==============================================
VECTOR_LOOKUP_A: MACRO
    ld hl, \1
    sla a ; x2
    ld d, 0
    ld e, a
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
ENDM


; ==============================================
; Gets a VRAM pointer to a tile
; - Parameters: `16-bit register`, `tile num`
; - Outputs:  pointer to tile
; - Destroys: `NONE`
; ==============================================
GET_TILE_PTR: MACRO
    ld \1, TILE_ADDRESS + 16 * (\2)
ENDM

; should not be called from the outside
COL_CGB_GBA: MACRO
red    = (((\1) >> 10)& $1F) * 3 / 4 + $8
green  = (((\1) >> 5) & $1F) * 3 / 4 + $8
blue   = (((\1) >> 0) & $1F) * 3 / 4 + $8
col = ((red) << 10) | ((green) << 5) | (blue)
    dw col
ENDM


; converts a GRAPHICS_PALETTE of CGB colors to GBA colors
PAL_CGB_GBA: MACRO
    COL_CGB_GBA \1
    COL_CGB_GBA \2
    COL_CGB_GBA \3
    COL_CGB_GBA \4
ENDM


; ==============================================
; Turns on screen
; --
; - enable bg, window, & sprite
; - bg tiles at 8000-8FFF
; - bg map at 9800-9BFF
; - window map at 9C00-9FFF
; - Destroys: `A`
; ==============================================
ENABLE_SCREEN: MACRO
	ld a, %11110011
	ld [rLCDC], a
ENDM


; ==============================================
; Increments a register `x` times
; - Parameters: `X`, `Y`
; - Destroys: `A`
; ==============================================
SET_WINDOW: MACRO
    LD_A \1
    ldh [rWX], a
    LD_A \2
    ldh [rWY], a
ENDM


; ==============================================
; `HALT`s until vblank has happened
; - updates `isVBlank`
; - Destroys: `A`=0
; ==============================================
WAIT_VBLANK: MACRO
.loop\@:
    halt
    ld a, [isVBlank]
    or a
    jr z, .loop\@
    xor a
    ld [isVBlank], a
ENDM
; ==============================================
; Sets CGB VRAM bank to 1
;   - Inputs: `NONE`
;   - Destroys: `A`
; ==============================================
SET_VRAM_BANK: MACRO
    ld a, 1
    ld [rVBK], a
ENDM


; ==============================================
; Turns off CGB extra VRAM bank
;   - Inputs: `NONE`
;   - Destroys: `A`
; ==============================================
RESET_VRAM_BANK: MACRO
    xor a
    ldh [rVBK], a
ENDM


; ==============================================
; initializes the stack
; ==============================================
RESET_SP: MACRO
    ld sp, $D000
ENDM


; ==============================================
; Increments a register `x` times
; - Parameters: `register`, `number of increments`
; ==============================================
INCREMENT: MACRO
REPT (\2)
    inc \1
ENDR
ENDM


; ==============================================
; Decrements a register `x` times
; - Parameters: `register`, `number of decrements`
; ==============================================
DECREMENT: MACRO
REPT \2
    dec \1
ENDR
ENDM

; ==============================================
; Performs a `LD HL, [HL]` and  `add hl, nn` instruction
; - useful for when `HL` is a pointer to a pointer
; - Destroys: `A` = `L`, `F`
; ==============================================
LOAD_HL_HL_IND: MACRO
    ld a, [hl+]
IF \1 != 0
    add a, \1
ENDC
    ld h, [hl]
    ld l, a
ENDM


; ==============================================
; used for copying data
;	- Parameters: `source`, `destination`, `size` 
;	- Destroys: `ALL`
; ==============================================
MCOPY: MACRO
    ld hl, \1
    ld de, \2
    ld bc, \3
    call mem_copy
ENDM

; ==============================================
; used for copying data
;	- Parameters: `source`, `destination`, `size` 
;	- Destroys: `ALL`
; ==============================================
MCOPY_VRAM: MACRO
    ld hl, \1
    ld de, \2
    ld bc, \3
    call mem_copy_VRAM
ENDM


; ==============================================
; used for setting data
;	- Parameters: `value`, `destination`, `size` 
;	- Destroys: `ALL` except `E`
; ==============================================
MSET: MACRO
    LD_A \1
    ld hl, \2
    ld bc, \3
    call mem_set
ENDM

; ==============================================
; fetches the pointer given an X and Y coord
;	- Parameters: `register`, `x`, `y` 
;	- Destroys: `NONE`
; ==============================================
GET_XY: MACRO
    ld \1, (BG_LOCATION) + (\2) + 32 * (\3)
ENDM

; ==============================================
; fetches the pointer given an X and Y coord
;	- Parameters: `register`, `x`, `y` 
;	- Destroys: `NONE`
; ==============================================
GET_XY_WINDOW: MACRO
    ld \1, (WINDOW_LOCATION) + (\2) + (32 * (\3))
ENDM


; ==============================================
; draws an int safely to the bg map
;	- Parameters: `number`, `x`, `y` 
;	- Destroys: `ALL`
; ==============================================
integerAtWindow: MACRO
    LD_A \1
    ld hl, WINDOW_LOCATION + (\2) + (32 * \3) + 2
    call drawNumber
ENDM

; ==============================================
; draws a string safely to the bg map
;	- Parameters: `string`, `x`, `y` 
;	- Destroys: `ALL`
; ==============================================
STRING_AT: MACRO
    ld hl, \1
    ld de, BG_LOCATION + (\2) + 32 * (\3)
    call gfx_drawString
ENDM

; ==============================================
; draws a string safely to the window
;	- Parameters: `string`, `x`, `y` 
;	- Destroys: `AF`, `DE`, `HL`
; ==============================================
STRING_AT_WINDOW: MACRO
    ld hl, \1
    ld de, WINDOW_LOCATION + (\2) + 32 * (\3)
    call drawString
ENDM


; ==============================================
; Clears the joypad mask so no buttons are recognized
;	- Parameters: `NONE` 
;	- Destroys: `AF`
; ==============================================
CLEAR_JOYPAD_MASK: MACRO
    xor a
    ld [joypadMask], a
ENDM

; ==============================================
; Shifts a register left by a given number of times
; - Parameters: `register`, `amount`
; ==============================================
SHIFT_LEFT: MACRO
REPT \2
    sla \1
ENDR
ENDM


; ==============================================
; Shifts a register left by a given number of times
; - Parameters: `register`, `amount`
; ==============================================
SHIFT_RIGHT: MACRO
REPT \2
    srl \1
ENDR
ENDM

; ==============================================
; Copies `DE` into `HL`
; ==============================================
LOAD_HL_DE: MACRO
    ld h, d
    ld l, e
ENDM

; ==============================================
; Copies `HL` into `DE`
; ==============================================
LOAD_DE_HL: MACRO
    ld d, h
    ld e, l
ENDM

; ==============================================
; pushes all the regs to the stack
; ==============================================
PUSH_ALL: MACRO
    push af
    push hl
    push de
    push bc
ENDM

; ==============================================
; pops all the regs from the stack
; ==============================================
POP_ALL: MACRO
    pop bc
    pop de
    pop hl
    pop af
ENDM

REQUIRE16RP: MACRO
___rp EQUS strlwr("\1")
IF (strcmp(___rp, "bc")!=0) && (strcmp(___rp, "de")!=0) && (strcmp(___rp, "hl")!=0)
    WARN "MUST BE 16-BIT REGISTER PAIR"
ENDC
    PURGE ___rp
ENDM

; ==============================================
; Performs a 16-bit between two registers
;   - Destroys: `A`
; ==============================================
SUB16: MACRO
__rp1 EQUS strlwr("\1")
__rp2 EQUS strlwr("\2")
__hr1 EQUS strsub("{__rp1}", 1, 1) ; low register pair 1
__hr2 EQUS strsub("{__rp2}", 1, 1) ; low register pair 2
__lr1 EQUS strsub("{__rp1}", 2, 1) ; high register pair 1
__lr2 EQUS strsub("{__rp2}", 2, 1) ; high register pair 2
    REQUIRE16RP "{__rp1}"
    REQUIRE16RP "{__rp2}"

    ld a, __lr1
    sub __lr2
    ld __lr1, a
    ld a, __hr1
    sbc __hr2
    ld __hr1, a

    PURGE __rp1, __rp2, __lr1, __lr2, __hr1, __hr2
ENDM

; ==============================================
; LD `reg16`, `reg16`
; ==============================================
LD16: MACRO
__rp1 EQUS strlwr("\1")
__rp2 EQUS strlwr("\2")
__hr1 EQUS strsub("{__rp1}", 1, 1) ; low register pair 1
__hr2 EQUS strsub("{__rp2}", 1, 1) ; low register pair 2
__lr1 EQUS strsub("{__rp1}", 2, 1) ; high register pair 1
__lr2 EQUS strsub("{__rp2}", 2, 1) ; high register pair 2
    REQUIRE16RP "{__rp1}"
    REQUIRE16RP "{__rp2}"

    ld __lr1, __lr2
    ld __hr1, __hr2

    PURGE __rp1, __rp2, __lr1, __lr2, __hr1, __hr2
ENDM