#!/usr/bin/env python3
"""
run_agent.py -- Agentic Enterprise executor (Phase 2b.1: skeleton)

Usage:
    python3 run_agent.py --vault /path/to/vault --agent communication-agent
    python3 run_agent.py --vault /path/to/vault --agent client-ceo --context domain=client

Behavior (Phase 2b.1):
  - Loads runtime.yaml
  - Resolves the agent's read_scope and write_scope
  - Loads the agent's prompt template
  - Substitutes {{PLACEHOLDERS}} from the context
  - Prints a dry-run plan
  - Makes NO LLM calls and writes NO files

Future phases add: LLM call, context assembly, write enforcement, master log.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    print("ERROR: pyyaml required. Install with: pip3 install pyyaml", file=sys.stderr)
    sys.exit(2)


# ---------------------------------------------------------------
# Data model
# ---------------------------------------------------------------

@dataclass
class AgentPlan:
    """Everything the executor knows before it does anything."""
    vault: Path
    runtime_config: dict[str, Any]
    agent_name: str
    prompt_path: Path
    prompt_template: str
    prompt_rendered: str
    read_scope: list[str] = field(default_factory=list)
    write_scope: list[str] = field(default_factory=list)
    model: str = ""
    placeholders: dict[str, str] = field(default_factory=dict)
    warnings: list[str] = field(default_factory=list)


# ---------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------

PLACEHOLDER_RE = re.compile(r"\{\{([A-Z_][A-Z0-9_]*)\}\}")


def load_runtime(vault: Path) -> dict[str, Any]:
    path = vault / "99_Agent_Workspace" / "config" / "runtime.yaml"
    if not path.is_file():
        raise FileNotFoundError(f"runtime.yaml not found: {path}")
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def find_prompt(vault: Path, agent_name: str) -> Path:
    """
    Map an agent name to a prompt file.

    Rules:
      - "communication-agent"  -> prompts/communication-agent.md
      - "client-ceo"           -> prompts/ceo-agent.md
      - "venture-lead"         -> prompts/lead-agent.md
      - "personal-worker-01"   -> prompts/worker-agent.md
    """
    prompts_dir = vault / "99_Agent_Workspace" / "prompts"

    # Direct match first
    direct = prompts_dir / f"{agent_name}.md"
    if direct.is_file():
        return direct

    # Role-based mapping
    if agent_name.endswith("-ceo"):
        role_file = prompts_dir / "ceo-agent.md"
    elif "lead" in agent_name:
        role_file = prompts_dir / "lead-agent.md"
    elif "worker" in agent_name:
        role_file = prompts_dir / "worker-agent.md"
    elif agent_name == "communication-agent" or agent_name.startswith("comms-"):
        role_file = prompts_dir / "communication-agent.md"
    else:
        role_file = prompts_dir / "worker-agent.md"

    if not role_file.is_file():
        raise FileNotFoundError(f"No prompt template for agent '{agent_name}' in {prompts_dir}")
    return role_file


def resolve_placeholders_from_agent(
    agent_name: str, extra_context: dict[str, str]
) -> dict[str, str]:
    """
    Derive the domain-related placeholders from the agent name and any
    explicitly passed --context key=value pairs.
    """
    ctx: dict[str, str] = dict(extra_context)

    # Derive domain from agent name prefix
    for prefix, domain, domain_path in [
        ("personal", "personal", "01_Personal"),
        ("client", "client", "02_Client"),
        ("venture", "venture", "03_Venture"),
    ]:
        if agent_name.startswith(prefix):
            ctx.setdefault("DOMAIN", domain)
            ctx.setdefault("DOMAIN_PATH", domain_path)
            break

    # Discipline derivation (for lead / worker prompts)
    for disc, disc_path in [
        ("dev", "10_Dev"),
        ("design", "20_Design"),
        ("marketing", "30_Marketing"),
        ("research", "40_Research"),
        ("growth", "80_Growth"),
        ("sales", "80_Sales"),
    ]:
        if disc in agent_name:
            ctx.setdefault("DISCIPLINE", disc)
            ctx.setdefault("DISCIPLINE_PATH", disc_path)
            break

    # Worker ID = the full agent name
    ctx.setdefault("YOUR_ID", agent_name)

    # Lead name: "<Discipline>-Lead" capitalized when derivable
    if "DISCIPLINE" in ctx:
        ctx.setdefault("LEAD", ctx["DISCIPLINE"].capitalize() + "-Lead")

    # Worker cap from runtime defaults
    ctx.setdefault("MAX_WORKERS", str(extra_context.get("MAX_WORKERS", "3")))

    return ctx


def render(template: str, ctx: dict[str, str]) -> tuple[str, list[str]]:
    """
    Replace {{PLACEHOLDER}} tokens. Returns (rendered, unresolved_names).
    Unresolved names are left in the output as-is so the caller can warn.
    """
    unresolved: list[str] = []

    def sub(match: re.Match[str]) -> str:
        name = match.group(1)
        if name in ctx:
            return str(ctx[name])
        unresolved.append(name)
        return match.group(0)

    rendered = PLACEHOLDER_RE.sub(sub, template)
    # Deduplicate while preserving order
    seen = set()
    deduped = []
    for name in unresolved:
        if name not in seen:
            seen.add(name)
            deduped.append(name)
    return rendered, deduped




# ---------------------------------------------------------------
# Ollama integration (Phase 2b.2)
# ---------------------------------------------------------------
# PHASE_2B2_MARKER

# PHASE_2B2_FIX_MARKER
def ollama_generate(
    host: str,
    model: str,
    prompt: str,
    timeout_seconds: int = 120,
    stream: bool = True,
) -> tuple[bool, str, str]:
    """
    Send a prompt to Ollama. Returns (success, response_text, error_text).

    Uses /api/generate with stream=true so we can print tokens live.
    Non-stream mode returns the full text at once.
    """
    url = host.rstrip("/") + "/api/generate"
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": stream,
        "options": {
            "temperature": 0.3,
            "num_ctx": 4096,
            "num_predict": 4096,
        },
    }

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout_seconds) as resp:
            if not stream:
                body = resp.read().decode("utf-8")
                try:
                    parsed = json.loads(body)
                    return True, parsed.get("response", ""), ""
                except json.JSONDecodeError:
                    return True, body, ""

            # Stream mode: read line-by-line, print tokens live, accumulate
            chunks: list[str] = []
            for raw_line in resp:
                line = raw_line.decode("utf-8").strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                piece = obj.get("response", "")
                if piece:
                    sys.stdout.write(piece)
                    sys.stdout.flush()
                    chunks.append(piece)
                if obj.get("done"):
                    break
            sys.stdout.write("\n")
            return True, "".join(chunks), ""

    except urllib.error.URLError as e:
        return False, "", f"Ollama connection failed: {e}"
    except TimeoutError:
        return False, "", f"Ollama timed out after {timeout_seconds}s"
    except Exception as e:
        return False, "", f"Ollama error: {type(e).__name__}: {e}"


def resolve_ollama_host(runtime: dict) -> str:
    return (runtime.get("ollama") or {}).get("host", "http://localhost:11434")


def resolve_ollama_timeout(runtime: dict) -> int:
    return int(
        ((runtime.get("ollama") or {}).get("timeouts") or {}).get(
            "generate_seconds", 120
        )
    )



# ---------------------------------------------------------------
# Context assembly (Phase 2b.3)
# ---------------------------------------------------------------
# PHASE_2B3_MARKER

import fnmatch
import datetime as _dt


# Mapping: agent role -> (governance files, inbox dir, plan dir)
ROLE_CONTEXT = {
    "ceo": {
        "governance": [
            # Contract is baked into the prompt template. Not read here.
        ],
        "inbox_template": "00_Communication/20_Outbox_To_Domains/{Domain}/",
        "reports_template": "00_Communication/10_Inbox_From_Domains/{Domain}/",
        "plans_template": "99_Agent_Workspace/plans/{domain}/",
    },
    "lead": {
        "governance": [
            "04_Shared/00_Governance/AGENTS.md",
        ],
        "inbox_template": "99_Agent_Workspace/plans/{domain}/",
        "reports_template": "",
        "plans_template": "",
    },
    "worker": {
        "governance": [],
        "inbox_template": "",
        "reports_template": "",
        "plans_template": "",
    },
    "communication": {
        "governance": [
            "04_Shared/00_Governance/AGENTS.md",
            "04_Shared/00_Governance/ACCESS_POLICY.yaml",
            "00_Communication/00_Agent/Identity.md",
        ],
        "inbox_template": "00_Communication/30_Access_Requests/Pending/",
        "reports_template": "",
        "plans_template": "",
    },
    "audit": {
        "governance": [
            "04_Shared/00_Governance/AGENTS.md",
        ],
        "inbox_template": "",
        "reports_template": "",
        "plans_template": "",
    },
}


def classify_agent(agent_name: str) -> str:
    """Return 'ceo', 'lead', 'worker', 'communication', or 'audit'."""
    if agent_name == "communication-agent" or agent_name.startswith("comms-"):
        return "communication"
    if agent_name.startswith("audit-"):
        return "audit"
    if agent_name.endswith("-ceo"):
        return "ceo"
    if "lead" in agent_name:
        return "lead"
    return "worker"


def path_in_scope(rel_path: str, scopes: list[str]) -> bool:
    """Check whether rel_path matches any of the glob patterns in scopes."""
    for pattern in scopes:
        # Patterns like '02_Client/**' -> match '02_Client' and everything below.
        if pattern.endswith("/**"):
            root = pattern[:-3]  # strip '/**'
            if rel_path == root or rel_path.startswith(root + "/"):
                return True
        elif fnmatch.fnmatch(rel_path, pattern):
            return True
    return False


def read_file_capped(path: Path, max_chars: int) -> str:
    """Read a file, capping at max_chars. Append a truncation note if needed."""
    try:
        content = path.read_text(encoding="utf-8")
    except Exception as e:
        return f"[could not read {path.name}: {e}]"
    if len(content) > max_chars:
        return content[:max_chars] + f"\n\n[... truncated at {max_chars} chars; full file is {len(content)} chars ...]"
    return content


def list_files_recursive(root: Path, pattern: str = "**/*") -> list[Path]:
    """List files under root matching pattern. Returns [] if root missing."""
    if not root.is_dir():
        return []
    return sorted([p for p in root.glob(pattern) if p.is_file()])


def assemble_context(plan: "AgentPlan") -> dict:
    """
    Assemble the context block for the agent's prompt.
    Returns a dict with keys: governance, inbox, recent_activity, task,
    files_considered, files_used, files_skipped_scope.
    """
    vault = plan.vault
    scopes = plan.read_scope
    role = classify_agent(plan.agent_name)
    cfg = ROLE_CONTEXT.get(role, ROLE_CONTEXT["worker"])

    domain = plan.placeholders.get("DOMAIN", "")
    domain_cap = domain.capitalize() if domain else ""

    files_considered = 0
    files_used = 0
    files_skipped_scope = 0

    # --- Governance ---
    gov_parts = []
    for rel in cfg["governance"]:
        p = vault / rel
        files_considered += 1
        if not path_in_scope(rel, scopes):
            files_skipped_scope += 1
            continue
        if p.is_file():
            gov_parts.append(f"### {rel}\n\n{read_file_capped(p, 6000)}")
            files_used += 1

    # --- Inbox ---
    inbox_parts = []
    inbox_tpl = cfg.get("inbox_template", "")
    if inbox_tpl and "{" in inbox_tpl:
        inbox_rel = inbox_tpl.format(Domain=domain_cap, domain=domain)
        inbox_dir = vault / inbox_rel
        for p in list_files_recursive(inbox_dir, "**/*.md"):
            files_considered += 1
            rel = p.relative_to(vault).as_posix()
            if not path_in_scope(rel, scopes):
                files_skipped_scope += 1
                continue
            inbox_parts.append(f"### {rel}\n\n{read_file_capped(p, 4000)}")
            files_used += 1

    # --- Recent plans ---
    plan_parts = []
    plans_tpl = cfg.get("plans_template", "")
    if plans_tpl and "{" in plans_tpl:
        plans_rel = plans_tpl.format(domain=domain)
        plans_dir = vault / plans_rel
        plan_files = list_files_recursive(plans_dir, "**/*.md")[-5:]
        for p in plan_files:
            files_considered += 1
            rel = p.relative_to(vault).as_posix()
            if not path_in_scope(rel, scopes):
                files_skipped_scope += 1
                continue
            plan_parts.append(f"### {rel}\n\n{read_file_capped(p, 2000)}")
            files_used += 1

    # --- Task directive ---
    if role == "ceo":
        task = (
            "Read the brief(s) in YOUR INBOX above. Produce a plan that: "
            "(1) states the objective in one line, (2) lists 3-5 concrete "
            "steps, (3) names which Lead owns each step, (4) names the "
            "deliverable files that will be produced, (5) lists at most 3 "
            "open questions, (6) states any Human Action Required. "
            "Follow the OUTPUT FORMAT in your system prompt exactly. "
            "Do NOT invent file paths that are not supported by the brief. "
            "Do NOT produce placeholders like '[insert here]'."
        )
    elif role == "communication":
        task = (
            "Read the pending access requests above. For each: evaluate "
            "against ACCESS_POLICY.yaml. Produce a verdict note per the "
            "Communication Agent output format. Do not take any file action."
        )
    elif role == "lead":
        task = (
            "Read the task in YOUR INBOX above. Produce a plan with at most "
            "5 bullets naming the workers you will spawn and what each "
            "will produce."
        )
    else:
        task = (
            "Read the task in YOUR INBOX above. Produce one artifact that "
            "answers it."
        )

    # --- Compose final context block ---
    sections = []
    if gov_parts:
        sections.append("=== GOVERNANCE ===\n\n" + "\n\n".join(gov_parts))
    if inbox_parts:
        sections.append("=== YOUR INBOX ===\n\n" + "\n\n".join(inbox_parts))
    if plan_parts:
        sections.append("=== RECENT ACTIVITY ===\n\n" + "\n\n".join(plan_parts))
    sections.append("=== YOUR TASK ===\n\n" + task)

    context_text = "\n\n".join(sections)

    return {
        "text": context_text,
        "files_considered": files_considered,
        "files_used": files_used,
        "files_skipped_scope": files_skipped_scope,
    }




# ---------------------------------------------------------------
# Write directives (Phase 2b.4)
# ---------------------------------------------------------------
# PHASE_2B4_MARKER

import hashlib
import os as _os

WRITES_FENCE_RE = re.compile(
    r"```agent-writes\s*\n(.*?)\n```",
    re.DOTALL,
)


def parse_write_directives(response_text: str) -> tuple[list[dict], list[str]]:
    """
    Extract `agent-writes` YAML blocks from the model's response.
    Returns (directives, parse_errors).
    """
    directives: list[dict] = []
    errors: list[str] = []

    for match in WRITES_FENCE_RE.finditer(response_text):
        block = match.group(1)
        try:
            parsed = yaml.safe_load(block) or {}
        except yaml.YAMLError as e:
            errors.append(f"YAML parse error in agent-writes block: {e}")
            continue

        writes = parsed.get("writes") if isinstance(parsed, dict) else None
        if not isinstance(writes, list):
            errors.append("agent-writes block missing 'writes:' list")
            continue

        for i, w in enumerate(writes):
            if not isinstance(w, dict):
                errors.append(f"write #{i+1}: not a dict")
                continue
            directives.append(w)

    return directives, errors


def normalize_rel_path(rel_path: str) -> str:
    """
    Normalize a vault-relative path:
      - Strip leading '/'
      - Collapse '//' and '/./'
      - Resolve '../' (reject if it escapes)
    Returns '' if the path is invalid or escapes the vault.
    """
    if not rel_path or not isinstance(rel_path, str):
        return ""
    p = rel_path.strip().lstrip("/")
    # Reject absolute Windows-ish drive letters and schemes
    if re.match(r"^[a-zA-Z]:", p) or p.startswith("~"):
        return ""
    # Split, resolve dot segments
    parts = []
    for seg in p.split("/"):
        if seg in ("", "."):
            continue
        if seg == "..":
            if not parts:
                return ""  # escapes vault
            parts.pop()
        else:
            parts.append(seg)
    return "/".join(parts)


def is_in_write_scope(rel_path: str, scopes: list[str]) -> bool:
    return path_in_scope(rel_path, scopes)


def is_forbidden(rel_path: str, forbidden: list[str]) -> str | None:
    """Return the matched forbidden pattern, or None."""
    for pattern in forbidden:
        if pattern.endswith("/**"):
            root = pattern[:-3]
            if rel_path == root or rel_path.startswith(root + "/"):
                return pattern
        elif fnmatch.fnmatch(rel_path, pattern):
            return pattern
    return None


def sha256_of(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]


def log_event(log_dir: Path, agent: str, event: str, path: str,
              result: str, detail: str = "") -> None:
    """
    Append one JSON line to the master log for the current month.
    Creates the log directory if missing.
    """
    try:
        log_dir.mkdir(parents=True, exist_ok=True)
        log_file = log_dir / "master.log"
        entry = {
            "ts": _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
            "event": event,
            "agent": agent,
            "path": path,
            "result": result,
            "detail": detail,
        }
        with log_file.open("a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception as e:
        sys.stderr.write(f"[log_event] failed: {e}\n")


def execute_writes(
    plan: "AgentPlan",
    directives: list[dict],
    runtime: dict,
    allow_writes: bool,
    dry_run: bool,
    max_writes: int,
) -> tuple[int, int, list[str]]:
    """
    Process each write directive.
    Returns (written_count, refused_count, notes).
    """
    vault = plan.vault
    scope = plan.write_scope
    forbidden = (runtime.get("forbidden_paths") or [])

    log_dir = vault / "00_Communication" / "40_Access_Log" / "master" / _dt.datetime.now().strftime("%Y-%m")
    agent = plan.agent_name

    written = 0
    refused = 0
    notes: list[str] = []

    if len(directives) > max_writes:
        notes.append(
            f"Too many writes ({len(directives)}); only first {max_writes} will be considered."
        )
        directives = directives[:max_writes]

    for i, d in enumerate(directives, start=1):
        raw_path = d.get("path", "")
        content = d.get("content", "")
        reason = d.get("reason", "")

        rel = normalize_rel_path(raw_path)
        if not rel:
            refused += 1
            notes.append(f"[{i}] REFUSED  {raw_path!r}  (invalid path)")
            log_event(log_dir, agent, "write_refused", str(raw_path), "invalid_path",
                      f"raw={raw_path!r}")
            continue

        # Forbidden check (overrides write_scope)
        fb = is_forbidden(rel, forbidden)
        if fb:
            refused += 1
            notes.append(f"[{i}] REFUSED  {rel}  (forbidden pattern: {fb})")
            log_event(log_dir, agent, "write_refused", rel, "forbidden", f"pattern={fb}")
            continue

        # Scope check
        if not is_in_write_scope(rel, scope):
            refused += 1
            notes.append(f"[{i}] REFUSED  {rel}  (outside write_scope)")
            log_event(log_dir, agent, "write_refused", rel, "out_of_scope",
                      f"scope_size={len(scope)}")
            continue

        # Integrity check: content must be a string
        if not isinstance(content, str) or not content.strip():
            refused += 1
            notes.append(f"[{i}] REFUSED  {rel}  (empty or non-string content)")
            log_event(log_dir, agent, "write_refused", rel, "empty_content", "")
            continue

        # Target path
        target = vault / rel
        # Defence-in-depth: ensure resolved path stays inside vault
        try:
            target.resolve().relative_to(vault.resolve())
        except ValueError:
            refused += 1
            notes.append(f"[{i}] REFUSED  {rel}  (path escapes vault)")
            log_event(log_dir, agent, "write_refused", rel, "escape", "")
            continue

        size = len(content)
        digest = sha256_of(content)

        if dry_run or not allow_writes:
            notes.append(f"[{i}] DRY-RUN  {rel}  ({size} bytes, sha={digest})  reason={reason!r}")
            log_event(log_dir, agent, "write_dryrun", rel, "ok", f"size={size} sha={digest}")
            continue

        # Actually write
        try:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content, encoding="utf-8")
            written += 1
            notes.append(f"[{i}] WRITTEN  {rel}  ({size} bytes, sha={digest})")
            log_event(log_dir, agent, "write_allowed", rel, "ok", f"size={size} sha={digest}")
        except Exception as e:
            refused += 1
            notes.append(f"[{i}] FAILED   {rel}  ({type(e).__name__}: {e})")
            log_event(log_dir, agent, "write_failed", rel, "exception", str(e))

    log_event(log_dir, agent, "run_writes_done", "-", "ok",
              f"written={written} refused={refused} dry_run={dry_run or not allow_writes}")

    return written, refused, notes


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def build_plan(vault: Path, agent_name: str, extra_context: dict[str, str]) -> AgentPlan:
    runtime = load_runtime(vault)

    prompt_path = find_prompt(vault, agent_name)
    prompt_template = prompt_path.read_text(encoding="utf-8")

    ctx = resolve_placeholders_from_agent(agent_name, extra_context)
    rendered, unresolved = render(prompt_template, ctx)

    # Scopes: prefer runtime.yaml direct match; else inherit from domain or role prefix.
    warnings: list[str] = []
    write_scope_map = runtime.get("write_scope") or {}
    read_scope_map = runtime.get("read_scope") or {}

    write_scope = write_scope_map.get(agent_name, [])
    read_scope = read_scope_map.get(agent_name, [])

    if not write_scope and not read_scope:
        # Pattern-based inheritance: agents inherit scope from their domain CEO.
        inherited_from = None
        for prefix, key in [
            ("personal-", "personal-ceo"),
            ("client-", "client-ceo"),
            ("venture-", "venture-ceo"),
            ("comms-", "communication-agent"),
            ("audit-", "audit-lead"),
        ]:
            if agent_name.startswith(prefix):
                inherited_from = key
                break
        if agent_name == "communication-agent":
            inherited_from = "communication-agent"

        if inherited_from:
            read_scope = read_scope_map.get(inherited_from, [])
            write_scope = write_scope_map.get(inherited_from, [])
            if read_scope or write_scope:
                warnings.append(
                    f"Scope inherited from '{inherited_from}' (no direct entry for '{agent_name}')."
                )

        if not write_scope and not read_scope:
            warnings.append(
                f"No read_scope/write_scope entry for '{agent_name}' and no matching domain prefix."
            )

    if unresolved:
        warnings.append(
            "Unresolved placeholders in prompt: " + ", ".join(f"{{{{{n}}}}}" for n in unresolved)
        )

    # Model resolution
    model = (
        (runtime.get("ollama") or {}).get("models", {}).get("default", "qwen2.5:7b")
    )

    return AgentPlan(
        vault=vault,
        runtime_config=runtime,
        agent_name=agent_name,
        prompt_path=prompt_path,
        prompt_template=prompt_template,
        prompt_rendered=rendered,
        read_scope=list(read_scope),
        write_scope=list(write_scope),
        model=model,
        placeholders=ctx,
        warnings=warnings,
    )


def print_plan(plan: AgentPlan, show_rendered: bool = False) -> None:
    v = plan.vault
    print("=" * 68)
    print(f"AGENT PLAN -- {plan.agent_name}")
    print("=" * 68)
    print()
    print(f"Vault           : {v}")
    print(f"Prompt file     : {plan.prompt_path}")
    print(f"Prompt size     : {len(plan.prompt_template)} bytes")
    print(f"Model           : {plan.model}")
    print()
    print("Placeholders:")
    if plan.placeholders:
        for k, val in sorted(plan.placeholders.items()):
            print(f"  {{{{{k}}}}}  =  {val}")
    else:
        print("  (none)")
    print()
    print("Read scope:")
    if plan.read_scope:
        for entry in plan.read_scope:
            print(f"  {entry}")
    else:
        print("  (none declared in runtime.yaml)")
    print()
    print("Write scope:")
    if plan.write_scope:
        for entry in plan.write_scope:
            print(f"  {entry}")
    else:
        print("  (none declared in runtime.yaml)")
    print()

    if plan.warnings:
        print("Warnings:")
        for w in plan.warnings:
            print(f"  ! {w}")
        print()

    print("Next steps (Phase 2b.2+):")
    print("  - assemble context from read_scope")
    print("  - call Ollama with the rendered prompt")
    print("  - enforce write_scope on any files the model proposes")
    print("  - append actions to master log")
    print()

    if show_rendered:
        print("-" * 68)
        print("RENDERED PROMPT")
        print("-" * 68)
        print(plan.prompt_rendered)
        print("-" * 68)

    print("DRY RUN COMPLETE -- no LLM call, no file writes.")


def parse_context(pairs: list[str]) -> dict[str, str]:
    ctx: dict[str, str] = {}
    for item in pairs:
        if "=" not in item:
            raise ValueError(f"--context expects KEY=VALUE, got: {item}")
        k, v = item.split("=", 1)
        ctx[k.strip().upper()] = v.strip()
    return ctx


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(
        prog="run_agent.py",
        description="Agentic Enterprise executor (Phase 2b.1: skeleton)",
    )
    p.add_argument("--vault", required=True, help="Path to the vault")
    p.add_argument("--agent", required=True, help="Agent name, e.g. communication-agent, client-ceo, venture-lead")
    p.add_argument(
        "--context",
        action="append",
        default=[],
        metavar="KEY=VALUE",
        help="Extra placeholders. Can be repeated. Keys are uppercased.",
    )
    p.add_argument(
        "--show-rendered",
        action="store_true",
        help="Also print the full rendered prompt.",
    )
    p.add_argument(
        "--call",
        action="store_true",
        help="Send the rendered prompt to Ollama. Without this flag, dry-run only.",
    )
    p.add_argument(
        "--no-stream",
        action="store_true",
        help="Disable streaming; wait for the full response before printing.",
    )
    p.add_argument(
        "--timeout",
        type=int,
        default=0,
        help="Override the Ollama generate timeout (seconds). 0 = use runtime.yaml.",
    )
    p.add_argument(
        "--model",
        default="",
        help="Override the model name (e.g. qwen2.5:7b, qwen2.5:3b).",
    )
    p.add_argument(
        "--no-context",
        action="store_true",
        help="Skip context assembly. Send only the rendered system prompt.",
    )
    p.add_argument(
        "--show-context",
        action="store_true",
        help="Print the assembled context block before sending to Ollama.",
    )
    p.add_argument(
        "--allow-writes",
        action="store_true",
        help="Enable write mode. Without this flag, all writes are refused.",
    )
    p.add_argument(
        "--write-dry-run",
        action="store_true",
        help="Parse and validate writes but do not write anything.",
    )
    p.add_argument(
        "--max-writes",
        type=int,
        default=10,
        help="Refuse if the model proposes more than N writes. Default 10.",
    )
    args = p.parse_args(argv)

    vault = Path(args.vault).expanduser().resolve()
    if not vault.is_dir():
        print(f"ERROR: vault not found: {vault}", file=sys.stderr)
        return 1

    try:
        extra = parse_context(args.context)
        plan = build_plan(vault, args.agent, extra)
    except (FileNotFoundError, ValueError) as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1

    print_plan(plan, show_rendered=args.show_rendered)

    # ----- Phase 2b.3: context assembly -----
    context_info = None
    final_prompt = plan.prompt_rendered

    if not args.no_context:
        print("=" * 68)
        print("CONTEXT ASSEMBLY")
        print("=" * 68)
        context_info = assemble_context(plan)
        print(f"Files considered  : {context_info['files_considered']}")
        print(f"Files used        : {context_info['files_used']}")
        print(f"Files skipped     : {context_info['files_skipped_scope']} (out of read_scope)")
        print(f"Context size      : {len(context_info['text'])} chars")
        print()
        if args.show_context:
            print("-" * 68)
            print("CONTEXT BLOCK")
            print("-" * 68)
            print(context_info["text"])
            print("-" * 68)
        # Compose the final prompt: system prompt + context
        final_prompt = (
            plan.prompt_rendered
            + "\n\n"
            + "# ============================================================\n"
            + "# CONTEXT (provided by the executor)\n"
            + "# ============================================================\n\n"
            + context_info["text"]
        )

    if not args.call:
        print("(dry-run: pass --call to send the prompt to Ollama)")
        return 0

    # ----- Phase 2b.2: LLM call -----
    host = resolve_ollama_host(plan.runtime_config)
    timeout = args.timeout or resolve_ollama_timeout(plan.runtime_config)
    model = args.model or plan.model

    print("=" * 68)
    print(f"OLLAMA CALL -- model={model} host={host} timeout={timeout}s")
    print("=" * 68)
    print()

    t0 = time.time()
    ok, response, error = ollama_generate(
        host=host,
        model=model,
        prompt=final_prompt,
        timeout_seconds=timeout,
        stream=not args.no_stream,
    )
    elapsed = time.time() - t0

    print()
    print("-" * 68)
    if ok:
        print(f"RESPONSE: {len(response)} chars, {elapsed:.1f}s")
        if args.no_stream:
            print()
            print("=" * 68)
            print("MODEL OUTPUT")
            print("=" * 68)
            print(response)
            print("=" * 68)
    else:
        print(f"ERROR: {error}")
        return 2
    print("-" * 68)

    if not ok:
        return 2

    # ----- Phase 2b.4: write directives -----
    directives, parse_errors = parse_write_directives(response)

    print()
    print("=" * 68)
    print(f"WRITE DIRECTIVES  ({len(directives)} found)")
    print("=" * 68)

    if parse_errors:
        print("Parse errors:")
        for e in parse_errors:
            print(f"  ! {e}")
        print()

    if not directives:
        print("(no writes proposed)")
        log_dir = plan.vault / "00_Communication" / "40_Access_Log" / "master" / _dt.datetime.now().strftime("%Y-%m")
        log_event(log_dir, plan.agent_name, "run_no_writes", "-", "ok",
                  f"elapsed={elapsed:.1f}s")
        return 0

    allow = args.allow_writes and not args.write_dry_run
    dry = args.write_dry_run or not args.allow_writes

    written, refused, notes = execute_writes(
        plan=plan,
        directives=directives,
        runtime=plan.runtime_config,
        allow_writes=allow,
        dry_run=dry,
        max_writes=args.max_writes,
    )

    print()
    for n in notes:
        print(f"  {n}")

    print()
    print("-" * 68)
    if dry:
        print(f"DRY-RUN: {len(directives)} directive(s) parsed, 0 written.")
        print("  Pass --allow-writes to execute.")
    else:
        print(f"RESULT: {written} written, {refused} refused.")
    print("-" * 68)

    log_dir = plan.vault / "00_Communication" / "40_Access_Log" / "master" / _dt.datetime.now().strftime("%Y-%m")
    log_event(log_dir, plan.agent_name, "run_completed", "-", "ok",
              f"writes={written} refused={refused} elapsed={elapsed:.1f}s")

    return 0


if __name__ == "__main__":
    sys.exit(main())
