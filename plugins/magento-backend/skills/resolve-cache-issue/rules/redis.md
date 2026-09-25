# Redis / Valkey rules

## REDIS_UNAVAILABLE

Collect connection/error evidence, service state, configured endpoint/database/prefix, and application logs. Distinguish backend outage from application configuration mismatch. Do not delete keys as a first diagnostic action.

## REDIS_MEMORY_EVICTION

Inspect `used_memory`, `used_memory_peak`, `maxmemory`, `evicted_keys`, and hit/miss statistics. Establish whether eviction correlates with the reported cache behavior. Address capacity/configuration before broad deletion.

## BACKEND_STORAGE_PROBLEM

The cache backend is unreachable or failing rather than holding a stale value, so caches MISS or error on every request and remediation aimed at entries will not help. Collect connection/error evidence, configured endpoint/database/prefix, service and container state, filesystem capacity for a filesystem backend, backend error logs, and whether all nodes are affected or only one. An enabled cache type whose backend fails can look identical to `CACHE_DISABLED`; the two are separated by backend evidence, not by the reported symptom. Restore backend health before considering any entry-level remediation.

## CACHE_OVER_INVALIDATION

The opposite fault to a stale entry: invalidation fires too broadly or too often, so entries churn and the symptom is load or performance rather than staleness. Find the invalidation trigger and measure its scope. Inspect tags/identities and custom invalidation logic — a full-type clean or a broad flush called on entity save, a plugin or observer firing invalidation on every request, or tag assignments so coarse that one product edit drops a whole category's entries. Correlate invalidation frequency with the performance window, and prefer correcting invalidation scope over compensating with more frequent cleans or a larger backend.
