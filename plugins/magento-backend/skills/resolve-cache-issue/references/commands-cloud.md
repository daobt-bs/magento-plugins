# Cloud human command packs

Use small, read-only packs. Every command should have a purpose, risk, expected fields, and the decision it enables.

## Cache status

```yaml
id: MAGENTO_CACHE_STATUS
command: bin/magento cache:status
risk: read_only
purpose: determine enabled Magento cache types
expected_fields: [config, layout, block_html, full_page]
```

## HTTP behavior

```yaml
id: HTTP_CACHE_HEADERS
command: curl -sS -D - -o /dev/null -H 'X-Magento-Debug: 1' https://example.com/path
risk: read_only
purpose: distinguish edge behavior from origin behavior
expected_fields: [X-Magento-Cache-Debug, X-Magento-Cache-Control, Age, Cache-Control, Vary, Set-Cookie]
interpretation:
  - X-Magento-Cache-Debug reads HIT, MISS, or UNCACHEABLE when Varnish is in front; on the built-in FPC it is set only in developer mode, so its absence is not evidence of a MISS.
  - Age is present only on a Varnish HIT, and only when the request carried X-Magento-Debug; Varnish otherwise strips it.
  - X-Magento-Tags is set by Magento but deleted by Varnish, so it must be read from origin directly to be meaningful.
  - X-Magento-Cache-Control appears only with the debug header and carries the origin's own Cache-Control before Varnish rewrote it.
  - Repeat with the affected request's cookies and the same URL before comparing; a cookie-less request can HIT or MISS differently from the reported one.
```

## Node identity

```yaml
id: NODE_IDENTITY
command: hostname
risk: read_only
purpose: correlate evidence with a specific node
expected_fields: [hostname]
```

## Redis

```yaml
id: REDIS_MEMORY_INFO
command: redis-cli INFO memory
risk: read_only
purpose: inspect memory pressure, maxmemory, and eviction context
expected_fields: [used_memory, used_memory_peak, maxmemory]
```

```yaml
id: REDIS_STATS_INFO
command: redis-cli INFO stats
risk: read_only
purpose: inspect hit/miss and eviction signals
expected_fields: [keyspace_hits, keyspace_misses, evicted_keys]
```

## Disk

```yaml
id: DISK_USAGE
command: df -h
risk: read_only
purpose: detect filesystem capacity pressure
expected_fields: [filesystem, size, used, avail, capacity]
```

For logs and multi-node checks, use the environment's supported access path and identify the node before interpreting the sample. Never make destructive commands the default cloud diagnostic path.
