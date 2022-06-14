ORG 0h ;# Offset 0, for NASM

push cs
pop ds

call thepasswordis
  ; db "The password is: '$"
  db 0xab, 0x97, 0x9a, 0xdf, 0x8f, 0x9e, 0x8c, 0x8c, 0x88, 0x90, 0x8d, 0x9b, 0xdf, 0x96, 0x8c, 0xc5, 0xdf, 0xdd, 0xdb, 0

thepasswordis:
pop dx
mov cx, dx

decoder_top:
  cmp byte [ecx], 0
  je decoder_bottom
  xor byte [ecx], 0xff
  inc cx
  jmp decoder_top

decoder_bottom:
mov ah, 09
int 0x21

call cannotberun
  db "This program cannot be run in DOS mode.$", 0

cannotberun:
pop dx
mov ah, 09
int 0x21

dec cx
dec cx
mov dx, cx
mov ah, 09
int 0x21

; # terminate the program
mov ax,0x4c01
int 0x21
