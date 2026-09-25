# Output contract

Use this structure in the final case report. Every section is required; when a section has no content yet, write the specific unknown (`not yet run`, `not applicable`, `none observed`) rather than dropping it.

```text
## Diagnosis
Issue: <ISSUE_ID, or `inconclusive`>
Environment: <local | development | staging | production | cloud | unknown>
Scope: <affected entity/page; store/website; the node(s) actually observed>
Confidence: <high | medium | low>
Evidence completeness: <complete | partial | static-only>

## Evidence
1. <observed fact> — <source: command, file:line, or header>
   Proves: <what this fact establishes>
   Does not prove: <what stays open despite it>
2. ...

## Hypotheses
Ruled out: <rule ID or false positive> — <the evidence that excludes it>
Remaining: <rule ID> — <what still supports it>

## Root Cause
<the mechanism that produces the symptom, or `unproven: <what is missing>`>

## Remediation
Tier: <T0 | T1 | T2 | T3>
Target: <exact cache type, key pattern, node, file, or endpoint>
Blast radius: <what else this affects>
Rollback: <how to undo, or `not applicable`>
Command: <exact command, or the human command pack>

## Verification
Criterion: <the observation that would prove the reported symptom is gone>
Observed: <result after remediation, or `not yet run`>
Result: <pass | fail | pending>

## Risk
<Low | Medium | High>

## Status
<Resolved | Need human input | Inconclusive>
```

## Section semantics

**Confidence** is how strongly the collected evidence supports the stated root cause, not how severe the issue is or how likely the hypothesis is in general. `high` — the mechanism was observed directly at runtime. `medium` — source/config evidence plus symptoms matching it, with runtime confirmation still partial. `low` — symptoms plus a plausible mechanism only.

**Evidence completeness** is how much of the expected runtime evidence was actually available. `complete` — runtime evidence covers the failure. `partial` — some of it. `static-only` — nothing was observed at runtime. Never pair `high` confidence with `static-only` completeness.

**Hypotheses** records that the alternatives were considered. `Ruled out` is why this is not the adjacent cause — the competing rule from `rules/`, or an entry from `references/false-positives.md`. `Remaining` is the rule that survives, and the evidence still supporting it.

**Remediation** is what makes the report actionable for a human deciding whether to approve. `Tier` is the tier from `references/safety.md` and must match the command's actual blast radius. `Target` is narrow enough to check — not "the cache". `Blast radius` names what else the command disturbs, including other nodes. `Rollback` is the inverse operation.

**Verification** states the criterion before the result, so a reader can see whether the test actually covers the reported symptom. `Result` is `pass` only when `Observed` shows the reported symptom gone. `cache` state or a clean command exit is not verification.

**Status** is bound to `Verification.Result`. `Resolved` requires `pass`. `Need human input` requires the human-input block below. `Inconclusive` when no hypothesis survives the evidence.

## Human input required

Append this block when the case needs a human. It is what unblocks the next step, so it names the branch, not just the command:

```text
## Human input required
Uncertainty: <the single fact that decides the next branch>
Command to run: <smallest read-only command>
Decides: <field value A> → <branch A>; <field value B> → <branch B>
```

Interpret only output the human actually pastes back. Never invent or assume it.