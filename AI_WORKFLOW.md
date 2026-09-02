# AI_WORKFLOW.md

## ChatGPT + Claude collaboration contract

GitHub is the shared handoff state. Conversation memory is not.

Before any work:

1. read mandatory project docs
2. inspect latest repository state, open PRs, and recent commits when GitHub is available
3. identify the exact baseline module from the verified AzerothCore release
4. identify only the MoP-specific difference
5. patch the smallest module/data/adapter
6. run static/regression checks
7. record status and evidence

## Branch convention

- ChatGPT/Codex: `ai/chatgpt/<task>`
- Claude: `ai/claude/<task>`

Do not overwrite another agent's active branch or silently duplicate the same work.

## Baseline synchronization rule

Before porting a feature to MoP, check whether the AzerothCore baseline feature has changed. If it has, synchronize the canonical feature first, then apply the MoP adapter/data delta.

This prevents client versions from diverging.

## Token-efficient modular rule

Do not resend/rewrite entire large modules when only a command table, API adapter, data file, or one UI handler changes. Keep stable UI modules stable and change narrow dependency files.

## Regression handoff

Every user-reported screenshot/error must be converted to a regression-ledger entry. Both ChatGPT and Claude must check that ledger before changing the affected module.
