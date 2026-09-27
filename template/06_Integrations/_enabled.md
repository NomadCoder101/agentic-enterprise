# Enabled Integrations

Version: 1.0
Owner: nomadcoder
Updated: 2026-09-26

> Integrations are the hands of the Business OS. They connect Hermes to
> external services — payments, email, social media, ads, and more.
>
> Hermes decides what to do. Integrations execute in the real world.

## Active Integrations

| Integration | Type | Purpose | Status |
|-------------|------|---------|--------|
| (none yet) | — | — | — |

## Available Integrations

| Integration | Type | Purpose |
|-------------|------|---------|
| Zapier | Universal | Connect to 5,000+ SaaS tools |
| MCP | Universal | Standardized tool protocol |
| Stripe | Payments | Billing, subscriptions |
| Gmail | Email | Inbound/outbound email |
| LinkedIn | Social | Outreach, posting |

## How to Enable an Integration

1. Create the integration folder: `06_Integrations/<name>/`
2. Add credentials to the appropriate secrets store (never commit them)
3. Fill in `INTEGRATION.md` with the config and endpoints
4. Register the integration with Hermes (via its config)
5. Log the change in `01_Personal/50_Wiki/WIKI_CHANGELOG.md`

## Integration Structure

    06_Integrations/<name>/
    ├── INTEGRATION.md     config, endpoints, scopes
    ├── _credentials.md    (placeholder — secrets NOT stored here)
    └── _logs/             recent activity

## Credentials Rule

**Never store secrets in the vault.**
- Use `.env` files in `~/.hermes/` or environment variables
- Reference them here by name only
- The `_credentials.md` file documents *which* env vars are needed, not their values
