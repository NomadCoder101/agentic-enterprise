# Changelog

All notable changes to Agentic Enterprise are documented here.

Format based on Keep a Changelog.
This project adheres to Semantic Versioning.

## [0.2.0] - 2026-04-12

### Added
- Executor: `template/99_Agent_Workspace/skills/run_agent.py`
- Agent resolution from name (role-based mapping to prompt files)
- Scope inheritance for domain-prefixed agents (client-* inherits from client-ceo)
- Ollama integration via `/api/generate`
- Context assembly within `read_scope` (governance, inbox, plans)
- Write directives via `agent-writes` YAML code fence
- Write enforcement against `write_scope` and `forbidden_paths`
- Path normalization (rejects `../`, absolute paths, escapes)
- Master log in JSON-lines format (append-only)
- CLI flags: `--show-context`, `--write-dry-run`, `--allow-writes`,
  `--model`, `--timeout`, `--max-writes`
- Isolation test harness: `scripts/test-scope-enforcement.sh`
  (8/8 scope enforcement tests pass)

### Changed
- CEO prompt (v1.1): explicit output format with agent-writes example
- Communication prompt: WRITE FORMAT section added
- `runtime.yaml`: `generate_seconds` default 120 -> 600
- `runtime.yaml`: `embed_seconds` default 30 -> 60
- `runtime.yaml`: CEO `read_scope` entries include outbox paths

### Security
- Verified: cross-domain writes refused (Client -> Venture, Client -> Personal)
- Verified: governance file writes refused
- Verified: path traversal attempts refused
- Verified: absolute path attempts refused
- Verified: master log tampering refused
## [Unreleased]

### Planned
- Executor runtime (Python) that runs agents end-to-end.
- Scheduler integration (cron/systemd) from runtime.yaml.
- Communication Agent dry-run tooling.
- Docker image for enterprise deployments.
- Multi-user mode with human collaborators.
- Capability playbook templates (design, dev, marketing, sales).

## [0.1.0] - 2026-04-12

### Added
- Initial release.
- Three sovereign domains: Personal, Client, Venture.
- Communication Agent security kernel.
- Machine-readable ACCESS_POLICY.yaml.
- Master audit log with append-only semantics.
- Per-agent write scope and read scope enforcement.
- Agent prompt library: CEO, Lead, Worker, Communication.
- One-command installer (install.sh).
- Preflight environment checker (scripts/preflight.sh).
- Post-install validator (scripts/validate-clone.sh).
- Enterprise template with placeholder substitution.
- Domain modularity: include or exclude domains per clone.
- README with quick start, policy editing, and daily workflow docs.
