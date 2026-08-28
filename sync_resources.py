#!/usr/bin/env python3
import os
import filecmp
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PRIS = os.path.join(HERE, "work", "pristine")
TRAN = os.path.join(HERE, "work", "extracted")
RES = os.path.join(HERE, "resources")

if not os.path.isdir(PRIS) or not os.path.isdir(TRAN):
    print("run apply.sh first (work/pristine and work/extracted are required)")
    sys.exit(1)

changed = []
removed = []
for dp, _, fs in os.walk(TRAN):
    for f in fs:
        p = os.path.join(dp, f)
        rel = os.path.relpath(p, TRAN)
        if ".godot" in rel.split(os.sep) and not f.endswith(".fontdata"):
            continue
        q = os.path.join(PRIS, rel)
        if not os.path.exists(q) or not filecmp.cmp(p, q, shallow=False):
            changed.append(rel)

for dp, _, fs in os.walk(RES):
    for f in fs:
        rel = os.path.relpath(os.path.join(dp, f), RES)
        if ".godot" in rel.split(os.sep) and not f.endswith(".fontdata"):
            continue
        if not os.path.exists(os.path.join(TRAN, rel)):
            removed.append(rel)

for rel in changed:
    dst = os.path.join(RES, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(os.path.join(TRAN, rel), dst)
    print("+", rel)

for rel in removed:
    os.remove(os.path.join(RES, rel))
    print("-", rel)

print("done: updated", len(changed), "files, removed", len(removed))
