# Wallet UI example

Run the production platform registry:

```sh
fvm flutter run
```

Run the deterministic wallet used by browser and Patrol verification:

```sh
fvm flutter run --dart-define=DEMO_WALLET=true
```

For Android Patrol against Surfpool, start the validator on an address reachable by the device and pass that URL:

```sh
surfpool start --host 0.0.0.0 --offline --ci
patrol test -d <device-id> \
  --dart-define=DEMO_WALLET=true \
  --dart-define=SURFPOOL_URL=http://<host-ip>:8899
```

An Android emulator can use `http://10.0.2.2:8899`. A physical device must use the development machine's LAN address.
