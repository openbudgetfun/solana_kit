---
"solana_kit_surfpool": patch
---

# Pass the fork datasource URL through the environment

`Surfnet` passed a fork's upstream RPC URL — whose query string commonly carries an API key — as a `--rpc-url` process argument, where it was world-readable through `ps` and `/proc` on the machine running Surfnet. The URL now rides in the `SURFPOOL_DATASOURCE_RPC_URL` environment variable, which the CLI supports natively; output redaction is unchanged.
