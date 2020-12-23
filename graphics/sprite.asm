SECTION "SPRITE", ROM0
; ==============================================
; Clears all sprites.
; --
;   - Initiates a DMA transfer
;   - Destroys: `ALL`
; ==============================================
gfx_zeroOAM:
    xor a
    ld hl, DMA_ADDRESS
    ld bc, 160
    call mem_set
    jp _HRAM


; ==============================================
; Clears the background
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
gfx_zeroBackground:
    MSET 0, BG_LOCATION, 32 * 32
    ret

; ==============================================
; Clears the window
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
gfx_zeroWindow:
    MSET 0, WINDOW_LOCATION, 32 * 32
    ret