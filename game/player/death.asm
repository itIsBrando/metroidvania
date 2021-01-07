SECTION "DEATH", ROM0

; ==============================================
; Kills the player
; --
;   `***DOES NOT RETURN***`
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_death:
    ; set the alternative palette to the normal one so the player
    ;  can fade out seperately from other entities
    ld a, GRAPHICS_PALETTE
    ldh [rOBP1], a
    ; set death to NZ
    ld [plr_is_dead], a

    call dth_create

    ; set player's palette to be different then others'
    ld hl, plr_obj_flag
    set OAMB_PAL1, [hl]
    call plr_setRedrawFlag
    
    ; this loop will continue animations and moving entities
    ld b, 60
.loop:
    push bc
    halt 

    ld a, %111
    and b
    jr nz, .noFade

    IS_CGB
    call nz, plr_death_cgb

    ld hl, rOBP1
    ld a, [hl]
    SHIFT_RIGHT a, 2
    ld [hl], a

.noFade:
    ; do enemy movement
    call ent_runScripts
    ; do entity animations
    call anim_doAll
    ; do player animation
    call plr_animate
    
    pop bc
    dec b
    jr nz, .loop

    ; fade everything out
    call gfx_fadeOut

    ; redraw minimap because the room may have changed
    call wnd_clearMinimap
    ; restore player's position
    call map_restoreCheckpoint

    ; load the room
    call map_getFromID
    ld a, 1
    call map_loadRoom

    ; set player's palette correctly
    xor a
    ld [plr_obj_flag], a

    ; force redraw
    call plr_checkGrounded
    call plr_setRedrawFlag
    halt
    
    ; reset bg offsets because `map_loadRoom` draws at the top left of bgmap
    xor a
    ldh [rSCX], a
    ldh [rSCY], a

    ; reintroduce screen
    call gfx_fadeIn

    ; tell entities that we are no longer dying
    xor a
    ld [plr_is_dead], a

    ; prevent stack overflow
    RESET_SP
    ; return to mainloop
    jp mainLoop


; ==============================================
; Darkens the palette in BG0 in CGB only
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
plr_death_cgb:
    ret


; ==============================================
; Sets the player's x and y coords to that of the checkpoint
; --
;   - `***Does not load map if the map ID has changed***`
;	- Inputs: `NONE`
;	- Outputs: `A` = new map ID
;	- Destroys: `ALL`
; ==============================================
map_restoreCheckpoint:
    
    ld hl, plr_checkpoint_y
    ld de, plr_obj_y
    ld a, [hl+] ; Y
    ld [de], a  ; Y
    inc de
    ld a, [hl+] ; X
    ld [de], a  ; X

    ld a, [hl]
    ld [map_current_id], a
    ret 