
; ==============================================
; Appends a new entity into the entity table
; --
;   - safely creates a new entity. Checks for overflow
;	- Inputs: `HL` = pointer to entity
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
ent_create:
    ; save pointer
    push hl
    
    ; return if overflow
    ld hl, ent_table_size
    ld a, [hl]
    ; *** THIS WILL CRASH***
    cp ENTITY_TABLE_SIZE
    ret nc

    ; increase counter
    inc [hl]

    ld b, a ; save for later

    ; find address in entity table
    call ent_getEntry

    ; save HL
    LD16 de, hl
    
    ; clear all of the other data
    ld c, ENTITY_ENTRY_SIZE
    xor a
.clearEntryLoop:
    ld [hl+], a
    dec c
    jr nz, .clearEntryLoop

    ; restore HL
    LD16 hl, de

    ; write OAM position (which = index+1)
    ld a, b
    inc a
    ld [hl], a

    ; retrieve pointer to source entity
    pop de

    ; save base address of this table entry
    push hl

    inc hl ; Y

    ld b, 3
.loop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, .loop

    ; get pointer to move routine
    ; B = LSB, A = MSB
    ld a, [de]
    ld b, a
    inc de
    ld a, [de]

    pop hl

    ld de, ENTITY_ENTRY_SCRIPT
    add hl, de
    
    
    ; store script pointer
    ld [hl], b
    inc hl
    ld [hl], a
    
    ; say that we should redraw
    DECREMENT hl, (ENTITY_ENTRY_SCRIPT+1) - ENTITY_ENTRY_SHOULD_UPDATE
    ld [hl], 1

    ; rewind to the tile
    ld de, (-ENTITY_ENTRY_SHOULD_UPDATE) + ENTITY_ENTRY_TILE
    add hl, de

    ld a, [hl]
    DECREMENT hl, ENTITY_ENTRY_TILE
    ; set animations based off of tile
    cp MAP_TILE_BAT_1
    jr nz, .check_other_animations


    ld a, MAP_TILE_BAT_2
    ld b, 15 ; time per frame
    jp ent_setAnimation

.check_other_animations:
    cp MAP_TILE_SLIME_1
    jr nz, .check_spike
    
    ld a, MAP_TILE_SLIME_2
    ld b, 7
    jp ent_setAnimation

.check_spike:
    cp MAP_TILE_MOVING_SPIKE
    ret nz
    ld a, MAP_TILE_MOVING_SPIKE + 1
    ld b, 3
    call ent_setAnimation

    xor a
    jp ent_setDataByte1

; ==============================================
; A foreach loop for each entity in the entity table
; --
;   - the routine in `DE` will be called for each entity with `HL` = base pointer to that entity
;   - DELETING NOT SUPPORTED
;	- Inputs: `DE` = pointer to routine to call for each entity
;	- Destroys: `ALL`
; ==============================================
ent_foreach:
    ld a, $C3
    ; store instruction and JP instruction
    ld hl, ent_call_buffer
    ld [hl+], a
    ld [hl], e
    inc hl
    ld [hl], d

    ld hl, ent_table_size
    ld a, [hl+]

    ld b, a
.loop:

    push hl
    push bc

    call ent_call_buffer

    pop bc
    pop hl
    ld de, ENTITY_ENTRY_SIZE
    add hl, de

    dec b
    jr nz, .loop

    ret


; ==============================================
; Removes an element from the entity table
; --
;	- Inputs: `A` = index
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
ent_delete:
    ld b, a ; save index
    call plr_setRedrawFlag ; force a DMA transfer

    ld a, [ent_table_size]
    or a
    ret z ; return if empty

    ;return if the passed index > size of entity table
    cp b
    ret c

    ; remove last entry from OAM
    SHIFT_LEFT a, 2
    ld e, a
    ld d, 0
    ld hl, DMA_ADDRESS
    add hl, de

    call gfx_VRAMReadable
    ld [hl], 0 ; set Y coordinate to 0


    ; fetch last entry & hide it
    ld a, [ent_table_size]
    dec a
    call ent_getEntry

    ; load A with OAM index
    ld a, [hl]
    ; now we must remove the sprite from OAM
    SHIFT_LEFT a, 2 ;x4
    ld hl, DMA_ADDRESS
    ld d, 0
    ld e, a
    add hl, de
    call gfx_VRAMReadable
    ld [hl], 0 ; y = 0

    ; Decrease table size
    ld hl, ent_table_size
    dec [hl]

    ; pointer to entry to delete
    ld a, b
    call ent_getEntry

    push hl

    ld a, [ent_table_size]
    inc a ; must increase A because we decremented it earlier
    sub b ; A = number of entities to the right of the one to delete

    call math_mult_A_12
    ld c, a ; how many elements to remove

    push hl ; save entity to delete
    ld de, ENTITY_ENTRY_SIZE
    add hl, de
    pop de

    ; is this even necessary???
    di

    ; DE = entry to delete
    ; HL = next entry
.loop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec c
    jr nz, .loop

    pop hl

    ; each OAM index must be redone
    ld de, ENTITY_TABLE_SIZE
    ld a, [ent_table_size]
    inc a
    sub b
.reorderOAM:
    dec [hl]
    add hl, de
    dec a
    jr nz, .reorderOAM

    reti

; ==============================================
; Clears the entire entity table.
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
ent_deleteAll:
    xor a
    ld [ent_table_size], a
    ld bc, ENTITY_TABLE_SIZE
    ld hl, ent_table
    call mem_set

    ld a, 1
    ld [int_shouldEmptyOAM], a
    ret