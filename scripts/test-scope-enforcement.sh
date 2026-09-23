#!/usr/bin/env bash
# test-scope-enforcement.sh -- directly tests write_scope enforcement
# without relying on the LLM to produce malicious output.
set -euo pipefail

SCRIPT="$HOME/Desktop/MySecondBrain/99_Agent_Workspace/skills/run_agent.py"
VAULT="$HOME/Desktop/MySecondBrain"

python3 - "$SCRIPT" "$VAULT" << 'PYEOF'
import sys
from pathlib import Path

# Load the executor as a proper module.
import importlib.util

script_path = Path(sys.argv[1])
module_name = "run_agent"
spec = importlib.util.spec_from_file_location(module_name, script_path)
if spec is None or spec.loader is None:
    print(f"ERROR: could not load {script_path}")
    sys.exit(1)

run_agent = importlib.util.module_from_spec(spec)
# Register BEFORE exec_module so @dataclass can find the module.
sys.modules[module_name] = run_agent
spec.loader.exec_module(run_agent)

vault = Path(sys.argv[2])

# Build a plan for client-ceo.
plan = run_agent.build_plan(vault, "client-ceo", {})

print("=" * 68)
print("SCOPE ENFORCEMENT TEST")
print("=" * 68)
print()
print("Agent: client-ceo")
print("Write scope:")
for s in plan.write_scope:
    print(f"  {s}")
print()

test_cases = [
    ("02_Client/60_Engagements/AcmeCorp/10_Projects/Website-2026Q2/legit.md", "WRITTEN"),
    ("03_Venture/60_Ventures/leak-test/secret.txt",                          "REFUSED"),
    ("01_Personal/50_Wiki/leak-test.md",                                     "REFUSED"),
    ("04_Shared/00_Governance/AGENTS.md",                                    "REFUSED"),
    ("../escape-attempt.md",                                                 "REFUSED"),
    ("/etc/passwd",                                                          "REFUSED"),
    ("02_Client/../../03_Venture/breach.md",                                 "REFUSED"),
    ("00_Communication/40_Access_Log/master/fake.log",                       "REFUSED"),
]

directives = []
for path, _ in test_cases:
    directives.append({
        "path": path,
        "content": f"# Test content for {path}\n",
        "reason": f"Scope test: {path}",
    })

written, refused, notes = run_agent.execute_writes(
    plan=plan,
    directives=directives,
    runtime=plan.runtime_config,
    allow_writes=False,   # dry-run only
    dry_run=True,
    max_writes=100,
)

print("-" * 68)
print("RESULTS")
print("-" * 68)

passes = 0
fails = 0
for i, (path, expected) in enumerate(test_cases, start=1):
    note = next((n for n in notes if n.startswith(f"[{i}]")), "(missing)")
    if "REFUSED" in note:
        actual = "REFUSED"
    elif "DRY-RUN" in note or "WRITTEN" in note:
        actual = "WRITTEN"
    else:
        actual = "UNKNOWN"

    if actual == expected:
        marker = "PASS"
        passes += 1
    else:
        marker = "FAIL"
        fails += 1
    print(f"  [{marker}]  expected={expected:8s}  actual={actual:8s}  {path}")

print()
print(f"Passed: {passes}   Failed: {fails}")

# Edge cases
written2, refused2, _ = run_agent.execute_writes(
    plan=plan, directives=[], runtime=plan.runtime_config,
    allow_writes=False, dry_run=True, max_writes=10,
)
print(f"\nEmpty directives:  written={written2} refused={refused2}  (expected 0, 0)")

big_batch = [{"path": f"02_Client/test{i}.md", "content": "x", "reason": "t"} for i in range(20)]
w3, r3, n3 = run_agent.execute_writes(
    plan=plan, directives=big_batch, runtime=plan.runtime_config,
    allow_writes=False, dry_run=True, max_writes=5,
)
print(f"Max-writes=5 with 20 directives: notes={len(n3)}  (expected 5 + truncation note)")

print()
print("=" * 68)
if fails == 0:
    print("ALL SCOPE TESTS PASSED")
else:
    print(f"{fails} TEST(S) FAILED -- investigate")
print("=" * 68)

sys.exit(0 if fails == 0 else 1)
PYEOF
