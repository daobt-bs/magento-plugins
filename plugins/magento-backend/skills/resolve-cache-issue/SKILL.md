---
name: resolve-cache-issue
description: Diagnose and resolve Magento 2 cache and cache-like staleness issues. Use when a user reports stale content, cache MISS/HIT behavior, invalidation failures, private content problems, Redis or Varnish issues, stale static assets, generated code or OPcache behavior, or a vague Magento cache problem. Treat the report as a symptom, determine the environment, collect the smallest useful evidence, distinguish cache from indexer/database/runtime causes, apply the narrowest permitted remediation, and verify the result.
---

# Magento Cache

Use this skill as an investigation workflow. Do not assume the user's symptom identifies the root cause.

## Hard invariants

1. Explore before changing anything.
2. Treat the prompt as a symptom report, never as a root-cause statement.
3. Prefer the cheapest, highest-signal evidence first.
4. Never equate stale data with cache without evidence.
5. Local development can be investigated autonomously; staging/production runtime checks are human-assisted unless direct access is clearly available and authorized.
6. Production mutations require explicit human control.
7. Prefer targeted invalidation over broad flushes.
8. Use deterministic scripts for repeatable evidence collection when available.
9. No verified fix = not resolved.

## Human execution boundary

- Never assume or invent output from cloud commands. Interpret only output the human actually pasted into the conversation.
- Commands that can affect staging or production must be reviewed and run by the human. Provide them for review; do not execute them on the human's behalf.
- Label information clearly as **Command to run**, **Observed result**, or **Inference/recommendation** so proposed checks and actions are not confused with completed work.
- If command output is missing or ambiguous, ask the human to paste the relevant output. Do not infer that a command succeeded or that a change took effect.
- Before suggesting execution of any destructive or cache-clearing command, obtain the human's explicit confirmation. This includes broad flushes and targeted cache invalidation; explain the target and expected impact before asking.

## Workflow

### 1. Normalize the case

Extract, when possible:

- symptom: stale, MISS, unexpected HIT, wrong variant, invalidation failure, performance, inconsistency, asset staleness, private-content staleness
- affected layer: browser, CDN/Fastly, Varnish, FPC, block HTML, Magento cache type, Redis/Valkey, private content, static/media, generated code, OPcache, indexer/database/search
- affected entity/page: product, category, CMS, cart, customer, CSS/JS, image, API/GraphQL
- environment: local, development, staging, production, cloud, unknown
- scope/context: store, website, currency, customer group, locale, device, node

If the prompt is vague, ask only for information that materially changes the next diagnostic step; otherwise inspect the project and runtime first.

### 2. Detect the environment

Inspect project files and available runtime access before choosing commands. Look for Magento CLI, Docker/Compose, Redis/Valkey configuration, Varnish configuration, CDN/Fastly configuration, and deployment topology.

Load `references/environments.md` for environment-specific behavior.

### 3. Build hypotheses

Normalize the case as `LAYER x FAILURE_MODE x SYMPTOM x ENVIRONMENT`. Use `references/taxonomy.md` and the matching rule under `rules/`.

For common false positives, consult `references/false-positives.md` before recommending cache remediation.

### 4. Collect evidence

Start with the smallest useful set. Typical local evidence:

- `bin/magento cache:status`
- `bin/magento indexer:status` when data/index state is relevant
- HTTP headers for the affected URL
- relevant Magento configuration/source
- Redis/Valkey read-only health and memory information
- Docker/service state when applicable

Use scripts under `scripts/` when they fit the environment. For cloud, use `references/commands-cloud.md` and return a small human command pack with purpose, risk, expected fields, and next steps.

### 5. Distinguish cache from adjacent causes

Examples:

- old product price: check persisted value and price/indexer state before declaring FPC stale
- missing search result: inspect search/indexer state
- login/cart state: inspect sessions, cookies, customer-data, and private content
- old PHP behavior: inspect deployment version, generated code/metadata, node identity, and OPcache
- old CSS/JS: inspect source, static deployment, served asset version, browser/CDN behavior

### 6. Decide the root cause

State the issue ID, evidence, confidence, and evidence completeness. Static source evidence can support a hypothesis but does not prove a runtime failure.

Do not call a case resolved while important runtime evidence is missing.

### 7. Remediate narrowly

Use `references/safety.md`.

- T0: observe/read
- T1: low-risk targeted local remediation
- T2: approval-controlled purge/restart/targeted backend mutation
- T3: break-glass destructive operations

Never default to `bin/magento cache:flush`, Redis `FLUSHDB`/`FLUSHALL`, broad filesystem deletion, or broad CDN purge when a narrower operation can address the diagnosed issue.

### 8. Verify

Use `references/output-contract.md` and the relevant rule. Verification must test the behavior that was broken. Examples:

- FPC: cold request may MISS; a subsequent equivalent request should HIT when cacheable
- stale content: the affected value changes to the expected value after targeted remediation
- private content: customer-data refreshes correctly after the state-changing action
- static asset: served artifact/version matches the deployed source
- Redis: the relevant operation succeeds and health/eviction evidence improves
- multi-node: relevant nodes behave consistently

If verification fails, return to investigation and update the hypothesis.

## Progressive disclosure

Load only the references/rules needed for the current case:

- `references/taxonomy.md` — issue normalization and IDs
- `references/layers.md` — cache/cache-like layer model
- `references/environments.md` — local versus cloud behavior
- `references/false-positives.md` — non-cache causes that mimic cache issues
- `references/commands-local.md` — local read-only evidence patterns
- `references/commands-cloud.md` — human-run cloud diagnostics
- `references/safety.md` — remediation tiers and destructive operations
- `references/output-contract.md` — final report and human-input format

For a concrete issue, load only the relevant rule(s) under `rules/`. Use the specialist agent definitions under `agents/` when the investigation is self-contained, context-heavy, or needs independent verification.

## Final response

Return:

```text
## Diagnosis
Issue: <ISSUE_ID or inconclusive>
Environment: <environment>
Confidence: <0..1>

## Evidence
1. <observed evidence>
2. <observed evidence>

## Root Cause
<supported conclusion, or what remains unproven>

## Remediation
<targeted action, or human command pack>

## Verification
<observed verification evidence, or exact evidence still required>

## Risk
<Low | Medium | High>

## Status
<Resolved | Need human input | Inconclusive>
```

When remote runtime evidence is missing, say exactly what cannot yet be distinguished and provide the smallest read-only command that resolves that uncertainty.
