# Agent Reference

> A catalog of every agent type in the enterprise. For governance rules,
> see 04_Shared/00_Governance/AGENTS.md inside a vault. This file is a
> reference for humans, not a binding contract.

## Communication Layer

### Communication Agent
- Role: security kernel, request broker, policy enforcer, auditor.
- Reads: all domains.
- Writes: 00_Communication/**, <requester>/_Inbound/**.
- Never writes to: governance, any other domain's folders.
- Prompt template: 99_Agent_Workspace/prompts/communication-agent.md.

## Domain: Personal

### Personal CEO-Agent
- Role: runs the Personal domain.
- Reads: 01_Personal/**, 04_Shared/20_Capabilities/**, 04_Shared/40_Knowledge/**.
- Writes: 01_Personal/**, 00_Communication/10_Inbox_From_Domains/Personal/**.
- Prompt: 99_Agent_Workspace/prompts/ceo-agent.md (DOMAIN=personal).

### Personal Leads
- Personal-Dev-Lead, Personal-Design-Lead, Personal-Marketing-Lead, Personal-Research-Lead.
- Prompt: 99_Agent_Workspace/prompts/lead-agent.md (DOMAIN=personal).

### Personal Workers
- Spawned by Leads. One task, one note, stop.
- Prompt: 99_Agent_Workspace/prompts/worker-agent.md.

## Domain: Client

### Client CEO-Agent
- Role: runs the Client domain.
- Reads: 02_Client/**, 04_Shared/20_Capabilities/**, 04_Shared/40_Knowledge/**.
- Writes: 02_Client/**, 00_Communication/10_Inbox_From_Domains/Client/**.
- Prompt: 99_Agent_Workspace/prompts/ceo-agent.md (DOMAIN=client).

### Client Leads
- Dev-Lead, Design-Lead, Marketing-Lead, Research-Lead, Sales-Lead, Ops-Lead.
- Prompt: 99_Agent_Workspace/prompts/lead-agent.md (DOMAIN=client).

### Specialized Client Roles (as needed)
- Account-Manager: one per active client.
- Proposal-Writer: drafts proposals.
- Pricing-Analyst: quotes and margin analysis.
- QA: testing and quality assurance.

## Domain: Venture

### Venture CEO-Agent
- Role: runs the Venture domain.
- Reads: 03_Venture/**, 04_Shared/20_Capabilities/**, 04_Shared/40_Knowledge/**.
- Writes: 03_Venture/**, 00_Communication/10_Inbox_From_Domains/Venture/**.
- Prompt: 99_Agent_Workspace/prompts/ceo-agent.md (DOMAIN=venture).

### Venture Leads
- Venture-Lead, Dev-Lead, Design-Lead, Marketing-Lead, Research-Lead, Growth-Lead.
- Prompt: 99_Agent_Workspace/prompts/lead-agent.md (DOMAIN=venture).

## Shared Layer

### Audit-Lead
- Role: independent review of Client and Venture.
- Reads: 02_Client/**, 03_Venture/**, 04_Shared/**, 00_Communication/**.
- Writes: 04_Shared/50_Audit/**, 00_Communication/50_Notifications/**.
- Never reads: 01_Personal.

### Agency Ops Agents
- Agency-Marketer: marketing the agency itself.
- Agency-Sales: selling agency services.
- Recruiter: sourcing talent (human or AI).
- Finance-Lead: agency finance, invoicing.
- Legal-Lead: contracts, compliance, IP.

## Naming Conventions

All agents are named <domain>-<role>-<NN>:

    personal-engineer-01
    client-designer-02
    venture-marketer-01
    comms-broker-01

CEO-Agents use the suffix -ceo:

    personal-ceo
    client-ceo
    venture-ceo

## Authority Levels

| Level | Who | Can do |
|-------|-----|--------|
| 5 | NomadCoder | Anything |
| 4 | Communication Agent | Approve/deny per policy; escalate |
| 3 | Domain CEO-Agent | Assign work inside own domain; escalate |
| 2 | Team Lead | Assign work to workers; report up |
| 1 | Worker agent | Execute one scoped task |

No agent may take a Level-5 action. Level-5 decisions are always escalated.

## Adding a New Agent

1. Pick a domain and discipline.
2. Copy the prompt template from 99_Agent_Workspace/prompts/.
3. Fill placeholders.
4. Register write_scope and read_scope in runtime.yaml.
5. Save. Live on next run.
