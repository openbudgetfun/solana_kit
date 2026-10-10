# Upstream audit — solana-mobile/mobile-wallet-adapter protocol-kit@3.0.0 → protocol-kit@3.0.1

`@solana-mobile/mobile-wallet-adapter-protocol-kit@3.0.1` was published on 2026-10-09, one day after 3.0.0. This note maps every change in that release to its Dart counterpart, so the compatibility claim can be audited.

Status: the workspace tracks `protocol-kit@3.0.1` (`checkedCommit 100e023048b7`); `clone:repos:status` verifies the pin.

## Upstream changes

| Commit                                                                                                                    | Change                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `93eafe52` fix(js): keep `startRemoteScenario` out of the React Native builds of protocol-kit and protocol-web3js (#1724) | A module-organization refactor: `startRemoteScenario` and its `KitRemoteMobileWallet` / `KitRemoteScenario` types move from `transact.ts` into a dedicated `startRemoteScenario.ts`, with an empty React Native fork (`src/__forks__/react-native/startRemoteScenario.ts` exporting nothing) because the React Native build of `@solana-mobile/mobile-wallet-adapter-protocol` only ships `transact`. `augmentWalletAPI` becomes exported for the new module. The function body is unchanged from 3.0.0. |
| ten dependency bumps across examples and dev tooling                                                                      | `@react-native-async-storage/async-storage`, `@types/node`, the react-native / wallet-standard / eslint / typescript / solana groups, `next`, `eslint-config-next` — all in `examples/` or dev dependency groups.                                                                                                                                                                                                                                                                                        |

## Dart impact

**None.** The refactor exists because JavaScript bundlers select per-platform builds through package `exports` conditions and React Native forks — a module-graph concern the Dart port does not have. The Dart `startRemoteScenario` lives in `remote_association_scenario.dart`, its behavior was verified against the unchanged function body during the 3.0.0 audit, and no wire-protocol, API, or packaging surface changed in 3.0.1.

## Reference pin

`config/reference-repos.json` advanced `mobile-wallet-adapter` from tag `@solana-mobile/mobile-wallet-adapter-protocol-kit@3.0.0` (`checkedCommit 12b1784ca7b0`) to tag `@solana-mobile/mobile-wallet-adapter-protocol-kit@3.0.1` (`checkedCommit 100e023048b7`).
