#!/usr/bin/env python3
"""アプリアイコン(1024x1024 PNG)を生成。朱色の背景に白い鳥居。著作権フリー(自作)。"""
import zlib, struct, os

W = H = 1024
TOP = (198, 62, 48)      # toriiRed 系の上部
BOT = (150, 36, 26)      # 下部(濃い朱)
WHITE = (252, 250, 246)

def lerp(a, b, t): return int(a + (b - a) * t)

pw = int(0.052 * W)
lx, rx = int(0.34 * W), int(0.66 * W)
ptop, pbot = int(0.33 * H), int(0.86 * H)
k_x0, k_x1, k_y0, k_y1 = int(0.15 * W), int(0.85 * W), int(0.23 * H), int(0.305 * H)
cap_x0, cap_x1, cap_y0 = int(0.29 * W), int(0.71 * W), int(0.185 * H)
n_x0, n_x1, n_y0, n_y1 = int(0.27 * W), int(0.73 * W), int(0.45 * H), int(0.505 * H)

def is_white(x, y):
    if ptop <= y <= pbot and (lx - pw//2 <= x <= lx + pw//2 or rx - pw//2 <= x <= rx + pw//2):
        return True
    if k_y0 <= y <= k_y1 and k_x0 <= x <= k_x1:               # 笠木
        return True
    if cap_y0 <= y < k_y0 and cap_x0 <= x <= cap_x1:          # 上の島木
        return True
    if n_y0 <= y <= n_y1 and n_x0 <= x <= n_x1:               # 貫
        return True
    return False

raw = bytearray()
for y in range(H):
    raw.append(0)  # filter type 0
    t = y / H
    bg = bytes((lerp(TOP[0], BOT[0], t), lerp(TOP[1], BOT[1], t), lerp(TOP[2], BOT[2], t)))
    w = bytes(WHITE)
    for x in range(W):
        raw += w if is_white(x, y) else bg

def chunk(typ, data):
    return struct.pack(">I", len(data)) + typ + data + struct.pack(">I", zlib.crc32(typ + data) & 0xffffffff)

png = (b'\x89PNG\r\n\x1a\n'
       + chunk(b'IHDR', struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
       + chunk(b'IDAT', zlib.compress(bytes(raw), 9))
       + chunk(b'IEND', b''))

out = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "ios/ShrineFinder/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png")
open(out, "wb").write(png)
print("wrote", out, len(png) // 1024, "KB")
