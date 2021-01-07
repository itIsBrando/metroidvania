SECTION "BLIT", ROM0

; ==============================================
; Copies a column of tiles (`MAP_HEIGHT`) to the screen
; --
;	- Inputs: `HL` = source pointer, `A` = VRAM column number (0-31)
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
gfx_blitColumn:
    and $1F
    ld e, a
    ld d, 0

    push hl

    ; find Y offset
    ldh a, [rSCY]
    and $F8 ; divide by 8, multiply by 8
    ld h, d ; D = H = 0
    ld l, a
    add hl, hl  ; x16
    add hl, hl  ; x32

    add hl, de  ; add X offset

    ; HL = pointer to VRAM
    ld de, BG_LOCATION
    add hl, de

    pop de
    ; DE = pointer to source
    ld b, MAP_HEIGHT
.loop:
    call gfx_VRAMReadable
    ld a, [de]
    ld [hl], a

    call gfx_blitCGB

    ld a, b
    ld bc, 32
    add hl, bc

    push hl

    ld hl, MAP_WIDTH
    add hl, de
    LOAD_DE_HL

    pop hl
    
    push af
    call srll_checkOverflow
    pop af
    
    ld b, a
    dec b
    jr nz, .loop
    ret


; ==============================================
; Modifies the colors of certain tiles during blitting
; --
;	- Inputs: `HL` = VRAM pointer, `DE` = pointer to buffer
;	- Outputs: `NONE`
;	- Destroys: `AF`, `C`
; ==============================================
gfx_blitCGB:
    ld c, a ; save tile
    ; only run if we in CGB
    IS_CGB
    ret z
    
    ld a, c
    ; `C` will be our flag's byte
    ld c, $0

    call .is_palette1
    jr nz, .no_palette1
    inc c ; $01
    jr .skip_all_further_checks
.no_palette1:
    call .is_palette2
    jr nz, .no_palette2
    inc c
    inc c ; $02

.no_palette2:

.skip_all_further_checks:
    ld a, 1
    ldh [rVBK], a

    call gfx_VRAMReadable
    ld [hl], c

    xor a
    ldh [rVBK], a

    ret

; checks if `A` is a tile that should use a different palette
; `NZ` = normal, `Z` = colored
.is_palette1:
    cp MAP_TILE_FALLING_BLOCK_1
    ret z
    cp MAP_TILE_SPIKE
    ret z
    cp MAP_TILE_BREAKABLE_BLOCK
    ; ret z
    ret
; checks if `A` is a tile that should use a different palette
; `NZ` = normal, `Z` = colored
.is_palette2:
    cp MAP_TILE_CHECKPOINT_1
    ret z
    cp MAP_TILE_CHAIN
    ret z
    cp MAP_TILE_HANGING_CHAIN
    ; ret z
    ret

; ==============================================
; Copies a row of tiles (`MAP_WIDTH`) to the screen
; --
;	- Inputs: `HL` = pointer to buffer, `A` = row (0-31)
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
gfx_blitRow:
    and $1F
    SHIFT_LEFT a, 3 ; x8

    push hl
    ld l, a
    ld h, 0
    add hl, hl      ; x16
    add hl, hl      ; x32
    ; HL = pointer to VRAM
    ld de, BG_LOCATION
    add hl, de

    xor a
    ld [plr_bullet_buffer], a

    ; add X offset
    ldh a, [rSCX]
    SHIFT_RIGHT a, 3 ; divide by 8
    and $1F
    ld d, 0
    ld e, a
    add hl, de
    pop de
    
    ; DE = pointer to source
    ld b, MAP_WIDTH

    ; we need to do this but i cannot explain it easily
    add a, b
    cp $1F-1
    call nc, .willNeedSub

.loop:
    call gfx_VRAMReadable
    ld a, [de]
    ld [hl], a

    call gfx_blitCGB
    
    inc hl
    
    ; this is also part of the thing i cannot explain
    ld a, [plr_bullet_buffer]
    cp b
    call z, .doSub

    call srll_checkOverflow
    
    inc de
    dec b
    jr nz, .loop
    ret 

.willNeedSub:
    inc a
    and $1F
    ld [plr_bullet_buffer], a
    ret

.doSub:
    push de
    ld de, -32
    add hl, de
    pop de
    ret 

; ==============================================
; CP HL,DE
; --
;	- Inputs: `HL`, `DE
;	- Outputs: `NZ` if HL-DE > 0
;	- Destroys: `A`, `HL`
; ==============================================
utl_cp_HL_DE:
    SUB16 hl, de
    ld a, l
    or h
    ret