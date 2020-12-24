SECTION "VARIABLES", WRAM0
VARIABLES_START:
; ==============================================
; Used for randomization
; ==============================================
math_seed:
    ds 2


; ==============================================
; From the output of `utl_scanJoypad`
; ==============================================
key:
    ds 1

; ==============================================
; A byte mask for button presses
; ==============================================
joypadMask:
    ds 1


; ==============================================
; Holds the raw `A` register from the BIOS
; ==============================================
cgb_gameboy_type:
    ds 1


; ==============================================
; Used by VBlank interrupt to determine if OAM needs to happen
; ==============================================
int_shouldOAMTransfer:      
    ds 1


; ==============================================
; Set to `1` to clear all entities from OAM
; ==============================================
int_shouldEmptyOAM:
    ds 1


; ==============================================
; If nonzero, then it's decremented. If zero, then player can shoot
; ==============================================
plr_bullet_cool_down:
    ds 1


; ==============================================
; Base address of the player object. Very similar to that of an entity
; ==============================================
plr_obj_base:
; ==============================================
; Position in the OAM table
; ==============================================
plr_obj_OAM_index:
    ds 1
plr_obj_y:
    ds 1
plr_obj_x:
    ds 1
plr_obj_tile:
    ds 1
; ==============================================
; Corresponds to the flag byte of a sprite
; ==============================================
plr_obj_flag:
    ds 1
; ==============================================
; `1` if grounded, else `0`. This will be false if jumping
; ==============================================
plr_obj_is_grounded_flag:
    ds 1
; ==============================================
; `1` if jumping, else `0`
; ==============================================
plr_obj_is_jumping_flag:
    ds 1
; ==============================================
; `1` if the player should be redrawn
; ==============================================
plr_shouldUpdate:
    ds 1

PLAYER_SIZEOF EQU (@ - plr_obj_base)

; ==============================================
; Holds the player's bullet type
; - `01` = normal
; - `10` = bomb blaster
; - `100` = tele-pellet
; ==============================================
plr_bullet_type:
    ds 1

; ==============================================
; `NZ` if `plr_death` is running
; ==============================================
plr_is_dead:
    ds 1

; ==============================================
; `0` if no collision, else `index+1` of entity collided with
; ==============================================
ent_collision_flag:
    ds 1

; ==============================================
; Holds the size of the entity table
; - 0 = none
; ==============================================
ent_table_size:
    ds 1


; ==============================================
; Holds all of the entities
; ==============================================
ent_table:
    ds ENTITY_TABLE_SIZE * ENTITY_ENTRY_SIZE


; ==============================================
; Holds three bytes to call a routine
;   - used by foreach loop
; ==============================================
ent_call_buffer:
    ds 3

; ==============================================
; Set to the flags byte of a tile.
; - `bit 0` = solidness
; - `bit 1` = can pass through but not fall through
; - `bit 2` = runs a script upon collision
; - `bit 3` = breakable by bomb blaster
; ==============================================
map_collision_raw_flag:
    ds 1

; ==============================================
; Set to `1` if the last collision routine found a solid, else `0`
; ==============================================
map_collision_flag:
    ds 1

; ==============================================
; Set to `1` if you want collisions to trigger collision scripts
;   - reset after calling a collision routine
; ==============================================
map_collision_can_run_script:
    ds 1
; ==============================================
; Holds the current id of the map
; ==============================================
map_current_id:
    ds 1

; ==============================================
; Use to set a tile during vblank
; - `enable` (1=enable), `tile`, `pointer to VRAM`
; ==============================================
map_obj_set_tile:
    ds 4

; ==============================================
; Buffer for the currently drawn room. Does not need VRAM to be accessible
; ==============================================
map_room_buffer:
    ds MAP_ROOM_DATA_SIZE
    
; PRINTT "MAP ROOM BUFFER:"
; PRINTV map_room_buffer - VARIABLES_START+$C000
; PRINTT "\nROOM BUFFER SIZE:"
; PRINTV MAP_ROOM_DATA_SIZE
; PRINTT "\n"

; ==============================================
; Holds all entity data necessary to spawn a bullet
;   - only used by `plr_fireGun` and CAN be used as scrap
;   - y, x, tile, script pointer
; ==============================================
plr_bullet_buffer:
    ds 6


; ==============================================
; Holds the index of the current entity in `ent_runScripts`
;   - 1 byte
; ==============================================
srpt_entity_index:
    ds 1


; ==============================================
; Used for calling all entity scripts.
;   - 1 byte
;   - holds the number of entity scripts that still need to be run
; ==============================================
srpt_entity_counter:
    ds 1


; ==============================================
; Y coordinate that the player will respawn at
; ==============================================
plr_checkpoint_y:
    ds 1

; ==============================================
; X coordinate that the player will respawn at
; ==============================================
plr_checkpoint_x:
    ds 1

; ==============================================
; Map ID that the player will respawn at
; ==============================================
plr_checkpoint_id:
    ds 1

; ==============================================
; A counter that increases each frame that the player is not on the ground
; ==============================================
plr_frames_since_grounded:
    ds 1

; ==============================================
; The color value `0-3` to draw to the current position in the minimap
; ==============================================
wnd_minimapColor:
    ds 1

; ==============================================
; Timer that increments every frame and is used for animations
; ==============================================
anim_timer:
    ds 1

; ==============================================
; Set to 1 to redraw the window after 120 frames
; ==============================================
gfx_window_text_counter:
    ds 1


; ==============================================
; A byte that holds the bullets that are collected in the form of a bitfield
; ==============================================
itm_collected:
    ds 1

PRINTT "\nSIZE OF VARIABLES: "
PRINTV gfx_window_text_counter- VARIABLES_START + $C000