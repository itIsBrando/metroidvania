; this file relates to the four scripts required to handle the death animation
SECTION "DEATHSCRIPT", ROM0

DEATH_MOVE_BY EQU 4


; ==============================================
; Creates the death entities for the player
; --
;	- Inputs: `NONE`
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
dth_create:
    call plr_getPosition

    ld hl, plr_bullet_buffer
    ld [hl+], a                 ; Y
    ld [hl], e                  ; X
    inc hl 
    ld [hl], MAP_TILE_BULLET    ; TILE
    inc hl

    ld c, 4
.loop:
    push bc

    ; save HL, which is pointer to entity script
    push hl
    ; fetch the script to use
    ld hl, dth_scripts
    
    ld b, 0
    dec c
    sla c
    add hl, bc

    ; ld hl, [hl]
    LOAD_HL_HL_IND 0
    LD16 de, hl
    pop hl
    call utl_write_DE_to_HL

    ; create left bullet
    push hl
    ld hl, plr_bullet_buffer
    call ent_create
    pop hl

    pop bc
    dec c
    jr nz, .loop

    ret

dth_scripts:
    dw dth_moveLeft, dth_moveRight, dth_moveUp, dth_moveDown

; ==============================================
; Script for player death animation
; --
;	- Inputs: `DE` = pointer to entity base
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
dth_moveLeft:
    push de
    LD16 hl, de

    ld e, -DEATH_MOVE_BY
    call ent_changeX

    cp 160
    jp nc, srpt_delete

    pop hl
    ret
    

; ==============================================
; Script for player death animation
; --
;	- Inputs: `DE` = pointer to entity base
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
dth_moveRight:
    LD16 hl, de
    
    ld e, DEATH_MOVE_BY
    call ent_changeX

    cp 160
    call nc, srpt_delete
    
    ret 


; ==============================================
; Script for player death animation
; --
;	- Inputs: `DE` = pointer to entity base
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
dth_moveUp:
    LD16 hl, de
    
    ld e, -DEATH_MOVE_BY
    call ent_changeY

    or a
    call z, srpt_delete
    
    ret


; ==============================================
; Script for player death animation
; --
;	- Inputs: `DE` = pointer to entity base
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
dth_moveDown:
    LD16 hl, de
    
    ld e, DEATH_MOVE_BY
    call ent_changeY

    cp 144
    call nc, srpt_delete
    ret 
