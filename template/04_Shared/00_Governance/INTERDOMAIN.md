# INTERDOMAIN.md — Cross-Domain Protocol

Version: 1.0
Owner: {{OWNER_HANDLE}}
Effective: 2026-04-12

Binding protocol for all cross-domain communication. Operates together with
ACCESS_POLICY.yaml (the rules) and AGENTS.md (the contract).

## Core Rule

No domain reads another domain directly. Ever.
All cross-domain data flows through the Communication Agent.

## Request Lifecycle

1. A requesting agent writes a request note to:
   00_Communication/30_Access_Requests/Pending/req-YYYY-MM-DD-NNNN.md

2. The Communication Agent evaluates the request against
   04_Shared/00_Governance/ACCESS_POLICY.yaml.

3. The result is one of:
   - auto_approve   -> resource is copied (sanitized) into the requester's
                       _Inbound/req-YYYY-MM-DD-NNNN/ folder
   - auto_deny      -> request is logged, requester is notified with reason
   - escalate       -> notification written to 00_Communication/50_Notifications/;
                       NomadCoder has 72h to decide; timeout = deny

4. Every step is appended to the master log:
   00_Communication/40_Access_Log/master/YYYY-MM/master.log

## Request Format

Every access request is a Markdown file with this frontmatter:

    type: access-request
    request_id: req-2026-04-12-0001
    from_domain: personal
    from_agent: personal-engineer
    to_domain: client
    resource: "02_Client/60_Engagements/AcmeCorp/10_Projects/Website-2026Q2/"
    reason: "Learning React patterns used in a professional project."
    duration: read_once
    urgency: normal

Field meanings:
- request_id   : monotonic, unique per day
- from_domain  : personal | client | venture | shared
- from_agent   : the agent identifier
- to_domain    : personal | client | venture | shared
- resource     : glob or path inside the target domain
- reason       : one sentence, human-readable
- duration     : read_once | read_session | read_persistent
- urgency      : low | normal | high

## Response Format

The Communication Agent writes a response file with the same request_id into
one of:
- 00_Communication/30_Access_Requests/Auto_Approved/
- 00_Communication/30_Access_Requests/Auto_Denied/
- 00_Communication/30_Access_Requests/Escalated/

Response frontmatter:

    type: access-response
    request_id: req-2026-04-12-0001
    verdict: auto_approve | auto_deny | escalated
    evaluated_by: comms-broker-01
    evaluated_at: 2026-04-12T11:02:14Z
    matched_rule: personal-reads-client-deliverable
    delivered_to: 01_Personal/_Inbound/req-2026-04-12-0001/
    redactions_applied: ["**/financials/**", "**/contracts/**"]
    reason: "..."

## Guarantees

- Copy, not link. Originals are never exposed to the requester's filesystem.
- Redaction. Any path matching a rule's redact: list is stripped before copy.
- Sanitization. Files with markers from ACCESS_POLICY.yaml redaction.default_markers
  are never delivered.
- Append-only log. Every request, verdict, and delivery is timestamped.
- Timeout = deny. Silence is not consent.
- No write-through. Cross-domain requests never grant write access. Only reads.

## Handoff vs Access Request

Two distinct patterns:

- Access Request (this file): an agent needs to READ data from another domain.
  Mediated by the Communication Agent.

- Handoff: a domain transfers ownership of a deliverable to another domain.
  Example: Personal builds an MVP -> hands it to Venture for production.
  Handoffs are written as a special access-request with action: handoff and
  must always be escalated to NomadCoder. Ownership does not transfer until
  NomadCoder approves.

## What Is Never Allowed

- A Client agent reading Venture files, ever.
- A Venture agent reading Client files, ever.
- Any agent writing into Personal, ever.
- Any agent modifying governance files, ever.
- Any agent bypassing the Communication Agent for cross-domain data.

## Emergency Stop

If NomadCoder suspects misbehavior:
- Kill the scheduler -> no agent runs.
- Optionally rename 00_Communication/30_Access_Requests/Pending/ to
  Pending.lock/ -> all new requests are refused until restored.
- The master log remains intact for forensics.
