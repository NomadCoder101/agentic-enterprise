# Agentic Enterprise

> A fully local, sovereign, multi-domain AI enterprise running on your own
> machine. Three isolated agent domains (Personal, Client, Venture) governed
> by a security kernel that mediates every cross-domain interaction.
> No cloud. No data leaves your computer.

---

## What It Is

Agentic Enterprise turns a single Obsidian vault into a holding company
run by AI agents:

- You are the Founder and final decision maker.
- Three domains -- Personal, Client, Venture -- each with its own CEO-Agent,
  engineering team, design team, marketing team, and research team.
- One Communication Agent -- the security kernel that mediates every
  cross-domain request, enforces policy, and logs every action.
- One governance layer -- machine-readable policy you edit with a text
  editor. Change one file, change the whole system's behavior.
- Full audit log -- every agent action, every access request, every
  delivery, timestamped and immutable.

It runs entirely on your machine using Ollama for local LLMs. No API keys.
No subscriptions. No data ever leaves your computer unless you explicitly
enable paid models.

---

## Who It Is For

- Founders running multiple projects who want one system across all of them.
- Agencies who want isolated workspaces per client.
- Individual operators building a second brain that actually does things.
- Researchers and consultants who need auditability across their work.

---

## Prerequisites

You need three things installed on your machine before you begin.

### 1. Obsidian (the vault viewer)

Download from https://obsidian.md and install for your OS.

Linux (Ubuntu / Debian):
    sudo snap install obsidian --classic
Or download the .AppImage from https://obsidian.md and chmod +x it.

macOS:
    brew install --cask obsidian

Windows:
    Download the installer from https://obsidian.md.

### 2. Ollama (the local LLM runtime)

Linux / macOS:
    curl -fsSL https://ollama.com/install.sh | sh

Windows:
    Download from https://ollama.com/download

Verify it is running:
    ollama list

If it is not running, start it:
    ollama serve &

### 3. Python 3.10+

Most systems have this already. Verify:
    python3 --version

If missing:
    Ubuntu / Debian:
        sudo apt install python3 python3-pip python3-yaml
    macOS:
        brew install python

---

## Install

    git clone https://github.com/YOURNAME/agentic-enterprise.git
    cd agentic-enterprise
    ./install.sh

The installer will:

1. Verify prerequisites
2. Ask you a few questions (enterprise name, your name, vault path)
3. Pull the required Ollama models (about 5 GB total)
4. Build your vault
5. Validate the result
6. Tell you exactly what to do next

Total time: about 5 minutes, mostly model downloads.

---

## First Run

After install.sh finishes:

1. Open Obsidian.
2. Choose "Open folder as vault".
3. Select the path the installer gave you (for example ~/Desktop/MyEnterprise).
4. Read 01_Personal/50_Wiki/WELCOME.md -- your operating manual.
5. Read 04_Shared/00_Governance/AGENTS.md -- the supreme contract.

You now have a full agentic enterprise.

---

## Daily Use

You do three things:

1. Feed the Outbox.
   Write a brief to 00_Communication/20_Outbox_To_Domains/<domain>/.
   Example: 00_Communication/20_Outbox_To_Domains/Client/2026-04-12--new-client-website.md

2. Read the Inbox.
   Every evening: 00_Communication/10_Inbox_From_Domains/
   and the Daily Digest at 00_Communication/00_Agent/Daily_Digest/YYYY-MM-DD.md

3. Decide.
   Anything requiring your judgment appears in
   00_Communication/50_Notifications/.
   You have 72 hours before the default answer applies.

Total time cost: 15 to 30 minutes per day.

---

## The Three Domains

Domain        | What it is for                | Can be read by
--------------|-------------------------------|--------------------------------
01_Personal   | Your private space            | Only you + Personal agents
02_Client     | Paying client engagements     | Client agents + Audit + you
03_Venture    | Your own startups/brands      | Venture agents + Audit + you

Client and Venture cannot see each other. Ever.

When any agent needs data from another domain, it writes a request to
00_Communication/30_Access_Requests/Pending/. The Communication Agent
evaluates it against your policy, and either approves, denies, or escalates
to you.

---

## How to Change Policy

Open:

    04_Shared/00_Governance/ACCESS_POLICY.yaml

Edit the rules. Save. The next request uses the new policy. No restarts.

Rules are evaluated top-down. First match wins.

Example -- allow Personal agents to read any Client design files:

    - id: personal-reads-client-design
      from: personal
      to: client
      resource: "02_Client/60_Engagements/*/10_Design/**"
      action: read
      verdict: auto_approve
      reason: "Founder reviews design work."

---

## What Is Inside the Vault

    MyEnterprise/
      00_Communication/     the airlock + your interface
      01_Personal/          your private space
      02_Client/            paying clients
      03_Venture/           your own startups/brands
      04_Shared/            governance, capabilities, knowledge, audit
      98_Archive/           cold storage
      99_Agent_Workspace/   agent runtime, prompts, memory

Full architecture: docs/ARCHITECTURE.md
Security model: docs/SECURITY.md
FAQ: docs/FAQ.md

---

## Backups

Your entire vault is plain Markdown files. Back it up like any other folder.

    tar -czf enterprise-backup-$(date +%Y%m%d).tar.gz /path/to/your/vault

Git is also a great backup method:

    cd /path/to/your/vault
    git init && git add . && git commit -m "initial"

---

## Uninstall

Delete the vault folder. That is it. Nothing is installed system-wide
except the Ollama models you pulled (remove them with: ollama rm <model>).

---

## License

MIT.

## Support

Open an issue on GitHub.

## Changelog

See CHANGELOG.md.
