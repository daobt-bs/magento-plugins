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
command: curl -sSI https://example.com/path
risk: read_only
purpose: distinguish edge behavior from origin behavior
expected_fields: [Age, Cache-Control, Vary, Set-Cookie, X-Magento-Cache-Debug]
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
