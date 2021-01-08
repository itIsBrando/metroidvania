; ==============================================
; Shorthand delay loop that is meant for constant delay
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `C`
; ==============================================
gfx_haltDelay: 
    ld c, 8
.loop:
    halt
    dec c
    jr nz, .loop
    ret


; ==============================================
; Fades the screen in
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `BC`
; ==============================================
gfx_fadeIn:
    IS_CGB
    jr nz, cgb_fadeIn
    
    ld c, GRAPHICS_PALETTE
    xor a
    
    ld b, 4
.loop:
    rl c
    rl a
    rl c
    rl a

    ldh [rBGP], a
    ldh [rOBP0], a
    
    call gfx_haltDelay
    dec b
    jr nz, .loop
    ret


; ==============================================
; Fades in the colors in CGB mode only
; --
;   - see `gfx_fadein`
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `BC`
; ==============================================
cgb_fadeIn:
    push hl
    push de

    call cgb_paletteClear

    ld b, 4
.loop:
    call gfx_haltDelay

    dec b
    
    ; load all bg palettes
    push bc

    ; save color number (0-3)
    ld a, b
    ld [plr_bullet_buffer], a

    ld a, 3 ; run three times
    ld hl, .cgb_palettes
    ld de, .local_for_loop_routine
    call util_forloop

    pop bc

    ld a, b
    or a
    jr nz, .loop
    
    pop de
    pop hl

    jp cgb_loadOBJPalettes

.local_for_loop_routine:
    ld c, a ; save pal number

    ; get palette number (0-3)
    ld a, [plr_bullet_buffer]
    ld b, a ; save that in B

    ; HL = pointer to color palette, so we must get a color
    add a, a
    ld d, 0
    ld e, a
    add hl, de
    LOAD_HL_HL_IND 0
    
    ld a, c ; restore pal number
    jp cgb_writeBGColor
.cgb_palettes:
    dw cgb_bg0_palette, cgb_bg1_palette, cgb_bg2_palette


; ==============================================
; Fades the screen out
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `B`
; ==============================================
gfx_fadeOut:
    IS_CGB
    jr nz, cgb_fadeOut

    ld b, 4
.loop:
    ldh a, [rBGP]
    SR a, 2
    ldh [rBGP], a
    ldh [rOBP0], a
    
    call gfx_haltDelay
    dec b
    jr nz, .loop
    ret


; ==============================================
; Fades the screen out in CGB mode
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `BC`
; ==============================================
cgb_fadeOut:
    ; save these so parent function does not destroy all
    push hl
    push de
    push bc

    ld b, 4
.loop:
    dec b

    ; clear color `B` in each palette (0-7)
    ld c, 7
.clear_bg_loop:
    ld a, c
    ld hl, 0
    call cgb_writeBGColor
    dec c
    ld a, c
    inc a
    jr nz, .clear_bg_loop

    xor a
    ld hl, 0
    call cgb_writeOBJColor

    call gfx_haltDelay

    ld a, b
    inc a
    jr nz, .loop

    pop bc
    pop de
    pop hl
    ret


; ==============================================
; Sets all palettes
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `A`, HL`
; ==============================================
gfx_resetPalette:
    ; revert palettes
    ld a, GRAPHICS_PALETTE
    ld hl, rBGP
    ld [hl+], a
    ld [hl], a
    
    IS_CGB
    ret z

    ; do CGB palette loading
    call cgb_loadBGPalettes
    jp cgb_loadOBJPalettes


; ==============================================
; Sets the dark palette for the underground
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
gfx_setDarkPalette:
    IS_CGB
    jr nz, .cgb

    ; set sprite palettes to be invisible
    ld a, $FF
    ldh [rOBP0], a
    ; set all white colors to black
    ld a, GRAPHICS_PALETTE | 3
    ldh [rBGP], a
    ret

.cgb:
    ; set sprite colors to black
    ld b, 4
.loop:
    dec b

    xor a
    ld hl, $0421
    call cgb_writeOBJColor

    ; darken background colors
    push bc
    xor a
    call cgb_darkenBGPalette
    pop bc

    push bc
    xor a
    call cgb_darkenBGPalette
    pop bc

    push bc
    xor a
    call cgb_darkenBGPalette
    pop bc
    
    ld a, b
    or a
    jr nz, .loop

    ; set background to black
    xor a
    ld b, a
    ld hl, $0842
    call cgb_writeBGColor

    ret