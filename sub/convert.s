;-------------------------------------------------------------------------------
; All the graphics are stored in 1 bit per pixel format. This is to save space
; and faciliate conversion to Game Boy format with color manipulation on the fly.
; One tile can be reused with different color variations for any level.
;
; hl - VRAM address to copy to
; de - tile address to copy from
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
	
bg0fg1:					; expand 1bpp to 2bpp w/out color change
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
	jr	nz,bg0fg1		; next tile
	ret

bg0fg2:					; update fg color to 2, bg stays 0
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
	jr	nz,bg0fg2		; next tile
	ret

bg0fg3:					; update fg color to 3, bg stays 0
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
	jr	nz,bg0fg3		; next tile
	ret

bg1fg0:					; swap bg color with fg -> bg = 1, fg = 0
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
	jr	nz,bg1fg0		; next tile
	ret

bg1fg2:					; bg = 1, fg = 2
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
	jr	nz,bg1fg2		; next tile
	ret

bg1fg3:					; bg = 1, fg = 3
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
	jr	nz,bg1fg3		; next tile
	ret

bg2fg0:					; bg = 2, fg = 0
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
	jr	nz,bg2fg0		; next tile
	ret

bg2fg1:					; bg = 2, fg = 1
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
	jr	nz,bg2fg1		; next tile
	ret

bg2fg3:					; bg = 2, fg = 3
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
	jr	nz,bg2fg3		; next tile
	ret

bg3fg0:					; bg = 3, fg = 0
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
	jr	nz,bg3fg0		; next tile
	ret

bg3fg1:					; bg = 3, fg = 1
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
	jr	nz,bg3fg1		; next tile
	ret

bg3fg2:					; bg = 3, fg = 2
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
	jr	nz,bg3fg2		; next tile
	ret
