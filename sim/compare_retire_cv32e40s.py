#!/usr/bin/env python3
"""Compare retire timing between two CV32E40S VerilatedVcd traces.

CV32E40S exposes the retired PC through:
  - debug_pc_valid_o  (1-bit scalar)
  - debug_pc_o        (32-bit vector)

In these traces, debug_pc_valid_o may stay high across consecutive retired
instructions while debug_pc_o changes every cycle. Therefore retirement events
are sampled on posedge clk whenever debug_pc_valid_o == 1.
"""
from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path

DEFAULT_PC_MIN = 0x80000428
DEFAULT_PC_MAX = 0x80000718


@dataclass(frozen=True)
class RetireEvent:
    time: int
    pc: int | None


def _find_ids(path: str, want: list[str]) -> dict[str, str]:
    ids: dict[str, str] = {}
    with open(path, "r", errors="ignore") as f:
        for line in f:
            l = line.lstrip()
            if l.startswith("$var"):
                parts = l.split()
                if len(parts) >= 5:
                    _id = parts[3]
                    ref = parts[4]
                    if ref in want and ref not in ids:
                        ids[ref] = _id
            if "$enddefinitions" in l:
                break

    missing = [w for w in want if w not in ids]
    if missing:
        raise SystemExit(f"{path}: missing $var for {missing}")
    return ids


def extract_retire_events(
    path: str,
    *,
    clk_ref: str = "clk",
    retire_ref: str = "debug_pc_valid_o",
    pc_ref: str = "debug_pc_o",
) -> list[RetireEvent]:
    want = [clk_ref, retire_ref, pc_ref]
    ids = _find_ids(path, want)

    id_clk = ids[clk_ref]
    id_ret = ids[retire_ref]
    id_pc = ids[pc_ref]

    t = 0
    clk = 0
    ret = 0
    pc: int | None = None
    events: list[RetireEvent] = []

    with open(path, "r", errors="ignore") as f:
        for line in f:
            if not line:
                continue
            if line[0] == "#":
                try:
                    t = int(line[1:].strip())
                except ValueError:
                    pass
                continue

            s = line.strip()
            if not s:
                continue

            # vector update: b<bits> <id>
            if s[0] == "b":
                parts = s.split()
                if len(parts) == 2:
                    bits = parts[0][1:]
                    _id = parts[1]
                    if set(bits) <= set("01") and _id == id_pc:
                        pc = int(bits, 2)
                continue

            # scalar update: <0|1><id>
            v = s[0]
            _id = s[1:]
            if _id == id_clk and v in "01":
                new_clk = 1 if v == "1" else 0
                if clk == 0 and new_clk == 1 and ret == 1:
                    events.append(RetireEvent(time=t, pc=pc))
                clk = new_clk
            elif _id == id_ret and v in "01":
                nv = 1 if v == "1" else 0
                ret = nv

    return events


def _fmt_hex(x: int | None) -> str:
    if x is None:
        return "None"
    return hex(x)


def compare(a: list[RetireEvent], b: list[RetireEvent]) -> dict:
    n = min(len(a), len(b))

    count_equal = len(a) == len(b)
    pc_equal = all(a[i].pc == b[i].pc for i in range(n))
    offs = [b[i].time - a[i].time for i in range(n)]
    uniq_offs = sorted(set(offs))

    switch_idx = None
    if n:
        cur = offs[0]
        for i, o in enumerate(offs):
            if o != cur:
                switch_idx = i
                break

    return {
        "n_a": len(a),
        "n_b": len(b),
        "n_cmp": n,
        "count_equal": count_equal,
        "pc_equal": pc_equal,
        "uniq_offs": uniq_offs,
        "offs": offs,
        "switch_idx": switch_idx,
    }


def filter_events_by_pc(events: list[RetireEvent], pc_min: int, pc_max: int) -> list[RetireEvent]:
    return [ev for ev in events if ev.pc is not None and pc_min <= ev.pc <= pc_max]


def load_atom_counts(path: Path) -> dict[str, int]:
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text())
    except Exception:
        return {}
    if not isinstance(data, dict):
        return {}
    return {
        k: int(v)
        for k, v in data.items()
        if isinstance(k, str) and isinstance(v, int)
    }


def update_atom_file(path: Path, atom: str) -> None:
    atom_counts = load_atom_counts(path)
    atom_counts[atom] = atom_counts.get(atom, 0) + 1
    path.write_text(json.dumps(atom_counts, indent=2, sort_keys=True) + "\n")


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Compare retire timing between two CV32E40S VerilatedVcd traces."
    )
    ap.add_argument("trace_a")
    ap.add_argument("trace_b")
    ap.add_argument("--switch-context", type=int, default=3,
                    help="Print N events around offset switch point.")
    ap.add_argument(
        "--clk", dest="clk_ref", default="clk",
        help="VCD $var ref name for clock used to sample retire events.",
    )
    ap.add_argument(
        "--retire", dest="retire_ref", default="debug_pc_valid_o",
        help="VCD $var ref name for retire-valid signal.",
    )
    ap.add_argument(
        "--pc", dest="pc_ref", default="debug_pc_o",
        help="VCD $var ref name for retire PC.",
    )
    ap.add_argument("--atom",
                    help="Atom name to record into naive leak classification JSON files.")
    ap.add_argument(
        "--out-dir", default="output_result",
        help="Directory containing NAIVE_LEAK.json and NAIVE_NON_LEAK.json (default: output_result).",
    )
    args = ap.parse_args()

    ev_a = extract_retire_events(
        args.trace_a, clk_ref=args.clk_ref, retire_ref=args.retire_ref, pc_ref=args.pc_ref
    )
    ev_b = extract_retire_events(
        args.trace_b, clk_ref=args.clk_ref, retire_ref=args.retire_ref, pc_ref=args.pc_ref
    )
    ev_a = filter_events_by_pc(ev_a, DEFAULT_PC_MIN, DEFAULT_PC_MAX)
    ev_b = filter_events_by_pc(ev_b, DEFAULT_PC_MIN, DEFAULT_PC_MAX)
    res = compare(ev_a, ev_b)

    print(f"events: A={res['n_a']} B={res['n_b']} compared={res['n_cmp']}")
    print(f"event_count_equal: {res['count_equal']}")
    print(f"pc_sequence_equal: {res['pc_equal']}")
    print(f"offset_unique: {res['uniq_offs']}")

    naive_is_leak = (not res["count_equal"]) or (res["uniq_offs"] != [0])
    if args.atom:
        out_dir = Path(args.out_dir)
        out_dir.mkdir(parents=True, exist_ok=True)
        target = out_dir / ("NAIVE_LEAK.json" if naive_is_leak else "NAIVE_NON_LEAK.json")
        update_atom_file(target, args.atom)
        print(f"naive_classification: {'LEAK' if naive_is_leak else 'NON_LEAK'} atom={args.atom}")

    idx = res["switch_idx"]
    if idx is None:
        print("offset_switch: none")
        return 0

    print(f"offset_switch_at: idx0={idx} idx1={idx+1} dt={ev_b[idx].time - ev_a[idx].time}")
    print(f"  A: t={ev_a[idx].time} pc={_fmt_hex(ev_a[idx].pc)}")
    print(f"  B: t={ev_b[idx].time} pc={_fmt_hex(ev_b[idx].pc)}")

    k = args.switch_context
    lo = max(0, idx - k)
    hi = min(res["n_cmp"], idx + k + 1)
    print("context:")
    for i in range(lo, hi):
        dt = ev_b[i].time - ev_a[i].time
        print(
            f"  i={i} dt={dt} "
            f"A(t={ev_a[i].time},pc={_fmt_hex(ev_a[i].pc)}) "
            f"B(t={ev_b[i].time},pc={_fmt_hex(ev_b[i].pc)})"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
