;-------------------------------------------------------------------------------
; All the graphics are stored in 1 bit per pixel format. This is to save space
; and faciliate conversion to Game Boy format with color manipulation on the fly.
; One tile can be reused with different color variations for any level.
;
; hl - VRAM address to copy to
; de - tile address to copy from
; b  - points to function to be used - _subs[b*2]
; c  - number of tiles to convert
;
; Since each tile is stored in 8 bytes it uses only 2 colors and needs to be 
; expanded to Game Boy format which is 16 bytes (bits in even bytes influence
; colors 0 and 1 and bits in odd bytes colors 2 and 3), Like this:
;
;      bits -  76543210
;              --------
; even byte - %00110100
;  odd byte - %01101101
;              |  | | |_ %00000010 = 2
;              |  | |_ %00000011 = 3
;              |  |_ %00000001 = 1
;              |_ %00000000 = 0
;
;    colors -  02312302 (eight pixels total)
;-------------------------------------------------------------------------------

bin2chr::
	push	hl			; store current value
	ld	hl,_subs		; table that contains offsets of all functions responsible for gfx conversion
	ld	a,b			; b is used as index for table above
	rlca				; each offset is 16 bits -> index must be multiplied by 2, rlca doesn't use carry flag value
	add	a,l			; hl = _subs + index
	jr	nc,_skip
	inc	h
_skip
	ld	l,a
	ld	a,(hl+)			; extract function offset
	ld	h,(hl)
	ld	l,a
	jp	hl			; execute it


_subs					; offsets to functions that deal with gfx conversion
	dw	_bg0fg1,_bg0fg2,_bg0fg3
	dw	_bg1fg0,_bg1fg2,_bg1fg3
	dw	_bg2fg0,_bg2fg1,_bg2fg3
	dw	_bg3fg0,_bg3fg1,_bg3fg2
	

_bg0fg1					; expand 1bpp to 2bpp w/out color change
	pop	hl
_1
	ld	a,(de)
	inc	de
	ld	(hl+),a			; 1st bitplane, colors 0 and 1, copy as is
	xor	a			; don't change colors
	ld	(hl+),a			; 2nd bitplane, colors 2 and 3
	ld	a,(de)                  ; repeat 8 times to create 1 tile
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_1			; next tile
	ret


_bg0fg2					; update fg color to 2, bg stays 0
	pop	hl
_2
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_2			; next tile
	ret


_bg0fg3					; update fg color to 3, bg stays 0
	pop	hl
_3
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_3			; next tile
	ret


_bg1fg0					; swap bg color with fg -> bg = 1, fg = 0
	pop	hl
_4
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_4			; next tile
	ret


_bg1fg2					; bg = 1, fg = 2
	pop	hl
_5
	ld	a,(de)
	ld	b,a
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	ld	b,a
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	ld	b,a
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	ld	b,a
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	ld	b,a
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	ld	b,a
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	ld	b,a
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	ld	b,a
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_5			; next tile
	ret


_bg1fg3					; bg = 1, fg = 3
	pop	hl
_6
	ld	b,$FF
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_6			; next tile
	ret


_bg2fg0					; bg = 2, fg = 0
	pop	hl
_7
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	xor	a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_7			; next tile
	ret


_bg2fg1					; bg = 2, fg = 1
	pop	hl
_8
	ld	a,(de)
	inc	de
	ld	(hl+),a
	cpl
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	cpl
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	cpl
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	cpl
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	cpl
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	cpl
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	cpl
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	cpl
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_8			; next tile
	ret


_bg2fg3					; bg = 2, fg = 3
	pop	hl
_9
	ld	b,$FF
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_9			; next tile
	ret


_bg3fg0					; bg = 3, fg = 0
	pop	hl
_10
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_10			; next tile
	ret


_bg3fg1					; bg = 3, fg = 1
	pop	hl
_11
	ld	b,$FF
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_11			; next tile
	ret


_bg3fg2					; bg = 3, fg = 2
	pop	hl
_12
	ld	b,$FF
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	ld	a,(de)
	inc	de
	cpl
	ld	(hl+),a
	ld	a,b
	ld	(hl+),a
	dec	c			; c holds number of tiles to convert
	jr	nz,_12			; next tile
	ret
