# Changelog

All notable changes to Agentic Enterprise are documented here.

Format based on Keep a Changelog.
This project adheres to Semantic Versioning.

## [Unreleased]

### Planned
- Docker image for enterprise deployments
- Multi-user mode with human collaborators
- Capability playbook templates (design, dev, marketing, sales)
- Hermes-native skills (enterprise-status, enterprise-run-agent, enterprise-write-brief)
- First module: service or ecom
- Gateway integration (Telegram/Discord)
- Hook-based event triggers
- MCP integration for external tools
- Zapier integration

## [0.3.0] - 2026-09-26

### Added
- Business OS modular structure
  - `05_Modules/` — pluggable business capabilities
  - `05_Modules/_enabled.md` — module manifest
  - `05_Modules/_templates/module-template/` — template for new modules
  - `05_Modules/ecom/`, `service/`, `saas/` — starter placeholders
  - `06_Integrations/` — external service connectors
  - `06_Integrations/_enabled.md` — integration manifest
  - `06_Integrations/_templates/integration-template/` — template
  - `06_Integrations/zapier/`, `mcp/`, `stripe/`, `gmail/`, `linkedin/` — placeholders
- EMPLOYEE_MODEL.md — agents are employees with names, personas, scopes
- HERMES_INTEGRATION.md — the full Hermes-native operating model
- INSTALL_HERMES.md — setup instructions for the Hermes integration
- Employee scope pattern in runtime.yaml — template for hiring
- Section 14 in AGENTS.md — Business OS modular structure rules

### Changed
- CEO prompt supports the agent-writes block with worked rules
- Communication prompt has WRITE FORMAT section
- runtime.yaml supports employee hiring via the scope pattern

### Proven
- First successful end-to-end Client CEO run via Hermes
- 5 real deliverables produced (design brief, copy, HTML, CSS, status)
- Master log entry appended
- Demonstrates the Business OS works with a capable model

### Known Limitations
- Local Ollama on CPU handles single-shot but not multi-step orchestration
- GPU acceleration is available but limited (older GPU not in Ollama's CUDA set)
- OpenRouter free tier has a 50 requests/day limit

### Recommended Setup
Use a model with 64K+ context and reliable tool calling. Options:
- OpenRouter free tier (nvidia/nemotron-3.5-lightning:free)
- Local qwen2.5:32b (slow but capable)
- Any OpenRouter/OpenAI-compatible paid model

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
