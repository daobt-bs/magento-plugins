# Magento cache issue taxonomy

Normalize cases instead of creating a separate rule for every wording of a symptom.

## Failure modes

- `stale`
- `miss`
- `unexpected_hit`
- `wrong_variant`
- `wrong_scope`
- `invalidation_failed`
- `invalidation_too_broad`
- `key_collision`
- `ttl_wrong`
- `backend_unavailable`
- `storage_full`
- `eviction`
- `stampede`
- `lock_contention`
- `security_leak`
- `performance_degradation`

## Initial issue IDs

Tier 1: `FPC_MISS`, `FPC_STALE`, `FPC_UNCACHEABLE_BLOCK`, `CACHE_INVALIDATION_FAILED`, `WRONG_CACHE_CONTEXT`, `PRIVATE_CONTENT_STALE`, `CACHE_DISABLED`, `CACHE_OVER_INVALIDATION`, `REDIS_UNAVAILABLE`, `REDIS_MEMORY_EVICTION`.

Tier 2: `CONFIG_STALE`, `LAYOUT_STALE`, `BLOCK_HTML_STALE`, `STATIC_ASSET_STALE`, `IMAGE_CACHE_STALE`, `WRONG_CACHE_KEY`, `MULTI_NODE_CACHE_INCONSISTENCY`, `WRONG_TTL_OR_HEADERS`, `CDN_FASTLY_STALE_OR_MISS`, `VARNISH_STALE_OR_MISS`.

Tier 3: `L2_CACHE_PROBLEM`, `GRAPHQL_CACHE_PROBLEM`, `WEBHOOK_CACHE_PROBLEM`, `REFLECTION_CACHE_STALE`, `EAV_METADATA_STALE`, `DB_DDL_CACHE_STALE`, `COMPILED_CONFIG_STALE`, `BACKEND_STORAGE_PROBLEM`, `GENERATED_CODE_STALE`, `OPCACHE_STALE`.

## Rule coverage

Every ID above resolves to a rule file. Load the file listed for the case's ID:

| ID | Rule |
| --- | --- |
| `FPC_MISS`, `FPC_STALE`, `FPC_UNCACHEABLE_BLOCK`, `CACHE_INVALIDATION_FAILED`, `WRONG_CACHE_CONTEXT`, `WRONG_CACHE_KEY` | `rules/fpc.md` |
| `PRIVATE_CONTENT_STALE` | `rules/private-content.md` |
| `CACHE_DISABLED`, `CONFIG_STALE`, `COMPILED_CONFIG_STALE`, `LAYOUT_STALE`, `BLOCK_HTML_STALE`, `L2_CACHE_PROBLEM`, `GRAPHQL_CACHE_PROBLEM`, `WEBHOOK_CACHE_PROBLEM`, `REFLECTION_CACHE_STALE`, `EAV_METADATA_STALE`, `DB_DDL_CACHE_STALE` | `rules/app-cache.md` |
| `REDIS_UNAVAILABLE`, `REDIS_MEMORY_EVICTION`, `BACKEND_STORAGE_PROBLEM`, `CACHE_OVER_INVALIDATION` | `rules/redis.md` |
| `STATIC_ASSET_STALE`, `IMAGE_CACHE_STALE` | `rules/static.md` |
| `GENERATED_CODE_STALE`, `OPCACHE_STALE`, `MULTI_NODE_CACHE_INCONSISTENCY` | `rules/runtime.md` |
| `WRONG_TTL_OR_HEADERS`, `CDN_FASTLY_STALE_OR_MISS`, `VARNISH_STALE_OR_MISS` | `rules/edge.md` |

When a case fits no listed ID, normalize it into the closest one and record the mismatch rather than inventing an ID.

## Case shape

```yaml
case:
  raw_prompt: "..."
  environment:
    type: unknown
    confidence: 0
  symptom:
    category: stale_content
    entity: product
    attribute: price
  suspected_layers: []
  evidence: []
  hypotheses: []
  status: investigating
```
