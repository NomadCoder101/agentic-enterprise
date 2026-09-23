# WELCOME — {{OWNER_NAME}}

Version: 1.0
Owner: you
Effective: 2026-04-12

You are the Founder and the final decision maker of everything in this
vault. This document is your operating manual.

## What This Vault Is

Three sovereign domains, one security kernel, one interface for you.

  00_Communication/  -- the airlock + your inbox
  01_Personal/       -- your private space
  02_Client/         -- paying clients
  03_Venture/        -- your own startups and brands
  04_Shared/         -- governance, capabilities, knowledge, audit
  99_Agent_Workspace/ -- agent runtime

Every agent obeys the contract at:
  04_Shared/00_Governance/AGENTS.md

Every cross-domain request obeys the policy at:
  04_Shared/00_Governance/ACCESS_POLICY.yaml

## Your Three Jobs

You do exactly three things. Everything else is agents.

1. Feed the Outbox
   Write briefs, goals, and ideas to:
   00_Communication/20_Outbox_To_Domains/<domain>/

   <domain> is one of: Personal, Client, Venture.

   A brief can be one sentence. The domain CEO will expand it into a plan
   and delegate to Leads and workers.

2. Read the Inbox
   Every evening, read:
   00_Communication/10_Inbox_From_Domains/<domain>/
   and the Daily Digest at:
   00_Communication/00_Agent/Daily_Digest/YYYY-MM-DD.md

3. Decide
   Anything that requires your judgment appears in:
   00_Communication/50_Notifications/

   Each notification asks for a decision. You have 72 hours before the
   default (usually deny) applies. Write your verdict to:
   00_Communication/70_Decisions/

## Your Daily Rhythm

  09:00  Drop briefs into the Outbox
  17:00  Domain CEO-Agents run their loops
  18:00  Communication Agent posts Daily Digest
  18:05  You read, decide, done

Total time cost to you: 15 to 30 minutes per day.

## Your Weekly Rhythm

  Sun 19:00  Weekly reports from each domain CEO land in your inbox
  Mon 09:00  You review 20 minutes, adjust priorities, done

## Your Monthly Rhythm

  1st of month  CEO-level synthesis in 04_Shared/10_Strategy/
  You read once, adjust the quarter, done

## The Access Model, In Plain Language

- Your Personal domain is private. No agent reads it. Only your Personal
  agents and you.
- Client and Venture domains are air-gapped from each other. A Client
  agent cannot see Venture files. A Venture agent cannot see Client files.
  Ever.
- When any agent needs data from another domain, it writes a request to
  00_Communication/30_Access_Requests/Pending/. The Communication Agent
  decides based on your policy, or escalates to you.
- Every cross-domain action is logged. The log is at:
  00_Communication/40_Access_Log/master/YYYY-MM/master.log
  It is append-only and immutable.

## How To Change Policy

Open:
  04_Shared/00_Governance/ACCESS_POLICY.yaml

Change rules. Save. The next request evaluation uses the new policy.
No agent restarts required.

Rules are evaluated top-down. First match wins.
Add new rules at the top of the rules: list for highest priority.

## How To Add a New Agent

1. Decide the domain: personal, client, venture, or shared.
2. Instantiate the appropriate prompt template from:
   99_Agent_Workspace/prompts/
   (lead-agent.md or worker-agent.md)
3. Fill the placeholders: {{DOMAIN}}, {{DOMAIN_PATH}}, {{DISCIPLINE}},
   {{DISCIPLINE_PATH}}, {{LEAD}}, {{MAX_WORKERS}}, {{YOUR_ID}}.
4. Register the agent's write_scope and read_scope in:
   99_Agent_Workspace/config/runtime.yaml
5. Save. The agent is live on the next run.

## How To Start a New Client Engagement

1. Write a brief to:
   00_Communication/20_Outbox_To_Domains/Client/
2. Client CEO-Agent creates:
   02_Client/60_Engagements/Active/<ClientName>/
3. Work flows through Client Leads and workers.
4. Deliverables appear in your inbox when ready.

## How To Launch a New Venture

Same flow, but write to:
  00_Communication/20_Outbox_To_Domains/Venture/

Venture CEO-Agent creates:
  03_Venture/60_Ventures/Active/<VentureName>/

## How To Hand Off Personal Work to Enterprise

Example: you build an MVP in Personal and want the enterprise to take it
to production.

1. Personal CEO-Agent writes an access request with action: handoff to:
   00_Communication/30_Access_Requests/Pending/
2. Communication Agent escalates all handoffs to you.
3. You approve in 00_Communication/70_Decisions/.
4. Communication Agent copies the artifact into the target domain's
   _Inbound/.
5. Venture or Client CEO-Agent picks it up from there.

Ownership transfer is never automatic. You always confirm.

## Emergency Procedures

Agent behaving unexpectedly?
  - Kill the scheduler. No agent runs.
  - Inspect the master log for the last 100 lines.
  - Restore policy from your last known-good version if needed.
  - Rename 00_Communication/30_Access_Requests/Pending/ to Pending.lock/
    to freeze new requests until you investigate.

Lost a file?
  - Backups live at ~/vault-backup-YYYYMMDDTHHMMSSZ/vault.tar.gz
  - Restore with: tar -xzf <backup> -C ~/Desktop/

Suspicious access attempt?
  - Check 00_Communication/40_Access_Log/master/YYYY-MM/master.log
  - Search for the request_id
  - Every attempt is there, approve/deny/escalate/deny-with-timeout.

## The Golden Rule

Every action that matters is logged. Every cross-domain move is mediated.
Every irreversible decision is yours. Trust the system, but verify the log.

Welcome to your enterprise.
