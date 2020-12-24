SECTION "ANIMATION", ROM0


; ==============================================
; Animates all of the entities in the entity table
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
oanim_doAll:
    ld a, [ent_table_size]
    or a
    ret z

    ld b, a

    ld hl, anim_timer
    inc [hl]

    ld hl, ent_table
.loop:
    push hl
    ld de, ENTITY_ENTRY_ANIMATION_FRAMES
    add hl, de
    ; skip if this entity does not have an animation
    ld a, [hl]
    or a
    jr z, .skipAnimation
    
    ; skip animation if it is not the right frame to do so
    ld hl, anim_timer
    and [hl]
    jr nz, .skipAnimation
    
    ; retrieve base pointer
    pop hl
    push hl
    ; we need to perform a byte swap so copy HL into DE
    LD16 de, hl
    ; DE = pointer to current tile
    INCREMENT de, ENTITY_ENTRY_TILE
    ; HL = pointer to new tile
    ld a, b ; save B
    ld bc, ENTITY_ENTRY_ALT_TILE
    add hl, bc
    ld b, a ; restore B
    
    ld c, [hl] ; new tile
    ld a, [de] ; current tile
    ld [hl], a ; write old tile to new tile
    ld a, c
    ld [de], a ; write new tile to old tile

    ; set redraw flag
    pop hl
    call ent_setRedraw
    jr .skipAnimation + 1 ; skip 'pop hl' instruction

.skipAnimation:
    pop hl
    
    ld de, ENTITY_ENTRY_SIZE
    add hl, de

    dec b
    jr nz, .loop

    ret

anim_doAll:
    ld hl, anim_timer
    inc [hl]
    
    ld a, [ent_table_size]
    or a
    ret z

    ld de, ent_animate
    jp ent_foreach

; ==============================================
; Checks to see if an entity should change tiles during this frame
; --
;	- Inputs: `HL` = base pointer
;	- Outputs: `Z` = if shouldn't animate, `NZ` = should animate
;	- Destroys: `AF`, `BC`, `DE`
; ==============================================
ent_canAnimate:
    push hl
    ld de, ENTITY_ENTRY_ANIMATION_FRAMES
    add hl, de
    ; skip if this entity does not have an animation
    ld a, [hl]
    or a
    jr z, .return_z
    
    ; skip animation if it is not the right frame to do so
    ld hl, anim_timer
    and [hl]
    jr nz, .return_z
    
    ; retrieve base pointer
    pop hl

    xor a ; return NZ
    inc a
    ret

.return_z:
    pop hl
    xor a
    ret 

; ==============================================
; Swaps the current tile with the entity's alternative tile
; --
;	- Inputs: `HL` = base pointer
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
ent_animate:
    call ent_canAnimate
    ret z

    call ent_setRedraw

    ld de, ENTITY_ENTRY_TILE
    add hl, de

    LD16 de, hl

    ld bc, ENTITY_ENTRY_ALT_TILE - ENTITY_ENTRY_TILE
    add hl, bc
    ; HL = pointer to alt tile
    ; DE = pointer to cur tile

    ld b, [hl]
    ld a, [de]
    ld [hl], a
    ld a, b
    ld [de], a

    ret


; ==============================================
; Sets the first data byte of the entity
; --
;	- Inputs: `HL` = entity base, `A` = data byte
;	- Outputs: `NONE`
;	- Destroys: `AF`, `DE`
; ==============================================
ent_setDataByte1:
    ld de, ENTITY_ENTRY_DATA_1
    add hl, de
    ld [hl], a
    SUB16 hl, de
    ret


; ==============================================
; Sets an entity's animation tile & number of frames per tile
; --
;	- Inputs: `HL` = entity base, `A` = second animation tile, `B` = frames per tile `**MUST BE (POWER OF 2)-1**`
;	- Outputs: `NONE`
;	- Destroys: `AF, `DE`
; ==============================================
ent_setAnimation:
    ld de, ENTITY_ENTRY_ALT_TILE
    add hl, de

    ld [hl-], a     ; write tile
    ld [hl], b      ; write frames
    inc hl
    SUB16 hl, de
    ret


; ==============================================
; Animates the player
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `AF`, `HL`
; ==============================================
plr_animate:
    ld a, [anim_timer]
    and $1F
    ret nz

    ld hl, plr_obj_tile
    ld a, MAP_TILE_PLAYER

    cp [hl]
    jr nz, .set2

.set1:
    inc a
.set2:
    ld [hl], a
    jp plr_setRedrawFlag