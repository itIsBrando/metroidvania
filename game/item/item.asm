SECTION "ITEM", ROM0


; ==============================================
; Collect some type of bullet
; --
;   - Use PLAYER_BULLET...
;	- Inputs: `A` = bullet mask
;	- Outputs: `NONE`
;	- Destroys: `HL`
; ==============================================
itm_collectBullet:
    ld hl, itm_collected
    or a, [hl]
    ld [hl], a
    ret


; ==============================================
; Checks to see if the player has collected a specific bullet
; --
;   - Use PLAYER_BULLET...
;	- Inputs: `A` = bullet type
;	- Outputs: `NZ` = true, `Z` = false
;	- Destroys: `HL`
; ==============================================
itm_hasBullet:
    ld hl, itm_collected
    and [hl]
    ret


; ==============================================
; Given a PLAYER_BULLET... returns an index
; --
;	- Inputs: `A` = bullet type
;	- Outputs: `C` = index
;	- Destroys: `A` = `0`
; ==============================================
itm_getBulletIndex:
    ld c, -1
.loop:
    sra a
    inc c
    or a
    jr nz, .loop
    ret


; ==============================================
; Gets the next bit in the bitmask
; --
;	- Inputs: `NONE`
;	- Outputs: Updates `plr_bullet_type`
;	- Destroys: `AF`, `HL`
; ==============================================
itm_next:
    ld hl, plr_bullet_type
    ld a, [hl]
    rlca ; shift A left
    
    or a
    jr z, .overflow

    cp 1 << PLAYER_BULLET_SIZE
    jr nz, .noOverflow
.overflow:
    ld a, 1
.noOverflow:
    ; save next index
    ld [hl], a
    
    ; return if we have this bullet
    call itm_hasBullet
    ret nz
    ; else, check recurvisely
    jr itm_next