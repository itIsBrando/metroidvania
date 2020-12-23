SECTION "SCROLL", ROM0

; ==============================================
; Scrolls the map to the right
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_scrollRight:
    call wnd_clearMinimap
    call map_rightRoom
    xor a ; don't draw to screen
    call map_loadRoom

    ; ldh a, [rSCY] ; BG Y
    ; ; A * 32
    ; and $F8 ; divide by 8, then multiply by
    ; ld l, a
    ; ld h, 0
    ; add hl, hl  ; x16
    ; add hl, hl  ; x32

    ; ld de, BG_LOCATION
    ; add hl, de
    ; ; HL = Y position to draw

    ld c, MAP_WIDTH
    ldh a, [rSCX]
    SHIFT_RIGHT a, 3 ; divide by 8
    add a, c

    ld hl, map_room_buffer

.loop:
    push af
    push bc
    push hl

    halt
    call gfx_blitColumn

    ld b, 8
.loop2:

    ; move window
    ld hl, rSCX
    inc [hl]

    ; move player position
    ld hl, plr_obj_x
    dec [hl]
    call plr_setRedrawFlag

    dec b
    jr nz, .loop2

    pop hl
    pop bc
    pop af

    inc a
    inc hl

    dec c
    jr nz, .loop
    
    ld hl, plr_obj_x
    ld a, [hl]
    add a, 9
    ld [hl], a
    jp plr_setRedrawFlag


; ==============================================
; Scrolls the map to the left
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_scrollLeft:
    call wnd_clearMinimap

    call map_leftRoom
    xor a ; don't draw to screen
    call map_loadRoom

    ldh a, [rSCX]
    SHIFT_RIGHT a, 3 ; divide by 8
    dec a

    ld hl, map_room_buffer + MAP_WIDTH-1

    ld c, MAP_WIDTH
.loop:
    push af
    push bc
    push hl

    halt
    call gfx_blitColumn

    ld b, 8
.loop2:

    ; move BG
    ld hl, rSCX
    dec [hl]

    ; move player position
    ld hl, plr_obj_x
    inc [hl]
    call plr_setRedrawFlag

    dec b
    jr nz, .loop2

    pop hl
    pop bc
    pop af

    dec a
    dec hl

    dec c
    jr nz, .loop
    
    ld hl, plr_obj_x
    ld a, [hl]
    sub 9
    ld [hl], a
    jp plr_setRedrawFlag


; ==============================================
; Scrolls the map upwards
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_scrollUp:
    call wnd_clearMinimap
    call map_upRoom
    xor a
    call map_loadRoom
plr_test:
    ldh a, [rSCY]
    SHIFT_RIGHT a, 3
    dec a

    ; get pointer to the beginning of the last row
    ld hl, map_room_buffer + MAP_WIDTH * (MAP_HEIGHT - 1)
    
    ld c, MAP_HEIGHT
.loop:
    push af
    push hl

    halt

    push bc
    call gfx_blitRow
    pop bc

    ld b, 8
.loop2:
    ld hl, rSCY
    dec [hl]
    ld hl, plr_obj_y
    inc [hl]

    call plr_setRedrawFlag
    
    dec b
    jr nz, .loop2

    pop hl
    pop af
    
    dec a
    
    ld b, a
    ld de, MAP_WIDTH
    SUB16 hl, de

    ld a, b

    dec c
    jr nz, .loop
    
    ld a, -24
    jp plr_changeY


; ==============================================
; Scrolls the map downwards
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_scrollDown:
    call wnd_clearMinimap
    call map_downRoom
    xor a
    call map_loadRoom

    ldh a, [rSCY]
    SHIFT_RIGHT a, 3
    add a, MAP_HEIGHT

    ; get pointer to the beginning of the last row
    ld hl, map_room_buffer
    
    ld c, MAP_HEIGHT
.loop:
    push af
    push hl

    halt 
    call gfx_blitRow

    ld b, 8
.loop2:
    ld hl, rSCY
    inc [hl]
    ld hl, plr_obj_y
    dec [hl]

    call plr_setRedrawFlag
    
    dec b
    jr nz, .loop2

    pop hl
    pop af
    
    inc a
    
    ld de, MAP_WIDTH
    add hl, de

    dec c
    jr nz, .loop
    
    ld a, 8
    jp plr_changeY



; check if HL has overflowed from reading/writing to VRAM
; destroys A
srll_checkOverflow:
    ld a, h
    cp $9C
    ret c
    ; continue if HL>=9C00
    
    push de
    ld de, -(BG_LOCATION) & $FFFF
    add hl, de
    pop de
    ret