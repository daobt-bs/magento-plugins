# Runtime staleness rules

## GENERATED_CODE_STALE

Inspect `generated/code`, `generated/metadata`, deployment version, and node identity. Regenerate only when source/deployment evidence supports stale generated artifacts.

## OPCACHE_STALE

Establish that the affected node serves old PHP source and rule out wrong deployment/node and generated-code causes. Treat PHP-FPM/OPcache reset as approval-controlled in production.

## MULTI_NODE_CACHE_INCONSISTENCY

Collect equivalent evidence from each relevant node. Compare deployment version, generated artifacts, static assets, local cache state, backend endpoint, and runtime identity before remediation.
