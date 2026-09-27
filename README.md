# Business OS

> A local-first operating system for running any business with AI agents.
> No cloud. No subscriptions. Your data stays on your machine.

---

## What It Is

**The Business OS is a co-founder.**

When a founder installs the Business OS, they aren't installing software.
They're hiring:

- A CEO who asks the hard questions
- A CFO who tracks whether they're winning
- A Marketing team who finds customers
- A Sales team who closes them
- A Delivery team who ships
- An R&D team who proposes growth
- A Risk team who monitors danger

The BOS brings structure, judgment, momentum, memory, and a team the
founder could not afford to hire. The founder brings an idea, an offer,
a target, and the willingness to work.

**Together, they build a business.**

This is not a productivity tool. It's not a note-taking app with agents.
It's the operating system of a real company — one that starts small and
compounds over time.

The Business OS runs on your machine. It runs on local models or optional
paid ones. Your data never leaves your computer unless you explicitly
allow it.

---

## The Three Layers

Every Business OS is built from three layers.

### Core (universal)

The same structure for every business:

- **Three domains** — Personal, Client, Venture — each sovereign and
  isolated
- **Agents as employees** — names, personas, scopes, histories
- **Governance** — AGENTS.md, ACCESS_POLICY.yaml, BOS_DOCTRINE.md
- **Audit log** — every action, timestamped, immutable
- **Foundation files** — OFFER, KPI, PLAN, MARKET_BRIEF, CRISIS_PLAYBOOK,
  RISK_REGISTER

The core is the same across a coffee roaster and a SaaS company.

### Modules (business-specific)

Enable only what your business needs:

- **Ecom** — inventory, orders, reorders, fulfillment
- **Service** — projects, scheduling, quality, retention
- **SaaS** — subscriptions, onboarding, usage, churn
- **Marketplace** — matching, escrow, reviews
- **Consulting** — engagements, deliverables, retainers

Same core. Different configuration.

### Integrations (the hands)

Connect to the outside world:

- **Zapier** — 5,000+ SaaS tools, no code
- **MCP** — Model Context Protocol servers
- **Stripe** — payments
- **Gmail** — email
- **LinkedIn** — outreach and posting

Hermes decides what to do. Integrations do it in the real world.

---

## Your Team

Agents in the Business OS are employees, not bots.

They have:

- **A name** — Priya, Diego, Sage, Elias. Memorable, human.
- **A persona** — voice, temperament, working style
- **A role** — title, specialty, reporting line
- **A scope** — what they read, write, and cannot touch
- **A history** — every deliverable, every decision, every escalation

**You hire them by talking.**

You say:

> "I need 2 designers working on social media for Acme. One does posts,
> one does reels. Add a designer if needed."

The Business OS:

1. Spawns Priya and Diego
2. Assigns their scopes
3. Writes their personas
4. Briefs them
5. Runs them on the first task
6. Logs everything

Time: seconds.

Read more: `EMPLOYEE_MODEL.md`

---

## How You Use It

You don't open the Business OS. You talk to it.

### The Daily Rhythm

**Morning (5 min)**
- Read the daily digest
- Review the KPI dashboard
- Respond to escalations

**Midday (15 min)**
- Review proposals the Sales-Lead drafted
- Review deliverables the Ops-Lead produced
- Approve or redirect

**Evening (5 min)**
- Read the end-of-day summary
- Set tomorrow's priorities

**Total: ~30 minutes per day.** Everything else is the BOS.

### The Weekly Rhythm

**Monday (30 min)**
- Read the weekly market brief
- Review KPI trends
- Make strategic calls

### The Monthly Rhythm

**1st of the month (2 hours)**
- Read the CFO's P&L
- Read the R&D's growth proposal
- Adjust targets

---

## Prerequisites

You need four things.

### 1. Obsidian (the vault viewer)

Download from https://obsidian.md and install for your OS.

    # Linux (Ubuntu / Debian)
    sudo snap install obsidian --classic

    # macOS
    brew install --cask obsidian

### 2. Hermes (the COO)

Hermes is the runtime that operates the vault.

    curl -fsSL https://nousresearch.com/install.sh | sh

Or follow the instructions at:
https://github.com/NousResearch/hermes-agent

### 3. Python 3.10+

Most systems have this. Verify:

    python3 --version

### 4. A model provider (optional)

Two options:

- **Local** — https://ollama.com with `qwen2.5:32b` or similar
- **Cloud** — an https://openrouter.ai API key (free tier available)

Local is fully private. Cloud is faster and more capable. You can switch
between them.

---

## Install

    git clone https://github.com/NomadCoder101/agentic-enterprise.git
    cd agentic-enterprise
    ./install.sh

The installer will:

1. Verify prerequisites
2. Ask you a few questions (business name, your name, vault path)
3. Build your vault
4. Validate the result
5. Tell you what to do next

**Total time: about 3 minutes.**

Then, install the Hermes integration:

    # See INSTALL_HERMES.md for full instructions

---

## First Run — The Intake Conversation

The first time you talk to your CEO, they interview you.

Not a form. A conversation. Multi-turn. Resumable.

The CEO asks:

1. **What's the business?** — what we sell, to whom
2. **Who's the customer?** — ICP, geography, pain, trigger
3. **What's the offer?** — service, price, promise
4. **What's the proof?** — case studies, credentials, data
5. **What are the edges?** — what we refuse, minimum engagement
6. **What are the numbers?** — revenue target, burn, runway
7. **Where are we going?** — 12-month goal, milestones
8. **What worries you?** — initial risk register

The CEO writes:

- `OFFER.md`
- `KPI.md`
- `PLAN.md`
- `RISK_REGISTER.md`
- `MARKET_BRIEF.md`
- `CRISIS_PLAYBOOK.md`

**Your business is now operational.**

Read more: `BOS_DOCTRINE.md`

---

## The Foundation Files

Every Business OS has six foundation files. Every agent reads them.
Every skill serves them.

| File | Answers |
|------|---------|
| `OFFER.md` | What we sell, to whom, at what price |
| `KPI.md` | Are we winning? |
| `PLAN.md` | How do we get from here to the goal? |
| `MARKET_BRIEF.md` | What's happening out there? |
| `CRISIS_PLAYBOOK.md` | What do we do when things go wrong? |
| `RISK_REGISTER.md` | What could go wrong? |

Templates live in `04_Shared/10_Strategy/_templates/`.
Examples (fictional) live in `04_Shared/10_Strategy/examples/`.
Live versions (yours) live at the root.

---

## What's Proven

**v0.3.0** proved the full loop:

- First successful CEO run via Hermes
- 5 real deliverables produced (design brief, copy, HTML, CSS,
  status report)
- Master log entry appended
- Every action traceable, every write enforceable
- Fresh clone verified — template structure intact

The system works end-to-end. From chat to deliverables in minutes.

---

## Known Limitations

Honest about what the Business OS can and cannot do today.

### Local models

- **8–9B local models on CPU** handle single-shot tasks (list files,
  read a brief) but struggle with multi-step orchestration
- **32B local models** can orchestrate but are slow on CPU (~1 token/sec)
- **GPU acceleration** depends on your hardware; older GPUs may not be
  supported by current Ollama builds

### Model providers

- **OpenRouter free tier** has a 50 requests/day limit
- **Paid models** work best for production use

### Features

- **Crisis and market skills** are documented but not yet built (Session 6+)
- **Cron scheduling** and **Telegram gateway** are planned but not yet
  enabled
- **Integrations** (Stripe, Gmail, LinkedIn) are placeholders for now

### What the Business OS Does Well

- Reading and writing files in the vault
- Following the governance doctrine
- Executing the CEO pattern we proved
- Logging every action
- Running agents on specific tasks

---

## The Path Forward

What's next for the Business OS:

**Session 5 — Tier 1 Skills** (current)
- `enterprise-intake` — the CEO interview
- `enterprise-status` — business health report
- `enterprise-run-agent` — execute a domain CEO
- `enterprise-write-brief` — direct work
- `enterprise-review` — surface decisions
- `enterprise-audit` — log + health check

**Session 6 — Automation**
- Cron scheduling
- Hook-based event triggers
- Daily digest delivery

**Session 7 — Interface**
- Telegram gateway
- Push notifications

**Session 8+ — Capability**
- Crisis skills
- Market skills
- First module (service or ecom)
- First integration (Stripe or Gmail)

**Long-term**
- Multi-business support
- Cross-business learning
- White-label deployments

---

## Documentation

Full documentation lives in the vault:

- `BOS_DOCTRINE.md` — the operating model
- `EMPLOYEE_MODEL.md` — agents as employees
- `HERMES_INTEGRATION.md` — the Hermes-native operating model
- `AGENTS.md` — the supreme contract
- `ORG.md` — the org chart
- `ACCESS_POLICY.yaml` — the access rules

And in the repo:

- `docs/ARCHITECTURE.md` — the architecture
- `docs/SECURITY.md` — the security model
- `docs/FAQ.md` — common questions
- `docs/AGENTS.md` — agent reference

---

## The Philosophy

**A business exists to make money.** Every skill, every agent, every
action serves this objective.

**Empty is not quiet.** An empty inbox is not rest — it's a problem.
The BOS proposes action. It doesn't wait for instructions.

**The founder decides.** The BOS recommends, proposes, and executes.
But every strategic decision is the founder's.

**Time makes it better.** The Business OS learns your preferences,
your patterns, your business. Every week it knows you better.

**The founder owns everything.** The vault is plain Markdown. The
audit log is append-only. The data never leaves your machine unless
you say so.

---

## License

MIT

## Support

Open an issue on GitHub:
https://github.com/NomadCoder101/agentic-enterprise

## Changelog

See CHANGELOG.md.

---

## The Pitch

**Version 1 — what we do:**

> Run a company by yourself, with AI agents doing the work.

**Version 2 — how you use it:**

> Staff your company with a sentence.

**Version 3 — the category:**

> SaaS is dead. Long live the Business OS.
