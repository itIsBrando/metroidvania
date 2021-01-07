CART_NAME	    EQUS "\"SPIKES       \""
TILE_ADDRESS    EQU _VRAM

DMA_ADDRESS     EQU $C400
BG_LOCATION     EQU $9800
WINDOW_LOCATION EQU $9C00


MAP_WIDTH           EQU 20 ; width of each map
MAP_HEIGHT          EQU 16 ; heigh of each map. two columns of window
MAP_ROOM_DATA_SIZE  EQU (20*16) ; may not be constant in the future??


MAP_TILE_FALLING_BLOCK_1    EQU $04 ; falling block, frame one
MAP_TILE_BREAKABLE_BLOCK    EQU $0F
MAP_TILE_PLAYER             EQU $11
MAP_TILE_SPIKE              EQU $19
MAP_TILE_MINIMAP            EQU $1B ; start of 16x16 minimap
MAP_TILE_CHECKPOINT_1       EQU $1A ; checkpoint
MAP_TILE_BULLET             EQU $1F ; regular bullet
MAP_TILE_BOMB_BLASTER       EQU $20 ; bomb blaster bullet
MAP_TILE_TELE_PELLET        EQU $21 ; tele pellet bullet
MAP_TILE_CANNON             EQU $23 ; downward facing cannon
MAP_TILE_SLIME_1            EQU $24 ; slime sprite
MAP_TILE_SLIME_2            EQU $25 ; slime sprite
MAP_TILE_BAT_2              EQU $26 ; bat sprite
MAP_TILE_BAT_1              EQU $27 ; bat sprite
MAP_TILE_CHEST              EQU $28 ; chest that hold each egg
MAP_TILE_SPIKE_DOWN         EQU $29 ; spike facing downwards
MAP_TILE_SPIKE_RIGHT        EQU $2D ; spike facing eastwards
MAP_TILE_CHECKPOINT_2       EQU $2A ; checkpoint after setting position
MAP_TILE_OPEN_CHEST         EQU $5D ; open chest
MAP_TILE_PARTICLE1          EQU $60 ; particle that looks ugly
MAP_TILE_PARTICLE2          EQU $61
MAP_TILE_MOVING_SPIKE       EQU $76 ; moving saw looking thing
MAP_TILE_CHAIN              EQU $78 ; vertical chain that is for aesthetic
MAP_TILE_HANGING_CHAIN      EQU $79 ; a small, hanging chain that is for aesthetic

MAP_ROOM_TABLE_WIDTH        EQU 5 ; width  of the map array
MAP_ROOM_TABLE_HEIGHT       EQU 5 ; height of the map array
MAP_FALLING_BLOCK_FRAMES    EQU 10; number of frames the falling block will stay alive before it begins falling

; 00 is lightest and 11 is darkest
GRAPHICS_PALETTE		EQU %11100100
GRAPHICS_PALETTE2       EQU %01000000

PLAYER_COYOTE_FRAMES    EQU 5   ; number of frames that plr is allowed to jump after leaving the ground

PLAYER_BULLET_NORMAL      EQU %1   ; bitmask of normal bullet
PLAYER_BULLET_BMB_BLSTR   EQU %10  ; bitmask of bomb blaster
PLAYER_BULLET_TELE_PELLET EQU %100 ; bitmask of teleporting pellet
PLAYER_BULLET_SIZE        EQU 3 ; total number of custom bullets

; entity defines
ENTITY_TABLE_SIZE       EQU 12      ; max element number for the table
ENTITY_STORAGE_SIZE     EQU 5       ; size of each entity when stored in ROM. (`y, x, tile, script pointer`)

rsreset
ENTITY_ENTRY_OAM                rb 1 ; position used in OAM
ENTITY_ENTRY_Y                  rb 1 ; y coord
ENTITY_ENTRY_X                  rb 1 ; x coord
ENTITY_ENTRY_TILE               rb 1 ; tile of sprite
ENTITY_ENTRY_FLAG               rb 1 ; flags byte of sprite
ENTITY_ENTRY_IS_GROUNDED        rb 1 ; determines whether entity is grounded
ENTITY_ENTRY_IS_JUMPING         rb 1 ; UNUSED BUT KEPT FOR CONSTITENCY WITH PLAYER
ENTITY_ENTRY_SHOULD_UPDATE      rb 1 ; flag to determine whether it needs to get redrawn
ENTITY_ENTRY_SCRIPT             rb 2 ; pointer to routine that will be called every frame
ENTITY_ENTRY_ANIMATION_FRAMES   rb 1 ; number of frames for each tile. Set to 0 (default) for no animation
ENTITY_ENTRY_ALT_TILE           rb 1 ; optional frame 2 of an entity
ENTITY_ENTRY_SIZE               rb 0 ; size of each entity in the table

ENTITY_ENTRY_DATA_1             EQU ENTITY_ENTRY_IS_GROUNDED ; really is `ENTITY_ENTRY_IS_GROUNDED`
ENTITY_ENTRY_DATA_2             EQU ENTITY_ENTRY_IS_JUMPING ; union with ENTITY_ENTRY_IS_JUMPING
