# ORG.md — Organizational Chart

Version: 3.0
Owner: {{OWNER_HANDLE}}
Effective: 2026-04-12

This file describes who exists in the enterprise, what they own, and how they
report. It is descriptive — the binding rules live in AGENTS.md and
ACCESS_POLICY.yaml.

## Top-Level Hierarchy

{{OWNER_NAME}} (Founder, final authority)
  |
  +-- Communication Agent (security kernel, interface)
  |     Roles: Request Broker, Policy Evaluator, Data Handler, Notifier, Auditor
  |
  +-- 01_Personal  --> Personal CEO-Agent
  +-- 02_Client    --> Client CEO-Agent
  +-- 03_Venture   --> Venture CEO-Agent
  +-- 04_Shared    --> Audit-Lead
  |
  +-- 99_Agent_Workspace (runtime, not an agent)

## Reporting Lines

- Domains report to NomadCoder via the Communication Agent.
- Domains never report to each other directly.
- Audit-Lead reports to NomadCoder directly (bypasses Communication Agent
  for findings, uses it for access requests).
- Communication Agent reports to NomadCoder daily via Daily Digest.

## Domain Rosters

### 01_Personal — Personal CEO-Agent
- personal-engineer      (side projects, MVPs, code)
- personal-designer      (personal brand, aesthetics)
- personal-marketer      (personal presence, if any)
- personal-researcher    (learning, topics of interest)
- personal-finance       (personal finance only)

Special rules:
- The Personal domain is private. No other domain reads it.
- Personal agents may *request* access to Client or Venture via the
  Communication Agent. Requests are escalated to NomadCoder by default.

### 02_Client — Client CEO-Agent
- account-manager        (one per active client)
- client-engineer        (delivery: build, integrate, deploy)
- client-designer        (UI/UX, brand for clients)
- client-marketer        (SEO, SMM, paid ads for clients)
- client-researcher      (market, competitor, user research)
- client-QA              (testing, quality assurance)
- proposal-writer        (client proposals)
- pricing-analyst        (quotes, margin analysis)

Special rules:
- Client work is governed by contracts in 02_Client/60_Engagements/<client>/00_Contract/.
- Client deliverables are confidential.
- Client domain may read Shared capabilities and knowledge.
- Client domain may never read Venture or Personal.

### 03_Venture — Venture CEO-Agent
- venture-lead           (one per active venture)
- venture-engineer       (product engineering)
- venture-designer       (product & brand design)
- venture-marketer       (growth, launch, content)
- venture-researcher     (market validation, competitive intel)
- venture-growth         (paid acquisition, funnel, retention)

Special rules:
- Venture work is proprietary. Not shared with Client domain.
- Venture domain may read Shared capabilities and knowledge.
- Venture domain may never read Client or Personal.

### 04_Shared — Audit-Lead + holding-company functions
- audit-lead             (independent review of Client + Venture)
- agency-marketer        (marketing the agency itself)
- agency-sales           (selling agency services to prospects)
- recruiter              (sourcing talent, human or AI)
- finance-lead           (agency-wide finance, invoicing)
- legal-lead             (contracts, compliance, IP)

Special rules:
- Audit-Lead may read Client and Venture domains (auto-approved).
- Audit-Lead may never read Personal domain.
- Agency-Marketer, Agency-Sales, Recruiter, Finance-Lead, Legal-Lead
  support 04_Shared/30_Agency_Ops/ (the agency's own operations).

## Agent Naming Convention

All agents are named <domain>-<role>-<NN>, for example:
- personal-engineer-01
- client-designer-02
- venture-marketer-01
- comms-broker-01

The CEO-Agent of each domain is the only agent with the CEO suffix:
- personal-ceo
- client-ceo
- venture-ceo

## Escalation Chain

1. Worker agent -> Team Lead (within its domain)
2. Team Lead -> Domain CEO-Agent
3. Domain CEO-Agent -> Communication Agent
4. Communication Agent -> NomadCoder (via 00_Communication/50_Notifications/)

Cross-domain data needs do not follow this chain. Any agent writes an
access request directly to the Communication Agent. See INTERDOMAIN.md.

## Authority Levels

| Level | Who | Can do |
|-------|-----|--------|
| 5 | NomadCoder | Anything |
| 4 | Communication Agent | Approve/deny access per policy; escalate |
| 3 | Domain CEO-Agent | Assign work inside own domain; escalate |
| 2 | Team Lead | Assign work to workers; report up |
| 1 | Worker agent | Execute one scoped task |

No agent may take a Level-5 action. Level-5 decisions are always escalated
to NomadCoder.
