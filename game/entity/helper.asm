; ==============================================
; Gets an entity entry unsafely
; --
;	- Inputs: `A` = index to lookup
;	- Outputs: `HL` = pointer to entity
;	- Destroys: `AF`, `DE`, `HL`
; ==============================================
ent_getEntry:
    ; quick multiply by entity size
    call math_mult_A_12

    ld d, 0
    ld e, a
    ld hl, ent_table

    add hl, de
    ret


; ==============================================
; Sets the redraw flag for an entity
; --
;	- Inputs: `HL` = pointer to base of an entity entry
;	- Outputs: `NONE`
;	- Destroys: `DE`
; ==============================================
ent_setRedraw:
    ld de, ENTITY_ENTRY_SHOULD_UPDATE
    add hl, de
    ld [hl], 1
    ; save A
    ld d, a
    
    ; HL -= A
    ld a, l
    sub e ; ENTITY_ENTRY_SHOULD_UPDATE
    ld l, a
    jr nc, .noCarry
    dec h
.noCarry:
    ; retreive A
    ld a, d
    ret


; ==============================================
; Gets the flag byte
; --
;   -
;	- Inputs: `HL` = pointer to entity base
;	- Outputs: `NONE`
;	- Destroys: `AF`
; ==============================================
ent_getFlags:
    INCREMENT hl, ENTITY_ENTRY_FLAG
    
    ld a, [hl]
    DECREMENT hl, ENTITY_ENTRY_FLAG
    ret


; ==============================================
; Gets the tile byte
; --
;	- Inputs: `HL` = pointer to entity base
;	- Outputs: `A` = tile number of entity
;	- Destroys: `NONE`
; ==============================================
ent_getTile:
    INCREMENT hl, ENTITY_ENTRY_TILE

    ld a, [hl]
    DECREMENT hl, ENTITY_ENTRY_TILE
    ret
    

; ==============================================
; Gets a value of an entities X position (UNUSED!!)
; --
;	- Inputs: `HL` = pointer to base
;	- Outputs: `A` = X coord
;	- Destroys: `DE`
; ==============================================
ent_getX:
    ld de, ENTITY_ENTRY_X
    add hl, de
    ld a, [hl]
    SUB16 hl, de
    ret
    

; ==============================================
; Gets an entity's position ***NOTE OUTPUTS***
; --
;	- Inputs: `HL` = entity base
;	- Outputs: `A` = y, `E` = x
;	- Destroys: `NONE`
; ==============================================
ent_getPosition:
    INCREMENT hl, ENTITY_ENTRY_Y
    ld a, [hl+] ; get Y position
    ld e, [hl]  ; get X position
    DECREMENT hl, ENTITY_ENTRY_X
    ret

    

; ==============================================
; Change the `X` position of an entity (without checks!)
; --
;   -
;	- Inputs: `HL` = pointer to entity base, `E` = signed displacement
;	- Outputs: `A` = new `X` position
;	- Destroys: `AF`, `DE`
; ==============================================
ent_changeX:
    inc hl ; Y
    inc hl ; X
    
    ld a, [hl]
    add a, e
    ld [hl], a

    DECREMENT hl, 2
    jp ent_setRedraw


; ==============================================
; Change the `Y` position of an entity (without checks!)
; --
;   -
;	- Inputs: `HL` = pointer to entity base, `E` = signed displacement
;	- Outputs: `A` = new Y coordinate
;	- Destroys: `F`, `DE`
; ==============================================
ent_changeY:
    inc hl ; Y
    
    ld a, [hl]
    add a, e
    ld [hl], a

    dec hl
    jp ent_setRedraw


; ==============================================
; Changes the script of an entity to `srpt_entDeath`
; --
;   - This entity will disappear after 60 frames
;	- Inputs: `HL` = pointer to entity base
;	- Outputs: `NONE`
;	- Destroys: `DE`, `HL`
; ==============================================
ent_setDeath:
     ; set redraw
    call ent_setRedraw
    
    ; set palette
    ld de, ENTITY_ENTRY_FLAG
    add hl, de
    set OAMB_PAL1, [hl]

    inc hl

    ld [hl], 60 ; clear the counter (DATA_1)

    INCREMENT hl, 3

    ; write new script pointer
    ld de, srpt_entDeath
    call utl_write_DE_to_HL

    ; turn off animations
    INCREMENT hl, 2

    ld [hl], 0; ENTITY_ENTRY_ANIMATION_FRAMES
    ret
