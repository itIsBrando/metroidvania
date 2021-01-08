SECTION "ENTITYSCRIPTS", ROM0

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
    jp ent_delete


; ==============================================
; Local routine used by the bullet to kill the entity in index `A`-1
; --
;	- Inputs: `A` = index + 1
;	- Outputs: `Z` if did not delete, `NZ` if deleted
;	- Destroys: `ALL`
; ==============================================
srpt_killEntity:
    dec a
    ld c, a ; save index
    call ent_getEntry

    ; prevent some tiles from deletion
    call ent_getTile
    cp MAP_TILE_BULLET
    ret z
    cp MAP_TILE_BOMB_BLASTER
    ret z
    cp MAP_TILE_TELE_PELLET
    ret z
    cp MAP_TILE_CANNON
    ret z
    cp MAP_TILE_PARTICLE1
    ret z
    cp MAP_TILE_PARTICLE2
    ret z
    
    ; call ent_hide
    ld a, c ; restore index

    ; set new script for the entity
    call ent_getEntry
    call ent_setDeath

    ; now, delete self
    call srpt_delete

    ; ensure `NZ`
    or $FF
    ret


; ==============================================
; Moves an entity downwards without collision checking
; --
;   - Removes entity after going offscreen
;	- Inputs: `DE` = pointer to entity base
; ==============================================
srpt_moveDownNoCollision:
    LD16 hl, de
    
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
    LD16 hl, de

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

    SR a, 3
    dec a
    dec a ; Y - 16
    SR e, 3
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
    IS_CGB
    call nz, .cgb
    
    ld hl, ENTITY_ENTRY_DATA_1
    add hl, de
    
    ld a, [hl]
    dec [hl]

    ; if counter > 0, return
    or a
    ret nz

    ; else delete entity
    ld a, [srpt_entity_index]
    jp ent_delete

; change entity palette for CGB
; - preserves `DE` intentionally
.cgb:
    ; only modify palette every 16 frames
    ld a, [anim_timer]
    and $07
    ret nz
    
    ; toggle CGB color
    ld hl, ENTITY_ENTRY_FLAG
    add hl, de
    ld a, [hl]
    xor 1
    ld [hl], a

    ; set redraw
    LD16 hl, de
    call ent_setRedraw

    ; restore DE
    LD16 de, hl
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

.points: ; what are these coordinates??
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