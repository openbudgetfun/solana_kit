---
"solana_kit_rpc_spec_types": patch
---

# Bound BigInt materialization from plain integer literals

`parseJsonWithBigInts` capped positive-exponent expansion at 10,000 but accepted a plain integer literal of any length, so a hostile RPC response containing a multi-megabyte integer forced a same-sized `BigInt` allocation for a cost far cheaper for the sender than for this process. Integer literals are now rejected when they would materialize more than 10,001 digits — the same ceiling the exponent cap already permits — on both the plain and the mantissa-plus-exponent paths. No value the exponent path accepted before changes.
