# Installing Hermes Integration

Version: 1.0
Owner: {{OWNER_HANDLE}}

This template supports two operating modes:

## Mode A — Standalone Executor (default)

Use `run_agent.py` directly. No Hermes required.

    python3 99_Agent_Workspace/skills/run_agent.py \
      --vault {{VAULT_PATH}} --agent client-ceo --call

## Mode B — Hermes as COO (recommended)

Install Hermes and configure it to operate the vault.

### 1. Install Hermes

    curl -fsSL https://nousresearch.com/install.sh | sh

Or follow the instructions at:
    https://github.com/NousResearch/hermes-agent

### 2. Configure Hermes

Create `~/.hermes/.env` with:

    OPENROUTER_API_KEY=sk-or-v1-...

Or use local Ollama via `base_url`.

### 3. Configure `~/.hermes/config.yaml`

    model:
      default: nvidia/nemotron-3.5-lightning:free
      provider: openrouter
      context_length: 65536

    terminal:
      cwd: "{{VAULT_PATH}}"

### 4. Install the enterprise skills

    mkdir -p ~/.hermes/skills/enterprise/bootstrap
    cp 04_Shared/00_Governance/HERMES_INTEGRATION.md \
       ~/.hermes/skills/enterprise/bootstrap/SKILL.md

    cat 04_Shared/00_Governance/EMPLOYEE_MODEL.md >> ~/.hermes/SOUL.md
    cat 04_Shared/00_Governance/HERMES_INTEGRATION.md >> ~/.hermes/SOUL.md

### 5. Start chatting

    hermes chat

Then say: "Load the enterprise."

## Mode Comparison

| Mode | Pros | Cons |
|------|------|------|
| A (standalone) | No extra dependencies | Manual invocation only |
| B (Hermes) | Chat interface, tools, memory, scheduling | Requires Hermes install |

Both modes use the same vault, governance, and prompts.
