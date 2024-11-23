Code    Segment
        assume CS:Code, DS:Data, SS:Stack

Start:
        mov ax, Code
        mov DS, AX
		
ShowMenu:
        ; Set text mode
        mov ax, 03h
        int 10h
		
        ; Display menu text
        mov ah, 09h
        mov dx, offset MenuTitle
        int 21h
		
		xor bx, bx
        xor dx, dx
		mov ah, 02h ; set cursor pos
        mov dh, 1 ; row
        int 10h
		
		mov ah, 09h
        mov dx, offset MenuOption1
        int 21h
		
		xor bx, bx
        xor dx, dx
		mov ah, 02h ; set cursor pos
        mov dh, 2 ; row
        int 10h
		
		mov ah, 09h
        mov dx, offset MenuOption2
        int 21h

MenuLoop:
        ; Get key input
        mov ah, 00h
        int 16h
        
        cmp al, '1'
        je Game
        cmp al, '2'
        je Exit1
        jmp MenuLoop

Exit1:
        jmp Exit2

Game:
        ; switch display mode
        mov ax, 13h
        int 10h
        ; switch display mode

        mov ax, 0a000h ; set video starting address
        mov es, ax ; extra segment

        mov dx, 0
        push dx ; add time to stack
        
        mov dl, 1
        mov di, offset p1Dir ; set p1 direction 0=up, 1=right, 2=down, 3=left
        mov [di], dl
        
		mov di, offset p1Pos
        mov ax, 100 ; set p1 x pos
        mov bx, 100 ; set p1 y pos
        call setPosXY

        mov di, offset p1Prev
        mov ax, 100 ; set p1 x pos
        mov bx, 100 ; set p1 y pos
        call setPosXY
		
        ; Initialize p2 direction and position
        mov dl, 3  ; set p2 direction (facing left)
        mov di, offset p2Dir
        mov [di], dl
        
        mov di, offset p2Pos
        mov ax, 220 ; set p2 x pos
        mov bx, 100 ; set p2 y pos
        call setPosXY

        mov di, offset p2Prev
        mov ax, 220 ; set p2 x pos
        mov bx, 100 ; set p2 y pos
        call setPosXY

        ; Draw top wall
        mov dx, 0
        call DrawHorizontalLine
        ; Draw bottom wall
        mov dx, 199
        call DrawHorizontalLine
        ; Draw left wall
        mov dx, 321
        call DrawVerticalLine
        ; Draw right wall
        mov dx, 639
        call DrawVerticalLine

Draw:
        ;draw p1 currentPos
        mov di, offset p1Pos
        call getPosXY
		;ax = posX bx= posY
        call GetGraphPos
        
        ;ax = graphPos
        call CheckForCollisionP1
        mov cl, 9 ; set p1 color current pos
        mov di, ax ; di = address (320 * y + x)
        mov es:[di], cl ; set pixel color in video memory
        ;draw p1 currentPos
        
        ;draw p1 prevPos
        mov di, offset p1Prev
        call getPosXY
		; ax = posX bx = posY
        call GetGraphPos
        ; ax = graphPos
        mov di, ax
        mov cl, 100 ; set p1 previous pos color
        mov es:[di], cl ; set pixel color in video memory
        ;draw p1 prevPos

        ;set p1 prevPos to currentPos
        mov di, offset p1Pos
        call getPosXY
		; ax = posX bx = posY
		mov di, offset p1Prev
		call setPosXY

		;draw p2 currentPos
        mov di, offset p2Pos
        call getPosXY
		;ax = posX bx= posY
        call GetGraphPos
        
        ;ax = graphPos
        call CheckForCollisionP2
        mov cl, 13 ; set p2 color current pos
        mov di, ax ; di = address (320 * y + x)
        mov es:[di], cl ; set pixel color in video memory
        ;draw p2 currentPos
        
        ;draw p2 prevPos
        mov di, offset p2Prev
        call getPosXY
		; ax = posX bx = posY
        call GetGraphPos
        ; ax = graphPos
        mov di, ax
        mov cl, 6 ; set p2 previous pos color
        mov es:[di], cl ; set pixel color in video memory
        ;draw p2 prevPos

        ;set p2 prevPos to currentPos
        mov di, offset p2Pos
        call getPosXY
		; ax = posX bx = posY
		mov di, offset p2Prev
		call setPosXY

Delay:
        ;get time
        xor ah,ah
        int 1ah ; dx = current time

        pop cx
        push cx ; cx = previous time

        ;calc timer
        mov ax, dx
        sub dx, cx
        push ax
        
        mov al, 1
        xor ah, ah
        cmp dx, ax
        
        pop ax
        
        jc Delay
        
        pop cx
        push ax ; update time in stack

Move:
       ; check for keypress
        mov ah, 01h
        int 16h
        ; check for keypress

        jz MoveBasedOnDir ; if no key pressed
        ; get keypress
        mov ah, 00h
        int 16h
        ; get keypress

        cmp al, 27 ; when Esc
        jz Exit2

		mov di, offset p1Dir 
        mov dl, [di] ; dx = p1Dir
		
        cmp ah, 75 ; left arrow
		jnz SetDirRight
		cmp dl, 1 ; prevent opposite dir
		jz SetP1Dir
		mov dl, 3
SetDirRight:
        cmp ah, 77 ; right arrow
		jnz SetDirUp
		cmp dl, 3 ; prevent opposite dir
		jz SetP1Dir
        mov dl, 1
SetDirUp:
        cmp ah, 72 ; up arrow
		jnz SetDirDown
		cmp dl, 2 ; prevent opposite dir
		jz SetP1Dir
        mov dl, 0
SetDirDown:
        cmp ah, 80 ; down arrow
		jnz SetP1Dir
		cmp dl, 0 ; prevent opposite dir
		jz SetP1Dir
        mov dl, 2
SetP1Dir:

		mov di, offset p1Dir 
        mov [di], dl ; set p1Dir to dl
		
		mov di, offset p2Dir 
        mov dl, [di] ; dx = p2Dir
		
		cmp al, 'a' ; A key
		jnz SetDirRight2
		cmp dl, 1 ; prevent opposite dir
		jz SetP2Dir
		mov dl, 3
SetDirRight2:
        cmp al, 'd' ; D key
		jnz SetDirUp2
		cmp dl, 3 ; prevent opposite dir
		jz SetP2Dir
        mov dl, 1
SetDirUp2:
        cmp al, 'w' ; W key
		jnz SetDirDown2
		cmp dl, 2 ; prevent opposite dir
		jz SetP2Dir
        mov dl, 0
SetDirDown2:
        cmp al, 's' ; S key
		jnz SetP2Dir
		cmp dl, 0 ; prevent opposite dir
		jz SetP2Dir
        mov dl, 2
SetP2Dir:
        mov di, offset p2Dir 
        mov [di], dl ; set p2Dir to dl

        jmp MoveBasedOnDir

Exit2:
        jmp Exit

MoveBasedOnDir:
        mov di, offset p1Dir
        mov cl, [di] ; cl = dir
		
		mov di, offset p1Pos
        call getPosXY
		; ax = posX bx = posY

		cmp cl, 0
		jnz CheckRight
        call MoveUp
CheckRight:
        cmp cl, 1
		jnz CheckDown
        call MoveRight
CheckDown:
        cmp cl, 2
		jnz CheckLeft
        call MoveDown
CheckLeft:
        cmp cl, 3
		jnz MoveBasedOnDir2
        call MoveLeft

MoveBasedOnDir2:
		mov di, offset p1Pos
		call setPosXY

        mov di, offset p2Dir
        mov cl, [di] ; cl = dir
		
		mov di, offset p2Pos
        call getPosXY
		; ax = posX bx = posY
		
		cmp cl, 0
		jnz CheckRight1
        call MoveUp
CheckRight1:
        cmp cl, 1
		jnz CheckDown1
        call MoveRight
CheckDown1:
        cmp cl, 2
		jnz CheckLeft1
        call MoveDown
CheckLeft1:
        cmp cl, 3
		jnz CheckLast
        call MoveLeft

CheckLast:
		mov di, offset p2Pos
        call setPosXY
        jmp Draw

; ax = posX bx = posY
MoveLeft:
		cmp ax, 2
		jz MoveLeftThen
        dec ax
MoveLeftThen:
        ret

MoveRight:
		cmp ax, 318
        jz MoveRightThen
		inc ax
MoveRightThen:
        ret
		
MoveUp:
		cmp bx, 1
		jz MoveUpThen
        dec bx
MoveUpThen:
        ret

MoveDown:
        cmp bx, 198
		jz MoveDownThen
		inc bx
MoveDownThen:
        ret

Exit:
        mov ax, 03h
        int 10h

        pop dx

        mov ax, 4c00h
        int 21h

getPosXY:
		; di has the starting memory address
		; returns ax = posX bx= posY
		mov ax, [di]
		inc di
		inc di ; go to the third-fourth byte
		mov bx, [di]
		ret

setPosXY:
		;  ax = posX bx= posY di = starting memory address
		mov [di], ax
		inc di
		inc di ; go to the third-fourth byte
		mov [di], bx
		ret
		
DrawHorizontalLine:
        mov di, dx  
        mov ax, 320
        mul di
        mov di, ax
        mov cx, 320
DrawHLine:
        mov dx,50 ; pixel color
        mov es:[di], dx ; draw pixel
        inc di
        loop DrawHLine
        ret

DrawVerticalLine:
        mov di, dx ; di = x
        mov cx, 198 ; screen height
DrawVLine:
        mov dx,50 ; pixel color
        mov es:[di], dx ; draw pixel
        add di, 320    ; move down one line
        loop DrawVLine
        ret

GetGraphPos:
        ;return ax with graphPos
        ;ax = posX bx = posY
		mov cx, ax ; cx = posX
        mov ax, bx ; ax = posY
        mov bx, 320
        mul bx ; ax = 320 * posY
        add ax, cx ; ax += x
        jnc GetGraphPosWithoutOF
        inc ah ; handles overflow
        ret
GetGraphPosWithoutOF:
        ret

CheckForCollisionP1:
        ; colors
        ; p1: current-9 , trail-100
        ; p2: current-13,  trail-6
        ;ax = graphPos
        mov di, ax
        mov bx, es:[di]
        cmp bl, 100  ; if p1 collided with friendly trail color 
        jz P2Wins 
        cmp bl, 13 ; if p1 collided head on with p2 => enforce p1 win
        jz P2Wins
        cmp bl, 6 ; if p1 collided with p2 trail
        jz P2Wins
		cmp bl, 50 ; if p1 collided with wall
		jz P2Wins
        ret

CheckForCollisionP2:
        ; colors
        ; p1: current-9 , trail-100
        ; p2: current-13,  trail-6
        ;ax = graphPos
        mov di, ax
        mov bx, es:[di]
        cmp bl, 6  ; if p2 collided with friendly trail color 
        jz P1Wins
        cmp bl, 100 ; if p2 collided with p1 trail
        jz P1Wins
		cmp bl, 50 ; if p2 collided with wall
		jz P1Wins
        ret
	
P1Wins:
        mov dx, offset P1WinMsg
        jmp ShowResult

P2Wins:
        mov dx, offset P2WinMsg
        jmp ShowResult
		
ShowResult:
        ; Set text mode
        mov ax, 03h
        int 10h
        
        ; Show winner
        mov ah, 09h
        int 21h
        
        ; Wait for key
        mov ah, 00h
        int 16h
        
        jmp ShowMenu


p1Prev: db "****$"
p1Pos: db "****$"
p1Dir: db "**$"
p2Prev: db "****$"
p2Pos: db "****$"
p2Dir: db "**$"
MenuTitle: db "TRON JATEK$"
MenuOption1: db "1. Jatek inditasa$"
MenuOption2: db "2. Kilepes$"
P1WinMsg: db "Az Kek nyert!$"
P2WinMsg: db "A Piros nyert!$"

Code    Ends

Data    Segment

Data    Ends

Stack Segment

Stack Ends
      End       Start
