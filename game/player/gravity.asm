SECTION "PLAYER MOVE", ROM0
; ==============================================
; Applys gravity to the player
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_applyGravity:
    ; return if we are on ground
    ld a, [plr_obj_is_grounded_flag]
    or a
    ret nz

    call plr_moveDown
    
    ; return if the tile is not solid
    ld a, [map_collision_flag]
    or a
    ret z
    
    ; else, set grounded flag
    ld [plr_obj_is_grounded_flag], a
    ret

; ==============================================
; Updates plr_obj_is_grounded_flag
; --
;   - also updates `plr_frames_since_grounded`
;   - Checks if there is a solid block underneath the player
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_checkGrounded:
    call plr_collisionDown
    ld [plr_obj_is_grounded_flag], a
    or a
    ret z
    xor a
    ld [plr_frames_since_grounded], a
    ret


; ==============================================
; Makes the player jump
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_jump:

    ; if we are jumping, the continue jumping
    ld a, [plr_obj_is_jumping_flag]
    or a
    jr nz, .isJumping

    ; return if jump button is not pressed
    ld a, [key]
    bit PADB_A, a
    ret z

    ; return if we are not on the ground
    ld a, [plr_obj_is_grounded_flag]
    or a
    ; ret z

    ; check coyote frame
    ld a, [plr_frames_since_grounded]
    cp PLAYER_COYOTE_FRAMES
    ret nc

    ; otherwise, start our jump
.initJump:
    ld a, 1
    ld [plr_obj_is_jumping_flag], a
    ;jr .isJumping

; this is called each framw that the player is jumping
.isJumping:
    ; return if jump button is not pressed
    ld a, [key]
    bit PADB_A, a
    jr z, .stopJump

    ; check if we need to stop jumping
    ld hl, plr_obj_is_jumping_flag
    ld a, [hl]
    cp PLAYER_JUMP_TABLE_SIZE+1
    jr nc, .stopJump

    ; increase LUT index
    inc [hl]

    ld d, 0
    ld e, a

    push de
    call plr_collisionUp
    pop de
    or a
    jr nz, .stopJump


    ld hl, plr_jump_table-1
    add hl, de
    ld b, [hl]

    ld hl, plr_obj_y
    ld a, [hl] ; get Y coord
    cp $14
    jp c, map_scrollUp
    sub b
    ld [hl], a
    
    ; declare the we are not on the ground
    xor a
    ld [plr_obj_is_grounded_flag], a

    jp plr_setRedrawFlag


.stopJump
    ; reset mask
    ld hl, joypadMask
    res PADB_A, [hl]
    
    xor a
    ld [plr_obj_is_jumping_flag], a
    ret


; ==============================================
; Adds displacement to the player's X position
; --
;   - updates redraw flag
;	- Inputs: `A` = signed displacement
;	- Outputs: `A` = new X position
;	- Destroys: `AF`, HL`
; ==============================================
plr_changeX:
    ld hl, plr_obj_x
    add a, [hl]
    ld [hl], a
    jp plr_setRedrawFlag


; ==============================================
; Adds displacement to the player's Y position
; --
;   - updates redraw flag
;	- Inputs: `A` = signed displacement
;	- Outputs: `A` = new Y position
;	- Destroys: `AF`, HL`
; ==============================================
plr_changeY:
    ld hl, plr_obj_y
    add a, [hl]
    ld [hl], a
    jp plr_setRedrawFlag