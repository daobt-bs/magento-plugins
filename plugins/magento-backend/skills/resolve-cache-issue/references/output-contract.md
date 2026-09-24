# Output contract

Use this structure in the final case report:

```text
## Diagnosis
Issue: <ISSUE_ID or inconclusive>
Environment: <environment>
Confidence: <0..1>

## Evidence
1. <fact and source of evidence>
2. <fact and source of evidence>

## Root Cause
<supported conclusion, or remaining uncertainty>

## Remediation
<targeted action or human command pack>

## Verification
<behavior-level verification evidence>

## Risk
<Low | Medium | High>

## Status
<Resolved | Need human input | Inconclusive>
```

When human input is required, state the specific uncertainty, give the smallest read-only command, and list the fields that determine the next branch.

Confidence describes diagnostic support. Evidence completeness describes how much expected runtime evidence is available. Do not turn either into certainty when runtime evidence is absent.
