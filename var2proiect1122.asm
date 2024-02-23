.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Gengiu Robert -> Proiect -> Chuckie Egg",0
area_width EQU 1300
area_height EQU 450
area DD 0

counter DD 0 ; numara evenimentele de tip timer
gameover DD 0; 
gamewin DD 0; 
collision_check DD 0;

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20


player_x dd 590
player_y dd 360

win_x dd 290
win_y dd 180

character_height equ 20
character_width equ 30

lovit db 0
square_length equ 30


symbol_width EQU 10
symbol_height EQU 20
inaltime_platforma equ 20
latime_platforma equ 30
inaltime_harta_joc equ 15
latime_harta_joc equ 20
include digits.inc
include letters.inc
include structuri_joc.inc
include matrice_de_stare.inc
include chuckie.inc
include win.inc


distanta_miscare_caracter equ 30

marime_buton equ 100
butonDR_X EQU 1150
butonDR_Y EQU 300

butonJOS_X EQU 1000
butonJOS_Y EQU 300

butonST_X EQU 850
butonST_Y EQU 300

butonSUS_X EQU 1000
butonSUS_Y EQU 150

butonRETRY_X EQU 800
butonRETRY_Y EQU 200
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FF00ECh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm


realizare_elemente proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax,0
	jl background_default
	cmp eax,3
	jg background_default
	lea esi, structuri_joc
	jmp desenare_elemente
background_default:	
	mov eax, 4 ; ultima e background_default
	lea esi, structuri_joc
	
desenare_elemente:
	mov ebx, latime_platforma
	mul ebx
	mov ebx, inaltime_platforma
	mul ebx
	add esi, eax
	mov ecx, inaltime_platforma
loop_elemente_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, inaltime_platforma
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, latime_platforma
loop_elemente_coloane:
	cmp byte ptr [esi], 0
	je alb
	cmp byte ptr [esi], 1
	je negru
	cmp byte ptr [esi], 2
	je verde
	cmp byte ptr [esi], 3
	je movvv
	cmp byte ptr [esi], 4
	je rosu
	cmp byte ptr [esi], 5
	je blue
	cmp byte ptr [esi], 6
	je negru2
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
alb:
	mov dword ptr [edi], 0ffffffh
	jmp simbol_pixel_next
negru:
    mov dword ptr [edi], 0
	jmp simbol_pixel_next
verde:
	mov dword ptr [edi], 000FF08h
	jmp simbol_pixel_next
movvv:
	mov dword ptr [edi], 0FF00FBh
	jmp simbol_pixel_next
rosu:
	mov dword ptr [edi], 0FF0000H
	jmp simbol_pixel_next
blue:
	mov dword ptr [edi], 00000FFH
	jmp simbol_pixel_next
negru2:
	mov dword ptr [edi], 0000010H
	jmp simbol_pixel_next
simbol_pixel_next:
	inc esi
	add edi, 4
	loop loop_elemente_coloane
	pop ecx
	dec ecx
	cmp ecx, 0
	jne loop_elemente_linii
	popa
	mov esp, ebp
	pop ebp
	ret
realizare_elemente endp

realizare_elemente_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call realizare_elemente
	add esp, 16
endm




linie_orizontala macro x, y, lungime, culoare
local bucla_line
	mov eax, y ; EAX = y
	mov ebx, area_width
	mul ebx ; EAX = y * area_width
	add eax, x ; EAX = y * area_width + x
	shl eax, 2 ; EAX = (y * area_width + x) *4
	add eax, area
	mov ecx, lungime
bucla_line:
	mov dword ptr[eax], culoare
	add eax, 4
	loop bucla_line
endm

linie_verticala macro x, y, lungime, culoare
local bucla_line
	mov eax, y ; EAX = y
	mov ebx, area_width
	mul ebx ; EAX = y * area_width
	add eax, x ; EAX = y * area_width + x
	shl eax, 2 ; EAX = (y * area_width + x) *4
	add eax, area
	mov ecx, lungime
bucla_line:
	mov dword ptr[eax], culoare
	add eax, area_width * 4
	loop bucla_line
endm


incarcare_mapa_joc proc
	;functie pt parcurgere a matricii de stare
	push ebp
	mov ebp, esp
	pusha
	
	lea esi, matrice_de_stare 
	;add esi, eax
	mov ecx, inaltime_harta_joc
	mov ebx, 50 ;coord x de unde incepe sa se genereze harta
	mov edi, 100 ;coord y de unde incepe sa se genereze harta
loop_incarcare_linii:
	push ecx
	mov ecx, latime_harta_joc
loop_incarcare_coloane:
	cmp byte ptr [esi], 0
	je zid
	cmp byte ptr [esi], 1
	je scara
	cmp byte ptr [esi], 2
	je  inamic
	cmp byte ptr [esi], 3
	je  castigat 
	realizare_elemente_macro 4, area, ebx, edi
	jmp continue
zid:
	realizare_elemente_macro 0, area, ebx, edi
	jmp continue
scara:
	realizare_elemente_macro 1, area, ebx, edi
	jmp continue
inamic:  
	realizare_elemente_macro 2, area, ebx, edi 
	jmp continue
castigat:
	realizare_elemente_macro 3, area, ebx, edi 
	jmp continue
continue:
	add ebx, 30 ;parcurgere linie
	inc esi
	loop loop_incarcare_coloane
	pop ecx
	mov ebx, 50 ;resetam ebx la 50 pt a pleca cu generarea de pe fiecare linie la fel, sa nu se decaleze harta aiurea
	add edi, 20 ;parcurgere coloane
	dec ecx
	cmp ecx, 0
	jne loop_incarcare_linii
	popa
	mov esp, ebp
	pop ebp
	ret
incarcare_mapa_joc endp

incarcare_mapa_joc_macro macro 
	call incarcare_mapa_joc
endm


; procedura afisare caracter jucator 
; arg1 - pointer to the area
; arg2 - x coordinate
; arg3 - y coordinate
chuckie_player proc   ;------------------------------------------
push ebp
mov ebp, esp
pusha

lea esi, chuckie ;incarcare adresa
mov ecx, character_height ;inaltime matrice pe linii (nr de linii)
loop_row:
mov edi, [ebp + arg1] ; pointer to the area
mov eax, [ebp + arg3] ; y coordinate
add eax, character_height
sub eax, ecx ;calculare pozitie in matrice pt parcurgere
mov ebx, area_width
mul ebx
add eax, [ebp + arg2]
shl eax, 2;folosim acelasi principiu ca la functia de desenare linie,la y inmultim area_width apoi adunam x si inmultim totul cu 4 pt ca dword
add edi, eax
push ecx
mov ecx, character_width ;nr de coloane
loop_col:
mov edx, dword ptr [esi]
mov dword ptr [edi], edx; aici la area adica la edi adaug pozitia din matricea de caracter chuckie adica esi, mai pe scurt adaug la area culoarea
add esi, 4 ;adaugam cate 4 pt ca avem dword pt parcurgere
add edi, 4 ;adaugam cate 4 pt ca avem dword pt parcurgere
loop loop_col
pop ecx
loop loop_row

popa
mov esp, ebp
pop ebp
ret
chuckie_player endp 

chuckie_player_macro macro area, x, y  
push y
push x
push area
call chuckie_player 
add esp, 12
endm


miscare_stanga proc 

push ebp
mov ebp, esp
pusha

cmp player_x, 140 ; 110 - 30 lungime caracter
je coliziune
sub player_x, 30
coliziune:
popa
mov esp, ebp
pop ebp
ret

miscare_stanga endp

miscare_stanga_macro macro 
call miscare_stanga
endm



; procedura de realizare miscare dreapta
; arg1 - pointer to the area
; arg2 - x coordinate
; arg3 - y coordinate
dreapta proc
    push ebp 
    mov ebp, esp
    pusha

	mov lovit, 0 ;aceasta este o variabila ce verifica coliziunea /principiul invers urcarii si coborarii,merge cat timp nu vede coliziune
    mov ecx, square_length
loop_row:
    mov edi, [ebp + arg1] ; pointer to the area
    mov eax, [ebp + arg3] ; y coordinate
    add eax, character_height
    sub eax, ecx
    mov ebx, area_width 
    mul ebx
    add eax, [ebp + arg2] ; x coordinate
    add eax, 30 ;adaug latimea unei caramizi/platforme
    shl eax, 2
    add edi, eax
    cmp dword ptr [edi], 0;verificare negru pt coliziune, platformele au margine neagra
    jne coll
    mov lovit, 1
coll:

    loop loop_row	
	cmp lovit, 1;daca nu vede coliziunea cu zid, schimba pozitia caracterului,altfel nu
	je not_coll
	add player_x, 30
	not_coll:



    popa
    mov esp, ebp
    pop ebp
    ret
dreapta endp

dreapta_macro macro area, x, y
    push y
    push x
    push area
    call dreapta
    add esp, 12
endm



;procedura de realizare miscare stanga
; arg1 - pointer to the area
; arg2 - x coordinate
; arg3 - y coordinate
stanga proc
    push ebp 
    mov ebp, esp
    pusha

	mov lovit, 0;aceasta este o variabila ce verifica coliziunea/principiul invers urcarii si coborarii,merge cat timp nu vede coliziune
    mov ecx, square_length
loop_row:
    mov edi, [ebp + arg1] ; pointer to the area
    mov eax, [ebp + arg3] ; y coordinate
    add eax, character_height
    sub eax, ecx
    mov ebx, area_width 
    mul ebx
    add eax, [ebp + arg2] ; x coordinate
    sub eax, 30 ;scad latimea unei caramizi/platforme
    shl eax, 2
    add edi, eax
    cmp dword ptr [edi], 0;verificare negru pt coliziune, platformele au margine neagra
    jne coll
    mov lovit, 1
coll:

    loop loop_row	
	cmp lovit, 1;daca nu vede coliziunea cu zid, schimba pozitia caracterului,altfel nu
	je not_coll
	sub player_x, 30
	not_coll:



    popa
    mov esp, ebp
    pop ebp
    ret
stanga endp

stanga_macro macro area, x, y
    push y
    push x
    push area
    call stanga
    add esp, 12
endm



;procedura de realizare urcare
; arg1 - pointer to the area
; arg2 - x coordinate
; arg3 - y coordinate
urcare proc
    push ebp 
    mov ebp, esp
    pusha   
 
    mov collision_check, 0 ;aceasta este o variabila ce verifica coliziunea/ e principiul invers mersului stanga si dreapta, urca atat timp cat vede coliziunea cu un zid

    mov edi, [ebp + arg1] ; pointer to the area
    mov eax, [ebp + arg3] ; y coordinate
    sub eax, 40 ; aici verific cu 2 blocuri fata de pozitia curenta, astfel caracterul meu imi ramane in matrice,ca sa nu mearga prin pereti
    mov ebx, area_width         
    mul ebx
    add eax, [ebp + arg2] ; x coordinate
    shl eax, 2
    add edi, eax
    mov ecx, character_width 
loop_col:
    cmp dword ptr [edi], 0 ;comparare negru
    jne coll
    mov collision_check, 1
coll:
    add edi, 4
    loop loop_col
    cmp collision_check, 1;daca vede coliziunea cu zid, schimba pozitia caracterului,altfel nu
    je not_coll 
    sub player_y, 20 ;scad inaltimea unei caramizi/platforme
not_coll:
    popa
    mov esp, ebp
    pop ebp
    ret
	
    push ebp 
    mov ebp, esp
    pusha

urcare endp

urcare_macro macro area, x, y
    push y
    push x
    push area
    call urcare
    add esp, 12
endm


;procedura de realizare coborare
; arg1 - pointer to the area
; arg2 - x coordinate
; arg3 - y coordinate
coborare proc
    push ebp 
    mov ebp, esp
    pusha   
 
    mov collision_check, 0 ;aceasta este o variabila ce verifica coliziunea/ e principiul invers mersului stanga si dreapta, coboara atat timp cat vede coliziunea cu un zid
	

    mov edi, [ebp + arg1] ; pointer to the area
    mov eax, [ebp + arg3] ; y coordinate
    add eax, 20 ; aici verific cu 1 blocuri fata de pozitia curenta, astfel caracterul meu imi ramane in matrice,ca sa nu mearga prin pereti
    mov ebx, area_width 
    mul ebx
    add eax, [ebp + arg2] ; x coordinate
    shl eax, 2
    add edi, eax
    mov ecx, character_width 
loop_col:
    cmp dword ptr [edi], 0 ;comparare negru
    jne coll
    mov collision_check, 1
coll:
    add edi, 4
    loop loop_col
    cmp collision_check, 1;daca vede coliziunea cu zid, schimba pozitia caracterului,altfel nu
    je not_coll 
    add player_y, 20 ;adaug inaltimea unei caramizi/platforme
not_coll:
    popa
    mov esp, ebp
    pop ebp
    ret
	
    push ebp 
    mov ebp, esp
    pusha

coborare endp

coborare_macro macro area, x, y
    push y
    push x
    push area
    call coborare
    add esp, 12
endm


gameover_message proc 
   push ebp 
    mov ebp, esp
    pusha
;aici verific daca in stanga sau in dreapta gaseste (se loveste/principiul stanga dreapta) caracterul de lose, variabila gameover devine 1, altfel ramane 0
;si folosesc codul de mers stanga dreapta , verific in ambele cazuri
    mov ecx, square_length
loop_row:
    mov edi, [ebp + arg1] ; pointer to the area
    mov eax, [ebp + arg3] ; y coordinate
    add eax, character_height
    sub eax, ecx
    mov ebx, area_width 
    mul ebx
    add eax, [ebp + arg2] ; x coordinate
    add eax, 30
    shl eax, 2
    add edi, eax
    cmp dword ptr [edi], 0FF0000H;verificare ROSU pt coliziune CU INAMIC
    jne coll
    mov gameover, 1
coll:

    loop loop_row	
	

    mov ecx, square_length
loop_row1:
    mov edi, [ebp + arg1] ; pointer to the area
    mov eax, [ebp + arg3] ; y coordinate
    add eax, character_height
    sub eax, ecx
    mov ebx, area_width 
    mul ebx
    add eax, [ebp + arg2] ; x coordinate
    sub eax, 30
    shl eax, 2
    add edi, eax
    cmp dword ptr [edi], 0FF0000H;verificare ROSU pt coliziune CU INAMIC
    jne coll1
    mov gameover, 1
coll1:

    loop loop_row1	
	


    popa
    mov esp, ebp
    pop ebp
    ret
gameover_message endp

gameover_message_macro macro area,x,y
push y
push x
push area
call gameover_message
add esp ,12
endm



gamewin_message proc 
   push ebp 
    mov ebp, esp
    pusha

;aici verific daca in stanga sau in dreapta gaseste (se loveste/principiul stanga dreapta) caracterul de win, variabila gamewin devine 1, altfel ramane 0
;si folosesc codul de mers stanga dreapta , verific in ambele cazuri   
   mov ecx, square_length
loop_row12:
    mov edi, [ebp + arg1] ; pointer to the area
    mov eax, [ebp + arg3] ; y coordinate
    add eax, character_height
    sub eax, ecx
    mov ebx, area_width 
    mul ebx
    add eax, [ebp + arg2] ; x coordinate
    add eax, 30
    shl eax, 2
    add edi, eax
    cmp dword ptr [edi], 0000FFh;verificare albastru pt coliziune CU win
    jne coll12
    mov gamewin, 1
coll12:

    loop loop_row12	
	

    mov ecx, square_length
loop_row112:
    mov edi, [ebp + arg1] ; pointer to the area
    mov eax, [ebp + arg3] ; y coordinate
    add eax, character_height
    sub eax, ecx
    mov ebx, area_width 
    mul ebx
    add eax, [ebp + arg2] ; x coordinate
    sub eax, 30
    shl eax, 2
    add edi, eax
    cmp dword ptr [edi], 0000FFh;verificare albastru pt coliziune CU win
    jne coll112
    mov gamewin, 1
coll112:

    loop loop_row112
	


    popa
    mov esp, ebp
    pop ebp
    ret
gamewin_message endp

gamewin_message_macro macro area,x,y
push y
push x
push area
call gamewin_message
add esp ,12
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	jmp afisare_litere
	
evt_click:
	cmp gameover,1; daca a pierdut, repozitionam caracterul pe pozitia initiala si gameover =0, altfel sare peste acele comenzi
	jne retry
	mov gameover,0
	mov player_x,590
	mov player_y,360
	retry:
	
	
	cmp gamewin ,1; daca a castigat, repozitionam caracterul pe pozitia initiala si gamewin =0, altfel sare peste acele comenzi
	jne retry1
	mov gamewin,0
	mov player_x,590
	mov player_y,360
	retry1:
	
	
	mov eax, [ebp+ arg2] ;buton stanga
	cmp eax, butonST_X
	jl button4_fail
	cmp eax, butonST_X + marime_buton
	jg button4_fail
	mov eax, [ebp + arg3]
	cmp eax, butonST_Y
	jl button4_fail
	cmp eax, butonST_Y + marime_buton
	jg button4_fail
	stanga_macro area,player_x,player_y
	jmp afisare_litere
button4_fail:
	
	
	
	mov eax, [ebp+ arg2] ;buton urcare
	cmp eax, butonSUS_X
	jl button3_fail
	cmp eax, butonSUS_X + marime_buton
	jg button3_fail 
	mov eax, [ebp + arg3]
	cmp eax, butonSUS_Y
	jl button3_fail
	cmp eax, butonSUS_Y + marime_buton
	jg button3_fail 
    urcare_macro area,player_x,player_y
	jmp afisare_litere
button3_fail:
	

	mov eax, [ebp+ arg2] ;buton coborare
	cmp eax, butonJOS_X
	jl button2_fail
	cmp eax, butonJOS_X + marime_buton
	jg button2_fail
	mov eax, [ebp + arg3]
	cmp eax, butonJOS_Y
	jl button2_fail
	cmp eax, butonJOS_Y + marime_buton
	jg button2_fail
	coborare_macro area,player_x,player_y
	jmp afisare_litere
button2_fail:
	
	
	
	mov eax, [ebp+ arg2] ;buton dreapta
	cmp eax, butonDR_X    
	jl button1_fail
	cmp eax, butonDR_X + marime_buton 
	jg button1_fail
	mov eax, [ebp + arg3]
	cmp eax, butonDR_Y
	jl button1_fail
	cmp eax, butonDR_Y + marime_buton
	jg button1_fail
	dreapta_macro area,player_x,player_y
     
	jmp afisare_litere
button1_fail:

	
	
	
	
evt_timer:
	inc counter
	
afisare_litere:
    mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 60, 30
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 50, 30
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 40, 30
	
	;scriem un mesaj
	make_text_macro 'T', area, 10, 10
	make_text_macro 'I', area, 20, 10
	make_text_macro 'M', area, 30, 10
	make_text_macro 'E', area, 40, 10
	make_text_macro ' ', area, 50, 10
	make_text_macro 'S', area, 60, 10
	make_text_macro 'P', area, 70, 10
	make_text_macro 'E', area, 80, 10
	make_text_macro 'N', area, 90, 10
	make_text_macro 'T', area, 100, 10
	
	make_text_macro 'L', area, 160, 10
	make_text_macro 'E', area, 170, 10
	make_text_macro 'V', area, 180, 10
	make_text_macro 'E', area, 190, 10
	make_text_macro 'L', area, 200, 10
	make_text_macro ' ', area, 210, 10
	make_text_macro '1', area, 220, 10
	
	make_text_macro 'P', area, 280, 10
	make_text_macro 'L', area, 290, 10
	make_text_macro 'A', area, 300, 10
	make_text_macro 'Y', area, 310, 10
	make_text_macro 'E', area, 320, 10
	make_text_macro 'R', area, 330, 10
	make_text_macro ' ', area, 340, 10
	make_text_macro '1', area, 350, 10
	
	make_text_macro 'G', area, 410, 10
	make_text_macro 'E', area, 420, 10
	make_text_macro 'N', area, 430, 10
	make_text_macro 'G', area, 440, 10
	make_text_macro 'I', area, 450, 10
	make_text_macro 'U', area, 460, 10
	make_text_macro ' ', area, 470, 10
	make_text_macro 'R', area, 480, 10
	make_text_macro 'O', area, 490, 10
	make_text_macro 'B', area, 500, 10
	make_text_macro 'E', area, 510, 10
	make_text_macro 'R', area, 520, 10
	make_text_macro 'T', area, 530, 10
	
	make_text_macro 'P', area, 590, 10
	make_text_macro 'R', area, 600, 10
	make_text_macro 'O', area, 610, 10
	make_text_macro 'I', area, 620, 10
	make_text_macro 'E', area, 630, 10
	make_text_macro 'C', area, 640, 10
	make_text_macro 'T', area, 650, 10
	make_text_macro ' ', area, 660, 10
	make_text_macro 'L', area, 670, 10
	make_text_macro 'A', area, 680, 10
	make_text_macro ' ', area, 690, 10
	make_text_macro 'A', area, 700, 10
	make_text_macro 'S', area, 710, 10
	make_text_macro 'A', area, 720, 10
	make_text_macro 'M', area, 730, 10
	make_text_macro 'B', area, 740, 10
	make_text_macro 'L', area, 750, 10
	make_text_macro 'A', area, 760, 10
	make_text_macro 'R', area, 770, 10
	make_text_macro 'E', area, 780, 10



incarcare_mapa_joc_macro


;mai jos vom forma butoanele 

;buton dreapta
linie_orizontala butonDR_X,butonDR_Y,marime_buton,0FF00FBh
linie_orizontala butonDR_X,butonDR_Y+marime_buton,marime_buton,0FF00FBh
linie_verticala butonDR_X,butonDR_Y,marime_buton,0FF00FBh
linie_verticala butonDR_X+marime_buton,butonDR_Y,marime_buton,0FF00FBh

;buton JOS
linie_orizontala butonJOS_X,butonJOS_Y,marime_buton,0FF00FBh
linie_orizontala butonJOS_X,butonJOS_Y+marime_buton,marime_buton,0FF00FBh
linie_verticala butonJOS_X,butonJOS_Y,marime_buton,0FF00FBh
linie_verticala butonJOS_X+marime_buton,butonJOS_Y,marime_buton,0FF00FBh

;buton STANGA
linie_orizontala butonST_X,butonST_Y,marime_buton,0FF00FBh
linie_orizontala butonST_X,butonST_Y+marime_buton,marime_buton,0FF00FBh
linie_verticala butonST_X,butonST_Y,marime_buton,0FF00FBh
linie_verticala butonST_X+marime_buton,butonST_Y,marime_buton,0FF00FBh


;buton SUS
linie_orizontala butonSUS_X,butonSUS_Y,marime_buton,0FF00FBh
linie_orizontala butonSUS_X,butonSUS_Y+marime_buton,marime_buton,0FF00FBh
linie_verticala butonSUS_X,butonSUS_Y,marime_buton,0FF00FBh
linie_verticala butonSUS_X+marime_buton,butonSUS_Y,marime_buton,0FF00FBh


chuckie_player_macro area,player_x,player_y ;incarcare jucator 


gameover_message_macro area,player_x,player_y;aici verific daca s a indeplinit conditia de lose, daca da, mai jos incarc o noua harta ca sa ii zic asa de culoare neagra unde 
; urmeaza sa imi afisez mesajul de gameover,altfel,daca gameover nu e 1, imi sare peste acele afisari
    cmp gameover,1
    jne sari
    mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	make_text_macro 'D',area,250,10
	make_text_macro 'I',area,260,10
	make_text_macro 'N',area,270,10
	make_text_macro ' ',area,280,10
	make_text_macro 'P',area,290,10
	make_text_macro 'A',area,300,10
	make_text_macro 'C',area,310,10
	make_text_macro 'A',area,320,10
	make_text_macro 'T',area,330,10
	make_text_macro 'E',area,340,10
	make_text_macro ' ',area,350,10
	make_text_macro 'A',area,360,10
	make_text_macro 'I',area,370,10
	make_text_macro ' ',area,380,10
	make_text_macro 'P',area,390,10
	make_text_macro 'I',area,400,10
	make_text_macro 'E',area,410,10
	make_text_macro 'R',area,420,10
	make_text_macro 'D',area,430,10
	make_text_macro 'U',area,440,10
	make_text_macro 'T',area,450,10
	
	realizare_elemente_macro 4,area,400,400
	realizare_elemente_macro 4,area,430,400
	realizare_elemente_macro 4,area,460,400
	realizare_elemente_macro 4,area,370,400
	realizare_elemente_macro 4,area,340,400
	realizare_elemente_macro 4,area,490,400
	realizare_elemente_macro 4,area,310,400
	realizare_elemente_macro 4,area,520,380
	realizare_elemente_macro 4,area,550,360
	realizare_elemente_macro 4,area,580,340
	realizare_elemente_macro 4,area,610,320
	realizare_elemente_macro 4,area,610,300
	realizare_elemente_macro 4,area,610,280
	realizare_elemente_macro 4,area,610,260
	realizare_elemente_macro 4,area,610,240
	realizare_elemente_macro 4,area,610,220
	realizare_elemente_macro 4,area,610,200
	realizare_elemente_macro 4,area,280,380
	realizare_elemente_macro 4,area,250,360
	realizare_elemente_macro 4,area,220,340
	realizare_elemente_macro 4,area,190,320
	realizare_elemente_macro 4,area,190,300
	realizare_elemente_macro 4,area,190,280
	realizare_elemente_macro 4,area,190,260
	realizare_elemente_macro 4,area,190,240
	realizare_elemente_macro 4,area,190,220
	realizare_elemente_macro 4,area,190,200
	realizare_elemente_macro 4,area,220,180
	realizare_elemente_macro 4,area,250,160
	realizare_elemente_macro 4,area,280,140
	realizare_elemente_macro 4,area,310,120
	realizare_elemente_macro 4,area,340,120
	realizare_elemente_macro 4,area,370,120
	realizare_elemente_macro 4,area,400,120
	realizare_elemente_macro 4,area,430,120
	realizare_elemente_macro 4,area,460,120
	realizare_elemente_macro 4,area,490,120
	realizare_elemente_macro 4,area,520,140
	realizare_elemente_macro 4,area,550,160
	realizare_elemente_macro 4,area,580,180
	realizare_elemente_macro 4,area,310,200
	realizare_elemente_macro 4,area,490,200
	realizare_elemente_macro 4,area,340,270
	realizare_elemente_macro 4,area,370,270
	realizare_elemente_macro 4,area,400,270
	realizare_elemente_macro 4,area,430,270
    realizare_elemente_macro 4,area,460,270
	realizare_elemente_macro 4,area,490,290
	realizare_elemente_macro 4,area,310,290
sari:


gamewin_message_macro area,player_x,player_y;aici verific daca s a indeplinit conditia de win, daca da, mai jos incarc o noua harta ca sa ii zic asa de culoare neagra unde 
; urmeaza sa imi afisez mesajul de gamewin,altfel,daca gamewin nu e 1, imi sare peste acele afisari

    cmp gamewin,1
    jne sari21
    mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	
	
	make_text_macro 'A',area,250,10
	make_text_macro 'I',area,260,10
	make_text_macro ' ',area,270,10
	make_text_macro 'C',area,280,10
	make_text_macro 'A',area,290,10
	make_text_macro 'S',area,300,10
	make_text_macro 'T',area,310,10
	make_text_macro 'I',area,320,10
	make_text_macro 'G',area,330,10
	make_text_macro 'A',area,340,10
	make_text_macro 'T',area,350,10
	make_text_macro ' ',area,360,10
	make_text_macro 'F',area,370,10
	make_text_macro 'E',area,380,10
	make_text_macro 'L',area,390,10
	make_text_macro 'I',area,400,10
	make_text_macro 'C',area,410,10
	make_text_macro 'I',area,420,10
	make_text_macro 'T',area,430,10
	make_text_macro 'A',area,440,10
	make_text_macro 'R',area,450,10
	make_text_macro 'I',area,460,10
	
	realizare_elemente_macro 4,area,400,400
	realizare_elemente_macro 4,area,430,400
	realizare_elemente_macro 4,area,460,400
	realizare_elemente_macro 4,area,370,400
	realizare_elemente_macro 4,area,340,400
	realizare_elemente_macro 4,area,490,400
	realizare_elemente_macro 4,area,310,400
	realizare_elemente_macro 4,area,520,380
	realizare_elemente_macro 4,area,550,360
	realizare_elemente_macro 4,area,580,340
	realizare_elemente_macro 4,area,610,320
	realizare_elemente_macro 4,area,610,300
	realizare_elemente_macro 4,area,610,280
	realizare_elemente_macro 4,area,610,260
	realizare_elemente_macro 4,area,610,240
	realizare_elemente_macro 4,area,610,220
	realizare_elemente_macro 4,area,610,200
	realizare_elemente_macro 4,area,280,380
	realizare_elemente_macro 4,area,250,360
	realizare_elemente_macro 4,area,220,340
	realizare_elemente_macro 4,area,190,320
	realizare_elemente_macro 4,area,190,300
	realizare_elemente_macro 4,area,190,280
	realizare_elemente_macro 4,area,190,260
	realizare_elemente_macro 4,area,190,240
	realizare_elemente_macro 4,area,190,220
	realizare_elemente_macro 4,area,190,200
	realizare_elemente_macro 4,area,220,180
	realizare_elemente_macro 4,area,250,160
	realizare_elemente_macro 4,area,280,140
	realizare_elemente_macro 4,area,310,120
	realizare_elemente_macro 4,area,340,120
	realizare_elemente_macro 4,area,370,120
	realizare_elemente_macro 4,area,400,120
	realizare_elemente_macro 4,area,430,120
	realizare_elemente_macro 4,area,460,120
	realizare_elemente_macro 4,area,490,120
	realizare_elemente_macro 4,area,520,140
	realizare_elemente_macro 4,area,550,160
	realizare_elemente_macro 4,area,580,180
	realizare_elemente_macro 4,area,310,200
	realizare_elemente_macro 4,area,490,200
	realizare_elemente_macro 4,area,340,270
	realizare_elemente_macro 4,area,370,270
	realizare_elemente_macro 4,area,400,270
	realizare_elemente_macro 4,area,430,270
    realizare_elemente_macro 4,area,460,270
	realizare_elemente_macro 4,area,490,250
	realizare_elemente_macro 4,area,310,250
sari21:

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
