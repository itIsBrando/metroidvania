SECTION "SCRIPTS", ROM0


; ==============================================
; Hides a tile
; --
;	- Inputs: `DE` = pointer to tile
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
srpt_tileFallingBlock:
    
    LD16 hl, de

    ; replace this tile to prevent new collisions from firing this event
    ; note: this doesn't update the screen but it doesn't matter yet
    ld [hl], 1

    ; get an X & Y coord
    call map_roomToXY

    inc b
    inc b
    SL b, 3 ; column * 8 + 16
    inc a
    SL a, 3 ; row * 8 + 8
    
    ld hl, plr_bullet_buffer
    ld [hl], b ; y
    inc hl
    ld [hl+], a ; x
    ld [hl], $15; MAP_TILE_FALLING_BLOCK_1 ; tile
    inc hl

    ld de, srpt_fallingBlock
    call utl_write_DE_to_HL

    ld hl, plr_bullet_buffer
    jp ent_create



; ==============================================
; Kills the player from a tile
; --
;	- Inputs: `DE` = pointer to tile
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
srpt_killPlayer:
    ld a, [plr_is_dead]
    or a
    ret nz
    jp plr_death


; ==============================================
; Does variable tasks based off of current room
; --
;	- Inputs: `DE` = pointer to tile
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
srpt_collideWithButton:
    LD16 hl, de
    ld [hl], $6B

    ; tell vblank to modify this tile
    call map_roomToVRAM
    ld a, $6B
    call map_setTileWithPointer

    ld a, [map_current_id]
    ; room 0x3
    cp 0 + (3 * MAP_ROOM_TABLE_WIDTH)
    jr z, .room0x3
    ; room 4x1
    cp 4 + (1 * MAP_ROOM_TABLE_WIDTH)
    jr z, .room4x1
    ; room 4x2
    cp 4 + (2 * MAP_ROOM_TABLE_WIDTH)
    jr z, .room4x2
    ; room1x4
    cp 1 + (4 * MAP_ROOM_TABLE_WIDTH)
    ret nz
.room1x4:
    call gfx_resetPalette
    
    ; now we must create an entity that will count down
    ld hl, plr_bullet_buffer
    ld a, 1
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld de, srpt_entityDownButton
    call utl_write_DE_to_HL

    ld hl, plr_bullet_buffer
    jp ent_create

.room0x3:
    halt  ; I must halt becuase we are modifying two tiles
    
    ld e, 1
    ld a, 9
.clearTile: ; local label to reduce repetitiveness when clearing tiles at a coordinate
    call map_getTileCollision
    ld [hl], 0
    call map_roomToVRAM
    xor a
    jp map_setTileWithPointer

.room4x1:
    halt 
    ld e, 16
    ld a, 5
    jr .clearTile

.room4x2:
    halt 
    
    ; set empty tile
    ld e, 10
    ld a, 12
    call map_getTileCollision
    ld [hl], $0
    call map_roomToVRAM
    xor a
    call map_setTileWithPointer

    ; now we must create an entity that will count down
    ld hl, plr_bullet_buffer
    ld a, 1
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld de, srpt_entityDownButton
    call utl_write_DE_to_HL

    ; actually create our entity
    ld hl, plr_bullet_buffer
    jp ent_create


; ==============================================
; Collision with a chest
; --
;	- Inputs: `DE` = pointer to tile
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
srpt_collideWithChest:
    LD16 hl, de
    ld [hl], MAP_TILE_OPEN_CHEST

    call map_roomToVRAM

    ; replace closed chest with open chest
    ld a, MAP_TILE_OPEN_CHEST
    call map_setTileWithPointer

    ld a, [map_current_id]
    cp 4 + (0)
    jr z, .room4x0
    
    cp 1 + (3 * MAP_ROOM_TABLE_WIDTH)
    ret nz


; tele-pellet chest
.room1x3:
    ld a, PLAYER_BULLET_TELE_PELLET
    call itm_collectBullet
    
    ld hl, txt_chest_room1x3
    jp wnd_showText    

; bomb blaster chest
.room4x0:
    ld a, PLAYER_BULLET_BMB_BLSTR
    call itm_collectBullet

    ld hl, txt_chest_room4x0
    jp wnd_showText


; ==============================================
; Updates the player's respawn position
; --
;	- Inputs: `DE` = pointer to tile
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
srpt_collideWithCheckpoint:
    LD16 hl, de

    ld [hl], MAP_TILE_CHECKPOINT_2

    ; get pointer to tile in VRAM
    call map_roomToVRAM
    ; tell VBlank to set this tile
    ld a, MAP_TILE_CHECKPOINT_2
    call map_setTileWithPointer
    
    ld hl, txt_checkpoint_info
    call wnd_showText

    jp map_setCheckpoint

; ==============================================
; Text about getting a checkpoint
; ==============================================
txt_checkpoint_info:
    db "CHECKPOINT REACHED", 0


; ==============================================
; Collect the tele-pellet
; ==============================================
txt_chest_room1x3:
    db "GOT TELE-PELLET", 0

; ==============================================
; Collect the bomb blaster
; ==============================================

txt_chest_room4x0:
    db "GOT BOMB BLASTER", 0

; ==============================================
; Draws some informational text
; --
;	- Inputs: `DE` = pointer to tile
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
srpt_collideWithSpawner:
    ; check counter
    ld a, [gfx_window_text_counter]
    or a
    ret nz ; if the counter WAS > 0, then return and don't redraw

    ld hl, txt_spawner_info
    jp wnd_showText


; ==============================================
; Text about what to do with the spawner
; ==============================================
txt_spawner_info:
    db "PLACE AN EGG HERE", 0