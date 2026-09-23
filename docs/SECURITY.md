# Security Model

> What is protected, how, and what you can verify.

## Principles

1. **Isolation by default.** Domains do not read each other. Ever.
2. **Explicit override.** Cross-domain access requires a matched rule.
3. **Copy, not link.** Approved data is duplicated, not exposed.
4. **Append-only audit.** Every action leaves a permanent record.
5. **Timeout = deny.** Silence is not consent.
6. **The human decides the gray areas.** Policy handles routine; you handle the rest.

## What Is Protected

| Data | Who can read | Who can write |
|------|--------------|---------------|
| 01_Personal | You + Personal agents | You + Personal agents |
| 02_Client | Client agents + Audit + you | Client agents + you |
| 03_Venture | Venture agents + Audit + you | Venture agents + you |
| 04_Shared | Everyone | You + assigned agents |
| 00_Communication | Communication Agent + you | Communication Agent + all agents (inboxes only) |
| 04_Shared/00_Governance | Everyone (read) | You only (write) |

Hard rules that override everything:

- No agent writes into 01_Personal except Personal agents.
- No agent modifies 04_Shared/00_Governance. Ever.
- Client-origin requests cannot reach Venture data.
- Venture-origin requests cannot reach Client data.

## How Cross-Domain Access Works

Domains do not share a filesystem view. They share a request queue.

    1. Agent writes an access request to Pending/.
    2. Communication Agent evaluates against ACCESS_POLICY.yaml.
    3. Three verdicts:
       - auto_approve: sanitized copy lands in requester's _Inbound/.
       - auto_deny: logged, requester told why.
       - escalate: you decide; 72h timeout = deny.
    4. Every step is appended to the master log.

The requester never sees the original file. It sees a sanitized copy. The
original path is not exposed.

## Redaction

Every approval can specify redactions. By default, these patterns are always
stripped from any cross-domain copy:

    **/_private/**
    **/secrets/**
    **/.env
    **/*.key
    **/*.pem

You can add more per rule by setting `redact:` in ACCESS_POLICY.yaml.

## The Master Log

Location:

    00_Communication/40_Access_Log/master/YYYY-MM/master.log

Every line:

    <ISO8601-UTC> | <event> | <request_id> | <from> | <to> | <verdict> | <detail>

Events include:

    request_received
    rule_matched
    verdict_issued
    file_copied
    file_redacted
    delivered
    digest_written
    escalation_raised
    timeout_deny
    decision_applied

The log is append-only. It is never edited, truncated, or rotated manually.

## What the Communication Agent Cannot Do

- It cannot approve a request that violates ACCESS_POLICY.yaml.
- It cannot modify policy files.
- It cannot write into a domain except that domain's _Inbound/.
- It cannot skip logging.
- It cannot deliver a file that matches a redaction pattern.
- It cannot act on a decision only you can make.

## What Agents Cannot Do

Regardless of role, no agent may:

- Delete, rename, or move human-authored notes.
- Edit governance files.
- Send vault content off the machine.
- Make network calls (unless PAID_MODELS_ALLOWED is true).
- Write outside its domain and _Inbound/.
- Exceed rate limits (20/hour per domain, 10/day per agent).

## Threat Model

What this system defends against:

- **Prompt injection from a compromised agent.** Blocked by filesystem scope
  enforcement at the runtime layer, not by prompts.
- **Accidental cross-domain leakage.** Blocked by the airlock and by copy-only
  delivery.
- **Silent policy violations.** Blocked by the append-only log.
- **Unauthorized cross-domain reads.** Blocked by deny-by-default and by the
  request-only interface.

What this system does **not** defend against:

- A malicious actor with root access to your machine.
- Malicious code inside the Ollama model itself.
- You making a policy change that permits what you did not intend.

For those, rely on OS-level security and on reading the master log.

## How to Audit

For any given action:

    1. Find the request_id in 30_Access_Requests/.
    2. Grep the master log for that request_id.
    3. Read the sequence of events.
    4. Verify the delivered file's SHA256 in the delivery manifest.

For periodic review:

    grep 'auto_deny' 00_Communication/40_Access_Log/master/*/master.log
    grep 'escalation' 00_Communication/40_Access_Log/master/*/master.log
    grep 'timeout_deny' 00_Communication/40_Access_Log/master/*/master.log

## Changing the Rules

Open ACCESS_POLICY.yaml. Edit. Save. The next evaluation uses the new rules.
No restarts, no agent reloads.

Rules are evaluated top-down. First match wins. To make a rule take
precedence, move it up.

To test a change safely:

    1. Back up the current policy.
    2. Add the new rule.
    3. Send a test request.
    4. Verify the log.
    5. Roll back if needed.

## Emergency Procedures

If you suspect an agent is misbehaving:

    1. Kill the scheduler. No agent runs.
    2. Inspect the last 100 lines of the master log.
    3. Rename 30_Access_Requests/Pending/ to Pending.lock/.
    4. Investigate, then restore.

If you lose a file:

    Restore from your backup:
        ~/vault-backup-<timestamp>/vault.tar.gz

If a policy change causes problems:

    Restore the previous ACCESS_POLICY.yaml from git or backup.
