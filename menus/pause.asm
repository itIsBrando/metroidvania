SECTION "PAUSE MENU", ROM0
; ==============================================
; Starts the pause menu
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
mnu_pause_init:
    ; clear button mask
    ld hl, joypadMask
    res PADB_START, [hl]

    ; hide sprites
    xor a
    ldh [rOBP0], a

    ; scroll the window northwards
    ld a, 144 - 16
    ld b, 1
    call wnd_scrollNorth

    call mnu_pause_draw

.main:
    halt 
    call utl_scanJoypad
    call utl_maskJoypad

    bit PADB_UP, a
    call nz, .moveUp

    bit PADB_DOWN, a
    call nz, .moveDown

    bit PADB_START, a
    jr z, .main

    ; REMOVE LATER
    ld a, [map_current_id]
    call map_getFromID
    call map_loadRoom

    call map_setCheckpoint

    ; restore window position
    ld a, 144 - 16
    ld b, 1
    call wnd_scrollSouth

    ; restore sprite palette
    ld a, GRAPHICS_PALETTE
    ldh [rOBP0], a
    ret

.moveUp:
    ; reset mask
    xor a
    ld [joypadMask], a
    
    ld hl, map_current_id
    inc [hl]
    jr mnu_pause_draw

.moveDown:
    ; reset mask
    xor a
    ld [joypadMask], a

    ld hl, map_current_id
    dec [hl]
    jr mnu_pause_draw


; ==============================================
; Redraws the pause menu
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
mnu_pause_draw:
    ld a, [map_current_id]
    GET_XY_WINDOW hl, 9, 5
    jp gfx_drawNumber


; ==============================================
; Draws a 8-bit number
; --
;	- Inputs: `HL` = end of drawing location, `A` = number
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
gfx_drawNumber:
	ld b, 3
loop:
	push bc
	ld d, a
	ld e, 10


	call math_div_D_E
	push de ; save the result

	add a, "0"
	push af
	call gfx_VRAMReadable
	pop af
	
	ld [hl-], a
	pop af
	pop bc

	dec b
	jr nz, loop
    ret