# Example Access Request

> Copy this into a running vault at:
> 00_Communication/30_Access_Requests/Pending/

---
type: access-request
request_id: req-2026-04-12-0001
from_domain: personal
from_agent: personal-engineer-01
to_domain: client
resource: "02_Client/60_Engagements/AcmeCorp/10_Projects/Website-2026Q2/"
reason: "Learning React patterns used in a professional project."
duration: read_once
urgency: normal
---

## What I'm asking for

Read access to the AcmeCorp website project so I can study the React
patterns used by the Client Dev team.

## Why

I am building a personal project and want to adopt similar patterns.
Reading one professional example will save me a week of trial and error.

## How I will use it

I will read the source files once, take notes in my own workspace, and
delete the copy from my _Inbound/ folder when finished.

## What I will NOT do

- I will not modify any files in the Client domain.
- I will not share the code outside this vault.
- I will not include client code in my personal project -- only patterns.

## Expected verdict

Per ACCESS_POLICY.yaml rule `personal-reads-client-deliverable`, this
should escalate to NomadCoder. Redactions for financials, contracts, and
_private will apply automatically.
