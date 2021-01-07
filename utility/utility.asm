SECTION "UTILITY", ROM0

; ; ==============================================
; ; sets the `isCGB` flag if played on a CGB
; ; - Inputs: `A` = output of bootROM
; ; - Outpus: `NONE`
; ; - Destroys: `F`, `HL`
; ; ==============================================
; utl_getCGB:
;     ld hl, isCGB
;     ld [hl], 0
;     cp $11
;     ret nz
;     ld [hl], a
;     ret

; ; ==============================================
; ; sets the `isGBA` flag if played on a GBA
; ; - Inputs: `B` = output of bootROM
; ; - Outpus: `NONE`
; ; - Destroys: `HL`
; ; ==============================================
; utl_getGBA:
;     ld hl, isGBA
;     ld [hl], 0
;     bit 0, b
;     ret z
;     ld [hl], b
;     ret

; ==============================================
; Calls the value inside of `HL`
; --
;	- you must call this function for the return value to be correct
;	- Inputs: `HL` = address to jump to
;	- Outputs: `NONE`
;	- Destroys: `NONE`
; ==============================================
utl_callHL:
	jp hl


; ==============================================
; prevent some keys from latching. useful to prevent the same key
; from being recognized multiple times
; - Inputs: `A` = joypad
; - Outpus: `A` = masked joypad
; - Destroys: `F`, `BC`, `E`, `HL`
; ==============================================
utl_maskJoypad:

    ; re enables the mask bits if the key is let go
    ld hl, joypadMask
    ld b, 8
    ld c, 1
.maskLoop:
    ld e, a
    and a, c
    or a
    jr nz, .dontEnableMask
    ld a, c
    or a, [hl]
    ld [hl], a
.dontEnableMask:
    ld a, e
    sla c
    dec b
    jr nz, .maskLoop


    and [hl]
	ld [key], a
	ret


; ==============================================
; the part that is put in HRAM and stuff
; - Destroys: `AF`
; ==============================================
dma_routine:
	ld a, DMA_ADDRESS >> 8
	ldh [rDMA], a
	; initiate a wait
	ld a, $28
.wait:
	dec a
	jr nz, .wait
	ret
dma_routine_end:

; ==============================================
;	enables cart RAM at $A000-$A7FF for reading/writing
;	- Destroys: `AF`
; ==============================================
ram_enable:
	ld a, $0A
	ld [0000], a
	ret


; ==============================================
;	disables cart RAM
;	- Destroys: `F`, `A` = 0
; ==============================================
ram_disable:
	xor a
	ld [0000], a
	ret

; ==============================================
; Copies the value in `DE` into `HL`
; --
;	- `ld [hl], de`
;	- Inputs: `HL` = 2 byte RAM, `DE` = pointer to write
;	- Outputs: `NONE`
;	- Destroys: `NONE`
; ==============================================
utl_write_DE_to_HL:
    ld [hl], e
    inc hl
    ld [hl], d
    dec hl
    ret
    

; ==============================================
;	Returns a psuedorandom number into `HL`, `A` = `L`
;	- Destroys: `AF`
; ==============================================
math_xrnd:
	ld hl, math_seed
	ld a, [hl+]     ; seed must not be 0
	ld h, [hl]
	ld l, a

	ld a,h
	rra
	ld a,l
	rra
	xor h
	ld h,a
	ld a,l
	rra
	ld a,h
	rra
	xor l
	ld l,a
	xor h
	ld h,a

	; re-randomize seed
	
	ld [math_seed], a
	ld a, l
	ld [math_seed + 1], a
    ret


; ==============================================
; Calls a routine a certain number of times given a table of pointers
; --
;	- each routine call will have the following inputs: `A` = index, `B` = number left to iterate through, `HL` = pointer to entry in table
;	- Inputs: `HL` = pointer to table, `DE` = pointer to service routine, `A` = number of times to run
;	- Outputs: `NONE`
;	- Destroys: `ALL`
; ==============================================
util_forloop:
    or a
    ret z

    push af ; save counter
    push hl ; save pointer to table

    ld a, $C3
    ; store instruction and JP instruction
    ld hl, ent_call_buffer
    ld [hl+], a
    call utl_write_DE_to_HL

    pop hl ; HL = pointer to table
    pop bc ; B = counter
	xor a
.loop:

    push hl
    push bc
	push af

	ld e, [hl]
	inc hl
	ld h, [hl]
	ld l, e

    call ent_call_buffer

	pop af
    pop bc
    pop hl

	inc a
    inc hl
    inc hl

    dec b
    jr nz, .loop

    ret


; ==============================================
; fetches D-PAD data into upper word of `A`
; and BTNs into lower word
;	- Destroys: `AF`, `C`
; ==============================================
utl_scanJoypad:
	ld a, P1F_GET_DPAD
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0F
	swap a
	ld c, a
	ld a, P1F_GET_BTN
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0F	
	or c
	ld [key], a
	ret

; ==============================================
; copies data from `HL` to `DE` with a size of `BC`
;	- Destroys: `AF`, `BC`, `DE`, `HL`
; ==============================================
mem_copy:
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or a, c
	jr nz, mem_copy
	ret


; ==============================================
; copies data from `HL` to `DE` with a size of `BC`
;	- `HL` or `DE` can be in VRAM
;	- Destroys: `AF`, `BC`, `DE`, `HL`
; ==============================================
mem_copy_VRAM:
	call gfx_VRAMReadable
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or a, c
	jr nz, mem_copy
	ret


; ==============================================
; clears data from `HL` with a size of `BC` using `A`
;	- Destroys: `AF`, `BC`, `HL`, `D`
; ==============================================
mem_set:
	ld d, a
.loop:
	ld [hl], d
	inc hl
	dec bc
	ld a, b
	or a, c
	jr nz, .loop
	ret


; ==============================================
; Lookups up index `A` in the LUT in `DE`
; --
;	- Inputs: `A` = index, `DE` = 1 byte table
;	- Outputs: `A` = item
;	- Destroys: `DE`
; ==============================================
utl_lookup_A:
	push hl
    ld h, 0
    ld l, a
    add hl, de
    ld a, [hl]
    pop hl
	ret