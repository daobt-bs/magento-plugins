# Environment handling

## Local / development

If direct runtime access is available, investigate autonomously with read-only evidence first. Low-risk local remediation may be performed when it is clearly within the user's task and reversible.

Inspect source, configuration, database, filesystem, Docker/services, Magento CLI, HTTP, Redis/Valkey, Varnish, logs, generated artifacts, and static content as the hypothesis requires.

## Staging / production / cloud

Do not assume direct access to remote infrastructure. Prefer a small human-run diagnostic pack when runtime evidence is unavailable.

Remote command packs should identify command, purpose, risk, expected fields, and what decision the output enables. Production mutations remain human-controlled.

Cloud topology and supported commands are environment-specific; do not assume every Adobe Commerce Cloud environment exposes the same runtime tools.

## Multi-node

If inconsistency is suspected, identify the node and collect equivalent evidence from the relevant nodes. One healthy node does not prove the fleet is healthy.
