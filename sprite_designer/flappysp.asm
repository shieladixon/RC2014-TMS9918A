; TMS9918A Sprite example
; by S Dixon

#define CLASSIC 1			; 0 for CPM



OFFSCREEN_Y:		equ $e1
NO_MORE_SPRITES:	equ $d0

#define SCALING 1

; these values are for the sprite attribute 'name' field, the third byte in each sprite's attributes, a reference to the sprite pattern data
; it's a quirk of the chip that these go in fours. (kinda makes sense because there are 4 'characters' in each 16x16 sprite pattern)

SPRITE_PATTERN_NAME_DOWNFLAP_BLACK:		equ 0
SPRITE_PATTERN_NAME_DOWNFLAP_WHITE:		equ 4
SPRITE_PATTERN_NAME_DOWNFLAP_YELLOW:		equ 8
SPRITE_PATTERN_NAME_DOWNFLAP_RED:		equ 12

SPRITE_PATTERN_NAME_MIDFLAP_BLACK:		equ 16
SPRITE_PATTERN_NAME_MIDFLAP_WHITE:		equ 20
SPRITE_PATTERN_NAME_MIDFLAP_YELLOW:		equ 24
SPRITE_PATTERN_NAME_MIDFLAP_RED:		equ 28

SPRITE_PATTERN_NAME_UPFLAP_BLACK:		equ 32
SPRITE_PATTERN_NAME_UPFLAP_WHITE:		equ 36
SPRITE_PATTERN_NAME_UPFLAP_YELLOW:		equ 40
SPRITE_PATTERN_NAME_UPFLAP_RED:			equ 44



VsyncDiv:       		equ 6                           ; number of interrupts per animation frame
SpritePatternCount:		equ 12                           ; number of frames in animation * number of overlaid sprites = 3 * 4
SpriteAttrCount:    	equ 4 

AnimationDelay: equ $0070





#target BIN


#if CLASSIC
#code PAGE1,$8000
	        org     8000h
#else
#code PAGE1,$0100
	        org     100h
			
	        ld      (OldSP),sp                      ; save old Stack poitner
	        ld      sp, Stack                       ; set up Stack
#endif


        call    TmsProbe                        ; find what port TMS9918A listens on
        jp      z, NoTms

        call    TmsBitmap                       ; initialize screen

		; load in the sc2 file 
		
		ld hl,the_image+7
		ld de,(TmsPatternAddr)
		ld bc,$1800
		; copy bytes from ram to vram
		;       HL = ram source address
		;       DE = vram destination address
		;       BC = byte count
		call TmsWrite
		
		
		ld hl,the_image+$1807
		ld de,(TmsNameAddr)
		ld bc,$300
		call TmsWrite		
		

		ld hl,the_image+$2007	; 8192+7
		ld de,(TmsColorAddr)
		ld bc,$1800
		call TmsWrite
		
		
		

        ld      a, TmsSprite32					; perhaps misnamed - TmsSprite32 selects 16x16 sprites, otherwise 8x8
												; 'or' it with TmsSpriteMag for magnified sprites
				
#if SCALING								
		or 		a,TmsSpriteMag									
#endif												
        call    TmsSpriteConfig

		
		
		call all_sprites_off
		call update_sprite_patterns				; copy sprite patterns to VRAM. should only need doing once

		call init_sprite_pos					; sets sinetable to start



main_loop:
		
		call    keypress                        ; exit on keypress
        jp      nz, Exit




		ld de,AnimationDelay
		call pause_DE
		call wait_till_vblank
		
			call set_attrs_downflap
			call update_sprite_attrs				; copy new positions to VRAM
				
			call update_sprite_pos
		
		ld de,AnimationDelay
		call pause_DE
		call wait_till_vblank
		
			call set_attrs_upflap
			call update_sprite_attrs				; copy new positions to VRAM
		
			call update_sprite_pos
		
		ld de,AnimationDelay
		call pause_DE
		call wait_till_vblank
		
			call set_attrs_midflap
			call update_sprite_attrs				; copy new positions to VRAM

			call update_sprite_pos
		

		
		
        jp      main_loop


Exit:
#if CLASSIC
		ret
#else
		ld      sp, (OldSP)
        	rst     0
#endif




wait_till_vblank:
		ld b,200
smallpause:
		djnz smallpause
		
        call    TmsRegIn                        ; only update during vsync
        jp      p, wait_till_vblank

		ret





NoTmsMessage:
        defb    "TMS9918A not found, aborting!$"
NoTms:  ld      de, NoTmsMessage
        call    strout
        jp      Exit

        include "tms32.asm"
        include "utility32.asm"

VsyncCount:
        defb    VsyncDiv                        ; vsync down counter
CurrSprite:
        defb    0                               ; current sprite frame


XDelta1:
        defb    1                               ; direction horizontal motion
YDelta1:
        defb    1                               ; direction vertical motion


XDelta2:
        defb    $1                               ; direction horizontal motion
YDelta2:
        defb    $ff                               ; direction vertical motion



XDelta3:
        defb    1                               ; direction horizontal motion
YDelta3:
        defb    1                               ; direction vertical motion


XDelta4:
        defb    $1                               ; direction horizontal motion
YDelta4:
        defb    $ff                               ; direction vertical motion



XDelta5:
        defb    1                               ; direction horizontal motion
YDelta5:
        defb    1                               ; direction vertical motion


XDelta6:
        defb    $1                               ; direction horizontal motion
YDelta6:
        defb    $ff                               ; direction vertical motion



XDelta7:
        defb    1                               ; direction horizontal motion
YDelta7:
        defb    1                               ; direction vertical motion


XDelta8:
        defb    $1                               ; direction horizontal motion
YDelta8:
        defb    $ff                               ; direction vertical motion



; functions


update_sprite_patterns:
        ld      bc, SpritePatternCount*32            ; set up sprite patterns
        ld      de, (TmsSpritePatternAddr)
        ld      hl, SpritePatterns
        call    TmsWrite

		ret

		
update_sprite_attrs:
        ld      bc, SpriteAttrCount*4  					; 8 4's                           ; update sprite attribute table
        ld      de, (TmsSpriteAttrAddr)
        ld      hl, Sprite1Y
        call    TmsWrite

		ret

; more functions

all_sprites_off:
		
		ret

		;OFFSCREEN_Y
		ld b,32			; all sprites
		ld hl,Sprite1Y

aso_lp:		
		ld (HL),OFFSCREEN_Y
		inc hl
		inc hl
		inc hl
		ld (hl),0	; transparent
		inc hl		; next y
		
		djnz aso_lp
		
		ret




ypos: defb 00
xpos: defb 32

sintable: 		defb -4
			defb -3
			defb -2
			defb -2
			defb -2
			defb -2
			defb -2
			defb -2
			defb -1
			defb -1
			defb -1
			defb 0
			defb 0
			defb 0
			defb 0
			defb 1
			defb 1
			defb 1
			defb 2
			defb 2
			defb 2
			defb 2
			defb 2
			defb 2
			defb 3
			defb 4,$80



sintable_ptr: defw $0000

init_sprite_pos:
		ld hl,sintable
		ld (sintable_ptr),hl
		
		ld a,80
		ld (ypos),a

		
		ret



update_sprite_pos:
		;inc sintable_ptr
		ld hl,(sintable_ptr)
		inc hl
		ld (sintable_ptr),hl

		ld a,(hl)
		cp $80
		call z,init_sprite_pos
		
		; in case we did that
		ld hl,(sintable_ptr)
		ld a,(hl)
		
		ld b,a
		ld a,(ypos)
		add b
		ld (ypos),a

	
		ret




; yeah, there are more efficient ways to do this....

set_attrs_downflap:
		
		;call all_sprites_off
		
		call setSpriteLimit
		
		ld hl,Sprite1Y
		
				
		; black
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_DOWNFLAP_BLACK	; name
		inc hl
		ld (hl),TmsBlack
		inc hl
	
		
		; white
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_DOWNFLAP_WHITE	; name
		inc hl
		ld (hl),TmsWhite
		inc hl
			
		
		; yellow
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_DOWNFLAP_YELLOW	; name
		inc hl
		ld (hl),TmsDarkYellow
		inc hl		

		
		; red
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_DOWNFLAP_RED	; name
		inc hl
		ld (hl),TmsDarkRed
		inc hl
		
		
		ret



set_attrs_upflap:
		
		;call all_sprites_off
		
		call setSpriteLimit
		
		ld hl,Sprite1Y
		
				
		; black
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_UPFLAP_BLACK	; name
		inc hl
		ld (hl),TmsBlack
		inc hl
	
		
		; white
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_UPFLAP_WHITE	; name
		inc hl
		ld (hl),TmsWhite
		inc hl
			
		
		; yellow
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_UPFLAP_YELLOW	; name
		inc hl
		ld (hl),TmsDarkYellow
		inc hl		

		
		; red
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_UPFLAP_RED	; name
		inc hl
		ld (hl),TmsDarkRed
		inc hl
		
		
		ret
		
		
		
		
		
		
set_attrs_midflap:
		
		;call all_sprites_off
		
		call setSpriteLimit
		
		ld hl,Sprite1Y
		
				
		; black
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_MIDFLAP_BLACK	; name
		inc hl
		ld (hl),TmsBlack
		inc hl
	
		
		; white
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_MIDFLAP_WHITE	; name
		inc hl
		ld (hl),TmsWhite
		inc hl
			
		
		; yellow
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_MIDFLAP_YELLOW	; name
		inc hl
		ld (hl),TmsDarkYellow
		inc hl		

		
		; red
		ld a,(ypos)
		ld (hl),a	; y
		inc hl
		ld a,(xpos)
		ld (hl),a	; x
		inc hl
		ld (hl),SPRITE_PATTERN_NAME_MIDFLAP_RED	; name
		inc hl
		ld (hl),TmsDarkRed
		inc hl
		

		
		
		ret



setSpriteLimit:
		ld hl,Sprite5Y		; we want to use 4 sprites, set Y of 5 to D0
		ld (hl),NO_MORE_SPRITES
		ret


OldSP:
        defw    0
        defs    32
Stack:


; Sprite Attributes
Sprite1Y:
        defb OFFSCREEN_Y
Sprite1X:
        defb 0
Sprite1Name:
        defb 21*4
Sprite1Color: 
        defb TmsBlack
		
Sprite2Y:
        defb OFFSCREEN_Y
Sprite2X:
        defb 0
Sprite2Name:
        defb 21*4
Sprite2Color:
        defb TmsWhite
			
; Sprite Attributes
Sprite3Y:
        defb OFFSCREEN_Y
Sprite3X:
        defb 0
Sprite3Name:
        defb 21*4
Sprite3Color: 
        defb TmsDarkYellow
		
Sprite4Y:
        defb OFFSCREEN_Y
Sprite4X:
        defb 0
Sprite4Name:
        defb 21*4
Sprite4Color:
        defb TmsDarkRed
		
		

; Sprite Attributes
Sprite5Y:
        defb OFFSCREEN_Y
Sprite5X:
        defb 0
Sprite5Name:
        defb 21*4
Sprite5Color: 
        defb TmsDarkBlue
		
Sprite6Y:
        defb OFFSCREEN_Y
Sprite6X:
        defb 0
Sprite6Name:
        defb 21*4
Sprite6Color:
        defb TmsLightGreen
		
		
		
; Sprite Attributes
Sprite7Y:
        defb OFFSCREEN_Y
Sprite7X:
        defb 0
Sprite7Name:
        defb 21*4
Sprite7Color: 
        defb TmsDarkBlue
		
Sprite8Y:
        defb OFFSCREEN_Y
Sprite8X:
        defb 0
Sprite8Name:
        defb 21*4
Sprite8Color:
        defb TmsLightGreen		
		
		
		
; Sprite Attributes
Sprite9Y:
        defb OFFSCREEN_Y
Sprite9X:
        defb 0
Sprite9Name:
        defb 21*4
Sprite9Color: 
        defb TmsDarkBlue
		
SpriteAY:
        defb OFFSCREEN_Y
SpriteAX:
        defb 0
SpriteAName:
        defb 21*4
SpriteAColor:
        defb TmsLightGreen
		
		
		
; Sprite Attributes
SpriteBY:
        defb OFFSCREEN_Y
SpriteBX:
        defb 0
SpriteBName:
        defb 21*4
SpriteBColor: 
        defb TmsDarkBlue
		
SpriteCY:
        defb OFFSCREEN_Y
SpriteCX:
        defb 0
SpriteCName:
        defb 21*4
SpriteCColor:
        defb TmsLightGreen
		
		

; Sprite Attributes
SpriteDY:
        defb OFFSCREEN_Y
SpriteDX:
        defb 0
SpriteDName:
        defb 0
SpriteDColor: 
        defb TmsDarkBlue
		
SpriteEY:
        defb 154
SpriteEX:
        defb 0
SpriteEName:
        defb 21*4
SpriteEColor:
        defb TmsLightGreen
		
		
		
; Sprite Attributes
SpriteFY:
        defb OFFSCREEN_Y
SpriteFX:
        defb 0
SpriteFName:
        defb 21*4
SpriteFColor: 
        defb TmsDarkBlue
		
SpriteGY:
        defb OFFSCREEN_Y
SpriteGX:
        defb 0
SpriteGName:
        defb 21*4
SpriteGColor:
        defb TmsLightGreen	
		
		
; Sprite Attributes
SpriteHY:
        defb OFFSCREEN_Y
SpriteHX:
        defb 0
SpriteHName:
        defb 21*4
SpriteHColor: 
        defb TmsDarkBlue
		
SpriteIY:
        defb OFFSCREEN_Y
SpriteIX:
        defb 0
SpriteIName:
        defb 21*4
SpriteIColor:
        defb TmsLightGreen			
		
; Sprite Attributes
SpriteJY:
        defb OFFSCREEN_Y
SpriteJX:
        defb 0
SpriteJName:
        defb 21*4
SpriteJColor: 
        defb TmsDarkBlue
		
SpriteKY:
        defb OFFSCREEN_Y
SpriteKX:
        defb 0
SpriteKName:
        defb 21*4
SpriteKColor:
        defb TmsLightGreen			
		

SpriteLY:
        defb OFFSCREEN_Y
SpriteLX:
        defb 0
SpriteLName:
        defb 21*4
SpriteLColor:
        defb TmsLightGreen



SpritePatterns:

; frame 1:

; sprite pattern 1 - black
        defb 0,3,12,16,32,64,64,124
        defb 130,132,136,120,7,0,0,0
        defb 0,240,72,132,138,138,66,63
        defb 65,191,65,62,192,0,0,0
; sprite pattern 2 - white
        defb 0,0,0,0,0,0,0,0
        defb 124,120,112,0,0,0,0,0
        defb 0,0,48,120,116,116,60,0
        defb 0,0,0,0,0,0,0,0
; sprite pattern 3 - dark yellow
        defb 0,0,3,15,31,63,63,3
        defb 1,3,15,15,0,0,0,0
        defb 0,0,128,0,0,0,128,192
        defb 128,0,128,192,0,0,0,0
; sprite pattern 4 - dark red
        defb 0,0,0,0,0,0,0,0
        defb 0,0,0,0,0,0,0,0
        defb 0,0,0,0,0,0,0,0
        defb 63,64,62,0,0,0,0,0

; frame 2:

; sprite pattern 1 - black
        defb 0,3,12,16,32,64,64,124
        defb 130,252,32,24,7,0,0,0
        defb 0,240,72,132,138,138,66,63
        defb 65,191,65,62,192,0,0,0
; sprite pattern 2 - white
        defb 0,0,0,0,0,0,0,0
        defb 124,0,0,0,0,0,0,0
        defb 0,0,48,120,116,116,60,0
        defb 0,0,0,0,0,0,0,0
; sprite pattern 3 - dark yellow
        defb 0,0,3,15,31,63,63,3
        defb 1,3,31,15,0,0,0,0
        defb 0,0,128,0,0,0,128,192
        defb 128,0,128,192,0,0,0,0
; sprite pattern 4 - dark red
        defb 0,0,0,0,0,0,0,0
        defb 0,0,0,0,0,0,0,0
        defb 0,0,0,0,0,0,0,0
        defb 63,64,62,0,0,0,0,0

; frame 3:

; sprite pattern 1 - black
        defb 0,3,12,16,32,64,120,132
        defb 130,124,32,24,7,0,0,0
        defb 0,240,72,132,138,138,66,63
        defb 65,191,65,62,192,0,0,0
; sprite pattern 2 - white
        defb 0,0,0,0,0,0,0,120
        defb 124,0,0,0,0,0,0,0
        defb 0,0,48,120,116,116,60,0
        defb 0,0,0,0,0,0,0,0
; sprite pattern 3 - dark yellow
        defb 0,0,3,15,31,63,7,3
        defb 1,3,31,15,0,0,0,0
        defb 0,0,128,0,0,0,128,192
        defb 128,0,128,192,0,0,0,0
; sprite pattern 4 - dark red
        defb 0,0,0,0,0,0,0,0
        defb 0,0,0,0,0,0,0,0
        defb 0,0,0,0,0,0,0,0
        defb 63,64,62,0,0,0,0,0
	
		
		
 
SpritePatternLen: equ $-SpritePatterns

the_image:
		incbin "background-day.sc2"

