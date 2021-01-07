SECTION "PLR_COLLISION",ROM0


; ==============================================
; Checks collision at points (x - 2, y-16) and (x - 7, y-16) 
; --
;   - ****REMEMBER THAT SPRITES ARE DRAWN WITH X=8 BEING THE RIGHT MOST PIXEL****
;	- Inputs: `NONE`
;	- Outputs: `A` = `1` if solid, else `0`
;	- Destroys: `ALL`
; ==============================================
plr_collisionUp:
    call plr_getPosition

    DECREMENT e, 2 ; X - 2

    sub a, 16 ; Y - 16

    call plr_getCollision
    or a
    ret nz

    call plr_getPosition

    sub a, 16 ; Y - 16

    ld d, a ; save Y
    ; X - 7
    ld a, -7
    add a, e
    ld e, a

    ld a, d
    jp plr_getCollision
    

; ==============================================
; Checks collision at point (x - 4, y-8) 
; --
;   - ****REMEMBER THAT SPRITES ARE DRAWN WITH X=8 BEING THE RIGHT MOST PIXEL****
;	- Inputs: `NONE`
;	- Outputs: `A` = `1` if solid, else `0`
;	- Destroys: `ALL`
; ==============================================
plr_collisionDown:
    call plr_getPosition

    sub 8 ; Y - 8
    dec e ; X - 2
    dec e ; X - 2

    call plr_getCollision

    ld a, [map_collision_raw_flag]
    bit 1, a
    jr nz, .isPassable

    and $01
    jr z, .second_check
    ret

; if the tile can be passed through but is solid on top
.isPassable:
    call plr_getPosition
    DECREMENT e, 4  ; X - 4

    dec a           ; Y - 1
    
    call plr_getCollision
    ld a, [map_collision_raw_flag]
    and $03
    ret

; if A = 0 (nonsolid), then check another point
.second_check:
    call plr_getPosition
    ; check (x-7, y-8)
    sub 8
    ld d, a

    ld a, e
    sub a, 7
    ld e, a
    
    ld a, d
    call plr_getCollision

    ld a, [map_collision_raw_flag]
    and $01
    ret


; ==============================================
; Checks collision at points (x-1, y-9) & (x-1, y-16)
; --
;   - ****REMEMBER THAT SPRITES ARE DRAWN WITH X=X BEING THE RIGHT MOST PIXEL****
;	- Inputs: `NONE`
;	- Outputs: `A` = `1` if solid, else `0`
;	- Destroys: `ALL`
; ==============================================
plr_collisionRight:
    call plr_getPosition

    dec e ; X - 1
    sub 12 ; Y - 12

    call plr_getCollision
    or a
    ret nz

    call plr_getPosition

    dec e ; X - 1
    sub 9 ; Y - 9

    jp plr_getCollision

; ==============================================
; Checks collision at points (x - 8, y-16) & (x - 8, y - 9)
; --
;   - ****REMEMBER THAT SPRITES ARE DRAWN WITH X=X BEING THE RIGHT MOST PIXEL****
;	- Inputs: `NONE`
;	- Outputs: `A` = `1` if solid, else `0`
;	- Destroys: `ALL`
; ==============================================
plr_collisionLeft:
    call plr_getPosition

    sub a, 16
    ld d, a

    ld a, -8 ; X - 8
    add a, e
    ld e, a
    
    ld a, d

    call plr_getCollision
    or a
    ret nz

    ; if we found a transparent tile, check another
    ; check (x - 8, y - 8)
    call plr_getPosition

    sub 9 ; Y - 9
    ld d, a

    ld a, -8
    add a, e
    ld e, a

    ld a, d

    jp plr_getCollision