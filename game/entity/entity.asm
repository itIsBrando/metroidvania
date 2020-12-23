; ==============================================
; Writes an entity to DMA
; --
;   - Does not reset the redraw flag
;   - Inputs: `HL`= pointer to Y, X, TILE, FLAG; `E`= sprite number
;   - Destroys: `AF`, `B`, `HL`
; ==============================================
ent_writeDMA:
    push hl

    SHIFT_LEFT a, 2 ; x4
    ld d, 0
    ld e, a
    ld hl, DMA_ADDRESS
    add hl, de

    pop de

    ld b, 4
.loop:
    ; call gfx_VRAMReadable
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, .loop
    ret


; ==============================================
; Transfers entities to DMA. ONLY CALLED BY `VBLANK INTERRUPT`
; --
;	- Inputs: `A` = number of entities
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
ent_vblank:
    ld c, a
    ld hl, ent_table + ENTITY_ENTRY_SHOULD_UPDATE
    ld de, ENTITY_ENTRY_SIZE
.loopEntities:
    ld a, [hl]
    or a
    jr z, .dontRedraw

    ; clear redraw
    ld [hl], 0

    push hl
    
    ; get pointer to base
    ld de, (-ENTITY_ENTRY_SHOULD_UPDATE)
    add hl, de

    ld a, [hl+] ; get OAM position & move pointer to Y
    ld e, a

    call ent_writeDMA
    pop hl

    ld de, ENTITY_ENTRY_SIZE
    ld a, e ; nonzero
    ld [int_shouldOAMTransfer], a

.dontRedraw:
    add hl, de
    dec c
    jr nz, .loopEntities
    ret


; ==============================================
; Hides an entity
; --
;   - moves it offscreen
;	- Inputs: `HL` = pointer to base of entity entry
;	- Outputs: `NONE`
;	- Destroys: `A` = 0, `DE`
; ==============================================
ent_hide:
    push hl
    xor a
    inc hl
    ld [hl+], a ; Y
    ld [hl], a ; X
    pop hl
    jp ent_setRedraw



; ==============================================
; Runs all of the scripts for the enemies
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
ent_runScripts:
    ld a, [ent_table_size]
    or a
    ret z

    ld [srpt_entity_counter], a
    ld hl, ent_table
.loop:
    push hl
    ld de, ENTITY_ENTRY_SCRIPT
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a

    pop de
    push de

    ; find which index we are using
    ld a, [srpt_entity_counter]
    ld b, a
    ld a, [ent_table_size]
    sub b
    ld [srpt_entity_index], a

    call utl_callHL

    pop hl

    ld de, ENTITY_ENTRY_SIZE
    add hl, de

    ld a, [srpt_entity_counter]
    or a
    ret z
    dec a
    ret z

    ld [srpt_entity_counter], a
    jr .loop


; ==============================================
; Removes all entities from OAM. Initates OAM transfer
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
ent_emptyOAM:
    ld hl, DMA_ADDRESS + 4
    ld bc, 160 - 4
    xor a
    ld [int_shouldEmptyOAM], a
    call mem_set
    jp _HRAM



; ==============================================
; Checks collisions between two entities
; --
;	- Inputs: `HL` = self entity, `DE` = other entity
;	- Outputs: `ent_collision_flag` = `1` if collision, else `0`
;	- Destroys: `AF`, `DE`, `HL`
; ==============================================
ent_collision:
    xor a
    ld [ent_collision_flag], a

    INCREMENT de, ENTITY_ENTRY_Y
    INCREMENT hl, ENTITY_ENTRY_Y
    ld a, [de] ; Y1
    add a, 2
    cp [hl] ; Y1+2 >= Y2
    ret c

    sub 10
    cp [hl] ; Y1-8 <= Y2
    ret nc
    
    inc de
    inc hl
    ld a, [de] ; X1
    cp [hl] ; X1+8 >= X2
    ret c

    sub 8
    cp [hl] ; X1 <= X2
    ret nc
    
    ld a, 1
    ld [ent_collision_flag], a
    ret


; ==============================================
; Checks collisions between `ALL` entities
; --
;	- Inputs: `A` = index to self entity (will never collide with self)
;	- Outputs: `ent_collision_flag` = index of other entity
;	- Destroys: `ALL`
; ==============================================
ent_anyCollision:
    ld c, a ; save self index

    ; reset flag to ensure that the output will be accurate
    xor a
    ld [ent_collision_flag], a

    ld a, [ent_table_size]
    ld b, a

.loop:
    ; skip if we are looking at self
    ld a, [ent_table_size]
    sub b
    cp c
    jr z, .noCollision

    call ent_getEntry
    push hl ; save other entity

    ; get self entity
    ld a, c
    call ent_getEntry

    pop de
    call ent_collision

    ; if collision flag is nonzero, we have a collision
    ld a, [ent_collision_flag]
    or a
    jr z, .noCollision

    ; return if we found a collision
    ld a, [ent_table_size]
    sub b
    inc a
    ld [ent_collision_flag], a
    ret 

.noCollision:
    dec b
    jr nz, .loop
    ret
    