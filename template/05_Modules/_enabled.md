# Enabled Modules

Version: 1.0
Owner: nomadcoder
Updated: 2026-09-26

> This file declares which modules are active in this enterprise.
> Modules add capabilities beyond the universal core. Enable only
> what the business needs.

## Active Modules

| Module | Status | Purpose | Enabled On |
|--------|--------|---------|------------|
| (none yet) | — | — | — |

## Available Modules

| Module | Purpose | When to Enable |
|--------|---------|----------------|
| Ecom | Inventory, orders, reorders, fulfillment | If the business sells physical goods |
| Service | Projects, scheduling, quality, retention | If the business delivers services |
| SaaS | Subscriptions, onboarding, usage, churn | If the business sells software subscriptions |

## How to Enable a Module

1. Create the module folder: `05_Modules/<module-name>/`
2. Copy the template from `_templates/module-template/`
3. Fill in the module's `MODULE.md` with scope, agents, and skills
4. Add the module to the table above
5. Log the change in `01_Personal/50_Wiki/WIKI_CHANGELOG.md`

## Module Structure

Every module follows this structure:

    05_Modules/<module>/
    ├── MODULE.md          describes the module, its agents, its scope
    ├── 10_<Area>/         functional subfolders
    ├── 20_<Area>/
    └── 90_Archive/

Modules are isolated from each other. Each module owns its own subfolders.

## The Core Promise

The core of the Business OS is the same for every business:

- 3 domains (Personal, Client, Venture)
- Governance (AGENTS, ACCESS_POLICY, ORG, HERMES_INTEGRATION)
- Hermes as the operator
- The vault as the memory

Modules extend the core. They never replace it.
