#!/usr/bin/env python3
"""Schedule calculator for A05 (WBS) and A06 (Schedule).

Reads wbs.csv, the single source of the work packages and their estimates, and
regenerates every derived figure and date that the Workbook quotes, inside
named blocks:

    <!-- BEGIN GENERATED:<name> by schedule_calc.py --> ... <!-- END GENERATED:<name> -->

Blocks: wbs (wbs.md), schedule and reading (schedule.md), milestones
(charter-scope.md, A01 §9), targets (feasibility.md, A02 §4) and bpp
(baseline-project-plan.md, A07 §1). Dates are quoted nowhere else by hand. Run
from any directory after changing wbs.csv:

    python3 workbook/01-initiation/schedule_calc.py

Method (catalog B1): expected time ET = (o + 4r + p) / 6, standard deviation
(p - o) / 6, forward and backward passes for ES, EF, LS and LF, slack = LS - ES.
Level-of-effort packages (kind "loe") run alongside the span they cover and are
not on the network.

Units (ASM-052): hours of agent session time. Calendar dates are derived, not
estimated: session hours are converted to days at the pacing assumption
ASM-053 (HOURS_PER_DAY), counted from START_DATE.
"""
import csv
import math
import os
import re
from datetime import date, timedelta

HERE = os.path.dirname(os.path.abspath(__file__))
START_DATE = date(2026, 10, 21)   # Stage 1 start (the day this plan was written)
HOURS_PER_DAY = 3.0               # ASM-053 most likely pacing
PACING_RANGE = (2.0, 4.0)         # ASM-053 range: (slow, fast)

# Dates the plan is judged against. Each is sourced in A02 §4.
FIRST_MIDTERM_BY = date(2026, 11, 3)      # within 2 weeks of 2026-10-20 [USER Q-02]
EXAM_PERIOD_START = date(2026, 12, 7)     # [DOC ug_course_syllabus_template_doc_COMP4901B.docx.pdf p.2]
PROCESSED_BY = date(2026, 11, 30)         # SM-1 target (A01 §3, DEC-012)

# Processing load for the Computer Science lectures (A02 §4).
CS_LECTURES = (30, 78)                    # 3 modules x 10-26 lectures [ASM-051]
REVIEW_MIN_PER_LECTURE = (10, 25)         # [ASM-057]
RUN_MIN_PER_LECTURE = 15                  # [SEED §7 Performance] [ASM-037]
REVIEW_CAPACITY_H_PER_DAY = 1.5           # [ASM-063]

MILESTONE_LABELS = [  # (task id, label used in A01 §9 and A06)
    ("M1", "CP1: scope and plan approved"),
    ("M2", "CP2: requirements baseline and sourcing decision"),
    ("M3", "CP3: design baseline (ADVISORY)"),
    ("SL-05", "Pipeline complete: real lectures can be processed (after SL-05)"),
    ("M4", "R1 (MVP) ready: G5 and CP4 for R1"),
    ("M5", "R2 ready: G5 and CP4 for R2"),
    ("M6", "R3 ready: G5 and CP4 for R3"),
    ("M7", "Closedown: Gate G6"),
]


def load():
    with open(os.path.join(HERE, "wbs.csv"), newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    for r in rows:
        r["o"], r["r"], r["p"] = float(r["o"]), float(r["r"]), float(r["p"])
        r["et"] = (r["o"] + 4 * r["r"] + r["p"]) / 6
        r["sd"] = (r["p"] - r["o"]) / 6
        r["preds"] = [x for x in r["preds"].split(";") if x]
    return rows


def cpm(rows):
    all_by_id = {r["id"]: r for r in rows}
    net = [r for r in rows if r["kind"] != "loe"]
    by_id = {r["id"]: r for r in net}
    seen = set()
    for r in net:  # rows are listed in dependency order
        for p in r["preds"]:
            if p not in all_by_id:
                raise ValueError(f"Task {r['id']} references unknown predecessor {p!r}")
            if all_by_id[p]["kind"] == "loe":
                raise ValueError(f"Task {r['id']} cannot depend on level-of-effort row {p!r}")
            if p not in seen:
                raise ValueError(f"Task {r['id']} lists predecessor {p!r} out of topological order")
        r["es"] = max((by_id[p]["ef"] for p in r["preds"]), default=0.0)
        r["ef"] = r["es"] + r["et"]
        seen.add(r["id"])
    end = max(r["ef"] for r in net)
    succ = {r["id"]: [] for r in net}
    for r in net:
        for p in r["preds"]:
            succ[p].append(r["id"])
    for r in reversed(net):
        r["lf"] = min((by_id[s]["ls"] for s in succ[r["id"]]), default=end)
        r["ls"] = r["lf"] - r["et"]
        r["slack"] = r["ls"] - r["es"]
    for r in net:  # path SD and derived dates
        path = path_to(net, r["id"])
        r["path_sd"] = math.sqrt(sum(x["sd"] ** 2 for x in path))
        r["date"] = day(r["ef"])
        r["earliest"] = day(max(r["ef"] - 2 * r["path_sd"], 0), PACING_RANGE[1])
        r["latest"] = day(r["ef"] + 2 * r["path_sd"], PACING_RANGE[0])
    return net, end


def path_to(net, target):
    """Critical path from the start to `target`, following zero-slack predecessors."""
    by_id = {r["id"]: r for r in net}
    path, cur = [], by_id[target]
    while cur:
        path.append(cur)
        crit = [by_id[p] for p in cur["preds"] if abs(by_id[p]["ef"] - cur["es"]) < 1e-6]
        cur = crit[0] if crit else None
    return list(reversed(path))


def node(task_id):
    return "n" + re.sub(r"\W+", "_", task_id)


def day(hours, per_day=HOURS_PER_DAY):
    return START_DATE + timedelta(days=math.floor(hours / per_day + 1e-9))


def d(x):
    return f"{x.day} {x.strftime('%b')} {x.year}"


def d_short(x):
    return f"{x.day} {x.strftime('%b')}"


def f(x):
    return f"{x:.2f}"


def wbs_block(rows):
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
    ms = [r for r in rows if r["kind"] == "milestone"]
    total, ms_total = sum(r["et"] for r in leaves), sum(r["et"] for r in ms)
    out.append("")
    out.append(f"Work packages: {len(leaves)}, with a total expected time (ET) of {f(total)} h. "
               f"Gates and checkpoints (milestones in A06) add {f(ms_total)} h, "
               f"so all planned session time is {f(total + ms_total)} h.")
    return "\n".join(out)


def milestones_block(net):
    by_id = {r["id"]: r for r in net}
    out = [f"| Milestone | Derived date at {HOURS_PER_DAY:g} h/day | Range (earliest – latest) |",
           "| :-- | :-- | :-- |"]
    for tid, label in MILESTONE_LABELS:
        r = by_id[tid]
        out.append(f"| {label} | {d(r['date'])} | {d(r['earliest'])} – {d(r['latest'])} |")
    return "\n".join(out)


def verdict(r, needed):
    if r["latest"] <= needed:
        return "met, even in the slow case"
    if r["date"] <= needed:
        return f"met at {HOURS_PER_DAY:g} h/day; **not** met in the slow case"
    return f"**not met** at {HOURS_PER_DAY:g} h/day"


def targets_block(net):
    by_id = {r["id"]: r for r in net}
    m4, m5, m6, sl5 = by_id["M4"], by_id["M5"], by_id["M6"], by_id["SL-05"]
    out = [f"| Target | Needed by | Derived date at {HOURS_PER_DAY:g} h/day (range) | Result |",
           "| :-- | :-- | :-- | :-- |"]
    out.append(f"| R1 (MVP) before the first midterm | {d(FIRST_MIDTERM_BY)} | {d(m4['date'])} ({d(m4['earliest'])} – {d(m4['latest'])}) | {verdict(m4, FIRST_MIDTERM_BY)} |")
    out.append(f"| R1 in use before the exam period | {d(EXAM_PERIOD_START - timedelta(days=1))} | {d(m4['date'])} ({d(m4['earliest'])} – {d(m4['latest'])}) | {verdict(m4, EXAM_PERIOD_START - timedelta(days=1))} |")
    out.append(f"| Pipeline complete (SL-05), so processing can start | before {d(PROCESSED_BY)} (`DEC-012` SM-1) | {d(sl5['date'])} ({d(sl5['earliest'])} – {d(sl5['latest'])}) | {verdict(sl5, PROCESSED_BY)} |")
    for r, name in ((m5, "R2"), (m6, "R3")):
        out.append(f"| {name} before the exam period | none set by the student | {d(r['date'])} ({d(r['earliest'])} – {d(r['latest'])}) | {verdict(r, EXAM_PERIOD_START - timedelta(days=1))} |")
    out.append("")
    # Processing window and the student's review load (G1-r1, G1.10 c)
    lo_l, hi_l = CS_LECTURES
    run_lo, run_hi = lo_l * RUN_MIN_PER_LECTURE / 60, hi_l * RUN_MIN_PER_LECTURE / 60
    rev_lo, rev_hi = lo_l * REVIEW_MIN_PER_LECTURE[0] / 60, hi_l * REVIEW_MIN_PER_LECTURE[1] / 60
    out.append("**Processing the Computer Science lectures before " + d(PROCESSED_BY) + "**")
    out.append("")
    out.append(f"- Pipeline run time: {lo_l}–{hi_l} lectures × {RUN_MIN_PER_LECTURE} min = {run_lo:.1f}–{run_hi:.1f} h of Claude Code run time.")
    out.append(f"- Human review: {lo_l} × {REVIEW_MIN_PER_LECTURE[0]} min to {hi_l} × {REVIEW_MIN_PER_LECTURE[1]} min = {rev_lo:.1f}–{rev_hi:.1f} h of the student's active time.")
    out.append("")
    out.append(f"| Case | Processing window | Days | Review time needed per day | Review time that fits at {REVIEW_CAPACITY_H_PER_DAY:g} h/day (`ASM-063`) |")
    out.append("| :-- | :-- | --: | :-- | :-- |")
    for case, start in ((f"At {HOURS_PER_DAY:g} h/day", sl5["date"]), ("Slow case", sl5["latest"])):
        days = (PROCESSED_BY - start).days
        if days <= 0:
            out.append(f"| {case} | from {d(start)} | 0 | — | no: the window has closed |")
            continue
        lo, hi = rev_lo / days, rev_hi / days
        cap = REVIEW_CAPACITY_H_PER_DAY * days
        ok = (f"{cap:.1f} h: the whole load" if cap >= rev_hi else
              f"{cap:.1f} h: the load fits up to {cap:.1f} of {rev_hi:.1f} h" if cap >= rev_lo else
              f"{cap:.1f} h: not even the lowest load")
        out.append(f"| {case} | {d(start)} – {d(PROCESSED_BY)} | {days} | {lo:.2f}–{hi:.2f} h | {ok} |")
    return "\n".join(out)


def reading_block(net):
    by_id = {r["id"]: r for r in net}
    m4, m5, m6, sl5 = by_id["M4"], by_id["M5"], by_id["M6"], by_id["SL-05"]
    return "\n".join([
        f"- **R1 (MVP)** reaches its checkpoint after {m4['ef']:.0f} h of session time: {d(m4['date'])} at {HOURS_PER_DAY:g} h/day, "
        f"between {d(m4['earliest'])} and {d(m4['latest'])} across the range. Before the exam period: {verdict(m4, EXAM_PERIOD_START - timedelta(days=1))}.",
        f"- **The pipeline** is complete (SL-05) on {d(sl5['date'])} ({d(sl5['earliest'])} – {d(sl5['latest'])}). "
        "From then on, the Computer Science lectures can be processed for the SM-1 target (`DEC-012`); A02 §4 shows the student's review load.",
        f"- **R2 and R3** fall on {d(m5['date'])} and {d(m6['date'])} at {HOURS_PER_DAY:g} h/day, and as late as {d(m5['latest'])} and {d(m6['latest'])} in the slow case. "
        f"Before the exam period: R2 {verdict(m5, EXAM_PERIOD_START - timedelta(days=1))}; R3 {verdict(m6, EXAM_PERIOD_START - timedelta(days=1))}. "
        "Continuing straight on or pausing R2 and R3 until after the exams is decided at R1's CP4 (`DEC-010`).",
    ])


def schedule_block(rows, net, end):
    out = ["### Network calculation", "",
           "All figures are in hours of agent session time [ASM-052]. ET = (o + 4r + p) / 6; SD = (p − o) / 6; slack = LS − ES.", "",
           "| ID | Task | Predecessors | o | r | p | ET | SD | ES | EF | LS | LF | Slack | Critical |",
           "| :-- | :-- | :-- | --: | --: | --: | --: | --: | --: | --: | --: | --: | --: | :-: |"]
    for r in net:
        crit = "yes" if abs(r["slack"]) < 1e-6 else ""
        out.append(f"| {r['id']} | {r['name']} | {', '.join(r['preds']) or '—'} | {r['o']:g} | {r['r']:g} | {r['p']:g} | "
                   f"{f(r['et'])} | {f(r['sd'])} | {f(r['es'])} | {f(r['ef'])} | {f(r['ls'])} | {f(r['lf'])} | "
                   f"{f(abs(r['slack']))} | {crit} |")
    out.append("")
    loe = [r for r in rows if r["kind"] == "loe"]
    out.append("Level-of-effort packages, not on the network: " +
               "; ".join(f"{r['id']} {r['name']} ({r['deliverable']}, ET {f(r['et'])} h, spread over the span it covers)" for r in loe) + ".")
    out += ["", "### Milestones and derived dates", "",
            f"Dates count from {d(START_DATE)} at {HOURS_PER_DAY:g} h of session time per day, every day (`ASM-053`). "
            f"The range uses {PACING_RANGE[1]:g} h/day for the earliest date and {PACING_RANGE[0]:g} h/day for the latest, "
            "applied to ET − 2·SD and ET + 2·SD of the path, roughly a 95% band under PERT's assumptions.", "",
            f"| Milestone | EF (h) | Path SD (h) | Date at {HOURS_PER_DAY:g} h/day | Earliest (ET − 2SD at {PACING_RANGE[1]:g} h/day) | Latest (ET + 2SD at {PACING_RANGE[0]:g} h/day) |",
            "| :-- | --: | --: | :-- | :-- | :-- |"]
    by_id = {r["id"]: r for r in net}
    for tid, label in MILESTONE_LABELS:
        r = by_id[tid]
        out.append(f"| {tid}: {label} | {f(r['ef'])} | {f(r['path_sd'])} | {d(r['date'])} | {d(r['earliest'])} | {d(r['latest'])} |")
    crit = [r for r in net if abs(r["slack"]) < 1e-6]
    out += ["", f"Critical path: {' → '.join(r['id'] for r in crit)}.", "",
            f"Project length on the critical path: {f(end)} h ({len(crit)} tasks, all with zero slack).", "",
            "### Network diagram", "",
            "Each node shows the task ID, ET, ES–EF and LS–LF, in hours. Critical tasks are shaded.", "",
            "```mermaid", "flowchart TD"]
    groups = []
    for r in net:
        if r["group"] not in groups:
            groups.append(r["group"])
    for g in groups:
        out.append(f"  subgraph g_{re.sub(r'[^0-9A-Za-z]+', '_', g)}[\"{g}\"]")
        for r in net:
            if r["group"] == g:
                out.append(f"    {node(r['id'])}[\"{r['id']} · ET {r['et']:.2f} · ES–EF {r['es']:.2f}–{r['ef']:.2f} · LS–LF {r['ls']:.2f}–{r['lf']:.2f}\"]")
        out.append("  end")
    for r in net:
        for p in r["preds"]:
            out.append(f"  {node(p)} --> {node(r['id'])}")
    out.append("  classDef crit fill:#f9d5d3,stroke:#b03a2e,color:#000")
    out.append("  class " + ",".join(node(r["id"]) for r in crit) + " crit")
    last_task = [r for r in net if r["kind"] != "milestone"][-1]
    last_ms = [r for r in net if r["kind"] == "milestone"][-1]
    last_start = day(last_task["es"])
    last_end = max(last_task["date"], last_start + timedelta(days=1))
    ms_clause = (
        f", the same day as milestone {last_ms['id']}"
        if last_task["date"] == last_ms["date"]
        else f", while milestone {last_ms['id']} falls on {d_short(last_ms['date'])}"
    )
    out += ["```", "", "### Gantt chart", "",
            f"Bars use the derived dates at {HOURS_PER_DAY:g} h/day. Because Mermaid Gantt uses exclusive end dates and a minimum bar width of one day, a sub-day task on day D is drawn from D to D+1 (so bars within a day overlap, and {last_task['id']} on {d_short(last_task['date'])} is drawn {last_start} to {last_end}{ms_clause}).", "",
            "```mermaid", "gantt",
            f"  title Study App plan (dates derived at {HOURS_PER_DAY:g} h of session time per day, ASM-053)",
            "  dateFormat YYYY-MM-DD", "  axisFormat %d %b"]
    group = None
    for r in net:
        if r["group"] != group:
            group = r["group"]
            out.append(f"  section {group}")
        start = day(r["es"])
        name = re.sub(r"[:#;]", " ", f"{r['id']} {r['name']}")
        if r["kind"] == "milestone":
            out.append(f"  {name} :milestone, crit, {r['date']}, 0d")
        else:
            finish = max(r["date"], start + timedelta(days=1))
            out.append(f"  {name} :crit, {start}, {finish}")
    out.append("```")
    return "\n".join(out)


def bpp_block(rows, net, end):
    leaves = [r for r in rows if r["kind"] != "milestone"]
    ms = [r for r in rows if r["kind"] == "milestone"]
    total, ms_total = sum(r["et"] for r in leaves), sum(r["et"] for r in ms)
    by_id = {r["id"]: r for r in net}
    short = [("M1", "CP1"), ("M2", "CP2"), ("M3", "CP3"), ("SL-05", "pipeline"),
             ("M4", "R1"), ("M5", "R2"), ("M6", "R3"), ("M7", "closedown")]
    dates = "; ".join(
        f"{name} {d(by_id[tid]['date'])} ({d(by_id[tid]['earliest'])} – {d(by_id[tid]['latest'])})"
        for tid, name in short
    )
    return "\n".join([
        f"| [A05 WBS](wbs.md) | {len(leaves)} work packages with a total expected time of {f(total)} h of agent session time (plus {f(ms_total)} h of gates and checkpoints = {f(total + ms_total)} h in all); provisional slices SL-01 to SL-21, mapped to every seed story |",
        f"| [A06 Schedule](schedule.md) | **Network:** linear and resource-levelled, {f(end)} h of agent session time on the critical path ({len(net)} tasks, zero slack). **Derived dates at {HOURS_PER_DAY:g} h/day (earliest – latest):** {dates} |",
    ])


def apply_updates(updates):
    texts = {}
    for path, name, content in updates:
        if path not in texts:
            with open(path, encoding="utf-8") as fh:
                texts[path] = fh.read()
        pat = re.compile(
            r"(<!-- BEGIN GENERATED:" + re.escape(name) + r" [^>]*-->).*?(<!-- END GENERATED:" + re.escape(name) + r" -->)",
            re.S,
        )
        if not pat.search(texts[path]):
            raise SystemExit(f"No GENERATED:{name} markers in {path}")
        texts[path] = pat.sub(lambda m: m.group(1) + "\n" + content + "\n" + m.group(2), texts[path])

    tmp_pairs = []
    try:
        for path, new_text in texts.items():
            tmp_path = f"{path}.tmp.{os.getpid()}"
            with open(tmp_path, "w", encoding="utf-8") as fh:
                fh.write(new_text)
            tmp_pairs.append((tmp_path, path))
        for tmp_path, path in tmp_pairs:
            os.replace(tmp_path, path)
    finally:
        for tmp_path, _ in tmp_pairs:
            if os.path.exists(tmp_path):
                try:
                    os.remove(tmp_path)
                except OSError:
                    pass


if __name__ == "__main__":
    rows = load()
    net, end = cpm(rows)
    updates = [
        (os.path.join(HERE, "wbs.md"), "wbs", wbs_block(rows)),
        (os.path.join(HERE, "schedule.md"), "schedule", schedule_block(rows, net, end)),
        (os.path.join(HERE, "schedule.md"), "reading", reading_block(net)),
        (os.path.join(HERE, "charter-scope.md"), "milestones", milestones_block(net)),
        (os.path.join(HERE, "feasibility.md"), "targets", targets_block(net)),
        (os.path.join(HERE, "baseline-project-plan.md"), "bpp", bpp_block(rows, net, end)),
    ]
    apply_updates(updates)
    print("wbs.md, schedule.md, charter-scope.md (§9), feasibility.md (§4) and baseline-project-plan.md (§1) regenerated")
