SECTION "PLAYER", ROM0
; ==============================================
; Draws the player
; --
;   - Writes the player to DMA
;   - Destroys: `AF`, `HL`
; ==============================================
plr_draw:
    ld hl, plr_obj_OAM_index
    ld a, [hl+] ; get DMA address
    jp ent_writeDMA

; ==============================================
; Sets the tile of the player in the buffer
; --
;	- Inputs: `A` = tile
;	- Outputs: `NONE`
;	- Destroys: `A` = 1
; ==============================================
plr_setTile:
    ld [plr_obj_tile], a

; ==============================================
; Sets the redraw flag for the player
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `A` = 1
; ==============================================
plr_setRedrawFlag:
    ld a, 1
    ld [plr_shouldUpdate], a ; say that we need redraw
    ret
    

; ==============================================
; Moves the player
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `HL`
; ==============================================
plr_moveLeft: ; should turn this into an entity routine that accepts a pointer
    ; return if there is a solid
    call plr_collisionLeft
    or a
    ret nz

    ; set player direction
    ld hl, plr_obj_flag
    set OAMB_XFLIP, [hl]

    ld hl, plr_obj_x
    ld a, [hl]
    cp 8
    jp z, map_scrollLeft
    dec [hl]
    call plr_checkGrounded
    jr plr_setRedrawFlag


; ==============================================
; Moves the player
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `HL`
; ==============================================
plr_moveRight:
    ; return if there is a block there
    call plr_collisionRight
    or a
    ret nz

    ; set player direction
    ld hl, plr_obj_flag
    res OAMB_XFLIP, [hl]

    ld hl, plr_obj_x
    ld a, [hl]
    cp 160
    jp z, map_scrollRight
    inc [hl]
    call plr_checkGrounded
    jr plr_setRedrawFlag


; ==============================================
; Moves the player down
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_moveDown:
    ; return if there is a block there
    call plr_collisionDown
    or a
    ret nz

    ld hl, plr_obj_y
    inc [hl]
    ; check for scroll
    ld a, [hl]
    cp MAP_HEIGHT * 8
    jp nc, map_scrollDown

    call plr_checkGrounded    
    jr plr_setRedrawFlag


; ==============================================
; Set player X and Y
; --
;	- Inputs: `A` = Y, `E` = X
;	- Outputs: `NONE`
;	- Destroys: `AF`, `HL`
; ==============================================
plr_setPosition:
    ld hl, plr_obj_y
    ld [hl+], a
    ld [hl], e
    jr plr_setRedrawFlag


; ==============================================
; Gets the player's position
; --
;	- Inputs: `NONE`
;	- Outputs: `A` = y, `E` = x
;	- Destroys: `HL`
; ==============================================
plr_getPosition:
    ld hl, plr_obj_y
    ld a, [hl+]
    ld e, [hl]
    ret


; ==============================================
; Fires the player's gun (Possibly!)
; --
;   - `plr_bullet_cool_down` must = 0 and `A button` must be pressed
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_fireGun:
    ld hl, plr_bullet_cool_down
    ld a, [hl]
    or a
    jr z, .fire

    ; if plr_bullet_cool_down > 0
    dec [hl]
    ret

.fire:
    ; return if no button is pressed
    ld a, [key]
    bit PADB_B, a
    ret z

    ; get cooldown time for the bullet type
    push hl
    ld hl, gun_cooldown_table

    ; get an index from bullet type
    ld a, [plr_bullet_type]
    call itm_getBulletIndex
    
    ld d, a ; A = 0
    ld e, c
    add hl, de
    ld a, [hl]
    pop hl

    ld [hl], a ; cool down time (frames)

    ; get player position
    call plr_getPosition
    ld hl, plr_bullet_buffer
    push hl
    
    ld [hl+], a ; Y
    ld [hl], e  ; X
    inc hl      ; Tile

    ; get tile
    ld de, gun_tile_table
    ld a, [plr_bullet_type]
    ; get an index
    call itm_getBulletIndex
    ld a, c
    call utl_lookup_A

    ; store tile
    ld [hl], a
    inc hl      ; script pointer

    ld de, srpt_moveLeft

    ; check direction
    ld a, [plr_obj_flag]
    bit OAMB_XFLIP, a
    jr nz, .isLeft

    ld de, srpt_moveRight
.isLeft:
    ld [hl], e
    inc hl
    ld [hl], d
    
    pop hl
    jp ent_create


; ==============================================
; Hooks the `map_getCollision` routine
; --
;   - sets the flag that ensures that tile scripts will run
;	- Inputs: `A` = y, `E` = x
;	- Outputs: `1` = solid, `0` = transparent
;	- Destroys: `ALL`
; ==============================================
plr_getCollision:
    ld hl, map_collision_can_run_script
    ld [hl], 1
    jp map_getCollision


; ==============================================
; Changes the active bullet for the player
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_changeBullet:
    ; reset button mask
    ld hl, joypadMask
    res PADB_SELECT, [hl]

    ; change bullet type
    call itm_next
    
    ld a, [plr_bullet_type]
    call itm_getBulletIndex

    ; draw informational text
    ld hl, plr_bullet_texts
    ld d, a ; A = 0
    ld a, c ; A = index
    add a, a ; x2
    ld e, a
    add hl, de

    ld a, [hl+]
    ld h, [hl]
    ld l, a

    call wnd_showText

    ; change bullet icon
    ld a, [plr_bullet_type]
    call itm_getBulletIndex

    call gfx_VRAMReadable
    ld a, MAP_TILE_BULLET
    ; get tile
    add a, c
    ld [WINDOW_LOCATION + 4], a
    ret