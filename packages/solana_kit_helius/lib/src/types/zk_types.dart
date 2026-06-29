import 'package:solana_kit_helius/src/internal/json_reader.dart';

/// A compressed account in ZK compression.
class CompressedAccount {
  /// Creates a [CompressedAccount].
  const CompressedAccount({
    required this.hash,
    required this.address,
    required this.data,
    required this.owner,
    required this.lamports,
    this.leafIndex,
    this.tree,
    this.seq,
  });

  /// Creates a [CompressedAccount] from JSON.
  factory CompressedAccount.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedAccount(
      hash: r.requireString('hash'),
      address: r.requireString('address'),
      data: r.requireMap('data'),
      owner: r.requireString('owner'),
      lamports: r.requireInt('lamports'),
      leafIndex: r.optInt('leafIndex'),
      tree: r.optString('tree'),
      seq: r.optInt('seq'),
    );
  }

  /// The hash of this compressed account.
  final String hash;

  /// The address of this compressed account.
  final String address;

  /// The account data as a JSON map.
  final Map<String, Object?> data;

  /// The owner of this compressed account.
  final String owner;

  /// The lamport balance of this compressed account.
  final int lamports;

  /// The index of the leaf in the Merkle tree, if known.
  final int? leafIndex;

  /// The address of the state tree holding this account, if known.
  final String? tree;

  /// The sequence number of this account, if known.
  final int? seq;

  /// Converts this [CompressedAccount] to JSON.
  Map<String, Object?> toJson() => {
    'hash': hash,
    'address': address,
    'data': data,
    'owner': owner,
    'lamports': lamports,
    if (leafIndex != null) 'leafIndex': leafIndex,
    if (tree != null) 'tree': tree,
    if (seq != null) 'seq': seq,
  };
}

/// A Merkle proof for a compressed account.
class CompressedAccountProof {
  /// Creates a [CompressedAccountProof].
  const CompressedAccountProof({
    required this.hash,
    required this.root,
    required this.proof,
    required this.leafIndex,
    this.tree,
  });

  /// Creates a [CompressedAccountProof] from JSON.
  factory CompressedAccountProof.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedAccountProof(
      hash: r.requireString('hash'),
      root: r.requireString('root'),
      proof: r.requireList<String>('proof'),
      leafIndex: r.requireInt('leafIndex'),
      tree: r.optString('tree'),
    );
  }

  /// The hash of the compressed account this proof is for.
  final String hash;

  /// The Merkle root of the tree containing the account.
  final String root;

  /// The sibling hashes forming the Merkle proof path.
  final List<String> proof;

  /// The index of the leaf in the Merkle tree.
  final int leafIndex;

  /// The address of the state tree holding this account, if known.
  final String? tree;

  /// Converts this [CompressedAccountProof] to JSON.
  Map<String, Object?> toJson() => {
    'hash': hash,
    'root': root,
    'proof': proof,
    'leafIndex': leafIndex,
    if (tree != null) 'tree': tree,
  };
}

/// A compressed token account.
class CompressedTokenAccount {
  /// Creates a [CompressedTokenAccount].
  const CompressedTokenAccount({
    required this.hash,
    required this.owner,
    required this.mint,
    required this.amount,
    required this.frozen,
    this.delegate,
    this.leafIndex,
    this.tree,
  });

  /// Creates a [CompressedTokenAccount] from JSON.
  factory CompressedTokenAccount.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedTokenAccount(
      hash: r.requireString('hash'),
      owner: r.requireString('owner'),
      mint: r.requireString('mint'),
      amount: r.requireInt('amount'),
      delegate: r.optString('delegate'),
      frozen: r.requireBool('frozen'),
      leafIndex: r.optInt('leafIndex'),
      tree: r.optString('tree'),
    );
  }

  /// The hash of this compressed token account.
  final String hash;

  /// The owner of this compressed token account.
  final String owner;

  /// The mint address of the token.
  final String mint;

  /// The token balance held by this account.
  final int amount;

  /// The delegate authority of this account, if any.
  final String? delegate;

  /// Whether this account is frozen.
  final bool frozen;

  /// The index of the leaf in the Merkle tree, if known.
  final int? leafIndex;

  /// The address of the state tree holding this account, if known.
  final String? tree;

  /// Converts this [CompressedTokenAccount] to JSON.
  Map<String, Object?> toJson() => {
    'hash': hash,
    'owner': owner,
    'mint': mint,
    'amount': amount,
    if (delegate != null) 'delegate': delegate,
    'frozen': frozen,
    if (leafIndex != null) 'leafIndex': leafIndex,
    if (tree != null) 'tree': tree,
  };
}

/// A compressed account balance.
class CompressedBalance {
  /// Creates a [CompressedBalance].
  const CompressedBalance({required this.amount});

  /// Creates a [CompressedBalance] from JSON.
  factory CompressedBalance.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedBalance(amount: r.requireInt('amount'));
  }

  /// The lamport balance of the compressed account.
  final int amount;

  /// Converts this [CompressedBalance] to JSON.
  Map<String, Object?> toJson() => {'amount': amount};
}

/// A compressed token balance.
class CompressedTokenBalance {
  /// Creates a [CompressedTokenBalance].
  const CompressedTokenBalance({required this.mint, required this.amount});

  /// Creates a [CompressedTokenBalance] from JSON.
  factory CompressedTokenBalance.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedTokenBalance(
      mint: r.requireString('mint'),
      amount: r.requireInt('amount'),
    );
  }

  /// The mint address of the token.
  final String mint;

  /// The token balance amount.
  final int amount;

  /// Converts this [CompressedTokenBalance] to JSON.
  Map<String, Object?> toJson() => {'mint': mint, 'amount': amount};
}

/// A compressed token balance with decimals (V2).
class CompressedTokenBalanceV2 {
  /// Creates a [CompressedTokenBalanceV2].
  const CompressedTokenBalanceV2({
    required this.mint,
    required this.amount,
    required this.decimals,
  });

  /// Creates a [CompressedTokenBalanceV2] from JSON.
  factory CompressedTokenBalanceV2.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedTokenBalanceV2(
      mint: r.requireString('mint'),
      amount: r.requireInt('amount'),
      decimals: r.requireInt('decimals'),
    );
  }

  /// The mint address of the token.
  final String mint;

  /// The token balance amount.
  final int amount;

  /// The number of decimals for this mint.
  final int decimals;

  /// Converts this [CompressedTokenBalanceV2] to JSON.
  Map<String, Object?> toJson() => {
    'mint': mint,
    'amount': amount,
    'decimals': decimals,
  };
}

/// A compressed transaction signature.
class CompressedSignature {
  /// Creates a [CompressedSignature].
  const CompressedSignature({
    required this.signature,
    required this.slot,
    this.blockTime,
  });

  /// Creates a [CompressedSignature] from JSON.
  factory CompressedSignature.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedSignature(
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      blockTime: r.optInt('blockTime'),
    );
  }

  /// The transaction signature.
  final String signature;

  /// The slot in which the transaction was processed.
  final int slot;

  /// The block time of the transaction, if available.
  final int? blockTime;

  /// Converts this [CompressedSignature] to JSON.
  Map<String, Object?> toJson() => {
    'signature': signature,
    'slot': slot,
    if (blockTime != null) 'blockTime': blockTime,
  };
}

/// Health status of the ZK compression indexer.
class IndexerHealth {
  /// Creates an [IndexerHealth].
  const IndexerHealth({required this.status});

  /// Creates an [IndexerHealth] from JSON.
  factory IndexerHealth.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return IndexerHealth(status: r.requireString('status'));
  }

  /// The current health status of the indexer.
  final String status;

  /// Converts this [IndexerHealth] to JSON.
  Map<String, Object?> toJson() => {'status': status};
}

/// A validity proof for ZK compression operations.
class ValidityProof {
  /// Creates a [ValidityProof].
  const ValidityProof({
    required this.compressedProof,
    this.rootIndices,
    this.leafIndices,
  });

  /// Creates a [ValidityProof] from JSON.
  factory ValidityProof.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ValidityProof(
      compressedProof: r.requireList<String>('compressedProof'),
      rootIndices: r.optList<String>('rootIndices'),
      leafIndices: r.optString('leafIndices'),
    );
  }

  /// The compressed proof elements.
  final List<String> compressedProof;

  /// The root indices used by the proof, if available.
  final List<String>? rootIndices;

  /// The leaf indices used by the proof, if available.
  final String? leafIndices;

  /// Converts this [ValidityProof] to JSON.
  Map<String, Object?> toJson() => {
    'compressedProof': compressedProof,
    if (rootIndices != null) 'rootIndices': rootIndices,
    if (leafIndices != null) 'leafIndices': leafIndices,
  };
}

/// A proof for a new compressed address.
class NewAddressProof {
  /// Creates a [NewAddressProof].
  const NewAddressProof({
    required this.address,
    required this.root,
    required this.proof,
    required this.leafIndex,
    required this.tree,
  });

  /// Creates a [NewAddressProof] from JSON.
  factory NewAddressProof.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return NewAddressProof(
      address: r.requireString('address'),
      root: r.requireString('root'),
      proof: r.requireList<String>('proof'),
      leafIndex: r.requireInt('leafIndex'),
      tree: r.requireString('tree'),
    );
  }

  /// The new compressed address being proven.
  final String address;

  /// The Merkle root of the tree containing the address.
  final String root;

  /// The sibling hashes forming the Merkle proof path.
  final List<String> proof;

  /// The index of the leaf in the Merkle tree.
  final int leafIndex;

  /// The address of the state tree holding this address.
  final String tree;

  /// Converts this [NewAddressProof] to JSON.
  Map<String, Object?> toJson() => {
    'address': address,
    'root': root,
    'proof': proof,
    'leafIndex': leafIndex,
    'tree': tree,
  };
}

/// A transaction with associated compression information.
class TransactionWithCompressionInfo {
  /// Creates a [TransactionWithCompressionInfo].
  const TransactionWithCompressionInfo({
    this.transaction,
    this.compressionInfo,
  });

  /// Creates a [TransactionWithCompressionInfo] from JSON.
  factory TransactionWithCompressionInfo.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TransactionWithCompressionInfo(
      transaction: r.raw('transaction'),
      compressionInfo: r.optMap('compressionInfo'),
    );
  }

  /// The raw transaction object, if present.
  final Object? transaction;

  /// The compression metadata associated with the transaction, if present.
  final Map<String, Object?>? compressionInfo;

  /// Converts this [TransactionWithCompressionInfo] to JSON.
  Map<String, Object?> toJson() => {
    if (transaction != null) 'transaction': transaction,
    if (compressionInfo != null) 'compressionInfo': compressionInfo,
  };
}

// ---------------------------------------------------------------------------
// Request types for ZK compression methods
// ---------------------------------------------------------------------------

/// Request to get a compressed account by hash.
class GetCompressedAccountRequest {
  /// Creates a [GetCompressedAccountRequest].
  const GetCompressedAccountRequest({required this.hash});

  /// Creates a [GetCompressedAccountRequest] from JSON.
  factory GetCompressedAccountRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetCompressedAccountRequest(hash: r.requireString('hash'));
  }

  /// The hash of the compressed account to fetch.
  final String hash;

  /// Converts this [GetCompressedAccountRequest] to JSON.
  Map<String, Object?> toJson() => {'hash': hash};
}

/// Request to get a compressed account proof by hash.
class GetCompressedAccountProofRequest {
  /// Creates a [GetCompressedAccountProofRequest].
  const GetCompressedAccountProofRequest({required this.hash});

  /// Creates a [GetCompressedAccountProofRequest] from JSON.
  factory GetCompressedAccountProofRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressedAccountProofRequest(hash: r.requireString('hash'));
  }

  /// The hash of the compressed account to fetch a proof for.
  final String hash;

  /// Converts this [GetCompressedAccountProofRequest] to JSON.
  Map<String, Object?> toJson() => {'hash': hash};
}

/// Request to get compressed accounts by owner.
class GetCompressedAccountsByOwnerRequest {
  /// Creates a [GetCompressedAccountsByOwnerRequest].
  const GetCompressedAccountsByOwnerRequest({
    required this.owner,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressedAccountsByOwnerRequest] from JSON.
  factory GetCompressedAccountsByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressedAccountsByOwnerRequest(
      owner: r.requireString('owner'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The owner address of the accounts to fetch.
  final String owner;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressedAccountsByOwnerRequest] to JSON.
  Map<String, Object?> toJson() => {
    'owner': owner,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get the compressed balance by hash.
class GetCompressedBalanceRequest {
  /// Creates a [GetCompressedBalanceRequest].
  const GetCompressedBalanceRequest({required this.hash});

  /// Creates a [GetCompressedBalanceRequest] from JSON.
  factory GetCompressedBalanceRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetCompressedBalanceRequest(hash: r.requireString('hash'));
  }

  /// The hash of the compressed account whose balance to fetch.
  final String hash;

  /// Converts this [GetCompressedBalanceRequest] to JSON.
  Map<String, Object?> toJson() => {'hash': hash};
}

/// Request to get the total compressed balance by owner.
class GetCompressedBalanceByOwnerRequest {
  /// Creates a [GetCompressedBalanceByOwnerRequest].
  const GetCompressedBalanceByOwnerRequest({required this.owner});

  /// Creates a [GetCompressedBalanceByOwnerRequest] from JSON.
  factory GetCompressedBalanceByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressedBalanceByOwnerRequest(
      owner: r.requireString('owner'),
    );
  }

  /// The owner address whose total compressed balance to fetch.
  final String owner;

  /// Converts this [GetCompressedBalanceByOwnerRequest] to JSON.
  Map<String, Object?> toJson() => {'owner': owner};
}

/// Request to get compressed mint token holders.
class GetCompressedMintTokenHoldersRequest {
  /// Creates a [GetCompressedMintTokenHoldersRequest].
  const GetCompressedMintTokenHoldersRequest({
    required this.mint,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressedMintTokenHoldersRequest] from JSON.
  factory GetCompressedMintTokenHoldersRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressedMintTokenHoldersRequest(
      mint: r.requireString('mint'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The mint address whose token holders to fetch.
  final String mint;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressedMintTokenHoldersRequest] to JSON.
  Map<String, Object?> toJson() => {
    'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get a compressed token account balance by hash.
class GetCompressedTokenAccountBalanceRequest {
  /// Creates a [GetCompressedTokenAccountBalanceRequest].
  const GetCompressedTokenAccountBalanceRequest({required this.hash});

  /// Creates a [GetCompressedTokenAccountBalanceRequest] from JSON.
  factory GetCompressedTokenAccountBalanceRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressedTokenAccountBalanceRequest(
      hash: r.requireString('hash'),
    );
  }

  /// The hash of the compressed token account whose balance to fetch.
  final String hash;

  /// Converts this [GetCompressedTokenAccountBalanceRequest] to JSON.
  Map<String, Object?> toJson() => {'hash': hash};
}

/// Request to get compressed token accounts by delegate.
class GetCompressedTokenAccountsByDelegateRequest {
  /// Creates a [GetCompressedTokenAccountsByDelegateRequest].
  const GetCompressedTokenAccountsByDelegateRequest({
    required this.delegate,
    this.mint,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressedTokenAccountsByDelegateRequest] from JSON.
  factory GetCompressedTokenAccountsByDelegateRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressedTokenAccountsByDelegateRequest(
      delegate: r.requireString('delegate'),
      mint: r.optString('mint'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The delegate address of the accounts to fetch.
  final String delegate;

  /// The mint address to filter accounts by, if any.
  final String? mint;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressedTokenAccountsByDelegateRequest] to JSON.
  Map<String, Object?> toJson() => {
    'delegate': delegate,
    if (mint != null) 'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compressed token accounts by owner.
class GetCompressedTokenAccountsByOwnerRequest {
  /// Creates a [GetCompressedTokenAccountsByOwnerRequest].
  const GetCompressedTokenAccountsByOwnerRequest({
    required this.owner,
    this.mint,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressedTokenAccountsByOwnerRequest] from JSON.
  factory GetCompressedTokenAccountsByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressedTokenAccountsByOwnerRequest(
      owner: r.requireString('owner'),
      mint: r.optString('mint'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The owner address of the accounts to fetch.
  final String owner;

  /// The mint address to filter accounts by, if any.
  final String? mint;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressedTokenAccountsByOwnerRequest] to JSON.
  Map<String, Object?> toJson() => {
    'owner': owner,
    if (mint != null) 'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compressed token balances by owner.
class GetCompressedTokenBalancesByOwnerRequest {
  /// Creates a [GetCompressedTokenBalancesByOwnerRequest].
  const GetCompressedTokenBalancesByOwnerRequest({
    required this.owner,
    this.mint,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressedTokenBalancesByOwnerRequest] from JSON.
  factory GetCompressedTokenBalancesByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressedTokenBalancesByOwnerRequest(
      owner: r.requireString('owner'),
      mint: r.optString('mint'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The owner address whose token balances to fetch.
  final String owner;

  /// The mint address to filter balances by, if any.
  final String? mint;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressedTokenBalancesByOwnerRequest] to JSON.
  Map<String, Object?> toJson() => {
    'owner': owner,
    if (mint != null) 'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compression signatures for an account.
class GetCompressionSignaturesForAccountRequest {
  /// Creates a [GetCompressionSignaturesForAccountRequest].
  const GetCompressionSignaturesForAccountRequest({
    required this.hash,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressionSignaturesForAccountRequest] from JSON.
  factory GetCompressionSignaturesForAccountRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressionSignaturesForAccountRequest(
      hash: r.requireString('hash'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The hash of the account whose signatures to fetch.
  final String hash;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressionSignaturesForAccountRequest] to JSON.
  Map<String, Object?> toJson() => {
    'hash': hash,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compression signatures for an address.
class GetCompressionSignaturesForAddressRequest {
  /// Creates a [GetCompressionSignaturesForAddressRequest].
  const GetCompressionSignaturesForAddressRequest({
    required this.address,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressionSignaturesForAddressRequest] from JSON.
  factory GetCompressionSignaturesForAddressRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressionSignaturesForAddressRequest(
      address: r.requireString('address'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The address whose compression signatures to fetch.
  final String address;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressionSignaturesForAddressRequest] to JSON.
  Map<String, Object?> toJson() => {
    'address': address,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compression signatures for an owner.
class GetCompressionSignaturesForOwnerRequest {
  /// Creates a [GetCompressionSignaturesForOwnerRequest].
  const GetCompressionSignaturesForOwnerRequest({
    required this.owner,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressionSignaturesForOwnerRequest] from JSON.
  factory GetCompressionSignaturesForOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressionSignaturesForOwnerRequest(
      owner: r.requireString('owner'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The owner address whose compression signatures to fetch.
  final String owner;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressionSignaturesForOwnerRequest] to JSON.
  Map<String, Object?> toJson() => {
    'owner': owner,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compression signatures for a token owner.
class GetCompressionSignaturesForTokenOwnerRequest {
  /// Creates a [GetCompressionSignaturesForTokenOwnerRequest].
  const GetCompressionSignaturesForTokenOwnerRequest({
    required this.owner,
    this.mint,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetCompressionSignaturesForTokenOwnerRequest] from JSON.
  factory GetCompressionSignaturesForTokenOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetCompressionSignaturesForTokenOwnerRequest(
      owner: r.requireString('owner'),
      mint: r.optString('mint'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The token owner address whose signatures to fetch.
  final String owner;

  /// The mint address to filter signatures by, if any.
  final String? mint;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetCompressionSignaturesForTokenOwnerRequest] to JSON.
  Map<String, Object?> toJson() => {
    'owner': owner,
    if (mint != null) 'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get the latest compression signatures.
class GetLatestCompressionSignaturesRequest {
  /// Creates a [GetLatestCompressionSignaturesRequest].
  const GetLatestCompressionSignaturesRequest({this.cursor, this.limit});

  /// Creates a [GetLatestCompressionSignaturesRequest] from JSON.
  factory GetLatestCompressionSignaturesRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetLatestCompressionSignaturesRequest(
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetLatestCompressionSignaturesRequest] to JSON.
  Map<String, Object?> toJson() => {
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get the latest non-voting signatures.
class GetLatestNonVotingSignaturesRequest {
  /// Creates a [GetLatestNonVotingSignaturesRequest].
  const GetLatestNonVotingSignaturesRequest({this.cursor, this.limit});

  /// Creates a [GetLatestNonVotingSignaturesRequest] from JSON.
  factory GetLatestNonVotingSignaturesRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetLatestNonVotingSignaturesRequest(
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetLatestNonVotingSignaturesRequest] to JSON.
  Map<String, Object?> toJson() => {
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get proofs for multiple compressed accounts.
class GetMultipleCompressedAccountProofsRequest {
  /// Creates a [GetMultipleCompressedAccountProofsRequest].
  const GetMultipleCompressedAccountProofsRequest({required this.hashes});

  /// Creates a [GetMultipleCompressedAccountProofsRequest] from JSON.
  factory GetMultipleCompressedAccountProofsRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetMultipleCompressedAccountProofsRequest(
      hashes: r.requireList<String>('hashes'),
    );
  }

  /// The hashes of the compressed accounts to fetch proofs for.
  final List<String> hashes;

  /// Converts this [GetMultipleCompressedAccountProofsRequest] to JSON.
  Map<String, Object?> toJson() => {'hashes': hashes};
}

/// Request to get multiple compressed accounts by hashes.
class GetMultipleCompressedAccountsRequest {
  /// Creates a [GetMultipleCompressedAccountsRequest].
  const GetMultipleCompressedAccountsRequest({required this.hashes});

  /// Creates a [GetMultipleCompressedAccountsRequest] from JSON.
  factory GetMultipleCompressedAccountsRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetMultipleCompressedAccountsRequest(
      hashes: r.requireList<String>('hashes'),
    );
  }

  /// The hashes of the compressed accounts to fetch.
  final List<String> hashes;

  /// Converts this [GetMultipleCompressedAccountsRequest] to JSON.
  Map<String, Object?> toJson() => {'hashes': hashes};
}

/// Request to get proofs for multiple new addresses.
class GetMultipleNewAddressProofsRequest {
  /// Creates a [GetMultipleNewAddressProofsRequest].
  const GetMultipleNewAddressProofsRequest({required this.addresses});

  /// Creates a [GetMultipleNewAddressProofsRequest] from JSON.
  factory GetMultipleNewAddressProofsRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetMultipleNewAddressProofsRequest(
      addresses: r.requireList<String>('addresses'),
    );
  }

  /// The new compressed addresses to fetch proofs for.
  final List<String> addresses;

  /// Converts this [GetMultipleNewAddressProofsRequest] to JSON.
  Map<String, Object?> toJson() => {'addresses': addresses};
}

/// Request to get a transaction with compression info.
class GetTransactionWithCompressionInfoRequest {
  /// Creates a [GetTransactionWithCompressionInfoRequest].
  const GetTransactionWithCompressionInfoRequest({required this.signature});

  /// Creates a [GetTransactionWithCompressionInfoRequest] from JSON.
  factory GetTransactionWithCompressionInfoRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetTransactionWithCompressionInfoRequest(
      signature: r.requireString('signature'),
    );
  }

  /// The transaction signature to look up.
  final String signature;

  /// Converts this [GetTransactionWithCompressionInfoRequest] to JSON.
  Map<String, Object?> toJson() => {'signature': signature};
}

/// Request to get a validity proof for compressed operations.
class GetValidityProofRequest {
  /// Creates a [GetValidityProofRequest].
  const GetValidityProofRequest({required this.hashes, this.newAddresses});

  /// Creates a [GetValidityProofRequest] from JSON.
  factory GetValidityProofRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetValidityProofRequest(
      hashes: r.requireList<String>('hashes'),
      newAddresses: r.optList<String>('newAddresses'),
    );
  }

  /// The hashes of the compressed accounts to prove.
  final List<String> hashes;

  /// The new compressed addresses to prove, if any.
  final List<String>? newAddresses;

  /// Converts this [GetValidityProofRequest] to JSON.
  Map<String, Object?> toJson() => {
    'hashes': hashes,
    if (newAddresses != null) 'newAddresses': newAddresses,
  };
}

/// Request to get ZK signatures for an asset.
class GetZkSignaturesForAssetRequest {
  /// Creates a [GetZkSignaturesForAssetRequest].
  const GetZkSignaturesForAssetRequest({
    required this.id,
    this.cursor,
    this.limit,
  });

  /// Creates a [GetZkSignaturesForAssetRequest] from JSON.
  factory GetZkSignaturesForAssetRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetZkSignaturesForAssetRequest(
      id: r.requireString('id'),
      cursor: r.optString('cursor'),
      limit: r.optInt('limit'),
    );
  }

  /// The asset id whose ZK signatures to fetch.
  final String id;

  /// The pagination cursor, if continuing a previous request.
  final String? cursor;

  /// The maximum number of items to return.
  final int? limit;

  /// Converts this [GetZkSignaturesForAssetRequest] to JSON.
  Map<String, Object?> toJson() => {
    'id': id,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

// ---------------------------------------------------------------------------
// Paginated list wrappers
// ---------------------------------------------------------------------------

/// A paginated list of compressed accounts.
class CompressedAccountList {
  /// Creates a [CompressedAccountList].
  const CompressedAccountList({required this.items, this.cursor});

  /// Creates a [CompressedAccountList] from JSON.
  factory CompressedAccountList.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedAccountList(
      items: r.requireDecodedList('items', CompressedAccount.fromJson),
      cursor: r.optString('cursor'),
    );
  }

  /// The compressed accounts in this page.
  final List<CompressedAccount> items;

  /// The pagination cursor for the next page, if any.
  final String? cursor;

  /// Converts this [CompressedAccountList] to JSON.
  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A paginated list of compressed token accounts.
class CompressedTokenAccountList {
  /// Creates a [CompressedTokenAccountList].
  const CompressedTokenAccountList({required this.items, this.cursor});

  /// Creates a [CompressedTokenAccountList] from JSON.
  factory CompressedTokenAccountList.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedTokenAccountList(
      items: r.requireDecodedList('items', CompressedTokenAccount.fromJson),
      cursor: r.optString('cursor'),
    );
  }

  /// The compressed token accounts in this page.
  final List<CompressedTokenAccount> items;

  /// The pagination cursor for the next page, if any.
  final String? cursor;

  /// Converts this [CompressedTokenAccountList] to JSON.
  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A paginated list of compressed signatures.
class CompressedSignatureList {
  /// Creates a [CompressedSignatureList].
  const CompressedSignatureList({required this.items, this.cursor});

  /// Creates a [CompressedSignatureList] from JSON.
  factory CompressedSignatureList.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedSignatureList(
      items: r.requireDecodedList('items', CompressedSignature.fromJson),
      cursor: r.optString('cursor'),
    );
  }

  /// The compressed signatures in this page.
  final List<CompressedSignature> items;

  /// The pagination cursor for the next page, if any.
  final String? cursor;

  /// Converts this [CompressedSignatureList] to JSON.
  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A paginated list of compressed token balances.
class CompressedTokenBalanceList {
  /// Creates a [CompressedTokenBalanceList].
  const CompressedTokenBalanceList({required this.items, this.cursor});

  /// Creates a [CompressedTokenBalanceList] from JSON.
  factory CompressedTokenBalanceList.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedTokenBalanceList(
      items: r.requireDecodedList('items', CompressedTokenBalance.fromJson),
      cursor: r.optString('cursor'),
    );
  }

  /// The compressed token balances in this page.
  final List<CompressedTokenBalance> items;

  /// The pagination cursor for the next page, if any.
  final String? cursor;

  /// Converts this [CompressedTokenBalanceList] to JSON.
  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A paginated list of compressed token balances (V2 with decimals).
class CompressedTokenBalanceV2List {
  /// Creates a [CompressedTokenBalanceV2List].
  const CompressedTokenBalanceV2List({required this.items, this.cursor});

  /// Creates a [CompressedTokenBalanceV2List] from JSON.
  factory CompressedTokenBalanceV2List.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CompressedTokenBalanceV2List(
      items: r.requireDecodedList('items', CompressedTokenBalanceV2.fromJson),
      cursor: r.optString('cursor'),
    );
  }

  /// The compressed token balances (V2) in this page.
  final List<CompressedTokenBalanceV2> items;

  /// The pagination cursor for the next page, if any.
  final String? cursor;

  /// Converts this [CompressedTokenBalanceV2List] to JSON.
  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}
