#!/usr/bin/env python3
import struct
import sys


def find_pck_section(exe_path):
    with open(exe_path, "rb") as f:
        f.seek(0x3C)
        pe = struct.unpack("<I", f.read(4))[0]
        f.seek(pe)
        if f.read(4) != b"PE\0\0":
            raise SystemExit("not a PE file")
        nsect = struct.unpack("<H", f.read(2))[0]
        f.seek(pe + 20)
        opt = struct.unpack("<H", f.read(2))[0]
        f.seek(pe + 24 + opt)
        for _ in range(nsect):
            h = f.read(40)
            if len(h) < 40:
                break
            name = h[:8].rstrip(b"\0")
            vsize, vaddr, rsize, rptr = struct.unpack("<IIII", h[8:24])
            if name == b"pck":
                return rptr, rsize
    raise SystemExit("PE section 'pck' not found")


def main():
    exe, pck, out = sys.argv[1], sys.argv[2], sys.argv[3]
    with open(pck, "rb") as f:
        pck_data = f.read()
    if pck_data[:4] != b"GDPC":
        raise SystemExit("input is not a Godot pck (no GDPC magic)")

    pck_off, section_size = find_pck_section(exe)
    limit = section_size - 12

    with open(exe, "rb") as f:
        exe_data = f.read()

    if len(pck_data) <= limit:
        out_data = (
            exe_data[:pck_off]
            + pck_data
            + bytes(limit - len(pck_data))
            + struct.pack(">Q", len(pck_data))
            + b"GDPC"
            + exe_data[pck_off + section_size:]
        )
        mode = "in-place (section replaced)"
    else:
        out_data = bytearray(exe_data)
        out_data[pck_off:pck_off + 8] = b"\0" * 8
        out_data += pck_data + struct.pack("<Q", len(pck_data)) + b"GDPC"
        mode = "appended (section invalidated, EOF trailer used)"

    with open(out, "wb") as f:
        f.write(out_data)

    with open(out, "rb") as f:
        f.seek(0, 2)
        end = f.tell()
        f.seek(pck_off)
        section_magic = f.read(8)
        if mode.startswith("in-place"):
            f.seek(pck_off + section_size - 12)
            footer = f.read(12)
            ok = (
                section_magic[:4] == b"GDPC"
                and footer[-4:] == b"GDPC"
                and struct.unpack(">Q", footer[:8])[0] == len(pck_data)
            )
        else:
            f.seek(end - 4)
            trailer_magic = f.read(4)
            f.seek(end - 12)
            ds = struct.unpack("<Q", f.read(8))[0]
            ok = trailer_magic == b"GDPC" and ds == len(pck_data) and not section_magic.strip(b"\0")
    if not ok:
        raise SystemExit("verification failed")

    print(f"OK [{mode}] pck={len(pck_data)} bytes -> {out}")


if __name__ == "__main__":
    main()
