# Magento application cache rules

Magento application cache types (config, layout, block_html, collections, eav, db_ddl, reflection, compiled_config, translate, and module-provided types such as `customer_notification`, `graphql_query_resolver_result`, `config_webservice`, `config_integration`, `config_integration_api`) sit below FPC and above the backend. Adobe Commerce adds `webhooks_response`, `target_rule`, and `admin_ui_sdk`. Confirm the type list with `bin/magento cache:status` on the target project rather than assuming it — the list depends on the installed version and modules.

FPC and edge behavior are covered in `fpc.md` and `edge.md`; backend storage faults in `redis.md`.

## CACHE_DISABLED

A cache type that is off explains staleness and performance symptoms with no backend or invalidation fault at all, so establish enable state before investigating anything else. Inspect per-type `bin/magento cache:status`, the `cache_types` override in `app/etc/env.php` (written by `cache:enable`/`cache:disable`), a module or deployment script that disables a type, and whether a type is disabled on only some nodes. Check whether the disabled state is intentional and when it started; an incident-response disable that was never reverted is a common cause. Treat `BACKEND_STORAGE_PROBLEM` as the sibling hypothesis: there a type is enabled but storage fails, and the two are distinguished by backend evidence, not by the symptom.

## CONFIG_STALE

The `config` type holds merged system configuration from `config.xml`, the database (`core_config_data`), and deployment overrides. Symptoms: a setting appears reverted, changed values do not take effect, or behavior differs per store/website. Inspect the scope chain (default → website → store) for the affected path, the persisted row, whether the change was made through the admin/API (which invalidates) or by direct DB write (which does not), and whether `app/etc/env.php` overrides the value. Deployment overrides do not live in `core_config_data` and can win over the database value, which mimics staleness.

## COMPILED_CONFIG_STALE

`compiled_config`/DI compilation output in `generated/metadata` is a build artifact produced by `setup:di:compile`, not a runtime cache entry. Wrong behavior after a deploy with correctly invalidated config and layout caches usually means the artifact, the node, or the deployment version is wrong rather than a stale cache. Inspect deployment version, node identity, and generated artifacts before touching cache. Coordinate with `runtime.md` `GENERATED_CODE_STALE`, which covers the same artifacts from the generated-code side.

## LAYOUT_STALE

The `layout` type holds merged layout XML per page handle. Inspect layout XML overrides, observer/plugin-driven layout changes, theme and design fallback, and whether the change actually reached every node. Layout cache is broad: core offers no per-handle or per-block invalidation, so cleaning it affects all pages — state that blast radius before recommending it, and prefer finding the specific layout change that failed to invalidate over clearing the type.

## BLOCK_HTML_STALE

`block_html` caches block output separately from the full page. A block-level stale value while FPC behaves correctly points here rather than at FPC. Inspect the block's cacheable flag and cache lifetime, whether `getCacheKeyInfo()` covers every dimension the block's output depends on, and whether the block's owner invalidates it when the underlying data changes. Distinguish this from FPC_STALE: verify at block level before concluding the page cache is at fault.

## L2_CACHE_PROBLEM

L1/L2 is a cache *backend topology*, not a cache type, and it is not the `collections` type. When configured, application cache entries live in two places at once: L1 is a per-node local backend (file, e.g. `var/cache/magento_l1`) and L2 is the shared Redis/Valkey instance. Two implementations exist — `Magento\Framework\Cache\Backend\RemoteSynchronizedCache` (Zend) and the Symfony adapter registered as `symfony_l2`, with `Valkey` as the remote backend for both. L2 is the source of truth: each entry gets a companion `<id>:hash` key holding its payload hash, and a node serves its L1 copy only when that hash still matches L2.

Start by confirming the topology rather than assuming it. Inspect `cache/frontend/default/backend` and `backend_options` in `app/etc/env.php`: is a synchronized backend configured at all, which `local_backend`/`cache_dir` does it use, and is `use_stale_cache` set. If neither backend is configured, this hypothesis does not apply and the case is a plain backend or invalidation fault.

Two failure shapes follow from the design:

- **Per-node divergence.** One node serves a value while the rest are correct, or a deploy fixes some nodes and not others. The node's L1 copy outlived the L2 entry it was supposed to track — L2 was flushed or evicted (`redis.md` `REDIS_MEMORY_EVICTION`) while the local files survived. Collect the served value per node alongside node identity, and compare the local cache directory contents on each node against the `<id>:hash` keys present in L2 under the configured `id_prefix`.
- **Stale-but-served-by-design.** With `use_stale_cache` enabled, a node whose L2 entry is missing takes a lock and returns the *stale local* value instead of regenerating, notifying the application through `CompositeStaleCacheNotifier` rather than failing. A short window of provably old content after an invalidation, self-healing without intervention, is this behavior and not a broken invalidation. Confirm `use_stale_cache` in the frontend configuration before treating the recurrence as a defect.

FPC is deliberately kept off the shared L2 — it stays on its dedicated `page_cache` frontend because default-cache tag invalidations and FPC entries in the same Redis database evict each other's pages. A reported FPC symptom is therefore not this rule; treat it under `fpc.md` even when L1/L2 is configured.

Note that local writes carry no tags by design (tags live in L2 so nodes cannot diverge), `clean()` clears both levels, and `remove()` skips L1 when `use_stale_cache` is on. A case where cleaning one cache type leaves the symptom in place on a single node is consistent with an L1 copy that no targeted operation reaches — the per-node local directory is the only thing left holding the old value. Check local cache directory capacity too: a full L1 triggers the backend's own cleanup and produces eviction-shaped symptoms with a healthy L2. Distinguish this rule from `BACKEND_STORAGE_PROBLEM`, where L2 is unreachable and every node misses, and from `runtime.md` `MULTI_NODE_CACHE_INCONSISTENCY`, which covers node-level divergence that does not come from the cache backend.

## GRAPHQL_CACHE_PROBLEM

GraphQL caching is its own stack: the `graphql_query_resolver_result` type plus response-level caching (persisted queries, cache identity headers, and any CDN in front of the endpoint). Inspect whether the affected operation is a query or a mutation, whether customer context or a token makes the response uncacheable or wrongly shareable, the response's cache identity, and whether an edge layer caches the response. Do not clean application caches to address a GraphQL-layer issue without evidence pointing at that type.

## WEBHOOK_CACHE_PROBLEM

The `webhooks_response` type caches response data consumed through the webhook/async API path, so a stale value reflects the cached upstream response rather than Magento state. Inspect the type's enable state, the owning module's enablement, the configured lifetime, and the code path that reads and re-validates the cached response. Confirm the reported staleness is in the cached response and not in the producer's own data before remediating.

## REFLECTION_CACHE_STALE

The `reflection` type caches parsed PHP reflection and annotation data used by DI and plugin wiring. Stale reflection looks like changed plugin/interceptor behavior after a deploy that persists on a node. Inspect deployment version and node identity first: this is usually a deployment or wrong-node problem surfacing through the cache, and cleaning the type does not fix a node running the wrong code. Verify plugin/DI behavior after remediation rather than cache-clean success.

## EAV_METADATA_STALE

The `eav` type caches entity attribute metadata — attribute sets, attribute definitions, and frontend/backend models. Symptoms: a new attribute is unavailable or errors, attribute changes do not appear, or an attribute renders with the wrong model. Inspect whether the change came through a data patch and `setup:upgrade` (which invalidates) or through a direct database write (which does not), and compare the cached metadata against the `eav_attribute`/`eav_entity_attribute` rows. Verify by re-reading the affected attribute through the application, not by cache status.

## DB_DDL_CACHE_STALE

The `db_ddl` type caches the database schema description. Symptoms after a schema change: "column not found", missing table or index, or the application behaving against an older schema. Inspect whether the schema change was applied through declarative schema / `setup:upgrade` (which should invalidate this type) or through manual SQL, a migration run against a different database, or a container image built on a different schema revision. Multi-node schema skew is a common shape — collect node identity and the applied schema revision from each relevant node.

## Evidence to collect

Per type: `bin/magento cache:status` output, the owning configuration or source that governs the type, the invalidation path for the changed entity, and the specific request or action that reproduces the symptom before and after remediation. Application cache state in `app/etc/env.php` and the backend configuration belong with the backend evidence in `redis.md`.