#!/usr/bin/env python3
"""Patch _random_data0 in a .pp.S file by absolute byte address.

CV32E40S variant: supports 4-byte aligned addresses (RV32).
The .S file uses .dword (64-bit) entries stored little-endian, so a 4-byte
aligned address that is NOT 8-byte aligned targets the upper 32 bits of
the containing .dword.
"""
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path


DEFAULT_BASE = 0x80010000


@dataclass(frozen=True)
class Hit:
    line_no_1based: int
    word_idx_0based: int
    occ_in_line_0based: int
    label: str | None
    old_hex: str


HEX_RE = re.compile(r"0x[0-9a-fA-F]+")


def _parse_u64(s: str) -> int:
    s = s.strip().lower()
    if s.startswith("0x"):
        s = s[2:]
    if not s:
        raise ValueError("empty value")
    v = int(s, 16)
    if v < 0 or v > (1 << 64) - 1:
        raise ValueError("value out of u64 range")
    return v


def _fmt_u64(v: int) -> str:
    return f"0x{v:016x}"


def _replace_nth_hex(line: str, nth: int, new_hex: str) -> tuple[str, str]:
    matches = list(HEX_RE.finditer(line))
    if nth < 0 or nth >= len(matches):
        raise IndexError("nth out of range for line")
    m = matches[nth]
    old = m.group(0)
    return line[: m.start()] + new_hex + line[m.end() :], old


def patch_random_data0_pp(
    text: str, addr: int, new_val: int, base: int = DEFAULT_BASE
) -> tuple[str, Hit]:
    if addr < base:
        raise ValueError(f"addr {hex(addr)} < base {hex(base)}")
    off = addr - base
    if off % 4 != 0:
        raise ValueError(f"addr {hex(addr)} not 4-byte aligned relative to base {hex(base)}")

    # Which .dword (8-byte) entry contains this address?
    target_idx = off // 8
    # Does the address target the upper half (bytes 4..7) of the .dword?
    upper_half = (off % 8) == 4

    lines = text.splitlines(keepends=True)

    # Locate _random_data0 section
    start = None
    end = None
    for i, line in enumerate(lines):
        l = line.strip()
        if start is None and l == "_random_data0:":
            start = i
            continue
        if start is not None:
            if l.startswith("_end_data0:") or l.startswith(".section .data.random1"):
                end = i
                break
    if start is None:
        raise ValueError("cannot find _random_data0: label")
    if end is None:
        end = len(lines)

    word_idx = 0
    current_label = None
    for i in range(start + 1, end):
        line = lines[i]
        stripped = line.lstrip()
        m_label = re.match(r"^([A-Za-z0-9_\.]+):", stripped)
        if m_label:
            current_label = m_label.group(1)
        if ".dword" not in stripped:
            continue
        hexes = HEX_RE.findall(line)
        if not hexes:
            continue
        for occ in range(len(hexes)):
            if word_idx == target_idx:
                old_val = _parse_u64(hexes[occ])
                if upper_half:
                    # Patch only upper 32 bits, keep lower 32 bits
                    patched = ((new_val & 0xFFFFFFFF) << 32) | (old_val & 0xFFFFFFFF)
                else:
                    # 8-byte aligned: patch lower 32 bits, keep upper 32 bits
                    patched = (old_val & 0xFFFFFFFF00000000) | (new_val & 0xFFFFFFFF)
                new_hex = _fmt_u64(patched)
                new_line, old = _replace_nth_hex(line, occ, new_hex)
                lines[i] = new_line
                return "".join(lines), Hit(
                    line_no_1based=i + 1,
                    word_idx_0based=word_idx,
                    occ_in_line_0based=occ,
                    label=current_label,
                    old_hex=old,
                )
            word_idx += 1

    raise ValueError(
        f"addr {hex(addr)} (idx={target_idx}) out of _random_data0 range; scanned {word_idx} words"
    )


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Patch _random_data0 in .pp.S by absolute address (CV32E40S, 4-byte aligned)."
    )
    ap.add_argument("--file", default="import_from_hw_sw_fuzzer/input_0_a.pp.S")
    ap.add_argument("--base", default=hex(DEFAULT_BASE), help="Base address of _random_data0 (default 0x80010000)")
    ap.add_argument("--addr", required=True, help="Absolute byte address (hex), 4-byte aligned")
    ap.add_argument("--value", required=True, help="New value (hex, up to 64 bits; only lower 32 bits used for 4-byte patch)")
    ap.add_argument("--dry-run", action="store_true", help="Do not write, only report the would-be change")
    args = ap.parse_args()

    p = Path(args.file)
    base = int(str(args.base), 0)
    addr = int(str(args.addr), 0)
    val = _parse_u64(str(args.value))

    text = p.read_text(errors="ignore")
    new_text, hit = patch_random_data0_pp(text, addr=addr, new_val=val, base=base)

    print(f"file: {p}")
    print(f"base: {hex(base)} addr: {hex(addr)} idx: {hit.word_idx_0based}")
    print(f"hit : line={hit.line_no_1based} label={hit.label} occ={hit.occ_in_line_0based}")
    print(f"old : {hit.old_hex}")
    print(f"new : patched .dword")
    if args.dry_run:
        print("dry-run: not writing")
        return 0

    p.write_text(new_text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
