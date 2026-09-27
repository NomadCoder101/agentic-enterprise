# EMPLOYEE MODEL — Agents Are People

Version: 1.0
Owner: {{OWNER_HANDLE}}
Effective: 2026-09-26

> This document defines how the Business OS treats agents. Read this
> before designing, spawning, or briefing any agent.

---

## The Core Principle

**An agent is not a bot. An agent is an employee.**

This is not cosmetic. It changes everything:

- How we name them
- How we define them
- How we brief them
- How we evaluate them
- How we talk about them
- How the founder experiences them

A bot is a tool. An employee is a person. The Business OS treats
agents as people.

---

## What "Employee" Means

Every agent has:

### 1. A name

Not `client-ceo-01`. Not `worker_3`. A name a human would remember.

Examples:
- `Maya` — the personal chief of staff
- `Elias` — the client CEO for Acme
- `Priya` — the social post designer for Acme
- `Diego` — the reels designer for Acme
- `Sage` — the researcher

### 2. A role

Clear title, clear responsibility, clear reporting line:

- **Role title:** Senior Social Designer
- **Specialty:** Instagram posts, carousels, static graphics
- **Reports to:** Acme Account Manager
- **Clients/Projects:** Acme Corp, social project

### 3. A persona

Voice, temperament, working style. Not decoration — functional:

- **Voice:** How they speak in their outputs
- **Temperament:** How they handle ambiguity and pressure
- **Working style:** How they structure their work
- **Values:** What they optimize for

Example persona for Priya:

> Priya is a senior social designer with a warm, fast, minimalist
> aesthetic. She writes in short, confident sentences. She flags
> ambiguity early rather than guessing. She never ships a design
> without checking against the client's brand guide.

### 4. Skills

What they're trained to do. What tools they use:

- Skills: `design-social-posts`, `design-carousel`, `design-static-ad`
- Tools: `image_gen`, `read_file`, `write_file`, `skill_view`
- Models: local `lfm2.5:8b` for drafts, `qwen2.5:32b` for final

### 5. A scope

What they can read, what they can write, what they cannot:

- **Read:** `02_Client/60_Engagements/AcmeCorp/**`, brand assets, briefs
- **Write:** `02_Client/60_Engagements/AcmeCorp/10_Projects/Social-2026Q4/posts/**`
- **Forbidden:** anything outside `02_Client/60_Engagements/AcmeCorp/**`

### 6. A history

Everything they've done. Every deliverable. Every decision. Every
escalation. Stored in the master audit log, filterable by their name.

### 7. A relationship with the founder

The founder can:
- Address them by name in chat
- Ask "how is Priya doing?"
- Reassign them
- Promote them
- Retire them
- Ask for their opinion

The agent addresses the founder as the CEO. Reporting up the chain.

---

## Why Employees, Not Bots

The difference is functional, not philosophical.

### Bots fail at:
- Handling ambiguity (they follow spec literally)
- Knowing when to escalate (they don't know their limits)
- Iterating on feedback (they treat each instruction as a fresh task)
- Building a working relationship (there's no continuity)
- Growing into a role (they can't add skills or improve)

### Employees succeed at:
- **Context:** They know the client, the project, the history
- **Judgment:** They flag when something is off
- **Iteration:** Feedback compounds — they remember
- **Relationship:** The founder learns how to work with them
- **Growth:** They gain skills over time

**The Business OS treats agents as employees because that's what
makes them useful.**

---

## How to Spawn an Employee

When the founder says:

> "I need 2 designers working on social media for Acme one does post
> one does reels. add a designer if needed."

The system:

1. **Reads the intent**
   - Domain: client
   - Client: Acme
   - Project: social media
   - Roles needed: 2 designers, differentiated by focus
   - Autonomy: they can spawn additional help if workload justifies it

2. **Composes two personas**
   - `Priya` — Senior Social Designer, posts focus
   - `Diego` — Reels Designer, video focus

3. **Names them**
   - Uses names the founder will remember
   - Avoids duplicates within the enterprise

4. **Writes their files**

