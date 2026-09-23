# FAQ

## What is Agentic Enterprise?

An Obsidian vault that behaves like a small company run by AI agents.
Three domains (Personal, Client, Venture) operate in isolation, mediated
by a security kernel that enforces policy and logs everything.

## Is this online? Does my data leave my machine?

No. Everything runs locally using Ollama. No API keys, no cloud, no
telemetry. Your data never leaves your computer unless you explicitly
enable paid models and set PAID_MODELS_ALLOWED=true in runtime.yaml.

## Do I need a GPU?

No. Ollama runs on CPU. A GPU makes responses faster and lets you use
larger models, but a modern laptop with 16 GB RAM can run qwen2.5:7b at
usable speeds.

## Which models does it need?

By default:

- qwen2.5:7b           general reasoning
- qwen2.5-coder:7b     coding tasks
- nomic-embed-text     embeddings for search

All three are pulled automatically by install.sh. You can change them in
99_Agent_Workspace/config/runtime.yaml.

## How much disk space does it need?

- Models: about 5 GB
- Vault: negligible (Markdown files are tiny)
- Logs: less than 1 GB per year at typical use

## Can I add more domains?

Yes. Create a new top-level folder following the same template as
01_Personal / 02_Client / 03_Venture. Then add rules in ACCESS_POLICY.yaml
for who can read and write to it. Register it in runtime.yaml under
paths, write_scope, and read_scope.

## Can I have multiple enterprises?

Yes. The installer is the same. Run it in a different folder with a
different slug. Each enterprise is independent.

## Can I use this for my clients?

Yes. That is one of the intended uses. Each client can be an engagement
inside 02_Client/60_Engagements/. Or, if a client wants their own isolated
system, run install.sh in their infrastructure.

## Is this a real product or a prototype?

v0.1.0 ships the structure, the policy, the agent templates, and the
installer. The executor that actually runs agents end-to-end is the next
milestone. See CHANGELOG.md.

## How do I add a new agent?

1. Decide the domain and discipline.
2. Instantiate the appropriate prompt template from 99_Agent_Workspace/prompts/.
3. Fill the placeholders {{DOMAIN}}, {{DOMAIN_PATH}}, {{LEAD}}, {{YOUR_ID}}.
4. Register the agent's write_scope and read_scope in runtime.yaml.
5. Save. The agent is available on next run.

## How do I write a brief?

Create a Markdown file in 00_Communication/20_Outbox_To_Domains/<domain>/.
One paragraph is enough:

    ---
    type: brief
    domain: client
    priority: p1
    ---
    ## Objective
    Build a marketing website for Acme Corp.

    ## Constraints
    - Brand: use their logo and color palette.
    - Stack: static HTML + CSS, deploy on Netlify.
    - Deadline: 2 weeks.

    ## Deliverables
    - Landing page.
    - About page.
    - Contact form.

The domain CEO-Agent picks it up from there.

## How do I know if an agent did something?

Read the master log:

    00_Communication/40_Access_Log/master/YYYY-MM/master.log

Or run the daily digest that lands in:

    00_Communication/00_Agent/Daily_Digest/YYYY-MM-DD.md

## What happens if I disagree with an agent decision?

Escalate. Two paths:

1. Write directly to 00_Communication/70_Decisions/ overriding an escalation.
2. Edit ACCESS_POLICY.yaml to make future similar requests auto-decide.

## Can I run this on Windows?

Yes, via WSL2. Install Ubuntu in WSL, then follow the Linux instructions.

## Can I run this on macOS?

Yes. install.sh detects macOS and adjusts paths.

## Can I share the vault with collaborators?

Not yet in v0.1.0. Multi-user mode is planned. For now, share the vault
folder or use git sync.

## Does it work offline?

Yes. That is the point. Once models are pulled, no internet connection
is required.

## How do I back up?

The vault is plain Markdown. Back it up like any folder:

    tar -czf enterprise-backup-$(date +%Y%m%d).tar.gz /path/to/vault

Or use git:

    cd /path/to/vault
    git init && git add . && git commit -m "backup $(date)"

## How do I uninstall?

Delete the vault folder. Optionally remove Ollama models with
`ollama rm <model>`. Nothing else is installed system-wide.

## Where do I report bugs?

Open an issue on GitHub. Include:

- Your OS and version.
- Output of `scripts/preflight.sh`.
- The last 50 lines of the master log.
- Steps to reproduce.
