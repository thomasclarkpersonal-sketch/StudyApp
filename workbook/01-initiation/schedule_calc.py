#!/usr/bin/env python3
"""Schedule calculator for A05 (WBS) and A06 (Schedule).

Reads wbs.csv, the single source of the work packages and their estimates, and
regenerates the derived sections of wbs.md and schedule.md between the
"BEGIN GENERATED" and "END GENERATED" markers. Run from any directory:

    python3 workbook/01-initiation/schedule_calc.py

Method (catalog B1): expected time ET = (o + 4r + p) / 6, standard deviation
(p - o) / 6, forward and backward passes for ES, EF, LS and LF, slack = LS - ES.
Level-of-effort packages (kind "loe") run alongside the whole span they cover
and are not scheduled on the network.

Calendar dates are derived, not estimated: hours are converted to days at the
pacing assumption ASM-053 (HOURS_PER_DAY), counted from START_DATE.
"""
import csv
import math
import os
import re
from datetime import date, timedelta

HERE = os.path.dirname(os.path.abspath(__file__))
START_DATE = date(2026, 10, 21)   # Stage 1 start (the day this plan was written)
HOURS_PER_DAY = 3.0               # ASM-053 most likely pacing
PACING_RANGE = (2.0, 4.0)         # ASM-053 range
KEY_TASKS = {"SL-05": "pipeline complete: real lectures can be processed"}


def load():
    with open(os.path.join(HERE, "wbs.csv"), newline="") as f:
        rows = list(csv.DictReader(f))
    for r in rows:
        r["o"], r["r"], r["p"] = float(r["o"]), float(r["r"]), float(r["p"])
        r["et"] = (r["o"] + 4 * r["r"] + r["p"]) / 6
        r["sd"] = (r["p"] - r["o"]) / 6
        r["preds"] = [x for x in r["preds"].split(";") if x]
    return rows


def cpm(rows):
    net = [r for r in rows if r["kind"] != "loe"]
    by_id = {r["id"]: r for r in net}
    for r in net:  # rows are listed in dependency order
        r["es"] = max((by_id[p]["ef"] for p in r["preds"]), default=0.0)
        r["ef"] = r["es"] + r["et"]
    end = max(r["ef"] for r in net)
    succ = {r["id"]: [] for r in net}
    for r in net:
        for p in r["preds"]:
            succ[p].append(r["id"])
    for r in reversed(net):
        r["lf"] = min((by_id[s]["ls"] for s in succ[r["id"]]), default=end)
        r["ls"] = r["lf"] - r["et"]
        r["slack"] = r["ls"] - r["es"]
    return net, end


def path_to(net, target):
    """Critical path from the start to `target`, following zero-slack predecessors."""
    by_id = {r["id"]: r for r in net}
    path, cur = [], by_id[target]
    while cur:
        path.append(cur)
        crit = [by_id[p] for p in cur["preds"] if abs(by_id[p]["ef"] - cur["es"]) < 1e-9]
        cur = crit[0] if crit else None
    return list(reversed(path))


def node(task_id):
    return "n" + re.sub(r"\W+", "_", task_id)


def day(hours, per_day=HOURS_PER_DAY):
    return START_DATE + timedelta(days=math.floor(hours / per_day + 1e-9))


def f(x):
    return f"{x:.2f}"


def wbs_section(rows):
    out = ["| WBS | Work package | Deliverable | Owner role | Predecessors | o (h) | r (h) | p (h) | Source |",
           "| :-- | :-- | :-- | :-- | :-- | --: | --: | --: | :-- |"]
    group = None
    for r in rows:
        if r["kind"] == "milestone":
            continue
        if r["group"] != group:
            group = r["group"]
            out.append(f"| **{group}** | | | | | | | | |")
        preds = ", ".join(r["preds"]) or "—"
        kind = " (level of effort)" if r["kind"] == "loe" else ""
        out.append(f"| {r['id']} | {r['name']}{kind} | {r['deliverable']} | {r['owner']} | {preds} | "
                   f"{r['o']:g} | {r['r']:g} | {r['p']:g} | [ASM-052] |")
    leaves = [r for r in rows if r["kind"] != "milestone"]
    total = sum(r["et"] for r in leaves)
    out.append("")
    out.append(f"Work packages: {len(leaves)}. Sum of expected times (ET) over all work packages: {f(total)} h.")
    return "\n".join(out)


def schedule_section(rows):
    net, end = cpm(rows)
    out = []
    # Network table
    out.append("### Network calculation")
    out.append("")
    out.append("All figures are in hours of work [ASM-052]. ET = (o + 4r + p) / 6; SD = (p − o) / 6; slack = LS − ES.")
    out.append("")
    out.append("| ID | Task | Predecessors | o | r | p | ET | SD | ES | EF | LS | LF | Slack | Critical |")
    out.append("| :-- | :-- | :-- | --: | --: | --: | --: | --: | --: | --: | --: | --: | --: | :-: |")
    for r in net:
        crit = "yes" if abs(r["slack"]) < 1e-9 else ""
        out.append(f"| {r['id']} | {r['name']} | {', '.join(r['preds']) or '—'} | {r['o']:g} | {r['r']:g} | {r['p']:g} | "
                   f"{f(r['et'])} | {f(r['sd'])} | {f(r['es'])} | {f(r['ef'])} | {f(r['ls'])} | {f(r['lf'])} | "
                   f"{f(r['slack'])} | {crit} |")
    out.append("")
    loe = [r for r in rows if r["kind"] == "loe"]
    out.append("Level-of-effort packages, not on the network: " +
               "; ".join(f"{r['id']} {r['name']} ({r['deliverable']}, ET {f(r['et'])} h, spread over the span it covers)" for r in loe) + ".")
    out.append("")
    # Milestones
    out.append("### Milestones and derived dates")
    out.append("")
    out.append(f"Dates count from {START_DATE.isoformat()} at {HOURS_PER_DAY:g} h of work per day, every day (`ASM-053`). "
               f"The range columns use {PACING_RANGE[1]:g} h/day (earliest) and {PACING_RANGE[0]:g} h/day (latest), "
               "applied to ET − 2·SD and ET + 2·SD of the path, roughly a 95% band under PERT's assumptions.")
    out.append("")
    out.append("| Milestone | EF (h) | Path SD (h) | Date at 3 h/day | Earliest (ET − 2SD at 4 h/day) | Latest (ET + 2SD at 2 h/day) |")
    out.append("| :-- | --: | --: | :-- | :-- | :-- |")
    for r in net:
        if r["kind"] != "milestone" and r["id"] not in KEY_TASKS:
            continue
        label = f"{r['id']} {KEY_TASKS[r['id']]}" if r["id"] in KEY_TASKS else f"{r['id']} {r['name']}"
        path = path_to(net, r["id"])
        sd = math.sqrt(sum(x["sd"] ** 2 for x in path))
        lo, hi = max(r["ef"] - 2 * sd, 0), r["ef"] + 2 * sd
        out.append(f"| {label} | {f(r['ef'])} | {f(sd)} | {day(r['ef'])} | "
                   f"{day(lo, PACING_RANGE[1])} | {day(hi, PACING_RANGE[0])} |")
    out.append("")
    crit = [r for r in net if abs(r["slack"]) < 1e-9]
    out.append(f"Critical path: {' → '.join(r['id'] for r in crit)}.")
    out.append("")
    out.append(f"Project length on the critical path: {f(end)} h ({len(crit)} tasks, all with zero slack).")
    out.append("")
    # Mermaid network diagram
    out.append("### Network diagram")
    out.append("")
    out.append("Each node shows the task ID, ET, ES–EF and LS–LF, in hours. Critical tasks are shaded.")
    out.append("")
    out.append("```mermaid")
    out.append("flowchart TD")
    groups = []
    for r in net:
        if r["group"] not in groups:
            groups.append(r["group"])
    for g in groups:
        gid = "g_" + re.sub(r"\W+", "_", g)
        out.append(f"  subgraph {gid}[\"{g}\"]")
        for r in net:
            if r["group"] == g:
                out.append(f"    {node(r['id'])}[\"{r['id']} · ET {r['et']:.2f} · ES–EF {r['es']:.2f}–{r['ef']:.2f} · LS–LF {r['ls']:.2f}–{r['lf']:.2f}\"]")
        out.append("  end")
    for r in net:
        for p in r["preds"]:
            out.append(f"  {node(p)} --> {node(r['id'])}")
    out.append("  classDef crit fill:#f9d5d3,stroke:#b03a2e,color:#000")
    out.append("  class " + ",".join(node(r["id"]) for r in crit) + " crit")
    out.append("```")
    out.append("")
    # Mermaid Gantt
    out.append("### Gantt chart")
    out.append("")
    out.append(f"Bars use the derived dates at {HOURS_PER_DAY:g} h/day; tasks shorter than a day are drawn as one day.")
    out.append("")
    out.append("```mermaid")
    out.append("gantt")
    out.append("  title Study App plan (dates derived at 3 h of work per day, ASM-053)")
    out.append("  dateFormat YYYY-MM-DD")
    out.append("  axisFormat %d %b")
    group = None
    for r in net:
        if r["group"] != group:
            group = r["group"]
            out.append(f"  section {group}")
        start = day(r["es"])
        name = re.sub(r"[:#;]", " ", f"{r['id']} {r['name']}")
        if r["kind"] == "milestone":
            out.append(f"  {name} :milestone, crit, {day(r['ef'])}, 0d")
        else:
            finish = max(day(r["ef"]), start + timedelta(days=1))
            out.append(f"  {name} :crit, {start}, {finish}")
    out.append("```")
    return "\n".join(out)


def replace_generated(path, content):
    with open(path) as fh:
        text = fh.read()
    pat = re.compile(r"(<!-- BEGIN GENERATED[^>]*-->).*?(<!-- END GENERATED -->)", re.S)
    if not pat.search(text):
        raise SystemExit(f"No generated-section markers in {path}")
    text = pat.sub(lambda m: m.group(1) + "\n" + content + "\n" + m.group(2), text)
    with open(path, "w") as fh:
        fh.write(text)


if __name__ == "__main__":
    rows = load()
    replace_generated(os.path.join(HERE, "wbs.md"), wbs_section(rows))
    replace_generated(os.path.join(HERE, "schedule.md"), schedule_section(rows))
    print("wbs.md and schedule.md regenerated")
