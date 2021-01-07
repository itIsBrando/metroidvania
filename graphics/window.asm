; ==============================================
; Shows informational text on the window.
; --
;   - disappears after 60 frames
;	- Inputs: `HL` = string pointer
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
wnd_showText:
    ld a, 1
    ld [gfx_window_text_counter], a
    GET_XY_WINDOW de, 0, 2
    ld b, 0
    call gfx_drawString
    ; fill the rest of the line with nothing
    ld a, 20
    sub b
    or a
    ret z
.loop:
    call gfx_VRAMReadable
    xor a
    ld [de], a
    inc de
    dec b
    jr nz, .loop
    ret


; ==============================================
; Draws the window HUD
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
wnd_drawHUD:
    MCOPY dta_window_row_1, WINDOW_LOCATION, 20
    MCOPY dta_window_row_2, WINDOW_LOCATION + $20, 20

    IS_CGB
    ret z

    ; set VRAM bank
    ld a, 1
    ldh [rVBK], a
    ; set palette for minimap HUD
    ld hl, WINDOW_LOCATION + 18
    call .write_pal
    
    ld hl, WINDOW_LOCATION + $20 + 18
    call .write_pal

    xor a
    ldh [rVBK], a
    ret

.write_pal:
    call gfx_VRAMReadable
    ld a, 1
    ld [hl+], a
    ld [hl], a
    ret
; ==============================================
; Resets minimap pixels at `map_current_id`
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
wnd_clearMinimap:
    ld a, 3
    ld [wnd_minimapColor], a
    jr wnd_writeToMiniMap

; ==============================================
; Modifies tiles to show the minimap
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
wnd_generateMinimap:
    ld a, $01 ; color to write
    ld [wnd_minimapColor], a
    

; ==============================================
; Updates the minimap tiles
; --
;	- Inputs: `wnd_minimapColor` = color to write
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
wnd_writeToMiniMap
    ld a, [map_current_id]
    ld d, a
    ld e, MAP_ROOM_TABLE_WIDTH
    call math_div_D_E
    ; A = x
    ; D = y

    ld hl, TILE_ADDRESS + 16 * (MAP_TILE_MINIMAP) + 2

    ; add Y offset
    ; ****************************CHECK IF Y > 4********************************
    ld e, a ; save A
    
    ; if D > 4, then we've overflowed this current tile
    ld a, d
    cp 4
    jr c, .keepTile
    ; look at the tile below the current one
    ld hl, TILE_ADDRESS + 16 * (MAP_TILE_MINIMAP + 16) + 2
    DECREMENT d, 4
.keepTile:
    ld a, e ; restore A
    dec d
    inc d
    jr z, .skipLoop
.loop:
    INCREMENT hl, 4
    dec d
    jr nz, .loop

.skipLoop:
    ; A *= 3
    ld c, a
    add a, a
    add a, c

    cp 7 ; if x > 7
    jr c, .keepHL
    ; look at the tile to the right of current one
    ld de, 16
    add hl, de
    sub 8
.keepHL:
    ; 7 - a
    ld c, a
    ld a, 7
    sub c
    ;cpl
    ; add a, 7


    ld e, a
    ld d, a
    ; get color
    ld a, [wnd_minimapColor]
    ld b, a
    call gfx_setColor

    dec d
    ld e, d
    ; get color
    ld a, [wnd_minimapColor]
    ld b, a

    call gfx_setColor

    ret





; ==============================================
; Moves the window towards the top of the screen
; --
;	- Inputs: `A` = move window by, `B` = frames to delay per decrement (assuming 30fps)
;	- Outputs: `NONE`
;	- Destroys: `AF`, `C`, `HL`
; ==============================================
wnd_scrollNorth:
    srl a ; divide by two because we change rWY by two each loop
    
    ld hl, rWY
.loop:
    ld c, b
    halt
    dec c
    jr nz, .loop
    
    dec [hl]
    dec [hl]
    dec a
    jr nz, .loop
    ret


; ==============================================
; Moves the window towards the bottom of the screen
; --
;	- Inputs: `A` = move window by, `B` = frames to delay per decrement (assuming 30fps)
;	- Outputs: `NONE`
;	- Destroys: `AF`, `C`, `HL`
; ==============================================
wnd_scrollSouth:
    srl a
    ld hl, rWY
.loop:
    ld c, b
    halt
    dec c
    jr nz, .loop
    ld c, b
    
    inc [hl]
    inc [hl]
    dec a
    jr nz, .loop
    ret
    
