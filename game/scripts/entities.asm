SECTION "ENTITYSCRIPTS", ROM0

; ==============================================
; Move script WITH COLLISION (2px)
; --
;   - For player bullet only
;   - deletes on collision or out of range
;	- Inputs: `DE` = pointer to entity base, `A` = index
; ==============================================
srpt_moveLeft:
    push de
    inc de ; Y
    ld a, [de]
    ld h, a ; save Y for collision
    inc de ; X
    ld a, [de]
    cp 180
    jp nc, srpt_delete

    sub 8
    ld e, a ; e = X - 8
    ld [plr_bullet_buffer + 1], a ; save X for bomb blaster
    ld a, h ; Y
    sub 12  ; a = Y - 12
    ld [plr_bullet_buffer], a ; save Y for bomb blaster
    
    call map_getCollision
    ; check for tele-pellet
    or a
    jr nz, srpt_chkTeleport

    ; if we are index 0, then skip collision checking
    ld a, [srpt_entity_index]
    
    ; checks for any collision
    call ent_anyCollision
    ld a, [ent_collision_flag]
    or a
    jp nz, srpt_kill0

    pop hl
    ld e, -2
    jp ent_changeX


; local routine. Used by bullet movement when the player shoots at a bomable block
; hl = base, A = tile
srpt_chkBombable:
    ; delete bullet if current bullet is not bomb blaster
    cp MAP_TILE_BOMB_BLASTER
    jr nz, srpt_delete + 1
    
    ; delete bullet if the collision block is not bombable
    ld a, [map_collision_raw_flag]
    bit 3, a
    jr z, srpt_delete + 1

    ; retrieve coordinates of the tile we hit
    ld hl, plr_bullet_buffer
    ld a, [hl+] ; Y
    ld e, [hl]  ; X
    SHIFT_RIGHT a, 3
    SHIFT_RIGHT e, 3
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

    jr srpt_delete + 1


; local routine. Used by bullet movement routines.
; HL = base of entity
srpt_chkTeleport:
    pop hl
    call ent_getTile
    ; check for a tele-pellet
    ; if not a tele-pellet, check bomb blaster

    ; check for bomb blaster
    cp MAP_TILE_TELE_PELLET
    jr nz, srpt_chkBombable

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
    jr srpt_delete + 1 ; skip the pop instruction

; ==============================================
; Deletes an entity from a script. Decrements proper counters
; --
;   - jump to this routine if eatable on stack, or call with empty stack
;   - will not return if called or jumped to
;	- Inputs: `eatable top of stack`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
srpt_delete:
    pop hl ; pop base pointer (HL unneeded)
    
    ld a, [srpt_entity_index] ; index
    call ent_delete
    ld hl, srpt_entity_counter
    dec [hl]
    ret


; ==============================================
; Local routine used by the bullet to kill the entity in index 0
; --
;	- Inputs: `A` = index + 1
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
srpt_kill0:
    dec a
    push af
    call ent_getEntry

    ; prevent some tiles from deletion
    call ent_getTile
    cp MAP_TILE_BULLET
    jr z, .return
    cp MAP_TILE_CANNON
    jr z, .return
    cp MAP_TILE_PARTICLE1
    jr z, .return
    cp MAP_TILE_PARTICLE2
    jr z, .return
    
    ; call ent_hide
    pop af

    ; set new script for the entity
    call ent_getEntry
    call ent_setDeath

    ; now, delete self
    jp srpt_delete


.return:
    pop af
    pop hl ; HL was on stack
    ret

; ==============================================
; Move script WITH COLLISION (2px)
; --
;   - deletes on collision or out of range
;	- Inputs: `DE` = pointer to entity base, `A` = index
; ==============================================
srpt_moveRight:
    push de
    inc de ; Y
    ld a, [de]
    ld h, a ; save Y coord
    inc de ; X
    ld a, [de]
    cp 160
    jr nc, srpt_delete

    ; get for collision
    ld e, a ; e = X
    ld [plr_bullet_buffer + 1], a ; save X for bomb blaster
    ld a, h ; Y
    sub 12   ; a = Y - 12
    ld [plr_bullet_buffer], a ; save Y for bomb blaster

    call map_getCollision

    or a
    jr nz, srpt_chkTeleport

    ; check for entity-to-entity collision
    ld a, [srpt_entity_index]
    call ent_anyCollision

    ld a, [ent_collision_flag]
    or a
    jp nz, srpt_kill0

.skipCollision:   
    pop hl
    ld e, 2
    jp ent_changeX


; ==============================================
; Moves an entity downwards without collision checking
; --
;   - Removes entity after going offscreen
;	- Inputs: `DE` = pointer to entity base
; ==============================================
srpt_moveDownNoCollision:
    LOAD_HL_DE
    
    ld e, 3
    call ent_changeY

    cp 144
    jr nc, srpt_delete + 1

    ret 


; ==============================================
; Entity moves left and right until a collision occurs
; --
;   - up and down collisions not checked
;	- Inputs: `DE` = pointer to entity base, `A` = index
; ==============================================
srpt_moveLeftRight:
    LOAD_HL_DE

    ld a, [plr_is_dead]
    or a
    ret nz

    ; change action based off of direction
    call ent_getFlags
    bit OAMB_XFLIP, a
    jr z, .movingLeft
    
.movingRight:
    push hl

    ; get position
    call ent_getPosition

    ; Y - 12
    sub 12
    ld c, a

    ; X - 8
    ld a, e
    sub 8
    ld e, a
    ; restore Y to `A`
    ld a, c
    ; check the coordinate (x - 8, y - 12)
    call map_getCollision
    ; change direction if we run into something solid
    or a
    jr nz, .changeDirection

    pop hl
    ld e, -1
    call ent_changeX

    ; check for player collision
    ld de, plr_obj_base
    call ent_collision

    ld a, [ent_collision_flag]
    or a
    jp nz, plr_death
    ret

.movingLeft:
    push hl

    call ent_getPosition
    sub 12      ; Y - 12
    ; check the coordinate (x, y - 12)
    call map_getCollision
    or a
    jr nz, .changeDirection

    pop hl
    ld e, 1
    jp ent_changeX

.changeDirection:
    pop hl

    call ent_setRedraw

    ld de, ENTITY_ENTRY_FLAG
    add hl, de
    ld a, [hl]
    xor OAMF_XFLIP
    ld [hl], a

    ret

; ==============================================
; Script for the falling block
; --
;   - `ENTITY_ENTRY_DATA_1` is used as a lifetime counter
;	- Inputs: `DE` = pointer to entity base
; ==============================================
srpt_fallingBlock:
    ; Check if entity has been alive for 15 frames
    push de ; save entity base

    ld hl, ENTITY_ENTRY_DATA_1
    add hl, de

    pop de
    
    inc [hl]
    ld a, [hl]
    cp MAP_FALLING_BLOCK_FRAMES
    ret nz

    push de

    ; change script routine
    ld de, srpt_moveDownNoCollision
    INCREMENT hl, ENTITY_ENTRY_SCRIPT - ENTITY_ENTRY_DATA_1
    call utl_write_DE_to_HL

    pop hl
    ; get X and Y coordinate
    call ent_getPosition

    SHIFT_RIGHT a, 3
    dec a
    dec a ; Y - 16
    SHIFT_RIGHT e, 3
    dec e ; X - 8
    call map_getTileCollision
    ld [hl], 0 ; clear tile

    ; get our VRAM pointer
    call map_roomToVRAM
    ; tell vblank to write our tile to the background
    xor a
    call map_setTileWithPointer

    ; make gravity apply to player
    jp plr_checkGrounded


; ==============================================
; Cannon that periodically fires a bullet downwards
; --
;   - `ENTITY_ENTRY_DATA_1` is used as a lifetime counter
;	- Inputs: `DE` = pointer to base entity
; ==============================================
srpt_entityCannon:
    ; TODO ***unfortunately, this must be redrawn each frame AS OF RN!!***
    LD16 hl, de
    call ent_setRedraw
    
    ld de, ENTITY_ENTRY_DATA_1
    add hl, de

    ld a, [hl]
    inc a
    and $3F
    ld [hl], a
    ret nz

    ; HL = base
    ld de, -ENTITY_ENTRY_DATA_1
    add hl, de

    call ent_getPosition

    ; WHY DO I WRITE X BEFORE Y?????????
    ld hl, plr_bullet_buffer
    ld [hl+], a ; X
    ld [hl], e  ; Y
    inc hl
    ld [hl], MAP_TILE_BULLET
    inc hl

    ld de, srpt_moveDownNoCollision
    call utl_write_DE_to_HL

    ld hl, plr_bullet_buffer
    jp ent_create


; ==============================================
; An invisible entity that modifies the palettes
; --
;	- Inputs: `DE` = pointer to entity base
; ==============================================
srpt_entityDownButton:
    ld hl, ENTITY_ENTRY_DATA_1
    add hl, de

    inc [hl]
    ld a, [hl]
    cp 80
    ret nz

    ; do random stuff based off of room
    ld a, [map_current_id]

    ; room 1x4
    cp 1 + (4 * MAP_ROOM_TABLE_WIDTH)
    jr nz, .room1x4
    cp 4 + (2 * MAP_ROOM_TABLE_WIDTH)
    jr nz, .room4x2

.hasCoords:
    call map_getTileCollision
    ld [hl], $6A
    call map_roomToVRAM
    ld a, $6A
    call map_setTileWithPointer

    ld hl, srpt_entity_counter
    dec [hl]

    ld a, [srpt_entity_index]
    jp ent_delete


.room4x2:
    ; make funky palettes
    call gfx_setDarkPalette
    ; these are coordinates to the button
    ld e, 4
    ld a, 13
    jr .hasCoords


.room1x4:
    ; replace the empty tile with a filled tile
    ld e, 10
    ld a, 12
    call map_getTileCollision
    ld [hl], $01
    call map_roomToVRAM
    ld a, $01
    call map_setTileWithPointer
    
    halt 
    ld e, 3
    ld a, 9
    jr .hasCoords


; ==============================================
; The script that every entity should set when killed
; --
;	- Inputs: `DE` = pointer to entity base
; ==============================================
srpt_entDeath:
    ld hl, ENTITY_ENTRY_DATA_1
    add hl, de
    
    ld a, [hl]
    dec [hl]

    ; if counter > 0, return
    or a
    ret nz

    ; else delete entity
    ld a, [srpt_entity_index]
    call ent_delete

    ; decrement counter
    ld hl, srpt_entity_counter
    dec [hl]
    ret


; ==============================================
; Creates a particle at (x, y)
; --
;	- Inputs: `A` = y, `E` = x
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
ent_createParticle:
    ld hl, plr_bullet_buffer
    ld [hl+], a     ; Y
    ld [hl], e      ; X
    inc hl
    ld [hl], MAP_TILE_PARTICLE1 ; tile
    inc hl
    ld de, srpt_particle
    call utl_write_DE_to_HL

    ld hl, plr_bullet_buffer
    call ent_create

    ; set animation up
    ld a, [ent_table_size]
    dec a
    call ent_getEntry

    ld a, MAP_TILE_PARTICLE2
    ld b, $07
    jp ent_setAnimation


; ==============================================
; Particle entity
; --
;	- Inputs: `DE` = pointer to entity base
; ==============================================
srpt_particle:
    ld hl, ENTITY_ENTRY_DATA_1
    add hl, de
    ld a, [hl]
    inc [hl]

    ; delete after one second
    cp 60
    jp z, srpt_delete + 1

    ret


; ==============================================
; Spike entity that moves up, down, left, & right
; --
;   - `ENTITY_ENTRY_DATA_1` used for direction
;	- Inputs: `DE` = pointer to entity base
; ==============================================
srpt_movingSpike:
    push de ; save base here

    ; get direction
    ld hl, ENTITY_ENTRY_DATA_1
    add hl, de
    ld a, [hl]
    ld b, a ; save direction

    ld de, srpt_directionTable_x
    call utl_lookup_A

    pop hl ; pop base
    ; move by X displacement
    ld e, a ; A = E = dx
    call ent_changeX


    ld a, b ; A = B = direction
    ld de,srpt_directionTable_y
    call utl_lookup_A

    ; move by Y displacement
    ld e, a ; A = E = dy
    call ent_changeY

    push hl ; save base
    ; check collision
    call ent_getPosition
    
    ld d, a
    ld hl, .points
    ld b, 4
    call map_checkPoints

    pop hl ; pop base

    or a
    ret z ; return if transparent

    ; change direction
    ld de, ENTITY_ENTRY_DATA_1
    add hl, de
    ld a, [hl]
    xor 1
    ld [hl], a
    ret 

.points:
    db -8, -16
    db -8, -8
    db 0,  -8
    db 0,  -16


; given a direction (0-3) returns an X offset
srpt_directionTable_x:
    ; left right up down
    db -1,  1,   0,  0
; given a direction (0-3) returns a Y offset
srpt_directionTable_y:
    ; left right up down
    db 0,   0,  -1, 1


; ==============================================
; Checks a list of offsets for a solid collision
; --
;   - Designed to be used for entities.
;   - It is flexible enough to add dynamic sizes
;	- Inputs: `E` = x, `D` = y, `B` = number of points in `HL`, `HL` = pointer to list of (dx, dy) amounts
;	- Outputs: `A` = `1` if solid, else `0`
;	- Destroys: `ALL`
; ==============================================
map_checkPoints:
    ; reset this byte which we use as a buffer
    xor a
    ld [plr_bullet_buffer], a
.loop:
    push bc ; save counter
    push de ; save YX coordinates
    
    ld a, [hl+] ; dx
    add a, e ; dx + x
    ld e, a ; e = x

    ld a, [hl+] ; dy
    add a, d ; A = y + dy
    
    push hl

    call map_getCollision
    
    ; save flags
    ld hl, plr_bullet_buffer
    or a, [hl]
    ld [hl], a

    pop hl

    pop de
    pop bc
    dec b
    jr nz, .loop    
    ret