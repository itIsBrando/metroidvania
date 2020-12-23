SECTION "VBLANK", ROM0[$40]
    jp int_vblank


SECTION "SERVICE", ROM0

; ==============================================
; V-Blank interrupt
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
int_vblank:
    PUSH_ALL
    xor a
    ld [int_shouldOAMTransfer], a

    ; check for placing tiles
    ld hl, map_obj_set_tile
    ld a, [hl]
    or a
    call nz, int_placeTile

    ; check for clearing window text
    ld hl, gfx_window_text_counter
    ld a, [hl]
    or a
    call nz, int_clearWindowText

    ; check player redraw
    ld hl, plr_shouldUpdate
    ld a, [hl]
    or a
    jr z, .noPlrUpd
    ld [hl], 0
    call plr_draw
    ; say that we need to update
    ld a, 1
    ld [int_shouldOAMTransfer], a

.noPlrUpd:
    ; check if we need to flush OAM
    ld a, [int_shouldEmptyOAM]
    or a
    jr z, .updateEntities

    call ent_emptyOAM
    jr .return
    
.updateEntities:
    ld a, [ent_table_size]
    or a
    call nz, ent_vblank

    ld a, [int_shouldOAMTransfer]
    or a
    call nz, _HRAM

.return:

    POP_ALL
    reti

; ==============================================
; Places a tile during VRAM
; --
;	- Inputs: `HL`= pointer to `map_obj_set_tile`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
int_placeTile:
    ld [hl], 0 ; reset enable flag
    inc hl

    ld b, [hl] ; tile
    inc hl
    ; tile pointer
    ld a, [hl+]
    ld h, [hl] 
    ld l, a

    ld [hl], b
    ret


; ==============================================
; May clear text on the window if 120 frames have past since dipslaying
; --
;	- Inputs: `HL` =`A` = `gfx_window_text_counter`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
int_clearWindowText:
    inc [hl]
    ; return if 120 frames haven't passed
    cp 9+1
    jr c, int_scrollWindowUp
    cp 121-8
    call nc, int_scrollWindowDown
    cp 121
    ret nz
    
    ; reset counter
    ld [hl], 0
    ; don't need to redraw window HUD because the text will be hidden from the screen
    ret



; ==============================================
; Moves the background towards the top of the screen by 1px
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`,`HL`
; ==============================================
int_scrollWindowUp:
    ld hl, rWY
    ld a, [hl]
    cp 144-24
    ret c
    dec [hl]
    ret


; ==============================================
; Moves the background towards the bottom of the screen by 1px
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `NONE`
; ==============================================
int_scrollWindowDown:
    push hl
    ld hl, rWY
    inc [hl]
    pop hl
    ret