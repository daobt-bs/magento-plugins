# bs-plugins

Claude Code plugin marketplace for the Magento 2 Dev team.

## Plugins

| Plugin | Description |
|--------|-------------|
| [`magento-backend`](plugins/magento-backend/README.md) | Skills for Magento 2 backend code review, debugging, and security auditing |

## Structure

```
.
├── .claude-plugin/
│   └── marketplace.json                      # Marketplace manifest
└── plugins/
    └── magento-backend/
        ├── .claude-plugin/plugin.json        # Plugin manifest
        ├── README.md
        └── skills/
            ├── validate-magento-backend-code/SKILL.md
            ├── magento-debug/SKILL.md
            └── security-audit/SKILL.md
```

## Installation

Requires [Claude Code](https://docs.claude.com/en/docs/claude-code) with plugin support.

### Option 1 — Inside Claude Code

Run these slash commands in a Claude Code session:

```
/plugin marketplace add daobt-bs/magento-plugins
/plugin install magento-backend@bs-plugins
```

Then restart Claude Code. Run `/plugin` to confirm the plugin is installed and enabled.

### Option 2 — From the terminal

```bash
claude plugin marketplace add daobt-bs/magento-plugins
claude plugin install magento-backend@bs-plugins
```

By default the plugin is installed for your user (all projects). Use `--scope project` to install it only for the current project, or `--scope local` for the current project without sharing it via the repo.

### Option 3 — Enable for the whole team in a project

Add this to your Magento project's `.claude/settings.json` and commit it. Teammates who trust the project folder are prompted to install the marketplace and plugin automatically:

```json
{
  "extraKnownMarketplaces": {
    "bs-plugins": {
      "source": {
        "source": "github",
        "repo": "daobt-bs/magento-plugins"
      }
    }
  },
  "enabledPlugins": {
    "magento-backend@bs-plugins": true
  }
}
```

### Updating

```bash
claude plugin marketplace update bs-plugins
claude plugin update magento-backend@bs-plugins
```

Restart Claude Code to apply the update.

### Uninstalling

```bash
claude plugin uninstall magento-backend@bs-plugins
claude plugin marketplace remove bs-plugins
```

### Local development

Clone the repo and load the plugin directly without installing:

```bash
git clone https://github.com/daobt-bs/magento-plugins.git
claude --plugin-dir ./magento-plugins/plugins/magento-backend
```

## Adding a new plugin

1. Create `plugins/<plugin-name>/.claude-plugin/plugin.json` and add its skills under `plugins/<plugin-name>/skills/`.
2. Register it in `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "<plugin-name>",
     "source": "./plugins/<plugin-name>",
     "description": "..."
   }
   ```
3. Add a row to the Plugins table above.
4. Run `claude plugin validate .` to check the manifests.
