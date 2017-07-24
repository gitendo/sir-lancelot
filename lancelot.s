BANK0	group	$00

	lib	equ.inc

	HEADER	main, "SIR LANCELOT", DMG_ONLY, SGB_DISABLED, ROM, ROM_256K, SRAM_NONE, WORLD, $01

main:
	di
	ld	sp,WRAM_END
	call	init
_title
;	call	read_keypad
;	ld	a,b
;	bit	KEY_ST_BIT,a
;	jp	nz,_Start_BUTTON
;	jr	_wait

_stage
	call	prepare_stage

	ld	a,LCDC_ON | CHR_8000 | MAP_9800 | OBJ_16 | OBJ_ON | WIN_ON | WIN_9C00 | BG_ON
	ld	(LCDC),a

_loop
	call	wait_vbl
	call	oam_scroll_fix
	call	$FF80
	call	animate_ladder
	call	glow_items
	call	animate_foes
	call	move_foes
	call	timer
	ld	hl,time1
	ld	de,$9C31
	ld	bc,3
	call	printstr

	call	read_keypad

	call	colis
	jr	_loop


;-- helpers

timer:
	ld	a,(time4)
	inc	a
	and	%00000011
	ld	(time4),a

	cp	0
	ret	nz

	ld	hl,time3
;	ld	a,(hl)
;	inc	a
;	and	$0F
;	ld	(hl),a
;	ret	nz
;	dec	hl
	ld	a,(hl)
	dec	a
	bit	4,a
	jr	z,_1
	ld	(hl),a
	ret
_1
	dec	hl
	ld	a,(hl)
	dec	a
	bit	4,a
	jr	z,_2
	ld	(hl+),a	
	ld	a,$39
	ld	(hl),a
	ret
_2	
	dec	hl
	ld	a,(hl)
	dec	a
	bit	4,a
	jr	z,_3
	ld	(hl+),a
	ld	a,$39
	ld	(hl+),a
	ld	(hl),a
_3
	ret

;-------------------------------------------------------------------------------
colis:
;-------------------------------------------------------------------------------
	call	get_pos
	ld	a,(previous)
	and	KEY_L | KEY_R | KEY_A
	ld	(previous),a
	bit	KEY_L_BIT,a
	call	nz,move_left
	ld	a,(previous)		; ugly, fix it!
	bit	KEY_R_BIT,a
	call	nz,move_right
	ld	a,(previous)
	bit	KEY_A,a
	call	nz,jump
	call	fall
	ret

get_pos:
	ld	a,(oam_player_yl)	; scy fix not needed
	sub	16                      ; sprite fix
	srl	a                       ; /8
	srl	a
	srl	a
	ld	l,a
	ld	h,0
	sla	l                       ; *32
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h

	ld	a,(oam_player_xl)
	sub	8			; sprite fix
	ld	b,a
	ld	a,(SCX)
	add	a,b                     ; scx fix
	srl	a                       ; /8
	srl	a
	srl	a

	add	a,l
	jr	nc,_1
	inc	h
_1
	ld	(player_lo),a
	ld	a,h
	ld	(player_hi),a	
	ret

;-------------------------------------------------------------------------------
move_left:
;-------------------------------------------------------------------------------
	ld	a,(oam_player_attrl)	; flip x bit
	bit	5,a
	call	nz,player_flip        ; switch sprite halves

	ld	a,(player_lo)
	ld	l,a
	ld	a,(player_hi)
	ld	h,a
	ld	de,MAP0
	add	hl,de
_1
	ld	a,(STAT)
	bit	1,a
	jr	nz,_1

	ld	c,(hl)                  ; tile in 1st row
	ld	a,32			; next row
	add	a,l
	jr	nc,_2
	inc	h
_2
	ld	l,a
	ld	b,(hl)
	ld	a,$02
	cp	b
	ret	z
	cp	c
	ret	z

	ld	a,(oam_player_xl)	; move sprite till middle of the screen
	cp	$58
	jr	nc,_3

	ld	a,(scroll)              ; then move window
	cp	0
	jr	nz,_4
_3
	ld	a,(oam_player_xl)       ; then sprite again
	cp	$08                     ; left boundary
	ret	z
	dec	a
	ld	(oam_player_xl),a
	ld	a,(oam_player_xr)
	dec	a
	ld	(oam_player_xr),a
	ret

_4
	dec	a
	ld	(scroll),a
	ret

;-------------------------------------------------------------------------------
move_right:
;-------------------------------------------------------------------------------
	ld	a,(oam_player_attrr)	; flip x bit
	bit	5,a
	call	z,player_flip         ; switch sprite halves

	ld	a,(player_lo)
	ld	l,a
	ld	a,(player_hi)
	ld	h,a
	ld	de,MAP0+2		; right edge cheap fix
	add	hl,de
;	inc	hl
;	inc	hl
_1
	ld	a,(STAT)
	bit	1,a
	jr	nz,_1

	ld	c,(hl)                  ; tile in 1st row
	ld	a,32			; next row
	add	a,l
	jr	nc,_2
	inc	h
_2
	ld	l,a
	ld	b,(hl)
	ld	a,$02
	cp	b
	ret	z
	cp	c
	ret	z

	ld	a,(oam_player_xr)	; move sprite till middle of the screen
	cp	$58
	jr	c,_3

	ld	a,(scroll)              ; then move window
	cp	$60
	jr	nz,_4
_3
	ld	a,(oam_player_xr)       ; then sprite again
	cp	$A0                     ; right boundary
	ret	z
	inc	a
	ld	(oam_player_xr),a
	ld	a,(oam_player_xl)
	inc	a
	ld	(oam_player_xl),a
	ret
_4
	inc	a
	ld	(scroll),a
	ret

jump:
	ret

;-------------------------------------------------------------------------------
fall:
;-------------------------------------------------------------------------------
	ld	a,(jump_state)
	cp	0
	ret	nz

	ld	a,(oam_player_yl)	; scy fix not needed
	sub	16                      ; sprite fix
	srl	a                       ; /8
	srl	a
	srl	a
	ld	l,a
	ld	h,0
	sla	l                       ; *32
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h

	ld	a,(oam_player_xl)
;	sub	8			; sprite fix
	ld	b,a
	ld	a,(SCX)
	add	a,b                     ; scx fix
	srl	a                       ; /8
	srl	a
	srl	a

	add	a,l
	jr	nc,_0
	inc	h
_0
	ld	l,a

	ld	a,(oam_player_attrr)	; flip x bit
	bit	5,a
	jr	z,_11
	dec	hl
_11


;	ld	a,(player_lo)
;	ld	l,a
;	ld	a,(player_hi)
;	ld	h,a
	ld	de,MAP0+64		; bottom edge cheap fix
	add	hl,de
_1
	ld	a,(STAT)
	bit	1,a
	jr	nz,_1

	ld	b,(hl)                 ; tile in 1st row
	inc	l
	ld	c,(hl)
	ld	a,$02
	cp	b
	ret	z
	cp	c
	ret	z

	ld	a,(oam_player_yl)
	inc	a
	ld	(oam_player_yl),a
	ld	a,(oam_player_yr)
	inc	a
	ld	(oam_player_yr),a
	ret


;-------------------------------------------------------------------------------
player_flip:
;-------------------------------------------------------------------------------
	ld	hl,oam_player_tilel
	ld	de,oam_player_tiler
	ld	b,(hl)
	ld	a,(de)
	ld	(hl+),a
	ld	a,b
	ld	(de),a
	inc	e
	ld	a,(hl)
	xor	$20
	ld	(hl),a
	ld	(de),a
	ret

	
;-------------------------------------------------------------------------------
animate_foes:
;-------------------------------------------------------------------------------
	ld	hl,foe_anim_array
	ld	de,CHR_RAM+$100
	call	copy_frame
	ld	hl,foe_anim_array+4
	ld	de,CHR_RAM+$140
	call	copy_frame
	ld	hl,foe_anim_array+8
	ld	de,CHR_RAM+$180
	call	copy_frame
	ld	hl,foe_anim_array+12
	ld	de,CHR_RAM+$1C0
	call	copy_frame

	call	next_frame

	ld	hl,foe_array
	ld	bc,$C022
	ld	de,$C026
	call	obj_flip

	ld	hl,foe_array+4
	ld	bc,$C02A        
	ld	de,$C02E
	call	obj_flip

	ret

;-------------------------------------------------------------------------------
copy_frame:
;-------------------------------------------------------------------------------
	ld	a,(hl+)		; lo
	ld	c,a
	ld	a,(hl+)		; hi
	ld	b,a
	ld	a,(hl+)		; frame
	ld	l,c
	ld	h,b
	sla	a
	add	a,l
	jr	nc,_1
	inc	h
_1
	ld	l,a
	ld	a,(hl+)
	ld	c,a
	ld	h,(hl)
	ld	l,c
	ld	bc,64
	call	copy_vram
	ret

;-------------------------------------------------------------------------------
next_frame:
;-------------------------------------------------------------------------------
	ld	a,(delay)
	cp	0
	ret	nz

	ld	hl,foe_anim_array+2		; animation frame
	ld	c,4
_loop
	ld	a,(hl+)
	inc	a
	and	(hl)
	dec	l
	ld	(hl+),a
	inc	l
	inc	l
	inc	l
	dec	c
	jr	nz,_loop
	ret

;-------------------------------------------------------------------------------
move_foes:
;-------------------------------------------------------------------------------
	ld	hl,foe_array
	ld	de,$C021
_next
	ld	a,e
	cp	$41		; next oam row
	ret	z
	ld	a,(hl+)		; flag
	bit	4,a
	jr	nz,_right
	bit	5,a
	jr	nz,_left
	ret
_left
	and	$0F
	ld	c,a		; speed
	ld	a,(hl+)		; left boundary
	ld	b,a
	inc	l		; skip right boundary
	ld	a,(hl)		; x-pos
	sub	c
	ld	(hl),a		; x-pos
	cp	b
	jr	nz,_continue
	set	4,c		; switch to right
	jr	_flip

_right
	and	$0F
	ld	c,a		; speed
	inc	l		; skip left boundary
	ld	a,(hl+)		; right boundary
	ld	b,a
	ld	a,(hl)		; x-pos
	add	a,c
	ld	(hl),a		; x-pos
	cp	b
	jr	nz,_continue
	set	5,c		; switch to left

_flip
	dec	hl
	dec	hl
	dec	hl
	set	7,c		; switch flag
	ld	(hl),c
	inc	hl
	inc	hl
	inc	hl

_continue
	ld	(de),a	        ; oam x-pos 1/2
	add	a,8
	inc	e
	inc	e
	inc	e
	inc	e
	ld	(de),a	        ; oam x-pos 2/2
	inc	e
	inc	e
	inc	e
	inc	e
	inc	hl
	jr	_next	

;-------------------------------------------------------------------------------
obj_flip:
;-------------------------------------------------------------------------------
	ld	a,(hl)
	bit	7,a
	ret	z
	res	7,(hl)

	ld	a,(bc)
	ld	l,a
	ld	a,(de)
	ld	(bc),a
	ld	a,l
	ld	(de),a
	inc	c
	inc	e
	ld	a,(bc)
	xor	$20
	ld	(bc),a
	ld	a,(de)
	xor	$20
	ld	(de),a
	ret

;-------------------------------------------------------------------------------
oam_scroll_fix:
;-------------------------------------------------------------------------------
	ld	a,(scroll)
	cp	0
	ret	z

	ld	(SCX),a
	ld	b,a
	ld	c,7
	ld	de,$C001
	ld	hl,item_xy+1
	ld	a,(level)
	sla	a
	sla	a
	sla	a
	sla	a
	add	a,l
	jr	nc,_1
	inc	h
_1
	ld	l,a

_items
    	ld	a,(hl+)
	inc	hl
	sub	b
	ld	(de),a
	inc	e
	inc	e
	inc	e
	inc	e
	dec	c
	jr	nz,_items

	ld	c,8
_foes
	ld	a,(de)
	sub	b
	ld	(de),a
	inc	e
	inc	e
	inc	e
	inc	e
	dec	c
	jr	nz,_foes

	ret

;-------------------------------------------------------------------------------
printstr:
;-------------------------------------------------------------------------------
	ld	a,(STAT)
	bit	1,a
	jr	nz,printstr
_print
	ld	a,(hl+)
	ld	(de),a
	inc	de
	dec	c
	jr	nz,_print
	ret


;-------------------------------------------------------------------------------
glow_items:
;-------------------------------------------------------------------------------
	ld	a,(delay)
	cp	0
	ret	nz

	ld	a,(OBP1)
	add	a,$64
	ld	(OBP1),a

	ret

;-------------------------------------------------------------------------------
prepare_stage:
;-------------------------------------------------------------------------------
	ld	de,bg
	ld	a,(level)
	sla	a
	add	a,e
	jr	nc,_1
	inc	d
_1
	ld	e,a
	ld	a,(de)
	ld	l,a
	inc	de
	ld	a,(de)
	ld	h,a
	ld	de,CHR_RAM+$20
	ld	bc,16
	call	copy

	ld	hl,lancelot1
	ld	de,CHR_RAM+$40
	ld	bc,16*4
	call	copy

	ld	a,$39
	ld	(time1),a
	ld	(time2),a
	ld	(time3),a

	ld	de,items
	ld	a,(level)
	sla	a
	sla	a
	sla	a
	sla	a
	add	a,e
	jr	nc,_2
	inc	d
_2
	ld	e,a
	
	ld	b,$80
	ld	c,16
	call	copy_obj
	ld	b,$82
	ld	c,16
	call	copy_obj
	ld	b,$84
	ld	c,16
	call	copy_obj
	ld	b,$86
	ld	c,16
	call	copy_obj
	ld	b,$88
	ld	c,16
	call	copy_obj
	ld	b,$8A
	ld	c,16
	call	copy_obj
	ld	b,$8C
	ld	c,16
	call	copy_obj

	xor	a
	ld	hl,oam_array
	ld	bc,64			; oam + enemy tables
	call	clear	

	ld	hl,foe_bounds
	ld	a,(level)
	sla	a
	sla	a
	sla	a
	sla	a
	add	a,l
	jr	nc,_3
	inc	h
_3
	ld	l,a
	ld	de,foe_array
	ld	bc,16
	call	copy

	ld	hl,foes
	ld	a,(level)
	sla	a
	sla	a
	sla	a
	sla	a
	add	a,l
	jr	nc,_4
	inc	h
_4
	ld	l,a
	ld	de,foe_anim_array
	ld	bc,16
	call	copy

	call	items_oam
	call	foes_oam
	call	player_oam

	ret

;-------------------------------------------------------------------------------
player_oam:
;-------------------------------------------------------------------------------
	ld	hl,player
	ld	a,(level)
	sla	a
	sla	a
	add	a,l
	jr	nc,_1
	inc	h
_1
	ld	l,a
	ld	bc,oam_player_yl
	ld	de,oam_player_yr
	ld	a,(hl+)		; y
;	ld	(player_y),a
	ld	(bc),a
	ld	(de),a
	inc	c
	inc	e
	ld	a,(hl+)		; x
;	ld	(player_x),a
	ld	(bc),a
	add	a,8
	ld	(de),a
	inc	c
	inc	e
	ld	a,4		; tile
	ld	(bc),a
	ld	a,6
	ld	(de),a
	ld	a,(hl)		; direction
	or	0
	call	nz,player_flip
	ret

;-------------------------------------------------------------------------------
items_oam:
;-------------------------------------------------------------------------------
	ld	hl,item_xy
	ld	a,(level)
	sla	a
	sla	a
	sla	a
	sla	a
	add	a,l
	jr	nc,_1
	inc	h
_1
	ld	l,a

	ld	de,oam_array
	ld	b,$80
	ld	c,7
_loop
	ld	a,(hl+)		; y
	ld	(de),a
	inc	e
	ld	a,(hl+)		; x
	ld	(de),a
	inc	e
	ld	a,b
	inc	b
	inc	b
	ld	(de),a		; char
	inc	e
	ld	a,$10
	ld	(de),a		; pal
	inc	e
	dec	c
	jr	nz,_loop
	ret

;-------------------------------------------------------------------------------
foes_oam:
;-------------------------------------------------------------------------------
	ld	hl,foe_xy
	ld	a,(level)
	sla	a
	sla	a
	sla	a
	sla	a
	add	a,l
	jr	nc,_1
	inc	h
_1
	ld	l,a
	
	ld	de,oam_array+$20
	ld	b,$10		; starting tile
	ld	c,4
_loop
	push	hl
	ld	a,(hl+)		; y
	ld	(de),a
	inc	e
	ld	a,(hl+)		; x
	ld	(de),a
	inc	e
	ld	a,b
	inc	b
	inc	b
	ld	(de),a		; tile
	inc	e
	xor	a
	ld	(de),a		; pal
	inc	e
	pop	hl
	ld	a,(hl+)		; y
	ld	(de),a
	inc	e
	ld	a,(hl+)		; x
	add	a,8
	ld	(de),a
	inc	e
	ld	a,b
	inc	b
	inc	b
	ld	(de),a		; tile
	inc	e
	xor	a
	ld	(de),a		; pal
	inc	e
	dec	c
	jr	nz,_loop
	ret

;-------------------------------------------------------------------------------
; b (vram offset - hi byte, lo byte)
; c (copy size)
copy_obj:
;-------------------------------------------------------------------------------
	ld	a,(de)
	ld	l,a
	inc	de
	ld	a,(de)
	ld	h,a
	inc	de
	push	de
	ld	a,b
	and	$F0
	swap	a
	add	a,$80
	ld	d,a
	ld	a,b
	and	$0F
	swap	a
	ld	e,a
	xor	a
	ld	b,a
	call	copy
	pop	de	
	ret

;-------------------------------------------------------------------------------
animate_ladder:
;-------------------------------------------------------------------------------
	ld	hl,CHR_RAM+$10
	ld	e,l
	ld	d,h
	ld	a,(hl+)
	ld	b,a
	ld	c,$0F
_copy
	ld	a,(hl+)
	ld	(de),a
	inc	e
	dec	c
	jr	nz,_copy
	ld	a,b
	ld	(de),a
	ret
	
;-------------------------------------------------------------------------------
init:
;-------------------------------------------------------------------------------
	call	wait_vbl

	xor	a
	ld	(IF),a
	ld	(LCDC),a
	ld	(STAT),a
	ld	(SCX),a
	ld	(SCY),a
	ld	(LYC),a
	ld	(IE),a

	ld	a,$07
	ld	(WX),a
	ld	a,$80
	ld	(WY),a

	ld	a,$1B
	ld	(BGP),a
	ld	(OBP0),a
	xor	a
	ld	(OBP1),a

	call	copy_dma

	xor	a
	ld	hl,RAM
	ld	bc,$2000
	call	clear	

	xor	a
	ld	hl,VRAM
	ld	bc,$2000
	call	clear	

	ld	hl,bg0
	ld	de,CHR_RAM
	ld	bc,32
	call	copy

	ld	hl,font
	ld	de,CHR_RAM+$200
	ld	bc,1536
	call	copy

	ld	hl,map
	ld	de,MAP0
	ld	bc,576
	call	copy

	ld	hl,hud1
	ld	de,MAP1
	ld	bc,20
	call	copy

	ld	hl,hud2
	ld	de,MAP1+$20
	ld	bc,20
	call	copy

	ret

;-------------------------------------------------------------------------------
copy_dma:
;-------------------------------------------------------------------------------
	ld	b,$0A
	ld	c,$80
	ld	hl,_dmadata
_copy
	ld	a,(hl+)
	ld	(c),a
	inc	c
	dec	b
	jr	nz,_copy
	ret		
_dmadata
	db	$3E,$C0,$E0,$46,$3E,$28,$3D,$20,$FD,$C9 

;-------------------------------------------------------------------------------
wait_vbl:
;-------------------------------------------------------------------------------
	ld	a,(delay)
	inc	a
	and	%00000111
	ld	(delay),a
_wait
	ld	a,(LY)
	cp	$91
	jr	nz,_wait
	ret

;-------------------------------------------------------------------------------
clear:
;-------------------------------------------------------------------------------
	inc	b
	inc	c
	jr	_skip
_fill
	ld	(hl+),a
_skip
	dec	c
	jr	nz,_fill
	dec	b
	jr	nz,_fill
	ret

;-------------------------------------------------------------------------------	
copy:
;-------------------------------------------------------------------------------
	inc	b
	inc	c
	jr	_skip
_copy
	ld	a,(hl+)
	ld	(de),a
	inc	de
_skip
	dec	c
	jr	nz,_copy
	dec	b
	jr	nz,_copy
	ret

;-------------------------------------------------------------------------------	
copy_vram:
;-------------------------------------------------------------------------------
	inc	b
	inc	c
	jr	_skip
_copy
	ld	a,(STAT)
	bit	1,a
	jr	nz,_copy
	ld	a,(hl+)
	ld	(de),a
	inc	de
_skip
	dec	c
	jr	nz,_copy
	dec	b
	jr	nz,_copy
	ret

;-------------------------------------------------------------------------------
copy_fnt:	;delete or replace font w/ 1bpp
;-------------------------------------------------------------------------------
	inc	b
	inc	c
	jr	_skip
_copy
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a	
_skip
	dec	c
	jr	nz,_copy
	dec	b
	jr	nz,_copy
	ret

;-------------------------------------------------------------------------------
read_keypad:
;-------------------------------------------------------------------------------
        ld      a,$20		; P15 - read A,B,Select,Start
        ld      (P1),a        
        ld      a,(P1)		; delay
        ld      a,(P1)
	cpl
        and     $0f
	swap	a
	ld	b,a

        ld      a,$10		; P14 - read Up,Down,Left,Right
        ld      (P1),a
        ld      a,(P1)		; delay
        ld      a,(P1)
        ld      a,(P1)
        ld      a,(P1)
        ld      a,(P1)
        ld      a,(P1)
	cpl
        and     $0f
	or	b
        ld      b,a

	ld	a,(previous)
	xor	b
	and	b
	ld	(current),a
	ld	a,b
	ld	(previous),a
        push    af

	ld	a,$30
        ld      (P1),a

        ld      a,(current)
        ld      b,a
        pop     af
	ret
	
;-[ assets ]--------------------------------------------------------------------
	lib	graphics.s

bg:
	dw	bg9							; level 1
; y, x, direction (0-left, 1-right), 0
player:
	db	$58,$90,$00,$00
items:
	dw	itemD,item0,itemE,item5,itemC,itemB,itemA,0		; level 1
item_xy:
	dw	$0010,$B830,$E838,$E850,$E868,$6878,$B880,0		; level 1
foes:
	dw	pacman, $0300, bird, $0300, 0, 0, 0, 0			; level 1
foe_xy:
	dw	$1210,$2128,$0000,$0000					; level 1
; flag|speed, left, right, x
foe_bounds:
	db	$22,$08,$88,$12, $21,$20,$9C,$21, 0,0,0,0, 0,0,0,0	; level 1

hud1:
	db	"Lives: 3 Score: 0000"
hud2:
	db	"Items: 0/7 Time: 999"
		;01234567890123456789


BANK1	group	$01
	org	$4000
	nop
;-------------------------------------------------------------------------------
RAM	group	$00
	org	$C000
;-------------------------------------------------------------------------------
oam_array
oam_items	ds	8*4
oam_foes	ds	8*4
oam_player_yl		ds	1
oam_player_xl		ds	1
oam_player_tilel	ds	1
oam_player_attrl	ds	1
oam_player_yr		ds	1
oam_player_xr		ds	1
oam_player_tiler	ds	1
oam_player_attrr	ds	1
		ds	22*4
foe_array	ds	4*4
foe_anim_array	ds	4*4
level		ds	1
player_hi	ds	1
player_lo	ds	1
jump_state	ds	1
scroll		ds	1
delay		ds	1
previous	ds	1
current		ds	1
time1	ds	1
time2	ds	1
time3	ds	1
time4	ds	1