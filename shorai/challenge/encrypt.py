#!/usr/bin/env python3

import sys
import hashlib


from Crypto.Cipher import AES

enc_prefix = [112, 179]


def main(key, fname, fout):
    assert len(key) == 256/4
    rawkey = bytes.fromhex(key)
    keyhash = bytes([ord(hashlib.sha256(bytes(enc_prefix + [ord(x)])).hexdigest()[-1])^0xFF for x in key])
    print(keyhash)
    iv = b'BSidesSF2022'
    encdata, mac = do_encrypt(rawkey, iv, open(fname, 'rb').read())
    assert len(mac) == 16
    with open(fout, 'w') as fp:
        fp.write('#include <stdint.h>\n#include <sys/types.h>\n')
        fp.write('size_t E_LEN = %d;\n' % len(encdata))
        write_c_var(fp, 'E_SALT', bytes(enc_prefix))
        write_c_var(fp, 'E_KEYSUM', keyhash)
        write_c_var(fp, 'E_DATA', encdata)
        write_c_var(fp, 'E_MAC', mac)
        write_c_var(fp, 'E_IV', iv)
        write_c_var(fp, 'PPPP', obscure_string('/proc/%d/fd/%d'))
        write_c_var(fp, 'FFFF', obscure_string('getflag'))


def write_c_var(fp, name, buf):
    val = ','.join(['%d' % x for x in buf])
    fp.write("const uint8_t %s[] = {%s};\n" % (name, val))


def do_encrypt(key, iv, data):
    assert len(iv) == 12
    cipher = AES.new(key, AES.MODE_GCM, nonce=iv)
    return cipher.encrypt_and_digest(data)


def obscure_string(s):
    l = (len(s) & 0xFF)
    return bytes([l] + [ord(x)  ^ l for x in s])


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3])
