# Private content rules

## PRIVATE_CONTENT_STALE

Check customer-data sections, `sections.xml`, `private_content_version`, browser localStorage, cookies, the state-changing request and its HTTP semantics, and session storage where relevant.

Public page HTML can be cached while private customer data is refreshed independently. Verify customer-data state after the mutation and refresh path.
