# Redis / Valkey rules

## REDIS_UNAVAILABLE

Collect connection/error evidence, service state, configured endpoint/database/prefix, and application logs. Distinguish backend outage from application configuration mismatch. Do not delete keys as a first diagnostic action.

## REDIS_MEMORY_EVICTION

Inspect `used_memory`, `used_memory_peak`, `maxmemory`, `evicted_keys`, and hit/miss statistics. Establish whether eviction correlates with the reported cache behavior. Address capacity/configuration before broad deletion.

## CACHE_OVER_INVALIDATION

Find the invalidation trigger and measure its scope. Inspect tags/identities and custom invalidation code. Prefer correcting invalidation scope over compensating with frequent broad cleans.
