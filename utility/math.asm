SECTION "MATH", ROM0


; ==============================================
; Multiplies A by 10
; --
;	- Inputs: `A` = number
;	- Outputs: `A` *= 10
;	- Destroys: `E`
; ==============================================
math_mult_A_10:
    add a, a
    ld e, a
    add a, a
    add a, a
    add a, e
    ret 


; ==============================================
; Multiplies A by 12
; --
;	- Inputs: `A` = number
;	- Outputs: `A` *= 12
;	- Destroys: `E`
; ==============================================
math_mult_A_12:
    add a, a
    ld e, a
    add a, a
    add a, a
    add a, e
    add a, e
    ret 


; ==============================================
; 8-bit division from wikiTi by Xeda from cemetech. Does `D`/`E`
; - Outputs: `A` = remainder, `D` = result
; - Destroys: `F`, `B`, `E`
; ==============================================
math_div_D_E:
   xor	a
   ld	b, 8

.loop:
   sla	d
   rla
   cp	e
   jr	c, @+4
   sub	e
   inc	d
   
   dec b
   jr nz, .loop
   ret


; ==============================================
; 16 by 8 multiplication from wikiTi Does `DE`*`A`
; - Outputs: `AHL` = product
; - Destroys: `ALL?`
; ==============================================
math_mult_A_DE:
   ld	c, 0
   ld	h, c
   ld	l, h

   add	a, a		; optimised 1st iteration
   jr	nc, @+4
   ld	h,d
   ld	l,e

   ld b, 7
.loop:
   add	hl, hl
   rla
   jr	nc, @+4
   add	hl, de
   adc	a, c            ; yes this is actually adc a, 0 but since c is free we set it to zero and so we can save 1 byte and up to 3 T-states per iteration
   
   dec b
   jr nz, .loop
   
   ret

; ==============================================
; does a '16-bit' `AND` of `HL` and `DE`
;	- Ouputs: `HL` = HL & DE
;	- Destroys: `AF`
; ==============================================
math_and_HL_DE:
	ld a, h
	and d
	ld h, a
	ld a, l
	and e
	ld l, a
	ret

