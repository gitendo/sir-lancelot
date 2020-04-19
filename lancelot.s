BANK0	group	$00

	lib	equ.inc

	HEADER	game, "SIR LANCELOT", DMG_ONLY, SGB_DISABLED, ROM, ROM_256K, SRAM_NONE, WORLD, $01

;-------------------------------------------------------------------------------
game::
;-------------------------------------------------------------------------------
	di
	ld	sp,$E000

	call	wait_vbl

	xor	a
	ld	(IF),a
	ld	(LCDC),a
	ld	(STAT),a
	ld	(SCX),a
	ld	(SCY),a
	ld	(LYC),a
	ld	(IE),a

	xor	a
	ld	hl,RAM
	ld	bc,$2000-2
	call	fill

	xor	a
	ld	hl,VRAM
	ld	bc,$2000
	call	fill

	xor	a
	ld	hl,WRAM
	ld	bc,WRAM_LENGTH
	call	fill

	call	copy_dma

	call	init
_loop
	jr	_loop

;-------------------------------------------------------------------------------
init::
;-------------------------------------------------------------------------------
	ld	a,$07
;	ld	(WX),a
	ld	a,$80
;	ld	(WY),a

	ld	a,%00011011	;$1B
	ld	(BGP),a
	ld	(OBP0),a
	xor	a
	ld	(OBP1),a

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

	ld	hl,hud
	ld	de,MAP1
	ld	bc,20
	call	copy

	ld	hl,hud+20
	ld	de,MAP1+$20
	ld	bc,20
	call	copy

	ret


;-------------------------------------------------------------------------------
wait_vbl::
;-------------------------------------------------------------------------------
	ld	a,(LY)
	cp	$90
	jr	nz,wait_vbl
	ret


;-------------------------------------------------------------------------------
copy_dma::
;-------------------------------------------------------------------------------
	ld	b,dma_proc_end-dma_proc_start
	ld	c,<WRAM
	ld	hl,dma_proc_start
_copy
	ld	a,(hl+)
	ld	(c),a
	inc	c
	dec	b
	jr	nz,_copy
	ret		

dma_proc_start:
	ld	a,>RAM
	ld	(DMA),a
	ld	a,40
_transfer
	dec	a
	jr	nz,_transfer
	ret
dma_proc_end:	


;-------------------------------------------------------------------------------
; fills bc bytes at hl with a value
fill::
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
; copy bc bytes from hl to de
copy::
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
; read keypad, c = btn_trg (debounced), b = btn_cnt (continuous)
read_input:
;-------------------------------------------------------------------------------
	ld	a,$20
	ld	c,<P1
	ld	(c),a
	ld	a,(c)
	ld	a,(c)
	cpl
	and	$0f
	swap	a
	ld	b,a
	ld	a,$10
	ld	(c),a
	ld	a,(c)
	ld	a,(c)
	ld	a,(c)
	ld	a,(c)
	ld	a,(c)
	ld	a,(c)
	cpl
	and	$0f
	or	b
	ld	b,a

	ld	a,$30
	ld	(c),a

	ld	hl,btn_cnt
	ld	a,(hl+)
	xor	b
	and	b
	ld	(hl-),a
	ld	c,a
	ld	(hl),b
	ret

;-------------------------------------------------------------------------------
bg0:
	libbin	dmg\bg.chr

font:
	libbin	dmg\font.chr

map:
	libbin	dmg\levels.map

hud:
		;01234567890123456789
	db	"Lives: 3 Score: 0000"
	db	"Items: 0/7 Time: 999"


;-------------------------------------------------------------------------------
VAR1	group	$00
	org	RAM
;-------------------------------------------------------------------------------
oam_tbl:
	ds	40


;-------------------------------------------------------------------------------
VAR2	group	$00
	org	WRAM
;-------------------------------------------------------------------------------
btn_cnt:
	ds	1	
btn_trg:
	ds	1