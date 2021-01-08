; ==============================================
; Move script WITH COLLISION (2px)
; --
;   - For player bullet only
;   - deletes on collision or out of range
;	- Inputs: `DE` = pointer to entity base, `A` = index
; ==============================================
srpt_bullet_moveLeft:
    push de
    inc de ; Y
    ld a, [de]
    ld h, a ; save Y for collision
    inc de ; X
    ld a, [de]
    cp 180
    jp nc, srpt_delete

    sub 9
    ld e, a ; e = X - 8
    ld [plr_bullet_buffer + 1], a ; save X for bomb blaster
    ld a, h ; Y
    sub 12  ; a = Y - 12
    ld [plr_bullet_buffer], a ; save Y for bomb blaster
    
    call map_getCollision
    ; check for tele-pellet
    or a
    jp nz, srpt_bullet_chkTeleport

    ; if we are index 0, then skip collision checking
    ld a, [srpt_entity_index]
    
    ; checks for any collision
    call ent_anyCollision
    ld a, [ent_collision_flag]
    or a
    call nz, srpt_killEntity

    pop hl
    ld e, -2
    jp ent_changeX


; ==============================================
; Move script WITH COLLISION (2px)
; --
;   - deletes on collision or out of range
;	- Inputs: `DE` = pointer to entity base, `A` = index
; ==============================================
srpt_bullet_moveRight:
    push de
    inc de ; Y
    ld a, [de]
    ld h, a ; save Y coord
    inc de ; X
    ld a, [de]
    cp 160
    jp nc, srpt_delete

    ; get for collision
    ld e, a ; e = X
    ld [plr_bullet_buffer + 1], a ; save X for bomb blaster
    ld a, h ; Y
    sub 12   ; a = Y - 12
    ld [plr_bullet_buffer], a ; save Y for bomb blaster

    call map_getCollision

    or a
    jp nz, srpt_bullet_chkTeleport

    ; check for entity-to-entity collision
    ld a, [srpt_entity_index]
    call ent_anyCollision

    ld a, [ent_collision_flag]
    or a
    call nz, srpt_killEntity

.skipCollision:   
    pop hl
    ld e, 2
    jp ent_changeX


; local routine. Used by bullet movement when the player shoots at a bomable block
; hl = base, A = tile
srpt_bullet_chkBombable:
    ; delete bullet if current bullet is not bomb blaster
    cp MAP_TILE_BOMB_BLASTER
    jp nz, srpt_delete + 1
    
    ; delete bullet if the collision block is not bombable
    ld a, [map_collision_raw_flag]
    bit 3, a
    jp z, srpt_delete + 1

    ; retrieve coordinates of the tile we hit
    ld hl, plr_bullet_buffer
    ld a, [hl+] ; Y
    ld e, [hl]  ; X
    SR a, 3
    SR e, 3
    ; clear the tile at (E, A)
    call map_getTileCollision
    ld [hl], 0

    call map_roomToVRAM
    xor a
    call map_setTileWithPointer

    ld hl, plr_bullet_buffer
    ld a, [hl+] ; Y
    add a, $10

    ld e, [hl]  ; X
    call ent_createParticle

    jp srpt_delete + 1


; local routine. Used by bullet movement routines.
; HL = base of entity
srpt_bullet_chkTeleport:
    pop hl
    call ent_getTile
    ; check for a tele-pellet
    ; if not a tele-pellet, check bomb blaster

    ; check for bomb blaster
    cp MAP_TILE_TELE_PELLET
    jr nz, srpt_bullet_chkBombable

    ; teleport player to bullet position
    inc hl
    
    ; copy Y
    ld a, [hl+]
    ld [plr_obj_y], a
    ; copy X
    ld a, [hl]
    ld [plr_obj_x], a
    call plr_setRedrawFlag
    call plr_checkGrounded
    jp srpt_delete + 1 ; skip the pop instruction
