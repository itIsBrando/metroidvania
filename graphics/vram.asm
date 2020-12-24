SECTION "GFX_TIMING", ROM0
; ==============================================
; waits until VBlank starts
;	- Destroys: `AF`
; ==============================================
gfx_waitVBlank:
	ldh a,[rLY]
	cp a, 144
	jr c, gfx_waitVBlank
	ret


; ==============================================
; waits until VRAM is readable
;	- Destroys: `AF`
; ==============================================
gfx_VRAMReadable:
	ldh a, [rLCDC]
	bit 7, a
	ret z
.loop:
	ldh a, [rSTAT]
	bit 1, a
	ret z
	jr .loop

; ==============================================
; Draws a string
; --
; - Inputs: `HL` = string pointer, `DE` = draw location
; - Destroys: `AF`, `B`+= string length, `DE`, `HL`
; ==============================================
gfx_drawString:
	call gfx_VRAMReadable
	ld a, [hl+]
	or a
	ret z
	ld [de], a
	inc de
	jr gfx_drawString


; ==============================================
; Draws a draw on multiple liens if necessary. Assumes scroll is 0
; --
;	- Inputs: `HL` = string pointer, `DE` = draw location
;	- Outputs: `NONE` <b>hello</b>
;	- Destroys: `ALL`
; ==============================================
gfx_drawStringWithOverflow:
	ld b, 0
.loop:
	call gfx_VRAMReadable
	ld a, [hl+]
	or a
	ret nz
	ld [de], a
	inc de
	inc b
	ld a, 20
	; if b = 20
	cp b
	call z, .newline
	jr .loop

.newline:
	push hl
	ld hl, 32 - 20 - 1
	add hl, de
	LD16 de, hl
	pop hl
	ret


; ==============================================
; Gets a tile color
; --
;	- Inputs: `HL` = pointer to tile, `E` = bit position
;	- Outputs: `A` = 0-3 for color number
;	- Destroys: `B`, `E`
; ==============================================
gfx_getColor:
	call gfx_VRAMReadable
	ld a, [hl+]
	ld b, [hl]
	dec hl

	; if e=0, skip loop
	dec e
	inc e
	jr z, .noLoop
.loop:
	srl a
	srl b
	dec e
	jr nz, .loop
.noLoop:

	; lower bit
	and $01
	ld e, a
	; upper bit
	sla b
	ld a, b
	and $02
	or e
	ret


; ==============================================
; Sets a tile color
; --
;	- Inputs: `HL` = pointer to tile, `E` = bit position (0-7), `B`=color (0-3)
;	- Outputs: `NONE`
;	- Destroys: `AF`, `BC`, `E`
; ==============================================
gfx_setColor:
	ld a, b
	srl b ; B = upper bit
	
	and $01 ; A = lower bit
	ld c, 1

	; if e=0, skip loop
	dec e
	inc e
	jr z, .noLoop
.loop:
	sla a
	sla b
	sla c ; mask for later
	dec e
	jr nz, .loop

.noLoop:
	ld e, a ; lower bit

	ld a, c
	cpl ; A = 111110111
	ld c, a

	call gfx_VRAMReadable
	ld a, c
	and [hl] ; apply mask
	or e
	ld [hl+], a

	call gfx_VRAMReadable
	ld a, [hl]
	and c
	or b
	ld [hl-], a
	ret
	

; does not work
gfx_replaceColor:
	; this code fills a tiles with color 2
	ld d, 8
    GET_TILE_PTR hl, $2
.outLoop:
    push de
    ld d, 7
.loop:
    ld e, d
    ld b, 2
    call gfx_setColor
    dec d
    jr nz, .loop

    pop de
    inc hl
    inc hl
    dec d
    jr nz, .outLoop
	ret