SECTION "TILES", ROM0

TILE_DATA:
    incbin "data/tiles.2bpp"
TILE_DATA_SIZE EQU @ - TILE_DATA

SECTION "DATA", ROMX

dta_room0x0:
    dw dta_room0x0_entity_table
    db 20, 16
    db 22,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,24,0,0,0,0,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,24,40,0,0,0,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,22,5,10,0,0,0,46,0,0,9,5,5,5,5,5,10,0,0,0,0,22,22,8,0,0,0,46,0,0,23,22,22,22,22,22,24,0,0,0,0,22,24,0,0,9,5,5,5,5,22,22,22,22,22,22,22,5,5,5,5,22,24,47,47,7,6,6,6,6,6,6,6,6,6,6,22,22,22,22,22,22,24,0,0,0,0,46,0,0,0,0,0,0,46,46,23,22,22,22,22,22,24,0,0,0,0,46,0,0,0,0,0,0,46,46,23,22,22,22,22,22,24,0,0,0,9,5,5,5,5,5,5,10,46,46,23,22,22,22,22,22,24,0,0,0,7,6,6,6,6,6,22,24,11,12,23,22,22,22,22,22,24,0,0,0,0,46,0,0,0,0,23,24,0,0,7,6,22,22,22,22,2,3,2,3,2,3,2,3,47,47,23,24,0,0,0,0,23,22,22,22,24,0,0,0,0,46,0,0,0,0,23,24,0,0,0,0,23,22,22,22,24,0,0,9,5,5,5,5,5,5,22,22,5,10,0,0,23,22,22,22,24,0,0,23,22,22,22,22,22,22,22,22,22,24,0,0,23,22,22

dta_room0x1:
    dw dta_room0x1_entity_table
    db 20, 16
    db 22,24,0,0,23,22,22,22,22,22,22,22,22,22,24,0,0,7,6,6,22,24,47,47,7,6,6,6,6,6,6,6,22,22,24,0,0,0,0,0,22,24,0,0,0,0,0,0,0,46,46,0,23,22,24,0,0,0,0,0,22,24,0,0,26,0,0,0,0,46,46,0,23,22,24,11,12,9,5,5,22,22,5,5,5,5,5,5,10,11,12,4,7,6,8,11,12,7,22,22,22,22,6,6,6,6,6,6,8,0,0,4,0,0,46,0,0,0,23,22,22,24,46,46,0,0,0,0,0,0,0,4,0,0,46,0,0,0,23,22,22,24,46,46,0,0,0,0,0,0,0,4,0,0,46,0,0,4,7,22,22,24,11,12,9,5,5,5,5,5,5,10,47,47,1,0,0,4,0,23,22,24,0,0,23,22,22,22,22,22,22,24,0,0,0,0,0,4,0,23,22,24,0,0,7,6,6,6,6,6,6,22,25,25,25,25,25,1,0,23,22,24,11,12,46,0,0,0,0,0,0,7,6,6,6,6,6,8,0,23,22,24,0,0,46,0,0,0,0,0,0,0,46,0,0,0,0,46,0,23,22,24,0,0,46,0,0,0,0,0,0,0,46,0,0,0,0,46,0,23,22,22,5,5,5,5,5,5,10,0,0,9,5,5,5,5,5,5,5,22,22,22,22,22,22,22,22,22,24,0,0,23,22,22,22,22,22,22,22,22

dta_room0x2:
    dw dta_room0x2_entity_table
    db 20, 16
    db 22,6,6,6,6,6,6,6,8,0,0,23,22,22,22,22,22,22,22,22,24,0,0,0,0,0,46,0,0,0,0,23,22,22,22,22,22,22,22,22,24,0,0,0,0,0,46,0,0,0,0,23,22,22,22,22,22,22,22,22,24,0,0,0,9,5,5,5,5,5,5,22,22,6,6,6,6,6,6,22,24,47,47,47,7,6,6,6,6,6,6,6,8,47,47,47,47,47,47,23,24,0,0,0,0,0,0,0,0,0,0,0,46,0,0,0,0,0,0,23,24,0,0,0,0,9,10,0,0,0,0,0,46,0,9,10,11,12,0,23,22,5,5,5,5,22,22,5,5,5,5,5,5,5,22,24,0,0,0,23,22,22,22,22,22,22,22,22,22,6,6,6,6,6,6,8,0,0,0,23,22,6,6,6,6,6,6,22,24,41,41,41,41,41,41,46,0,0,26,23,24,0,0,0,0,0,0,23,24,0,0,0,0,0,0,46,0,11,12,23,24,0,0,0,0,0,0,7,8,0,0,0,0,0,0,46,0,0,0,23,24,0,0,0,0,0,0,0,0,0,0,9,10,0,0,46,0,0,0,23,24,0,0,0,0,0,0,0,0,0,0,23,24,0,0,46,0,0,0,23,24,0,0,9,5,5,5,5,5,5,5,22,22,5,5,5,5,5,5,22,24,0,0,23,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22

dta_room0x3:
    dw dta_empty_entity_table
    db 20, 16
    db 24,0,0,7,6,6,6,6,6,6,6,6,6,6,6,6,22,22,22,22,24,0,0,0,0,0,46,0,0,0,0,0,0,0,0,0,23,22,22,22,24,0,0,0,0,0,46,0,0,0,0,0,0,0,0,0,23,22,22,22,22,5,5,5,5,5,5,5,5,5,5,5,5,10,4,4,7,6,6,22,22,6,6,6,6,6,6,6,6,6,6,6,6,8,0,0,0,0,0,23,24,0,46,0,0,0,46,46,0,0,0,46,0,0,0,0,0,0,0,23,24,0,46,0,0,0,46,46,0,0,0,46,0,0,0,0,0,0,0,23,24,0,46,0,0,0,2,3,0,0,0,46,0,0,2,3,47,47,47,23,24,0,46,0,0,0,0,0,0,0,2,3,0,0,46,46,0,0,0,23,1,1,1,0,0,0,0,0,0,0,0,46,0,0,46,46,0,0,0,23,1,20,1,0,0,0,0,0,0,0,0,46,0,0,46,46,0,0,0,23,1,20,1,0,0,0,0,0,0,0,106,46,0,0,46,46,0,0,0,23,1,20,1,0,0,0,0,0,0,0,2,3,0,0,2,3,0,9,5,22,1,20,1,47,47,47,47,47,47,47,47,47,47,47,47,47,47,23,22,22,1,20,1,25,25,25,25,25,25,25,25,25,25,25,25,25,25,23,22,22,1,20,1,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22

dta_room0x4:
    dw dta_empty_entity_table
    db 20, 16
    db 1,20,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,20,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,20,1,1,1,1,1,20,20,20,20,20,20,20,20,20,20,20,20,1,1,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,1,1,20,20,20,20,20,20,20,1,1,20,20,20,20,20,20,1,20,20,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,20,20,1,1,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,1,1,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,1,1,20,20,20,20,1,1,20,20,20,20,20,1,1,20,20,1,1,1,1,1,20,20,20,20,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,1,20,2,3,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,1,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,1,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

dta_room1x1:
    dw dta_room1x1_entity_table
    db 20, 16
    db 6,6,6,6,6,22,22,22,6,6,6,6,6,6,6,6,6,22,22,22,0,0,46,0,0,23,22,24,0,121,0,0,0,0,0,46,0,7,6,22,0,0,46,0,0,23,22,24,0,121,0,0,0,0,0,46,0,0,0,23,5,5,10,47,47,23,22,24,0,0,9,5,5,5,10,46,0,0,0,23,22,6,8,0,0,7,22,24,47,47,23,22,22,22,22,5,10,47,47,23,24,0,46,0,2,3,22,24,0,0,7,6,6,6,6,22,24,0,0,7,24,0,46,0,0,0,23,2,3,0,120,0,0,46,46,23,24,0,0,0,24,2,3,0,0,2,3,24,0,0,120,0,0,46,46,23,24,0,26,0,24,0,46,0,0,0,23,24,0,0,120,0,0,46,46,23,22,5,5,5,24,0,46,0,0,9,22,22,5,5,5,5,10,46,46,23,22,22,22,22,24,0,46,2,3,7,6,6,6,6,22,22,24,46,46,23,22,22,22,22,24,0,46,0,0,120,0,0,0,0,7,22,24,11,12,7,6,6,6,6,24,2,3,0,0,120,0,0,0,0,0,23,24,0,0,0,0,0,46,0,24,0,46,0,0,120,0,0,0,0,0,23,24,0,0,0,0,0,46,0,22,5,5,5,5,5,5,5,10,0,0,23,22,5,5,5,5,5,5,5,22,22,22,22,22,22,22,22,24,0,0,7,6,6,6,6,6,6,6,6

; room to the right of boss room
dta_room1x2:
    dw dta_room1x2_entity_table
    db 20, 16
    db 22,22,22,22,22,22,22,22,24,0,0,7,6,6,6,6,6,6,6,22,22,22,22,22,22,22,22,22,24,0,0,0,0,0,46,0,0,46,46,23,22,22,22,22,22,22,22,22,24,0,0,0,0,0,46,0,0,46,46,23,22,22,22,22,22,22,22,22,22,5,5,5,5,5,10,0,0,46,46,23,22,22,22,22,6,6,6,6,6,6,6,6,6,6,8,0,0,11,12,23,22,6,6,8,0,46,46,0,0,0,0,0,0,46,46,0,0,0,0,23,24,0,46,0,0,46,46,0,0,0,0,0,0,46,46,0,0,0,0,23,24,0,46,0,0,46,46,0,0,0,0,0,0,46,46,0,0,0,0,23,24,0,46,0,0,11,12,0,0,4,4,0,0,11,12,0,0,9,5,22,24,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,6,22,24,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,46,0,23,22,5,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,46,0,7,22,22,22,5,10,0,0,0,0,0,0,0,0,0,0,0,0,46,0,0,22,22,22,22,24,25,25,25,9,10,0,0,0,0,9,5,5,10,0,0,22,22,22,22,22,5,5,5,22,22,5,5,5,5,22,22,22,22,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6

dta_room1x3:
    dw dta_empty_entity_table
    db 20, 16
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,46,0,128,0,0,0,0,0,0,0,0,0,0,46,0,0,0,1,1,0,46,0,0,0,0,1,1,1,1,1,0,0,0,1,1,1,0,0,1,0,46,0,0,0,0,0,128,0,0,0,0,0,0,46,0,1,1,1,1,0,46,0,0,0,0,0,0,0,0,0,0,0,0,46,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,46,0,40,1,1,1,1,1,1,47,47,47,47,47,47,47,47,47,47,47,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,25,25,25,25,25,25,25,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,46,1,1,1,1,1,1,1,1,1,1,1,1,1,41,41,0,0,0,0,46,0,1,1,1,1,1,1,1,1,1,0,0,128,0,0,0,0,0,0,46,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,26,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,102,103,104,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1

dta_room1x4:
    dw dta_empty_entity_table
    db 20, 16
    db 1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,46,1,1,1,1,1,1,1,0,0,4,4,4,0,0,0,0,0,0,0,46,0,0,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,46,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,46,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,46,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,46,1,1,1,1,0,46,0,0,0,0,0,0,0,0,46,0,46,0,0,46,0,1,1,1,0,46,0,0,0,0,1,1,0,0,46,0,46,0,0,46,0,1,1,1,0,46,0,0,0,0,1,1,0,0,1,1,1,0,0,46,0,1,1,1,0,46,0,0,106,0,1,1,0,0,1,1,1,0,0,46,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

dta_room2x0:
    dw dta_empty_entity_table
    db 20, 16
    db 22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,6,6,6,6,6,22,22,22,22,6,6,22,22,22,22,6,6,6,6,6,0,0,0,0,128,7,6,6,8,0,0,7,6,22,24,0,0,46,0,0,0,0,0,0,0,46,15,0,15,0,0,46,0,23,24,0,0,46,0,0,0,0,0,0,0,46,1,1,1,0,0,46,0,23,24,0,0,9,5,5,5,5,5,5,5,10,0,0,0,0,0,46,0,23,24,0,0,7,6,22,22,6,6,6,6,8,0,0,0,0,25,46,0,23,24,0,0,46,128,23,24,0,0,0,0,0,0,0,0,0,1,1,0,23,24,0,0,46,0,23,24,0,0,0,0,0,15,0,0,0,0,1,1,7,22,5,10,46,0,23,24,0,0,0,0,0,0,0,0,0,0,15,0,0,23,22,24,46,9,22,24,0,0,0,0,0,0,15,0,0,1,0,0,0,23,22,24,46,7,6,24,102,104,9,10,0,0,0,0,25,0,0,0,0,23,22,24,46,0,128,24,0,0,23,24,25,25,25,25,22,25,25,25,25,23,22,24,46,0,0,24,0,0,23,22,22,22,22,22,22,22,22,22,22,22,22,22,5,5,5,24,0,0,23,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22

dta_room2x1:
    dw dta_empty_entity_table
    db 20, 16
    db 24,0,0,7,6,6,6,6,6,6,6,6,6,22,22,22,22,22,22,22,24,0,0,15,0,0,0,0,0,0,0,46,0,23,22,22,22,22,22,22,22,5,5,10,4,4,1,4,4,1,0,46,0,7,6,6,6,22,22,22,22,6,6,8,0,0,0,0,0,0,0,46,26,46,0,121,0,23,22,22,24,0,128,0,0,0,0,0,0,0,0,11,105,12,0,121,0,23,22,22,8,0,0,0,4,4,0,4,4,4,0,0,0,0,0,121,0,23,22,22,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,121,0,23,22,22,0,0,9,10,0,0,0,0,0,0,0,0,0,0,0,0,0,23,22,22,5,5,22,22,25,25,25,25,25,25,25,25,25,0,0,0,0,23,22,22,22,22,22,22,22,22,22,6,6,6,6,22,22,25,25,25,25,23,22,22,22,22,22,22,22,22,24,0,0,0,0,23,22,22,22,22,22,22,22,22,6,6,6,6,6,6,8,47,47,47,47,23,22,22,22,22,22,22,22,22,0,0,0,0,15,0,0,0,0,0,0,23,22,22,22,22,22,22,22,22,0,0,0,0,15,0,0,0,0,0,0,23,22,22,22,22,22,22,22,22,5,5,5,5,5,5,5,5,10,0,0,23,22,22,22,22,22,22,22,22,6,6,6,6,6,6,6,6,8,0,0,7,6,6,6,6,6,6,6,6
    
; boss battle room
dta_room2x2:
    dw dta_empty_entity_table   ; entity table
    db 20, 16
    db 22,6,6,6,6,6,6,6,8,0,0,7,6,6,6,6,6,6,6,22,24,0,0,0,0,0,0,46,0,0,0,0,46,0,0,0,0,0,0,23,24,0,0,0,0,0,0,46,0,0,0,0,46,0,0,0,0,0,0,23,24,47,47,47,47,47,47,9,5,5,5,5,10,47,47,47,47,47,47,23,24,0,0,0,0,0,0,7,6,6,6,6,8,0,0,0,0,0,0,23,24,0,0,0,11,12,0,46,0,0,0,0,46,0,11,12,0,0,0,23,24,0,0,0,0,0,0,46,0,0,0,0,46,0,0,0,0,0,0,23,24,0,0,0,0,0,0,46,0,0,0,0,46,0,0,0,0,0,0,23,24,0,0,0,0,0,2,3,0,0,0,0,2,3,0,0,0,0,0,23,24,0,0,0,0,0,0,46,0,0,0,0,46,0,0,0,0,0,0,23,24,0,0,0,0,0,0,46,0,0,0,0,46,0,0,0,0,0,0,23,8,0,0,0,11,12,0,46,0,0,0,0,46,0,11,12,0,0,0,7,0,0,0,0,0,0,0,46,0,13,14,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,46,0,29,30,0,46,0,0,0,0,0,0,0,5,5,5,5,5,5,5,5,102,103,103,104,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,8,0,0,0,0,7,6,6,6,6,6,6,6

dta_room2x3:
    dw dta_empty_entity_table
    db 20, 16
    db 22,22,6,6,6,6,6,8,0,0,0,0,23,22,22,22,22,22,22,22,6,8,0,128,0,0,0,46,0,0,0,0,23,22,22,22,22,22,22,22,0,46,0,0,0,0,0,46,0,0,0,0,23,22,22,22,22,22,22,22,10,46,0,0,0,26,0,46,0,0,0,0,23,22,22,22,22,22,22,22,22,5,5,5,5,5,5,5,5,5,5,5,22,22,22,22,22,22,22,22,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

dta_room3x0:
    dw dta_empty_entity_table
    db 20, 16
    db 22,22,22,22,22,22,22,22,22,6,6,6,6,6,6,6,6,6,6,6,22,22,22,22,22,22,22,6,8,47,47,47,47,47,47,47,47,47,47,47,6,6,6,6,6,6,8,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,46,0,128,0,46,0,0,9,5,5,5,5,5,5,10,0,0,0,0,0,46,0,0,0,46,9,5,22,6,6,6,6,6,6,22,5,5,5,5,10,102,103,103,103,104,23,22,24,41,41,41,41,41,41,7,6,22,22,22,24,0,0,0,0,0,23,22,8,0,0,0,0,0,0,0,128,23,1,1,24,0,0,0,0,0,7,8,121,0,0,0,0,0,0,0,0,23,1,1,24,0,0,0,0,0,0,0,121,0,0,0,0,0,0,0,0,7,1,1,24,0,0,0,0,0,0,0,121,0,0,0,0,0,0,0,0,0,1,22,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,8,0,0,0,0,0,0,0,0,0,0,0,2,3,0,0,0,0,9,0,15,0,0,0,0,0,0,0,2,3,0,0,0,0,0,0,0,0,23,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,23,5,10,0,0,9,5,10,25,25,25,25,25,25,25,25,25,25,25,25,23,22,24,0,0,23,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22

dta_room3x1:
    dw dta_empty_entity_table
    db 20, 16
    db 23,24,0,0,7,6,6,6,6,6,6,6,22,22,22,22,22,22,22,22,23,24,0,0,15,15,0,0,0,0,0,0,7,6,22,22,6,6,22,22,23,24,11,12,9,10,47,47,47,47,47,47,47,47,7,8,0,128,7,22,23,24,0,0,23,24,0,0,2,3,0,0,0,26,15,15,0,0,0,7,23,24,0,0,23,24,0,2,3,0,0,2,3,5,5,10,0,0,0,0,23,24,0,0,23,24,0,0,1,0,0,0,0,23,22,24,0,0,0,0,23,24,11,12,23,2,3,0,2,3,0,0,0,23,22,24,0,0,0,9,23,24,0,0,7,8,0,0,1,0,0,2,3,23,22,24,0,0,0,23,23,24,0,0,128,0,0,2,3,0,0,0,0,7,6,22,10,0,0,23,23,24,0,0,0,0,0,0,2,3,0,0,0,46,46,23,24,47,47,23,22,22,5,5,5,5,5,5,10,0,0,0,0,46,46,7,8,0,0,23,23,22,22,22,22,22,22,22,22,5,5,5,10,11,12,0,0,0,0,23,23,22,22,22,22,22,22,22,22,22,22,22,24,0,0,0,0,0,0,23,23,22,22,22,22,22,22,22,22,22,22,22,22,5,5,5,5,5,5,23,23,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,23,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22

dta_room3x2:
    dw dta_empty_entity_table
    db 20, 16
    db 22,22,22,22,22,22,22,22,22,22,22,22,6,6,6,6,6,6,22,22,22,22,22,6,6,6,6,6,6,6,6,8,0,121,0,0,0,0,7,6,22,22,24,0,0,0,128,0,0,0,0,0,0,121,0,0,0,0,0,128,22,6,8,0,0,0,0,0,0,0,0,0,0,121,0,0,0,0,0,0,24,0,46,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,1,0,24,0,46,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,1,1,24,0,46,9,10,0,0,4,4,0,0,0,0,0,0,0,0,0,1,1,24,0,46,7,8,47,47,47,47,47,47,47,47,47,47,47,47,47,47,23,24,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,23,22,5,5,10,0,0,0,0,0,0,0,0,0,9,5,5,10,47,47,23,22,22,22,24,25,25,25,25,25,25,25,25,25,23,22,22,24,0,0,23,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,8,0,0,23,0,1,0,0,0,0,0,0,0,0,0,121,0,0,0,0,0,0,0,23,0,46,0,9,5,5,5,10,0,0,0,0,0,0,0,9,5,5,5,23,5,5,5,22,22,22,22,24,25,25,25,25,25,25,25,23,22,22,22,22,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6

dta_room4x0:
    dw dta_empty_entity_table
    db 20, 16
    db 6,6,22,22,22,6,6,6,6,6,6,6,6,6,6,6,6,6,6,22,47,47,7,6,8,0,0,128,0,0,0,15,0,0,0,0,0,46,46,23,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,46,46,23,0,0,0,0,0,0,0,9,5,5,5,5,5,4,4,5,10,46,46,23,5,5,5,5,5,5,5,22,22,22,22,6,6,4,4,6,8,46,46,23,22,22,22,22,22,22,22,22,22,6,8,121,0,0,0,0,121,11,12,23,22,22,22,22,22,22,22,6,8,120,0,121,0,0,0,0,0,0,0,23,22,6,6,6,6,22,24,0,0,120,0,0,0,0,0,0,0,0,0,23,8,47,47,47,47,23,24,0,0,120,0,0,0,0,0,0,0,0,0,23,0,0,0,0,0,23,24,40,0,120,0,0,0,0,0,9,10,11,12,23,0,0,0,0,0,23,24,102,103,103,103,103,103,103,104,23,24,0,0,23,10,0,0,0,0,23,24,0,0,0,0,0,0,0,0,23,24,0,0,23,24,0,0,0,0,23,24,0,0,0,0,0,0,0,0,23,24,0,0,23,22,5,10,0,0,23,24,25,25,25,25,25,25,25,25,23,24,11,12,23,22,22,24,0,0,23,22,22,22,22,22,22,22,22,22,22,24,0,0,23,22,22,24,0,0,23,22,22,22,22,22,22,22,22,22,22,24,0,0,23

dta_room4x1:
    dw dta_empty_entity_table
    db 20, 16
    db 23,22,24,0,0,7,6,6,22,22,22,22,22,22,22,22,24,121,121,23,23,22,24,0,0,46,0,106,23,22,6,6,6,22,22,22,2,3,121,23,23,22,24,4,4,7,6,6,6,8,41,41,41,7,6,22,24,121,121,23,7,6,8,0,0,0,121,0,120,0,0,0,0,41,41,7,1,121,121,23,0,128,0,0,0,0,121,0,120,0,0,0,0,0,0,0,1,121,2,3,0,0,0,0,0,0,0,0,120,0,0,0,0,0,0,0,15,121,121,23,10,0,0,0,0,0,0,0,120,0,0,0,0,0,0,0,1,121,121,23,24,47,47,47,9,5,5,5,5,5,5,5,5,5,1,1,2,3,121,1,24,0,0,0,7,6,6,6,6,8,41,41,41,1,1,1,1,121,121,1,22,1,0,0,41,46,0,0,0,0,0,0,0,0,0,46,1,1,1,1,24,45,0,0,0,46,0,0,0,0,0,0,0,0,0,46,0,121,1,1,24,45,0,0,0,46,0,0,0,0,0,0,0,0,0,46,0,121,121,23,24,45,0,0,0,46,0,1,0,0,0,0,0,0,0,46,0,121,121,23,22,5,5,5,10,46,0,1,0,0,1,0,0,0,0,1,1,11,12,23,22,22,22,22,22,10,4,1,25,25,1,25,25,1,1,1,1,0,0,23,22,22,22,22,22,24,0,1,1,1,1,1,1,1,1,1,1,0,0,23

dta_room4x2:
    dw dta_empty_entity_table
    db 20, 16
    db 1,1,1,1,1,1,0,1,22,22,22,22,22,22,22,22,24,0,0,23,1,1,120,15,0,0,0,1,22,22,22,22,22,22,22,22,24,11,12,23,0,0,120,1,1,1,1,1,6,6,6,6,6,22,22,22,24,0,0,23,0,0,120,0,0,0,0,0,0,0,128,0,0,7,6,22,24,0,0,23,0,26,120,0,0,0,0,0,0,0,0,0,0,0,0,23,24,11,12,23,5,5,10,0,0,0,0,0,0,0,9,10,0,1,47,23,24,47,47,23,22,22,24,25,25,25,25,25,25,25,23,24,0,1,0,23,24,0,0,23,22,6,6,6,22,22,22,22,6,6,6,8,0,1,0,23,24,11,12,23,24,0,0,0,7,6,6,8,0,0,46,0,0,1,25,23,24,0,0,23,24,0,0,106,0,0,0,0,0,9,10,0,0,1,22,22,24,0,0,23,24,0,0,9,5,5,5,5,5,22,22,5,5,1,22,22,24,11,12,23,24,0,0,7,6,6,6,6,6,6,6,6,6,6,6,6,8,0,0,23,24,0,0,0,46,0,0,0,0,0,15,0,0,0,0,46,0,0,0,23,24,0,0,0,46,0,0,0,0,0,1,0,0,0,0,9,5,5,5,22,22,5,5,5,5,5,5,10,25,25,1,25,25,25,25,23,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22


; ==============================================
; Entity table for 2nd room
; ==============================================
dta_room1x2_entity_table:
    db 2                            ; number of entries
    db $78, $70, MAP_TILE_SLIME_1   ; y, x, tile
    dw srpt_moveLeftRight           ; script pointer
    db $6B, $50, MAP_TILE_MOVING_SPIKE
    dw srpt_movingSpike


; ==============================================
; Entity Table
; ==============================================
dta_room0x0_entity_table:
    db 4    ; size
    db $78, $48, MAP_TILE_BAT_1 ; y, x, tile
    dw srpt_moveLeftRight       ; script pointer
    db $68, $18, MAP_TILE_BAT_1 ; y, x, tile
    dw srpt_moveLeftRight       ; script pointer
    db $60, $40, MAP_TILE_CANNON; y, x, tile
    dw srpt_entityCannon
    db $60, $54, MAP_TILE_CANNON; y, x, tile
    dw srpt_entityCannon

; ==============================================
; Entity Table
; ==============================================
dta_room0x1_entity_table:
    db 1                        ; size
    db $40, $70, MAP_TILE_BAT_1 ; y, x, tile
    dw srpt_moveLeftRight

dta_room0x2_entity_table:
    db 2                            ; size
    db $40, $70, MAP_TILE_SLIME_1   ; y, x, tile
    dw srpt_moveLeftRight
    db $60, $60, MAP_TILE_BAT_1     ; y, x, tile
    dw srpt_moveLeftRight

dta_room1x1_entity_table:
    db 3
    db $68, $19, MAP_TILE_BAT_1 ; y, x, tile
    dw srpt_moveLeftRight   ; script pointer
    db $50, $28, MAP_TILE_BAT_1 ; y, x, tile
    dw srpt_moveLeftRight   ; script pointer
    db $40, $0F, MAP_TILE_BAT_1 ; y, x, tile
    dw srpt_moveLeftRight   ; script pointer


; ==============================================
; Empty entity table
; ==============================================
dta_empty_entity_table:
    db 0               ; number of entries


; ==============================================
; Window HUD row 1 (20x1)
; ==============================================
dta_window_row_1:
    db 71,85,78,58,31,0,0,0,0,0,0,0,0,94,95,0,0,0,27,28    
; ==============================================
; Window HUD row 2 (20x1)
; ==============================================
dta_window_row_2:
    db 0,0,0,0,0,0,0,0,0,0,0,108,109,110,111,111,112,0,43,44

; ==============================================
; Sets a tile's flags byte
;   - Parameters: `start index`, `end index` *INCLUSIVE*, `value`
;   - gaps are not allowed
; ==============================================
SET_TILE: MACRO
__end:
__size EQU __end - dta_tile_data
IF __size > \1
    WARN "INVALID ORDER"
ENDC
IF \1 > \2
    WARN "START INDEX CANNOT BE LARGER THAN END"
ENDC

IF \2 - \1 > 0
REPT (\2) - (\1) + 1
    db \3
ENDR
ELSE
    db \3
ENDC
    PURGE __end, __size
ENDM

; ==============================================
; A 256-byte table that holds all flags for each tile
; - `bit 0`: solidness
; - `bit 1`: can jump through but cannot fall through
; - `bit 2`: runs a script upon player collision
; - `bit 3`: can be destroyed by the bomb blaster
; ==============================================
dta_tile_data:
    SET_TILE $00, $00, %00000000
    SET_TILE $01, $03, %00000001
    SET_TILE $04, $04, %00000101 ; falling blocks
    SET_TILE $05, $0A, %00000001
    SET_TILE $0B, $0C, %00000010 ; transparent block
    SET_TILE $0D, $0E, %00000000
    SET_TILE $0F, $0F, %00001001 ; bombable block
    SET_TILE $10, $15, %00000000
    SET_TILE $16, $18, %00000001 ; blocks
    SET_TILE $19, $19, %00000100 ; spike
    SET_TILE $1A, $1A, %00000100 ; checkpoint
    SET_TILE $1B, $1C, %00000000
    SET_TILE $1D, $1E, %00000100 ; spawner
    SET_TILE $1F, $27, %00000000
    SET_TILE $28, $28, %00000110 ; chest
    SET_TILE $29, $29, %00000100 ; also spike
    SET_TILE $2A, $2C, %00000000
    SET_TILE $2D, $2D, %00000100 ; also spike
    SET_TILE $2E, $65, %00000000
    SET_TILE $66, $69, %00000010 ; middle transparent platform
    SET_TILE $6A, $6A, %00000100 ; button
    SET_TILE $6B, $FF, %00000000


; ==============================================
; A lookup table for Y offsets
; ==============================================
plr_jump_table:
    db 2, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, -1, -1
    ; db 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 3, 3, 3, 3, 3, 1, 1, 1, 1, 0, 0, 0, 0
plr_jump_table_end:
PLAYER_JUMP_TABLE_SIZE EQU plr_jump_table_end - plr_jump_table


; ==============================================
; A table that holds the names of all the bullet/gun types
; ==============================================
plr_bullet_texts:
    dw .plr_text_1, .plr_text_2, .plr_text_3

.plr_text_1:
    db MAP_TILE_BULLET,     "NORMAL BULLET",0
.plr_text_2:
    db MAP_TILE_BULLET+1,   "BOMB BLASTER", 0
.plr_text_3:
    db MAP_TILE_BULLET+2,   "TELE-PELLET", 0


; ==============================================
; A 2D array the represents all of the maps
; ==============================================
map_room_table:
    dw dta_room0x0, 0,           dta_room2x0, dta_room3x0, dta_room4x0
    dw dta_room0x1, dta_room1x1, dta_room2x1, dta_room3x1, dta_room4x1
    dw dta_room0x2, dta_room1x2, dta_room2x2, dta_room3x2, dta_room4x2
    dw dta_room0x3, dta_room1x3, dta_room2x3, 0,           0
    dw dta_room0x4, dta_room1x4, 0,           0,           0


; ==============================================
; An array that holds tile numbers that have bit 3 of their flags byte set
; ==============================================
map_tiles_with_scripts:
    db MAP_TILE_FALLING_BLOCK_1, MAP_TILE_SPIKE, MAP_TILE_SPIKE_DOWN
    db $1D, $1E ; spawner
    db MAP_TILE_CHECKPOINT_1, MAP_TILE_CHEST
    db $6A ; button
    db $2D ; right facing spike
__end:

MAP_TILE_SCRIPTS_SIZE   EQU __end - map_tiles_with_scripts ; size of the array of tile scripts
PURGE __end


; ==============================================
; An array that holds pointers to scripts that get run from `map_getTileCollision`
; ==============================================
map_tile_script_pointers:
    dw srpt_tileFallingBlock, srpt_killPlayer, srpt_killPlayer
    dw srpt_collideWithSpawner, srpt_collideWithSpawner
    dw srpt_collideWithCheckpoint, srpt_collideWithChest ; <-- this is a chest
    dw srpt_collideWithButton
    dw srpt_killPlayer


; ==============================================
; Holds the number of frames of each gun's cooldown time
; ==============================================
gun_cooldown_table:
    db 20, 10, 40

; ==============================================
; Holds the tile number for each bullet type
; ==============================================
gun_tile_table:
    db MAP_TILE_BULLET, MAP_TILE_BULLET + 1, MAP_TILE_BULLET + 2