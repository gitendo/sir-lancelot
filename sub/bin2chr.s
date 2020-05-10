;-------------------------------------------------------------------------------
bin2chr:
;-------------------------------------------------------------------------------
; Convert DMG graphics data - 1bpp to 2bpp with color manipulation on the fly.
; It allows to reuse the same character(s), different color variation for any
; level.
;
; hl - dst
; de - src
; b - bg/fg color stored in nibbles
; c - chars to convert
;-------------------------------------------------------------------------------
	xor	a
	cp	b
	ret	nz
_expand					; 1bpp to 2bpp w/out color change
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
	xor	a
	ld	(hl+),a
	dec	c
	jr	nz,_expand
	ret
