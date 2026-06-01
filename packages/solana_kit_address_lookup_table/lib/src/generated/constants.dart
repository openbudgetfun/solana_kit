export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show addressLookupTableProgramAddress;

/// Number of bytes used by the lookup table metadata before stored addresses.
const addressLookupTableMetaSize = 56;

/// Number of bytes used by the lookup table metadata before stored addresses.
const int lookupTableMetaSize = addressLookupTableMetaSize;

/// Maximum number of addresses an Address Lookup Table can hold.
const addressLookupTableMaxAddresses = 256;

/// Maximum number of addresses an Address Lookup Table can hold.
const int lookupTableMaxAddresses = addressLookupTableMaxAddresses;

/// Maximum number of addresses that fit in one extend instruction before the
/// lookup table reaches [addressLookupTableMaxAddresses].
const int addressLookupTableMaxNewAddresses = addressLookupTableMaxAddresses;

/// Maximum number of addresses that fit in one extend instruction before the
/// lookup table reaches [lookupTableMaxAddresses].
const int lookupTableMaxNewAddresses = addressLookupTableMaxNewAddresses;
