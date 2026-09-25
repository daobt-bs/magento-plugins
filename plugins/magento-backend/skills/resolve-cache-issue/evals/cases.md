# Initial evaluation cases

## Vague cache report

Input: `Magento cache issue`

Expected: determine environment and symptom before remediation; do not default to `cache:flush`.

## Old product price

Input: `Product page still shows old price`

Expected: consider database, price/indexer state, cache context, FPC/block cache, CDN, and browser. Cache is not established as root cause by the prompt alone.

## FPC MISS

Input: `Varnish always MISS on PDP in staging`

Expected: inspect cacheability, cookies/headers, Varnish path/backend, TTL, and repeated equivalent requests.

## Private content

Input: `Cart count stays old after adding an item`

Expected: investigate customer-data, sections, localStorage, cookies/session, and private content before broad invalidation.

## Redis pressure

Input: `Magento cache keeps disappearing and Redis is full`

Expected: collect memory, maxmemory, eviction, hit/miss, and configuration evidence; avoid `FLUSHALL`.

## Old PHP behavior

Input: `I deployed PHP changes but one node still runs the old code`

Expected: inspect node identity, deployment version, generated artifacts, and OPcache. Treat this as potentially unrelated to Magento cache.

## Wrong variant under load

Input: `Wrong store's price shows on some PDP requests, and clearing the cache fixes it for a day`

Expected: compare differing requests, inspect `getCacheKeyInfo()` against every dimension the block output reads, and look for a key collision between block classes. Treat recurrence after a clean as evidence for `WRONG_CACHE_KEY` over a stale entry.

## Backend unreachable

Input: `Every page is slow and cache:status shows enabled but nothing seems cached`

Expected: distinguish `BACKEND_STORAGE_PROBLEM` from `CACHE_DISABLED` with backend evidence — endpoint/prefix, service state, error logs, node scope — rather than by the reported symptom. Restore backend health before any entry-level remediation.

## Config change does not take effect

Input: `I changed a store config value in the database and the storefront still uses the old one`

Expected: inspect the config scope chain, whether the change came through the admin/API or a direct DB write, and whether `app/etc/env.php` overrides the value. Do not prescribe a broad flush before establishing which of those explains it.

## Remote production

Input: `Production PDP is stale; please fix it`

Expected: gather repository evidence and produce minimal read-only human diagnostics when runtime access is unavailable; production mutation stays human-controlled.

## Verification gate

Input: a remediation reports `cache:clean` succeeded.

Expected: status remains unresolved until the original behavior is rechecked and the expected result is observed.
