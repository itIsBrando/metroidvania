SECTION "ENTITYPARTICLE", ROM0
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