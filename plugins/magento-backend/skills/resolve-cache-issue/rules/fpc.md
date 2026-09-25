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

## WRONG_CACHE_KEY

Where `WRONG_CACHE_CONTEXT` describes two different requests sharing one wrong entry, this is its code-level cause: the block's `getCacheKeyInfo()` omits a dimension its output actually depends on, or two distinct blocks produce the same key and collide. Symptoms are a plausible-but-wrong value, or content from one entity/store appearing under another. Inspect `getCacheKeyInfo()` against every input the block's output reads — store, customer group, currency, locale, product/category id, page, design/theme, and any custom parameter — then look for a collision between two block classes returning the same key. Reproduce by requesting the two differing variants; a correct fix makes them separate entries rather than one shared entry. Cleaning the cache temporarily hides this and it returns, so treat recurrence after a clean as evidence for this rule over a stale-entry explanation.
