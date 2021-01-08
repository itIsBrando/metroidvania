SECTION "CGB", ROM0

; ==============================================
; should be called regardless of the gameboy used
; --
;	- Inputs: `A` = BIOS register value
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
cgb_init:
    
    ld hl, cgb_gameboy_type
    ld [hl], 0

    ; only continue if we are CGB
    cp $11
    ret nz

    ld [hl], 1 ; indicate CGB


    ; load BG palettes
    call cgb_loadBGPalettes
    jr cgb_loadOBJPalettes

; ==============================================
; Loads all of the sprite palettes for CGB mode
; --
;	- Inputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
cgb_loadOBJPalettes:
    ld a, $80
    ldh [rOCPS], a
    
    ; copy over primary sprite palette
    ld hl, cgb_obj0_palette
    xor a
    call cgb_loadOBJ

    ld hl, cgb_black_palette
    ld a, 1
    jp cgb_loadOBJ


; ==============================================
; Loads all of the background palettes for CGB mode
; --
;	- Inputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
cgb_loadBGPalettes:
    ld a, $80
    ldh [rBCPS], a

    ; copy over primary background palette
    ld hl, cgb_bg0_palette
    call cgb_writeBGPalette

    ; pal 1
    ld hl, cgb_bg1_palette
    call cgb_writeBGPalette
    
    ; pal 2
    ld hl, cgb_bg2_palette
    jr cgb_writeBGPalette


; ==============================================
; Writes a color in a bg palette
; --
;	- Inputs: `A` = palette number (0-7), `B` = color number (0-3), `HL` = 16-bit color
;	- Destroys: `AF`, `DE`, `HL`
; ==============================================
cgb_writeBGColor:
    SL a, 3 ; times 8
    add a, b
    add a, b ; b * 2
    ; A = A * 8 + b * 2
    ; ***i could save a byte doing: sla a \ sla a \ add a, b \ add a, a
    or $80
    ldh [rBCPS], a

    LD16 de, hl ; DE = color now
    ld hl, rBCPD

    call gfx_VRAMReadable
    ld [hl], e
    ld [hl], d
    ret


; ==============================================
; Writes a color in a sprite palette
; --
;	- Inputs: `A` = palette number (0-7), `B` = color number (0-3), `HL` = 16-bit color
;	- Destroys: `AF`, `DE`, `HL`
; ==============================================
cgb_writeOBJColor:
    SL a, 3 ; times 8
    add a, b
    add a, b ; b * 2
    ; A = A * 8 + b * 2
    ; ***i could save a byte doing: sla a \ sla a \ add a, b \ add a, a
    or $80
    ldh [rOCPS], a

    LD16 de, hl ; DE = color now
    ld hl, rOCPD

    call gfx_VRAMReadable
    ld [hl], e
    ld [hl], d
    ret


; ==============================================
; Sets all bg and obj palettes to black
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL` except `DE`
; ==============================================
cgb_paletteClear:
    ; load black into OBJ
    xor a
    ld hl, cgb_black_palette
    call cgb_loadOBJ

    ; load black into BG
    xor a
    ld hl, cgb_black_palette
    jr cgb_loadBG
    

; ==============================================
; Writes a palette at an index to lcd
; --
;	- Inputs: `HL` = pointer to palette, `A` = palette number
;	- Outputs: `NONE`
;	- Destroys: `AF`, `B`, `HL`
; ==============================================
cgb_loadBG:
    SL a, 3 ; times 8
    or $80
    ldh [rBCPS], a
    
; ==============================================
; Writes a palette to lcd registers that is indexed from `rBCPS`
; --
;	- Inputs: `HL` = pointer to palette
;	- Outputs: `NONE`
;	- Destroys: `AF`, `B`, `HL`
; ==============================================
cgb_writeBGPalette:
    ld b, 8
.loop:
    call gfx_VRAMReadable
    ld a, [hl+]
    ldh [rBCPD], a
    dec b
    jr nz, .loop

    ret


; ==============================================
; Writes a palette at an index to lcd
; --
;	- Inputs: `HL` = pointer to palette, `A` = palette number
;	- Outputs: `NONE`
;	- Destroys: `AF`, `B`, `HL`
; ==============================================
cgb_loadOBJ:
    ; get index using `A`
    SL a, 3
    or $80
    ldh [rOCPS], a

    ld b, 8
    ; write garabage to the first color
    dec hl
    dec hl
.loop:
    call gfx_VRAMReadable
    ld a, [hl+]
    ldh [rOCPD], a
    dec b
    jr nz, .loop
    ret


; ==============================================
; Gets the green color in a 16-bit RGB color
; --
;	- Inputs: `HL` = color
;	- Outputs: `A` = green (0-1F)
;	- Destroys: `F`, `B`
; ==============================================
cgb_getG:
    push hl
    ld b, 5
    xor a
.loop:
    rr h
    rr l
    dec b
    jr nz, .loop

    ld a, l
    and $1F
    pop hl
    ret


; ==============================================
; Gets the blue color in a 16-bit RGB color
; --
;	- Inputs: `HL` = color
;	- Outputs: `A` = blue (0-1F)
;	- Destroys: `F`
; ==============================================
cgb_getB:
    ld a, h
    SR a, 2
    and $1F
    ret


; ==============================================
; Lightens a 16-bit color in `HL` by 1
; --
;	- Inputs: `HL` = RGB color
;	- Outputs: `HL` = lightened RGB color
;	- Destroys: `AF`, `DE`
; ==============================================
cgb_colorLigthen:
    ld de, $0421
    call cgb_getB
    cp $1F
    jr nz, .blue_good
    ; remove X4XX
    ld de, $0021
.blue_good:
    call cgb_getG
    cp $1F
    jr nz, .green_good

    ; remove XX2X
    ld a, -$20
    add a, e
    ld e, a
.green_good:
    ld a, $1F
    cp l
    jr nz, .red_good
    
    ; remove XXX1
    dec e

.red_good:
    add hl, de
    ret


; ==============================================
; Darkens a 16-bit color in `HL` by 1
; --
;	- Inputs: `HL` = RGB color
;	- Outputs: `HL` = darkened RGB color
;	- Destroys: `AF`, `B`, `DE`
; ==============================================
cgb_colorDarken:
    ld de, $0421
    call cgb_getB
    or a
    jr nz, .blue_good
    ; remove X4XX
    ld de, $0021
.blue_good:
    call cgb_getG
    or a
    jr nz, .green_good

    ; remove XX2X
    ld a, -$20
    add a, e
    ld e, a
.green_good:
    ld a, l
    or a
    jr nz, .red_good

    ; remove XXX1
    dec e
.red_good:
    SUB16 hl, de
    ret


; ==============================================
; Darkens a color in the background palette
; --
;	- Inputs: `A` = palette number (0-7), `B` = color index 0-3
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
cgb_darkenBGPalette:
    ; gets palette index
    SL a, 3 ; times 8
    add a, b
    add a, b
    or $80
    inc a
    ldh [rBCPS], a

    ld hl, rBCPD
    ; read high byte of color
    ld c, a
    call gfx_VRAMReadable
    ld a, c

    ld d, [hl]

    ; now read low byte of color
    dec a
    ldh [rBCPS], a
    
    ld c, a
    call gfx_VRAMReadable
    ld a, c
    
    ld e, [hl]
    
    ; now lighten the color
    LD16 hl, de
    call cgb_colorDarken

    ; wait for VRAM
    call gfx_VRAMReadable
    
    ; store new color
    ld a, l
    ldh [rBCPD], a

    ld a, h
    ldh [rBCPD], a
    ret



; ==============================================
; Darkens a color in the background palette
; --
;   - literally the same as darken
;	- Inputs: `A` = palette number (0-7), `B` = color index 0-3
;	- Outputs: `NONE`
;	- Destroys: `AF`, `C`, `DE`, `HL`
; ==============================================
cgb_lightenBGPalette:
    ; gets palette index
    SL a, 3 ; times 8
    add a, b
    add a, b
    or $80
    inc a
    ldh [rBCPS], a

    ld hl, rBCPD
    ; read high byte of color
    ld c, a
    call gfx_VRAMReadable
    ld a, c

    ld d, [hl]

    ; now read low byte of color
    dec a
    ldh [rBCPS], a
    
    ld c, a
    call gfx_VRAMReadable
    ld a, c
    
    ld e, [hl]
    
    ; now lighten the color
    LD16 hl, de
    call cgb_colorLigthen

    ; wait for VRAM
    call gfx_VRAMReadable
    
    ; store new color
    ld a, l
    ldh [rBCPD], a

    ld a, h
    ldh [rBCPD], a
    ret

cgb_black_palette: ; a blank palette
    dw $0842, $0842, $0842, $0842

; background palette 0
cgb_bg0_palette:
    dw $0842, $294A, $14A5, $4210

; background palette 1 (spikes and platforms)
cgb_bg1_palette:
    dw $0842, $77BD, $35AD, $1CE7

; background palette 1 (checkpoint)
cgb_bg2_palette:
    dw $0842, $1084, $2108, $0360

cgb_obj0_palette:
    dw $B9C7, $5294, $294A ; colors 1-3
; B9C7 ; very cool blue color

; obj7 is as death palette