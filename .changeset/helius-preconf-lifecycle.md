---
"solana_kit_helius": patch
---

# Fix Helius preconfirmation lifecycle

Handle preconfirmation WebSocket readiness, stream, send, and shutdown failures without exposing endpoint credentials or leaving pending requests unresolved. Wait for connection readiness before sending, close notification streams on terminal failures, encode API-key query values safely, and support an injectable channel connector.
