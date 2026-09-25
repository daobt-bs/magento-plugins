# Edge cache rules

## CDN_FASTLY_STALE_OR_MISS

Inspect edge headers, age, cache-control, cache-key behavior, purge evidence, and origin behavior. For Cloud environments, use a human-run command pack when direct runtime access is unavailable.

## VARNISH_STALE_OR_MISS

Inspect whether Varnish is in the request path, response headers, cookies, TTL, VCL behavior, and backend health. A Varnish MISS is not automatically a fault.

## WRONG_TTL_OR_HEADERS

Compare origin response headers with intended cache policy and edge-observed headers. Trace where the policy changes before altering configuration.
