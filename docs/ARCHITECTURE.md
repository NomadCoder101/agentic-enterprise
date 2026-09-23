# Architecture

> One page. Read this and you understand the whole system.

## The Big Picture

Agentic Enterprise is three sovereign domains bridged by one security kernel.

    00_Communication/     the airlock -- mediates all cross-domain access
    01_Personal/          your private space
    02_Client/            paying client engagements
    03_Venture/           your own startups and brands
    04_Shared/            governance, capabilities, knowledge, audit
    99_Agent_Workspace/   agent runtime (prompts, plans, memory, logs)

## The Three Domains

Every domain is a miniature enterprise with the same departments:

    00_CEO/               the domain's CEO-Agent workspace
    10_Dev/               engineering
    20_Design/            design
    30_Marketing/         marketing
    40_Research/          research
    50_Wiki/              domain-owned knowledge base
    60_*/                 projects (Personal) / engagements (Client) / ventures (Venture)
    70_Finance/           money flows
    80_*/                 journal (Personal) / pipeline (Client) / incubator (Venture)
    90_Archive/           completed work
    99_Agents/            agent configs and rosters
    _Inbound/             approved cross-domain data lands here

The symmetry is deliberate: one set of agent prompts and playbooks serves
all three domains. Only the governance differs.

## The Security Kernel

The Communication Agent is the only entity authorized to move data between
domains. No domain reads another domain directly.

Flow:

    1. Agent needs data from another domain.
    2. Agent writes a request to 00_Communication/30_Access_Requests/Pending/.
    3. Communication Agent evaluates the request against ACCESS_POLICY.yaml.
    4. Verdict: auto_approve | auto_deny | escalate.
    5. On approve: resource is copied (never linked) into the requester's
       _Inbound/ folder, sanitized per the matched rule.
    6. On escalate: NomadCoder decides; 72h timeout = deny.
    7. Every step is appended to the master log.

## The Access Matrix

From \ To  | Personal | Client | Venture | Shared | Communication
-----------|----------|--------|---------|--------|---------------
Personal   | RW       | R*     | R*      | R      | W inbound
Client     | no       | RW     | no      | R      | W inbound
Venture    | no       | no     | RW      | R      | W inbound
Audit      | no       | R      | R       | R      | RW
NomadCoder | RW       | RW     | RW      | RW     | RW

R* = read-only via the Communication Agent, subject to ACCESS_POLICY.yaml.

## The Agent Hierarchy

    NomadCoder (Founder, final authority)
      |
      +-- Communication Agent (security kernel, interface)
      |
      +-- Personal CEO-Agent -- Personal Leads -- Personal Workers
      +-- Client CEO-Agent   -- Client Leads   -- Client Workers
      +-- Venture CEO-Agent  -- Venture Leads  -- Venture Workers
      +-- Audit-Lead

Each CEO-Agent plans, delegates to Leads, aggregates. Each Lead spawns
bounded Workers. Workers do one task, one note, then stop.

## The Runtime

Agents do not run continuously. They are invoked by:

- A scheduler (see runtime.yaml scheduler.jobs)
- Manual invocation via the executor script
- A brief appearing in the Outbox

Every invocation follows the same loop:

    1. Read own domain context.
    2. Plan -> 99_Agent_Workspace/plans/<domain>/
    3. Execute in own domain only.
    4. Cross-domain needs -> access request.
    5. Self-review against quality gates.
    6. Report to domain CEO -> Communication Agent.
    7. Log everything.

## The Files That Matter

    04_Shared/00_Governance/AGENTS.md              supreme contract
    04_Shared/00_Governance/ACCESS_POLICY.yaml     access rules (edit to change behavior)
    04_Shared/00_Governance/INTERDOMAIN.md         request protocol
    04_Shared/00_Governance/ORG.md                 who exists, who reports to whom
    99_Agent_Workspace/config/runtime.yaml         models, permissions, scopes
    99_Agent_Workspace/prompts/*.md                agent prompt templates
    00_Communication/40_Access_Log/master/*/       every action, immutable

## What Happens When You Write a Brief

    1. You write a brief to 00_Communication/20_Outbox_To_Domains/Client/.
    2. The Client CEO-Agent picks it up.
    3. Client CEO-Agent plans and delegates to Leads.
    4. Leads spawn Workers; Workers produce artifacts.
    5. Client CEO-Agent aggregates, delivers.
    6. Deliverable lands in 00_Communication/10_Inbox_From_Domains/Client/.
    7. You read, decide, or ask for changes.

The same flow applies to Venture and Personal briefs.

## Extensibility

- Add a new capability: create a playbook under 04_Shared/20_Capabilities/.
- Add a new domain: create a new top-level folder and register it in
  ACCESS_POLICY.yaml and runtime.yaml.
- Add a new agent: instantiate a prompt template with placeholders filled.
- Change policy: edit ACCESS_POLICY.yaml. Takes effect on next request.

