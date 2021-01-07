; TODO:
; - rework entity script running to use foreach loop
; - ENT_DELETE SHOULD SET REDRAW FLAG!!! (9/5)
; - add enough rooms to allow the player to collect an egg (9/4)
; - have the minimap flash for the room the player is in (LOW)
;
; DONE:
; - create a `telebullet` that will teleport the player upon deletion (HIGH)
; - Fix the window graphical glitch (9/4)
; - enable tile collision scripts to be only activated by player (HIGH)
; - slime enemy
; - complete entity tables for completed rooms
; - entity animation (HIGH)
; - make shooting useful
; - entity-entity collision
; - gfx routine to replace colors of a tile (HIGH)
; - enable more time for falling tiles (maybe create an entity that wait some number of frames)

INCLUDE "includes/hardware.inc"
INCLUDE "includes/defines.inc"
INCLUDE "includes/macros.inc"

INCLUDE "graphics/sprite.asm"
INCLUDE "graphics/effects.asm"
INCLUDE "graphics/vram.asm"
INCLUDE "graphics/blit.asm"
INCLUDE "graphics/window.asm"
INCLUDE "graphics/cgb.asm"
INCLUDE "graphics/animation.asm"

INCLUDE "data/variables.asm"
INCLUDE "data/data.asm"
INCLUDE "data/interrupts.asm"

INCLUDE "utility/utility.asm"
INCLUDE "utility/math.asm"

INCLUDE "game/item/item.asm"

INCLUDE "menus/pause.asm"

INCLUDE "game/player/movement.asm"
INCLUDE "game/player/collision.asm"
INCLUDE "game/player/scroll.asm"
INCLUDE "game/player/gravity.asm"
INCLUDE "game/player/death.asm"

INCLUDE "game/entity/entity.asm"
INCLUDE "game/entity/helper.asm"
INCLUDE "game/entity/table.asm"
INCLUDE "game/entity/particle.asm"

INCLUDE "game/scripts/entities.asm"
INCLUDE "game/scripts/tiles.asm"
INCLUDE "game/scripts/death.asm"

INCLUDE "game/map.asm"

SECTION "BEGIN", ROM0[$100]
	di
	jp Start


ds $134 - $104

SECTION "HEADER", ROM0[$134]

	db CART_NAME, 0, 0 ; 134-142 is name
	db $80 ; CGB compatibility flag
	db "OK" ; new license code
	db 0 ; SGB compatibility flag
	db CART_ROM_MBC1_RAM_BAT
	db CART_ROM_256K
	db CART_RAM_16K
	db 1 ; INTERNATIONAL
	db $33 ; LICENSE CODE
	db 0 ; ROM VERISION
	db 0, 0, 0

SECTION "MAIN", ROMX

Start:
    ; initialize stack pointer
    RESET_SP

    ; initialize CGB
    call cgb_init
    
    ; zero out RAM
    MSET 0, $C001, $01FF-1 ; skip the CGB byte

    ; turn off screen
    xor a
    ldh [rLCDC], a

    ; initalize GRAPHICS_PALETTEs
    call gfx_resetPalette
    ld a, GRAPHICS_PALETTE2
    ldh [rOBP1], a ; rOBP1

    ; clear background & window
    call gfx_zeroBackground
    call gfx_zeroWindow

    ; load tiles
    MCOPY TILE_DATA, TILE_ADDRESS, TILE_DATA_SIZE

    ; load DMA transfer routine
    MCOPY dma_routine, _HRAM, dma_routine_end - dma_routine

    ld a, IEF_VBLANK
    ldh [rIE], a

    call wnd_drawHUD
    ; turn on screen so I can write
    ENABLE_SCREEN

    ; clear all sprites
    call gfx_zeroOAM

    ; set window
    SET_WINDOW 7, 144 - 16

    ; set player img
    ld a, MAP_TILE_PLAYER
    call plr_setTile

    ld a, $78
    ld e, $55
    call plr_setPosition

    ; load first room
    ld a, 2 + (2 * MAP_ROOM_TABLE_WIDTH)
    ; ld a, 1 + (3 * MAP_ROOM_TABLE_WIDTH) 
    ld [map_current_id], a
    call map_getFromID
    call map_loadRoom

    ld a, 1
    ld [plr_bullet_type], a
    ld [itm_collected], a

    ld a, PLAYER_BULLET_BMB_BLSTR
    call itm_collectBullet
    ld a, PLAYER_BULLET_TELE_PELLET
    call itm_collectBullet

    call map_setCheckpoint

    ei
mainLoop:

    halt
    
    call utl_scanJoypad
    call utl_maskJoypad

    bit PADB_START, a
    call nz, mnu_pause_init

    bit PADB_LEFT, a
    call nz, plr_moveLeft

    bit PADB_RIGHT, a
    call nz, plr_moveRight

    bit PADB_DOWN, a
    call nz, plr_moveDown

    ld a, [key]
    bit PADB_SELECT, a
    call nz, plr_changeBullet

    ; checks if the player will fire a gun
    call plr_fireGun

    ; see if the character is jumping
    call plr_jump

    ; check gravity
    call plr_applyGravity

    ; do enemy movement
    call ent_runScripts
    ; do entity animations
    call anim_doAll
    ; do player animation
    call plr_animate

    ; change alternative palette every 15 frames
    ; only in DMG mode
    ld a, [anim_timer]
    and $07
    or a
    call z, .changePalette


    ld a, [plr_obj_is_grounded_flag]
    or a
    jr nz, mainLoop
    
    ; increment coyote effect counter
    ld hl, plr_frames_since_grounded
    inc [hl]

    jr mainLoop

.changePalette:
    ld hl, rOBP1
    ld a, GRAPHICS_PALETTE2
    cp [hl]
    jr nz, .normal
.light:
    ld [hl], GRAPHICS_PALETTE
    ret
.normal:
    ld [hl], a
    ret