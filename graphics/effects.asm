

; ==============================================
; Fades the screen in
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `BC`
; ==============================================
gfx_fadeIn:
    
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
    
    halt
    halt
    halt
    halt
    halt
    halt
    dec b
    jr nz, .loop
    ret


; ==============================================
; Fades the screen out
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `B`
; ==============================================
gfx_fadeOut:
    
    ld b, 4
.loop:
    ldh a, [rBGP]
    SHIFT_RIGHT a, 2
    ldh [rBGP], a
    ldh [rOBP0], a
    
    halt
    halt
    halt
    halt
    halt
    halt
    dec b
    jr nz, .loop
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
    ret


; ==============================================
; Sets the dark palette for the underground
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `A`, `HL`
; ==============================================
gfx_setDarkPalette:
    ; set sprite palettes to be invisible
    ld a, $FF
    ldh [rOBP0], a
    ; set all white colors to black
    ld a, GRAPHICS_PALETTE | 3
    ldh [rBGP], a
    ret