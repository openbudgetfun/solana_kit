// ignore_for_file: public_member_api_docs

export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show addressLookupTableProgramAddress;

/// Number of bytes used by the lookup table metadata before stored addresses.
const addressLookupTableMetaSize = 56;

/// Number of bytes used by the lookup table metadata before stored addresses.
const lookupTableMetaSize = addressLookupTableMetaSize;

/// Maximum number of addresses an Address Lookup Table can hold.
const addressLookupTableMaxAddresses = 256;

/// Maximum number of addresses an Address Lookup Table can hold.
const lookupTableMaxAddresses = addressLookupTableMaxAddresses;

/// Maximum number of addresses that fit in one extend instruction before the
/// lookup table reaches [addressLookupTableMaxAddresses].
const addressLookupTableMaxNewAddresses = addressLookupTableMaxAddresses;

/// Maximum number of addresses that fit in one extend instruction before the
/// lookup table reaches [lookupTableMaxAddresses].
const lookupTableMaxNewAddresses = addressLookupTableMaxNewAddresses;
