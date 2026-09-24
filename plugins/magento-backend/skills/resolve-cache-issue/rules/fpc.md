# FPC rules

## FPC_MISS

Investigate whether `full_page` is enabled, the page is publicly cacheable, a `cacheable="false"` block makes it uncacheable, cookies or response headers force bypass, the edge routes correctly, and an equivalent second request becomes a HIT.

Evidence: Magento cache status, HTTP headers, relevant layout/source, cookies, and edge/Varnish behavior. A MISS is not a defect until the page is expected to be cacheable and the request pattern is controlled.

## FPC_STALE

Compare the served value with the authoritative current value. Inspect FPC invalidation, cache tags/identities, TTL, cache context, and edge layers. Target remediation to affected entries when the invalidation path is known.

## FPC_UNCACHEABLE_BLOCK

Search relevant layout XML and blocks for `cacheable="false"`. Inspect whether a custom block, observer, or layout update makes the page uncacheable. Verify with repeated requests after correcting the source/configuration.

## CACHE_INVALIDATION_FAILED

Trace invalidation from the changed entity to its cache identity/tag and backend/edge purge. Static source evidence is insufficient to prove runtime invalidation.

## WRONG_CACHE_CONTEXT

Compare requests that differ by store, currency, customer group, locale, cookies, query parameters, or other dimensions. Inspect `getCacheKeyInfo()` and HTTP `Vary`/cookie behavior as appropriate.
