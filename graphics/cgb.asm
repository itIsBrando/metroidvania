SECTION "CGB", ROM0

; ==============================================
; should be called regardless of the gameboy used
; --
;	- Inputs: `A` = BIOS register value
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
cgb_init:
    ld [cgb_gameboy_type], a

    ; only continue if we are CGB
    cp $11
    ret nz

    ld a, $80
    ldh [rBCPS], a
    ldh [rOCPS], a

    ; copy over primary background palette
    ld hl, cgb_bg0_palette
    call cgb_writeBGPalette

    ; copy over primary sprite palette
    ld hl, cgb_obj0_palette
    call cgb_writeOBJPalette

    ret 



; ==============================================
; Writes a palette to lcd registers
; --
;	- Inputs: `HL` = pointer to palette
;	- Outputs: `NONE`
;	- Destroys: `ALL`
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
; Writes a palette to lcd registers
; --
;	- Inputs: `HL` = pointer to palette (only three colors)
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
cgb_writeOBJPalette:
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

cgb_bg0_palette:
    dw $0842, $14A5, $294A, $4210 ; colors

cgb_obj0_palette:
    dw $B9C7, $5294, $294A ; colors 1-3
; B9C7 ; very cool blue color