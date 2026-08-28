#!/usr/bin/env python3
import struct
import sys


def main():
    exe, out = sys.argv[1], sys.argv[2]
    with open(exe, "rb") as f:
        f.seek(0x3C)
        pe = struct.unpack("<I", f.read(4))[0]
        f.seek(pe)
        if f.read(4) != b"PE\0\0":
            raise SystemExit("not a PE file")
        nsect = struct.unpack("<H", f.read(2))[0]
        f.seek(pe + 20)
        opt = struct.unpack("<H", f.read(2))[0]
        f.seek(pe + 24 + opt)
        pck_off = pck_size = None
        for _ in range(nsect):
            h = f.read(40)
            if len(h) < 40:
                break
            name = h[:8].rstrip(b"\0")
            vsize, vaddr, rsize, rptr = struct.unpack("<IIII", h[8:24])
            if name == b"pck":
                pck_off, pck_size = rptr, rsize
        if pck_off is None:
            raise SystemExit("PE section 'pck' not found")
        f.seek(pck_off)
        data = f.read(pck_size)
    if data[:4] != b"GDPC":
        raise SystemExit("no GDPC magic at section start")
    if data[-4:] == b"GDPC":
        data = data[:-12]  # strip the 12-byte [size][GDPC] footer
    with open(out, "wb") as f:
        f.write(data)
    print(f"OK: {len(data)} bytes -> {out}")


if __name__ == "__main__":
    main()
