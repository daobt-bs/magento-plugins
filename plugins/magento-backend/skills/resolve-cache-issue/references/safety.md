# Remediation safety

## T0 — observe

Read-only source/config inspection, DB reads, cache status, HTTP headers, Redis INFO, service status, logs, and disk usage.

## T1 — low-risk / targeted

Examples: targeted Magento cache clean and local artifact/cache regeneration when the cause is established and the operation is reversible.

## T2 — approval-controlled

Examples: CDN/Fastly purge, Varnish restart, targeted Redis deletion, PHP-FPM restart, or broader purge.

## T3 — break-glass / destructive

Examples: `bin/magento cache:flush`, Redis `FLUSHDB`, Redis `FLUSHALL`, broad filesystem deletion, and broad production cleanup.

## Rules

- Choose the narrowest operation that matches the diagnosed issue.
- `cache:clean` and `cache:flush` are not interchangeable.
- Do not use Redis `FLUSHALL` as routine cache remediation.
- Production mutations require human control.
- A remediation without behavior-level verification is incomplete.
