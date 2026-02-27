---
solana_kit_program_client_core: patch
solana_kit_rpc: patch
solana_kit_rpc_api: patch
solana_kit_rpc_subscriptions: patch
solana_kit_rpc_subscriptions_channel_websocket: patch
solana_kit_rpc_transport_http: patch
solana_kit_rpc_types: patch
---

Harden transport defaults (secure HTTP/WS by default with explicit insecure opt-in), flesh out program client core send/planning callbacks, expand RPC model/params/subscription test coverage, and improve workspace CI/testing automation.
