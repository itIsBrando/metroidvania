SECTION "MAP", ROM0

rsreset
MAP_HEADER_ENTITY_TABLE rb 2
MAP_HEADER_WIDTH        rb 1
MAP_HEADER_HEIGHT       rb 1
MAP_HEADER_SIZE         rb 0
MAP_HEADER_DATA         rb MAP_ROOM_DATA_SIZE

; ==============================================
; retrieves a pointer to a location given by (pxlX, pxlY)
;   - you must wait for the pointer to be accessible
;	- Inputs: `E` = X, `A` = Y
;   - Outpus: `HL` = pointer to tile
;   - Destroys: `AF`, `HL`, `DE`
; ==============================================
map_tileAt:
    and $F8 ; divide by 8 then multiplies by 8
    ld h, 0
    ld d, h
    ld l, a
    add hl, hl  ; x16
    add hl, hl  ; x32

    dec e
    dec e
    dec e
    dec e ; subtract X position by 4
    SHIFT_RIGHT e, 3 ; divide E (X coord) by 8
    add hl, de
    
    ld de, BG_LOCATION
    add hl, de
    ret


; ==============================================
; Loads a room 20x16. Draws it directly onto the screen if `A`!=`0`
; --
;   - Needs to also copy this to a buffer
;	- Inputs: `DE` = pointer to room header, `A=0` to not draw to screen
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
map_loadRoom:
    push af

    push de
    call ent_deleteAll
    pop hl

    LOAD_DE_HL ; since DE is preserved in the following routine, I need to copy the pointer into DE

    ld a, [hl+]
    ld h, [hl]
    ld l, a
    
    call map_loadEntityTable

    ld hl, MAP_HEADER_DATA
    add hl, de
    
    call map_loadBuffer

    call wnd_generateMinimap

    call gfx_resetPalette
    pop af

    or a
    call nz, map_drawRoom

    ld a, [map_current_id]
    cp 1 + (4 * MAP_ROOM_TABLE_WIDTH)
    ret nz

    jp gfx_setDarkPalette


; ==============================================
; Loads the map buffer with a map. That's it.
; --
;	- Inputs: `HL` = pointer to data
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
map_loadBuffer:
    ld de, map_room_buffer
    ld bc, MAP_ROOM_DATA_SIZE
    jp mem_copy


; ==============================================
; Loads the entity table for the current room
; --
;	- Inputs: `HL` = pointer to pointer of table
;	- Outputs: `NONE`
;	- Destroys: `AF`, `BC`, `HL`
; ==============================================
map_loadEntityTable:
    ; number of entries
    ld a, [hl+]
    or a
    ret z

    push de


    ld c, a
.loop:
    push hl
    push bc

    call ent_create
    
    pop bc
    pop hl

    ld de, ENTITY_STORAGE_SIZE
    add hl, de
    
    dec c
    jr nz, .loop

    pop de
    ret



; ==============================================
; Blits the room to the screen
; --
;   - does not account for `SCX/SCY`
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
map_drawRoom:
    ld hl, BG_LOCATION
    ld de, map_room_buffer
    ld c, MAP_HEIGHT
.loopY:
    ld b, MAP_WIDTH
.loopX:
    call gfx_VRAMReadable
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, .loopX

    push de
    ld de, 32 - 20
    add hl, de
    pop de
    dec c
    jr nz, .loopY
    ret

; ==============================================
; Returns a tile number given a row and column
; --
;	- Inputs: `E` = row, `A` = column
;	- Outputs: `A` = tile number, `HL` = pointer to tile
;	- Destroys: `BC`, `DE`
; ==============================================
map_getTileCollision:
    ld d, 0
    push de
    ; y * 20
    ld e, MAP_WIDTH
    call math_mult_A_DE
    pop de
    add hl, de
    ld de, map_room_buffer
    add hl, de
    ld a, [hl]
    ret


; ==============================================
; Checks the room buffer for collision
; --
;   - Stores flags into `map_collision_raw_flag`
;	- Inputs: `A` = y, `E` = x
;	- Outputs: `A` = `1` if solid, else `0`
;	- Destroys: `ALL`
; ==============================================
map_getCollision:
    cp 144 - 16
    jr nc, .off_screen

    SHIFT_RIGHT e, 3
    SHIFT_RIGHT a, 3

    call map_getTileCollision

    LOAD_DE_HL

    ; get flags byte
    ld hl, dta_tile_data
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl]
    ; store all flags
    ld [map_collision_raw_flag], a

    ; check if we need to run a script
    bit 2, a
    call nz, .run_tile_script

    ; reset this flag so other entities will not trigger collision scripts
    ld hl, map_collision_can_run_script
    ld [hl], 0
    
    ; only return solidness
    and %00000001
    ld [map_collision_flag], a
    ret
    

.off_screen:
    ;A!=0
    ld [map_collision_flag], a
    ret


; ==============================================
; Runs a tiles script
; --
;	- Inputs: `DE` = pointer to tile
;	- Outputs: `NONE`
;	- Destroys: `ALL` except `AF`
; ==============================================
.run_tile_script:
    push af
    ld a, [map_collision_can_run_script]
    or a
    jr z, .return

    ld a, [de] ; fetch the raw tile, not the flags
    
    ld hl, map_tiles_with_scripts
    ld b, MAP_TILE_SCRIPTS_SIZE
    ld c, 0
.loop:
    cp [hl]
    jr nz, .continue
    ; run script
    ld b, 0
    SHIFT_LEFT c, 1
    ld hl, map_tile_script_pointers
    add hl, bc
    ; now we must fetch pointer
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call utl_callHL
    pop af
    ret

.continue:
    inc hl
    inc c
    dec b
    jr nz, .loop
.return:
    pop af
    ret


; ==============================================
; Gets a room pointer given a room ID
; --
;	- Inputs: `A` = id
;	- Outputs: `DE` = pointer
;	- Destroys: `AF`, `HL`
; ==============================================
map_getFromID:
    add a, a ; x2
    ld d, 0
    ld e, a
    ld hl, map_room_table
    add hl, de

    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ret 


; ==============================================
; Returns the room pointer of the room to the left of the current one
; --
;	- Inputs: `NONE`
;	- Outputs: `DE` = pointer to room
;	- Destroys: `AF`, `HL`
; ==============================================
map_leftRoom:
    ld hl, map_current_id
    dec [hl]

    ld a, [hl]
    jr map_getFromID
    

; ==============================================
; Returns the room pointer of the room to the right of the current one
; --
;	- Inputs: `NONE`
;	- Outputs: `DE` = pointer to room
;	- Destroys: `AF`, `HL`
; ==============================================
map_rightRoom:
    ld hl, map_current_id
    inc [hl]

    ld a, [hl]
    jr map_getFromID
    

; ==============================================
; Returns the room pointer of the room above the current one
; --
;	- Inputs: `NONE`
;	- Outputs: `DE` = pointer to room
;	- Destroys: `AF`, `HL`
; ==============================================
map_upRoom:
    ld hl, map_current_id
    ld a, [hl]
    sub MAP_ROOM_TABLE_WIDTH
    ld [hl], a

    jr map_getFromID
    

; ==============================================
; Returns the room pointer of the room below the current one
; --
;	- Inputs: `NONE`
;	- Outputs: `DE` = pointer to room
;	- Destroys: `AF`, `HL`
; ==============================================
map_downRoom:
    ld hl, map_current_id
    ld a, MAP_ROOM_TABLE_WIDTH
    add a, [hl]
    ld [hl], a

    jr map_getFromID


; ==============================================
; Sets a tile on the buffer and VRAM (DOES NOT SET IN BUFFER YET)
; --
;   - see `map_setTileForVBlank` if you have a row and column
;	- Inputs: `HL` = VRAM pointer, `A` = tile
;	- Outputs: `NONE`
;	- Destroys: `DE`, `HL`
; ==============================================
map_setTileWithPointer:
    LOAD_DE_HL
    ld hl, map_obj_set_tile
    ld [hl], 1 ; set enable flag
    inc hl
    ld [hl+], a ; set tile
    ; set pointer
    ld [hl], e
    inc hl
    ld [hl], d
    ret

; ==============================================
; Sets a tile on the buffer and VRAM (DOES NOT SET IN BUFFER YET)
; --
;   - see `map_setTileWithPointer` if `HL` is loaded with a pointer
;	- Inputs: `A` = y, `E` = y, `B` = tile
;	- Outputs: `NONE`
;	- Destroys: `AF`, `DE`, `HL`
; ==============================================
map_setTileForVBlank:
    ld h, 0
    ld d, h
    add a, a    ;x2
    add a, a    ;x4
    add a, a    ;x8
    ld l, a
    add hl, hl  ;x16
    add hl, hl  ;x32
    ; add X coord
    add hl, de
    ld de, BG_LOCATION
    add hl, de
    LOAD_DE_HL
    ld hl, map_obj_set_tile
    ; set enable flag
    ld [hl], 1
    inc hl
    ; set tile
    ld [hl], b
    inc hl
    ; set lower pointer byte
    ld [hl], e
    inc hl
    ; set upper pointer byte
    inc [hl]
    ld [hl], d
    ret


; ==============================================
; Sets the checkpoint for current room & player position
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
map_setCheckpoint:
    call plr_getPosition
    ld hl, plr_checkpoint_y
    ; set Y and X positions
    ld [hl+], a
    ld [hl], e
    inc hl
    ; set room id 
    ld a, [map_current_id]
    ld [hl], a
    ret

; HL / 20 => B. `A` = remainder
; Destroys: `HL`, C = 20
math_div_HL_20
    ld b, 0
    ld c, 20
.loop:
    ld a, h
    or a
    jr nz, .noLowerCheck
    or l ; A = L
    cp c
    ret c ; we've finished if A < C. if our quotient is less than divisor

.noLowerCheck:
    ld a, l
    sub c
    jr nc, .nocarry
    dec h
.nocarry:
    ld l, a
    inc b
    jr .loop


; ==============================================
; Adds SCX & SCY to an X and Y coordinate
; --
;	- Inputs: `A` = X, `B` = y
;	- Outputs: `A` = X, `B` = y
;	- Destroys: `C`
; ==============================================
map_addBackgroundScroll:
    ld c, a
    ldh a, [rSCY] ; add bg displacement
    SHIFT_RIGHT a, 3
    add a, b ; Y + SCY
    ld b, a
    
    ldh a, [rSCX]
    SHIFT_RIGHT a, 3
    add a, c
    ret


; ==============================================
; Converts a room pointer to a coordinate
; --
;   - returns screen coordinates. Use `map_addBackgroundScroll` for `rSCX`/`rSCY` coordinates
;	- Inputs: `HL` = pointer in room
;	- Outputs: `A` = row, `B` = column
;	- Destroys: `C`, `DE`, `HL`
; ==============================================
map_roomToXY:
    ld de, map_room_buffer
    SUB16 hl, de
    ; X = remainder (`A`)
    ; Y = result (`B`)
    jp math_div_HL_20


; ==============================================
; Converts a room pointer to that of a VRAM pointer
; --
;	- Inputs: `HL` = pointer in room
;	- Outputs: `HL` = pointer to VRAM
;	- Destroys: `ALL`
; ==============================================
map_roomToVRAM:
    call map_roomToXY
    
    ; get actual points
    call map_addBackgroundScroll

    and $1F ; mask with 31 so we remain in range of VRAM
    ld c, a ; X + SCX
    ld a, b ; Y + SCY
    and $1F ; mask with 31 so we remain in range of VRAM
    ld h, 0
    ld b, h

    add a, a ; x2
    add a, a ; x4
    add a, a ; x8
    ld l, a
    add hl, hl      ; x16
    add hl, hl      ; x32
    add hl, bc
    ld bc, BG_LOCATION
    add hl, bc
    ret