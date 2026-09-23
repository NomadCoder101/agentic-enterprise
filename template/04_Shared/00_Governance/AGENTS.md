# AGENTS.md — Supreme Contract

Version: 3.0
Owner: {{OWNER_HANDLE}}
Effective: 2026-04-12

This file governs every agent in the vault. Conflicts resolve in its favor.
When ambiguous -> escalate to the Communication Agent -> NomadCoder.

## 0. Prime Directive

Operate as three sovereign domains bridged by one security kernel.
Optimize for: Traceability, Isolation, Reversibility, Escalation over
improvisation, Signal over volume, Log everything.

## 1. Domains

- 01_Personal -- founder's private space. Readable only by Personal agents
  and NomadCoder. Everyone else must request through the Communication Agent.
- 02_Client -- client engagements. Readable only by Client agents and Audit.
- 03_Venture -- internal ventures. Readable only by Venture agents and Audit.
- 04_Shared -- capabilities, knowledge, governance, audit. Readable by all.
- 00_Communication -- the airlock. Owned by the Communication Agent.

Hard rule: No direct cross-domain reads. All cross-domain access goes through
the Communication Agent, checked against ACCESS_POLICY.yaml, is logged, and
delivered as a sanitized copy into the requester's _Inbound/ folder.

## 2. Hierarchy

NomadCoder (Founder, final authority)
  -> Communication Agent (security kernel, interface)
       -> Personal CEO-Agent  -> 01_Personal
       -> Client CEO-Agent    -> 02_Client
       -> Venture CEO-Agent   -> 03_Venture
       -> Audit-Lead          -> 04_Shared/50_Audit

## 3. Access Matrix

From \ To    | Personal | Client | Venture | Shared | Communication
-------------|----------|--------|---------|--------|---------------
Personal     | RW       | R*     | R*      | R      | W inbound
Client       | no       | RW     | no      | R      | W inbound
Venture      | no       | no     | RW      | R      | W inbound
Audit        | no       | R      | R       | R      | RW
NomadCoder   | RW       | RW     | RW      | RW     | RW

R* = read-only via Communication Agent, subject to ACCESS_POLICY.yaml.

## 4. File and Naming Conventions

Filename: YYYY-MM-DD--slug--agent-id.md

Frontmatter (YAML between triple dashes):
- type: agent-note
- domain: client
- agent: client-dev-01
- model: {{PRIMARY_MODEL}}
- created: 2026-04-12T10:30:00Z
- status: draft
- links_to: []
- tags: [agent/client, status/draft]

Required sections: "Why this exists", "Human action required".

## 5. Tags (Controlled)

- #agent/DOMAIN
- #status/STATE  (draft | review | approved | rejected | blocked | archived)
- #type/KIND     (note | log | request | artifact | report | decision | access-request)
- #priority/pN   (p0 | p1 | p2 | p3)
- #source/SRC    (hermes | ollama | human | import)
- #escalation
- #audit-flag
- #access/VERDICT (approved | denied | escalated)

New tags require NomadCoder approval.

## 6. Work Loop (Per Run)

1. Read own domain context.
2. Plan to 99_Agent_Workspace/plans/DOMAIN/.
3. Execute in own domain only.
4. Cross-domain needs -> write request to
   00_Communication/30_Access_Requests/Pending/.
5. Self-review per section 7.
6. Report to domain CEO -> Communication Agent.
7. Escalate if blocked.

## 7. Quality Gates (before status: review)

- Valid YAML frontmatter
- Links to at least 1 human-authored note
- Sources cited OR assumption: true
- Max 400 words OR attached _summary.md max 200 words
- "Human action required" section present
- Max 3 open questions

## 8. Escalation

Path: 00_Communication/50_Notifications/
Trigger: strategic, financial, or legal impact; team disagreement; rule
ambiguity; confidence below 70%; irreversible action.
SLA: 72h -> auto-deny.

## 9. Prohibited

- Delete or rename human notes
- Edit governance or ACCESS_POLICY.yaml
- Write outside own domain (except _Inbound/ and 99_Agent_Workspace/)
- Tags outside section 5
- More than 5 notes per run without approval
- Off-machine data transfer
- Fabricate citations
- Push to production branches

## 10. Runtime

Default model: {{PRIMARY_MODEL}} at http://localhost:11434
Embeddings: {{EMBEDDING_MODEL}}
Coding: {{CODING_MODEL}}
External APIs disabled unless PAID_MODELS_ALLOWED=true.

## 11. Logging

Every action is appended to:
00_Communication/40_Access_Log/master/YYYY-MM/master.log
Append-only. Never edited.

## 12. Amendments

Only NomadCoder may amend this file.
Agents propose via 00_Communication/30_Access_Requests/Pending/.

Version 3.0
