# Changelog

All notable changes to Agentic Enterprise are documented here.

Format based on Keep a Changelog.
This project adheres to Semantic Versioning.

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
