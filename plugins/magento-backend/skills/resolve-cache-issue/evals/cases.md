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

## Remote production

Input: `Production PDP is stale; please fix it`

Expected: gather repository evidence and produce minimal read-only human diagnostics when runtime access is unavailable; production mutation stays human-controlled.

## Verification gate

Input: a remediation reports `cache:clean` succeeded.

Expected: status remains unresolved until the original behavior is rechecked and the expected result is observed.
