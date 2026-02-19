/// A compressed account in ZK compression.
class CompressedAccount {
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

  factory CompressedAccount.fromJson(Map<String, Object?> json) {
    return CompressedAccount(
      hash: json['hash']! as String,
      address: json['address']! as String,
      data: json['data']! as Map<String, Object?>,
      owner: json['owner']! as String,
      lamports: json['lamports']! as int,
      leafIndex: json['leafIndex'] as int?,
      tree: json['tree'] as String?,
      seq: json['seq'] as int?,
    );
  }

  final String hash;
  final String address;
  final Map<String, Object?> data;
  final String owner;
  final int lamports;
  final int? leafIndex;
  final String? tree;
  final int? seq;

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
  const CompressedAccountProof({
    required this.hash,
    required this.root,
    required this.proof,
    required this.leafIndex,
    this.tree,
  });

  factory CompressedAccountProof.fromJson(Map<String, Object?> json) {
    return CompressedAccountProof(
      hash: json['hash']! as String,
      root: json['root']! as String,
      proof: (json['proof']! as List<Object?>).cast<String>(),
      leafIndex: json['leafIndex']! as int,
      tree: json['tree'] as String?,
    );
  }

  final String hash;
  final String root;
  final List<String> proof;
  final int leafIndex;
  final String? tree;

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

  factory CompressedTokenAccount.fromJson(Map<String, Object?> json) {
    return CompressedTokenAccount(
      hash: json['hash']! as String,
      owner: json['owner']! as String,
      mint: json['mint']! as String,
      amount: json['amount']! as int,
      delegate: json['delegate'] as String?,
      frozen: json['frozen']! as bool,
      leafIndex: json['leafIndex'] as int?,
      tree: json['tree'] as String?,
    );
  }

  final String hash;
  final String owner;
  final String mint;
  final int amount;
  final String? delegate;
  final bool frozen;
  final int? leafIndex;
  final String? tree;

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
  const CompressedBalance({required this.amount});

  factory CompressedBalance.fromJson(Map<String, Object?> json) {
    return CompressedBalance(amount: json['amount']! as int);
  }

  final int amount;

  Map<String, Object?> toJson() => {'amount': amount};
}

/// A compressed token balance.
class CompressedTokenBalance {
  const CompressedTokenBalance({required this.mint, required this.amount});

  factory CompressedTokenBalance.fromJson(Map<String, Object?> json) {
    return CompressedTokenBalance(
      mint: json['mint']! as String,
      amount: json['amount']! as int,
    );
  }

  final String mint;
  final int amount;

  Map<String, Object?> toJson() => {'mint': mint, 'amount': amount};
}

/// A compressed token balance with decimals (V2).
class CompressedTokenBalanceV2 {
  const CompressedTokenBalanceV2({
    required this.mint,
    required this.amount,
    required this.decimals,
  });

  factory CompressedTokenBalanceV2.fromJson(Map<String, Object?> json) {
    return CompressedTokenBalanceV2(
      mint: json['mint']! as String,
      amount: json['amount']! as int,
      decimals: json['decimals']! as int,
    );
  }

  final String mint;
  final int amount;
  final int decimals;

  Map<String, Object?> toJson() => {
    'mint': mint,
    'amount': amount,
    'decimals': decimals,
  };
}

/// A compressed transaction signature.
class CompressedSignature {
  const CompressedSignature({
    required this.signature,
    required this.slot,
    this.blockTime,
  });

  factory CompressedSignature.fromJson(Map<String, Object?> json) {
    return CompressedSignature(
      signature: json['signature']! as String,
      slot: json['slot']! as int,
      blockTime: json['blockTime'] as int?,
    );
  }

  final String signature;
  final int slot;
  final int? blockTime;

  Map<String, Object?> toJson() => {
    'signature': signature,
    'slot': slot,
    if (blockTime != null) 'blockTime': blockTime,
  };
}

/// Health status of the ZK compression indexer.
class IndexerHealth {
  const IndexerHealth({required this.status});

  factory IndexerHealth.fromJson(Map<String, Object?> json) {
    return IndexerHealth(status: json['status']! as String);
  }

  final String status;

  Map<String, Object?> toJson() => {'status': status};
}

/// A validity proof for ZK compression operations.
class ValidityProof {
  const ValidityProof({
    required this.compressedProof,
    this.rootIndices,
    this.leafIndices,
  });

  factory ValidityProof.fromJson(Map<String, Object?> json) {
    return ValidityProof(
      compressedProof: (json['compressedProof']! as List<Object?>)
          .cast<String>(),
      rootIndices: (json['rootIndices'] as List<Object?>?)?.cast<String>(),
      leafIndices: json['leafIndices'] as String?,
    );
  }

  final List<String> compressedProof;
  final List<String>? rootIndices;
  final String? leafIndices;

  Map<String, Object?> toJson() => {
    'compressedProof': compressedProof,
    if (rootIndices != null) 'rootIndices': rootIndices,
    if (leafIndices != null) 'leafIndices': leafIndices,
  };
}

/// A proof for a new compressed address.
class NewAddressProof {
  const NewAddressProof({
    required this.address,
    required this.root,
    required this.proof,
    required this.leafIndex,
    required this.tree,
  });

  factory NewAddressProof.fromJson(Map<String, Object?> json) {
    return NewAddressProof(
      address: json['address']! as String,
      root: json['root']! as String,
      proof: (json['proof']! as List<Object?>).cast<String>(),
      leafIndex: json['leafIndex']! as int,
      tree: json['tree']! as String,
    );
  }

  final String address;
  final String root;
  final List<String> proof;
  final int leafIndex;
  final String tree;

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
  const TransactionWithCompressionInfo({
    this.transaction,
    this.compressionInfo,
  });

  factory TransactionWithCompressionInfo.fromJson(Map<String, Object?> json) {
    return TransactionWithCompressionInfo(
      transaction: json['transaction'],
      compressionInfo: json['compressionInfo'] as Map<String, Object?>?,
    );
  }

  final Object? transaction;
  final Map<String, Object?>? compressionInfo;

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
  const GetCompressedAccountRequest({required this.hash});

  factory GetCompressedAccountRequest.fromJson(Map<String, Object?> json) {
    return GetCompressedAccountRequest(hash: json['hash']! as String);
  }

  final String hash;

  Map<String, Object?> toJson() => {'hash': hash};
}

/// Request to get a compressed account proof by hash.
class GetCompressedAccountProofRequest {
  const GetCompressedAccountProofRequest({required this.hash});

  factory GetCompressedAccountProofRequest.fromJson(Map<String, Object?> json) {
    return GetCompressedAccountProofRequest(hash: json['hash']! as String);
  }

  final String hash;

  Map<String, Object?> toJson() => {'hash': hash};
}

/// Request to get compressed accounts by owner.
class GetCompressedAccountsByOwnerRequest {
  const GetCompressedAccountsByOwnerRequest({
    required this.owner,
    this.cursor,
    this.limit,
  });

  factory GetCompressedAccountsByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressedAccountsByOwnerRequest(
      owner: json['owner']! as String,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String owner;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'owner': owner,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get the compressed balance by hash.
class GetCompressedBalanceRequest {
  const GetCompressedBalanceRequest({required this.hash});

  factory GetCompressedBalanceRequest.fromJson(Map<String, Object?> json) {
    return GetCompressedBalanceRequest(hash: json['hash']! as String);
  }

  final String hash;

  Map<String, Object?> toJson() => {'hash': hash};
}

/// Request to get the total compressed balance by owner.
class GetCompressedBalanceByOwnerRequest {
  const GetCompressedBalanceByOwnerRequest({required this.owner});

  factory GetCompressedBalanceByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressedBalanceByOwnerRequest(owner: json['owner']! as String);
  }

  final String owner;

  Map<String, Object?> toJson() => {'owner': owner};
}

/// Request to get compressed mint token holders.
class GetCompressedMintTokenHoldersRequest {
  const GetCompressedMintTokenHoldersRequest({
    required this.mint,
    this.cursor,
    this.limit,
  });

  factory GetCompressedMintTokenHoldersRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressedMintTokenHoldersRequest(
      mint: json['mint']! as String,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String mint;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get a compressed token account balance by hash.
class GetCompressedTokenAccountBalanceRequest {
  const GetCompressedTokenAccountBalanceRequest({required this.hash});

  factory GetCompressedTokenAccountBalanceRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressedTokenAccountBalanceRequest(
      hash: json['hash']! as String,
    );
  }

  final String hash;

  Map<String, Object?> toJson() => {'hash': hash};
}

/// Request to get compressed token accounts by delegate.
class GetCompressedTokenAccountsByDelegateRequest {
  const GetCompressedTokenAccountsByDelegateRequest({
    required this.delegate,
    this.mint,
    this.cursor,
    this.limit,
  });

  factory GetCompressedTokenAccountsByDelegateRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressedTokenAccountsByDelegateRequest(
      delegate: json['delegate']! as String,
      mint: json['mint'] as String?,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String delegate;
  final String? mint;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'delegate': delegate,
    if (mint != null) 'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compressed token accounts by owner.
class GetCompressedTokenAccountsByOwnerRequest {
  const GetCompressedTokenAccountsByOwnerRequest({
    required this.owner,
    this.mint,
    this.cursor,
    this.limit,
  });

  factory GetCompressedTokenAccountsByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressedTokenAccountsByOwnerRequest(
      owner: json['owner']! as String,
      mint: json['mint'] as String?,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String owner;
  final String? mint;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'owner': owner,
    if (mint != null) 'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compressed token balances by owner.
class GetCompressedTokenBalancesByOwnerRequest {
  const GetCompressedTokenBalancesByOwnerRequest({
    required this.owner,
    this.mint,
    this.cursor,
    this.limit,
  });

  factory GetCompressedTokenBalancesByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressedTokenBalancesByOwnerRequest(
      owner: json['owner']! as String,
      mint: json['mint'] as String?,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String owner;
  final String? mint;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'owner': owner,
    if (mint != null) 'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compression signatures for an account.
class GetCompressionSignaturesForAccountRequest {
  const GetCompressionSignaturesForAccountRequest({
    required this.hash,
    this.cursor,
    this.limit,
  });

  factory GetCompressionSignaturesForAccountRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressionSignaturesForAccountRequest(
      hash: json['hash']! as String,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String hash;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'hash': hash,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compression signatures for an address.
class GetCompressionSignaturesForAddressRequest {
  const GetCompressionSignaturesForAddressRequest({
    required this.address,
    this.cursor,
    this.limit,
  });

  factory GetCompressionSignaturesForAddressRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressionSignaturesForAddressRequest(
      address: json['address']! as String,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String address;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'address': address,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compression signatures for an owner.
class GetCompressionSignaturesForOwnerRequest {
  const GetCompressionSignaturesForOwnerRequest({
    required this.owner,
    this.cursor,
    this.limit,
  });

  factory GetCompressionSignaturesForOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressionSignaturesForOwnerRequest(
      owner: json['owner']! as String,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String owner;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'owner': owner,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get compression signatures for a token owner.
class GetCompressionSignaturesForTokenOwnerRequest {
  const GetCompressionSignaturesForTokenOwnerRequest({
    required this.owner,
    this.mint,
    this.cursor,
    this.limit,
  });

  factory GetCompressionSignaturesForTokenOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetCompressionSignaturesForTokenOwnerRequest(
      owner: json['owner']! as String,
      mint: json['mint'] as String?,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String owner;
  final String? mint;
  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    'owner': owner,
    if (mint != null) 'mint': mint,
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get the latest compression signatures.
class GetLatestCompressionSignaturesRequest {
  const GetLatestCompressionSignaturesRequest({this.cursor, this.limit});

  factory GetLatestCompressionSignaturesRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetLatestCompressionSignaturesRequest(
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get the latest non-voting signatures.
class GetLatestNonVotingSignaturesRequest {
  const GetLatestNonVotingSignaturesRequest({this.cursor, this.limit});

  factory GetLatestNonVotingSignaturesRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetLatestNonVotingSignaturesRequest(
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String? cursor;
  final int? limit;

  Map<String, Object?> toJson() => {
    if (cursor != null) 'cursor': cursor,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get proofs for multiple compressed accounts.
class GetMultipleCompressedAccountProofsRequest {
  const GetMultipleCompressedAccountProofsRequest({required this.hashes});

  factory GetMultipleCompressedAccountProofsRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetMultipleCompressedAccountProofsRequest(
      hashes: (json['hashes']! as List<Object?>).cast<String>(),
    );
  }

  final List<String> hashes;

  Map<String, Object?> toJson() => {'hashes': hashes};
}

/// Request to get multiple compressed accounts by hashes.
class GetMultipleCompressedAccountsRequest {
  const GetMultipleCompressedAccountsRequest({required this.hashes});

  factory GetMultipleCompressedAccountsRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetMultipleCompressedAccountsRequest(
      hashes: (json['hashes']! as List<Object?>).cast<String>(),
    );
  }

  final List<String> hashes;

  Map<String, Object?> toJson() => {'hashes': hashes};
}

/// Request to get proofs for multiple new addresses.
class GetMultipleNewAddressProofsRequest {
  const GetMultipleNewAddressProofsRequest({required this.addresses});

  factory GetMultipleNewAddressProofsRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetMultipleNewAddressProofsRequest(
      addresses: (json['addresses']! as List<Object?>).cast<String>(),
    );
  }

  final List<String> addresses;

  Map<String, Object?> toJson() => {'addresses': addresses};
}

/// Request to get a transaction with compression info.
class GetTransactionWithCompressionInfoRequest {
  const GetTransactionWithCompressionInfoRequest({required this.signature});

  factory GetTransactionWithCompressionInfoRequest.fromJson(
    Map<String, Object?> json,
  ) {
    return GetTransactionWithCompressionInfoRequest(
      signature: json['signature']! as String,
    );
  }

  final String signature;

  Map<String, Object?> toJson() => {'signature': signature};
}

/// Request to get a validity proof for compressed operations.
class GetValidityProofRequest {
  const GetValidityProofRequest({required this.hashes, this.newAddresses});

  factory GetValidityProofRequest.fromJson(Map<String, Object?> json) {
    return GetValidityProofRequest(
      hashes: (json['hashes']! as List<Object?>).cast<String>(),
      newAddresses: (json['newAddresses'] as List<Object?>?)?.cast<String>(),
    );
  }

  final List<String> hashes;
  final List<String>? newAddresses;

  Map<String, Object?> toJson() => {
    'hashes': hashes,
    if (newAddresses != null) 'newAddresses': newAddresses,
  };
}

/// Request to get ZK signatures for an asset.
class GetZkSignaturesForAssetRequest {
  const GetZkSignaturesForAssetRequest({
    required this.id,
    this.cursor,
    this.limit,
  });

  factory GetZkSignaturesForAssetRequest.fromJson(Map<String, Object?> json) {
    return GetZkSignaturesForAssetRequest(
      id: json['id']! as String,
      cursor: json['cursor'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String id;
  final String? cursor;
  final int? limit;

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
  const CompressedAccountList({required this.items, this.cursor});

  factory CompressedAccountList.fromJson(Map<String, Object?> json) {
    return CompressedAccountList(
      items: (json['items']! as List<Object?>)
          .map((e) => CompressedAccount.fromJson(e! as Map<String, Object?>))
          .toList(),
      cursor: json['cursor'] as String?,
    );
  }

  final List<CompressedAccount> items;
  final String? cursor;

  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A paginated list of compressed token accounts.
class CompressedTokenAccountList {
  const CompressedTokenAccountList({required this.items, this.cursor});

  factory CompressedTokenAccountList.fromJson(Map<String, Object?> json) {
    return CompressedTokenAccountList(
      items: (json['items']! as List<Object?>)
          .map(
            (e) => CompressedTokenAccount.fromJson(e! as Map<String, Object?>),
          )
          .toList(),
      cursor: json['cursor'] as String?,
    );
  }

  final List<CompressedTokenAccount> items;
  final String? cursor;

  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A paginated list of compressed signatures.
class CompressedSignatureList {
  const CompressedSignatureList({required this.items, this.cursor});

  factory CompressedSignatureList.fromJson(Map<String, Object?> json) {
    return CompressedSignatureList(
      items: (json['items']! as List<Object?>)
          .map((e) => CompressedSignature.fromJson(e! as Map<String, Object?>))
          .toList(),
      cursor: json['cursor'] as String?,
    );
  }

  final List<CompressedSignature> items;
  final String? cursor;

  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A paginated list of compressed token balances.
class CompressedTokenBalanceList {
  const CompressedTokenBalanceList({required this.items, this.cursor});

  factory CompressedTokenBalanceList.fromJson(Map<String, Object?> json) {
    return CompressedTokenBalanceList(
      items: (json['items']! as List<Object?>)
          .map(
            (e) => CompressedTokenBalance.fromJson(e! as Map<String, Object?>),
          )
          .toList(),
      cursor: json['cursor'] as String?,
    );
  }

  final List<CompressedTokenBalance> items;
  final String? cursor;

  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A paginated list of compressed token balances (V2 with decimals).
class CompressedTokenBalanceV2List {
  const CompressedTokenBalanceV2List({required this.items, this.cursor});

  factory CompressedTokenBalanceV2List.fromJson(Map<String, Object?> json) {
    return CompressedTokenBalanceV2List(
      items: (json['items']! as List<Object?>)
          .map(
            (e) =>
                CompressedTokenBalanceV2.fromJson(e! as Map<String, Object?>),
          )
          .toList(),
      cursor: json['cursor'] as String?,
    );
  }

  final List<CompressedTokenBalanceV2> items;
  final String? cursor;

  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}
