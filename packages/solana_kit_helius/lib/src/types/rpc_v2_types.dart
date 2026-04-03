// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// Request to get program accounts with V2 pagination.
class GetProgramAccountsV2Request {
  const GetProgramAccountsV2Request({
    required this.programAddress,
    this.filters,
    this.encoding,
    this.dataSlice,
    this.after,
    this.limit,
  });

  factory GetProgramAccountsV2Request.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetProgramAccountsV2Request(
      programAddress: r.requireString('programAddress'),
      filters: r.optList<Map<String, Object?>>('filters'),
      encoding: r.optString('encoding'),
      dataSlice: r.optInt('dataSlice'),
      after: r.optString('after'),
      limit: r.optInt('limit'),
    );
  }

  final String programAddress;
  final List<Map<String, Object?>>? filters;
  final String? encoding;
  final int? dataSlice;
  final String? after;
  final int? limit;

  Map<String, Object?> toJson() => {
    'programAddress': programAddress,
    if (filters != null) 'filters': filters,
    if (encoding != null) 'encoding': encoding,
    if (dataSlice != null) 'dataSlice': dataSlice,
    if (after != null) 'after': after,
    if (limit != null) 'limit': limit,
  };
}

/// Response containing program accounts with V2 pagination.
class GetProgramAccountsV2Response {
  const GetProgramAccountsV2Response({required this.accounts, this.cursor});

  factory GetProgramAccountsV2Response.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetProgramAccountsV2Response(
      accounts: r.requireDecodedList(
        'accounts',
        ProgramAccountV2.fromJson,
      ),
      cursor: r.optString('cursor'),
    );
  }

  final List<ProgramAccountV2> accounts;
  final String? cursor;

  Map<String, Object?> toJson() => {
    'accounts': accounts.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A program account returned by the V2 API.
class ProgramAccountV2 {
  const ProgramAccountV2({required this.pubkey, required this.account});

  factory ProgramAccountV2.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ProgramAccountV2(
      pubkey: r.requireString('pubkey'),
      account: r.requireMap('account'),
    );
  }

  final String pubkey;
  final Map<String, Object?> account;

  Map<String, Object?> toJson() => {'pubkey': pubkey, 'account': account};
}

/// Request to get token accounts by owner with V2 pagination.
class GetTokenAccountsByOwnerV2Request {
  const GetTokenAccountsByOwnerV2Request({
    required this.ownerAddress,
    this.mint,
    this.programId,
    this.encoding,
    this.after,
    this.limit,
  });

  factory GetTokenAccountsByOwnerV2Request.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTokenAccountsByOwnerV2Request(
      ownerAddress: r.requireString('ownerAddress'),
      mint: r.optString('mint'),
      programId: r.optString('programId'),
      encoding: r.optString('encoding'),
      after: r.optString('after'),
      limit: r.optInt('limit'),
    );
  }

  final String ownerAddress;
  final String? mint;
  final String? programId;
  final String? encoding;
  final String? after;
  final int? limit;

  Map<String, Object?> toJson() => {
    'ownerAddress': ownerAddress,
    if (mint != null) 'mint': mint,
    if (programId != null) 'programId': programId,
    if (encoding != null) 'encoding': encoding,
    if (after != null) 'after': after,
    if (limit != null) 'limit': limit,
  };
}

/// Response containing token accounts with V2 pagination.
class GetTokenAccountsByOwnerV2Response {
  const GetTokenAccountsByOwnerV2Response({
    required this.accounts,
    this.cursor,
  });

  factory GetTokenAccountsByOwnerV2Response.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetTokenAccountsByOwnerV2Response(
      accounts: r.requireDecodedList(
        'accounts',
        TokenAccountV2.fromJson,
      ),
      cursor: r.optString('cursor'),
    );
  }

  final List<TokenAccountV2> accounts;
  final String? cursor;

  Map<String, Object?> toJson() => {
    'accounts': accounts.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A token account returned by the V2 API.
class TokenAccountV2 {
  const TokenAccountV2({required this.pubkey, required this.account});

  factory TokenAccountV2.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TokenAccountV2(
      pubkey: r.requireString('pubkey'),
      account: r.requireMap('account'),
    );
  }

  final String pubkey;
  final Map<String, Object?> account;

  Map<String, Object?> toJson() => {'pubkey': pubkey, 'account': account};
}

/// Request to get transactions for an address with V2 pagination.
class GetTransactionsForAddressRequest {
  const GetTransactionsForAddressRequest({
    required this.address,
    this.before,
    this.until,
    this.limit,
    this.commitment,
  });

  factory GetTransactionsForAddressRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTransactionsForAddressRequest(
      address: r.requireString('address'),
      before: r.optString('before'),
      until: r.optString('until'),
      limit: r.optInt('limit'),
      commitment: r.optEnum('commitment', CommitmentLevel.fromJson),
    );
  }

  final String address;
  final String? before;
  final String? until;
  final int? limit;
  final CommitmentLevel? commitment;

  Map<String, Object?> toJson() => {
    'address': address,
    if (before != null) 'before': before,
    if (until != null) 'until': until,
    if (limit != null) 'limit': limit,
    if (commitment != null) 'commitment': commitment!.toJson(),
  };
}

/// Response containing transactions for an address.
class GetTransactionsForAddressResponse {
  const GetTransactionsForAddressResponse({required this.transactions});

  factory GetTransactionsForAddressResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetTransactionsForAddressResponse(
      transactions: r.requireDecodedList(
        'transactions',
        TransactionForAddress.fromJson,
      ),
    );
  }

  final List<TransactionForAddress> transactions;

  Map<String, Object?> toJson() => {
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };
}

/// A transaction associated with an address.
class TransactionForAddress {
  const TransactionForAddress({
    required this.signature,
    required this.slot,
    this.blockTime,
    this.err,
    this.memo,
  });

  factory TransactionForAddress.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TransactionForAddress(
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      blockTime: r.optInt('blockTime'),
      err: r.raw('err'),
      memo: r.optString('memo'),
    );
  }

  final String signature;
  final int slot;
  final int? blockTime;
  final Object? err;
  final String? memo;

  Map<String, Object?> toJson() => {
    'signature': signature,
    'slot': slot,
    if (blockTime != null) 'blockTime': blockTime,
    if (err != null) 'err': err,
    if (memo != null) 'memo': memo,
  };
}
