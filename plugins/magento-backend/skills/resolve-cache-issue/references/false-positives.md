# Cache false positives

## Product value is old

Check database value, price/stock/search index state, FPC/block cache, then CDN/browser as applicable. Possible causes include wrong store scope, customer group, currency, price rules, index state, application logic, or cache context.

## Search result is missing

Investigate OpenSearch/Elasticsearch, indexers, product visibility/status, and inventory/index state before assuming cache.

## Login/cart state is wrong

Consider session storage, cookie domain/path, Redis sessions, load balancer behavior, sticky sessions, customer-data, localStorage, private content, and FPC.

## CSS/JS is old

Consider source files, static deployment, `pub/static`, `var/view_preprocessed`, RequireJS configuration, browser cache, and CDN cache.

## PHP code still behaves old

Consider deployment version, wrong node, `generated/code`, `generated/metadata`, DI compilation artifacts, OPcache, and application cache.

## Rule

Do not prescribe cache remediation until evidence separates the cache hypothesis from the strongest adjacent explanation.
