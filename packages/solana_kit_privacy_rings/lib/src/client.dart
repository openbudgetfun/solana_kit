import 'package:http/http.dart' as http;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_privacy_rings/src/balance.dart';
import 'package:solana_kit_privacy_rings/src/codec/transact.dart';
import 'package:solana_kit_privacy_rings/src/endpoints.dart';
import 'package:solana_kit_privacy_rings/src/history.dart';
import 'package:solana_kit_privacy_rings/src/keys/nullifier.dart';
import 'package:solana_kit_privacy_rings/src/keys/viewing_key.dart';
import 'package:solana_kit_privacy_rings/src/prover/client.dart';
import 'package:solana_kit_privacy_rings/src/rpc/client.dart';
import 'package:solana_kit_privacy_rings/src/rpc/types.dart';

/// Indexer and prover access for one Privacy Rings deployment.
///
/// Solana transaction submission stays on the repo's RPC client. This
/// type covers the two Privacy Rings services: the indexer that returns
/// encrypted notes, and the remote prover that returns a Groth16 proof.
/// `confidentialTransferWitness` builds the witness this client posts.
class PrivacyRings {
  /// Connects using the same URL rules as `createSprClient`.
  ///
  /// Pass a Helius RPC root as [solanaRpcUrl] and the indexer and prover
  /// inherit `https://<host>/v1/spr`, query included. Omit every URL to
  /// use the local stack (`:8899`, `:8784`, `:3001`).
  PrivacyRings({
    Uri? solanaRpcUrl,
    Uri? indexerUrl,
    Uri? proverUrl,
    String? apiKey,
    http.Client? httpClient,
    bool allowUnauthenticatedRemoteProver = false,
  }) : endpoints = resolvePrivacyRingsEndpoints(
         solanaRpcUrl: solanaRpcUrl,
         indexerUrl: indexerUrl,
         proverUrl: proverUrl,
       ),
       indexer = PrivacyIndexerClient(
         endpoint: resolvePrivacyRingsEndpoints(
           solanaRpcUrl: solanaRpcUrl,
           indexerUrl: indexerUrl,
           proverUrl: proverUrl,
         ).indexer,
         httpClient: httpClient,
         apiKey: apiKey,
       ),
       prover = PrivacyProverClient(
         endpoint: resolvePrivacyRingsEndpoints(
           solanaRpcUrl: solanaRpcUrl,
           indexerUrl: indexerUrl,
           proverUrl: proverUrl,
         ).prover,
         httpClient: httpClient,
         apiKey: apiKey,
         allowUnauthenticatedRemoteProver: allowUnauthenticatedRemoteProver,
       );

  /// The URLs this client calls.
  final PrivacyRingsEndpoints endpoints;

  /// Indexer JSON-RPC.
  final PrivacyIndexerClient indexer;

  /// Remote prover.
  final PrivacyProverClient prover;

  /// Closes the HTTP client when this object created it.
  ///
  /// The indexer and the prover share that decision: both close only a
  /// client they constructed. Pass one [http.Client] to both and close
  /// it yourself.
  void close() {
    indexer.close();
    prover.close();
  }

  /// Reads notes for [tags] and decrypts the confidential ones with
  /// [viewingKey].
  ///
  /// Confidential history comes from `getShieldedTransactionsByTags`.
  /// Proofless deposits come from `getEncryptedUtxosByTags`, and only
  /// the matches that have no transaction viewing key. Pages stop when
  /// the indexer returns a null token. If [maxPages] is reached while a
  /// token remains, this throws rather than returning a partial sum.
  ///
  /// A leaf in [spentLeaves] is omitted from the totals. The same leaf is
  /// counted once. When [nullifierKey] is set, a note whose Poseidon
  /// nullifier appears on a confidential transaction in this history is
  /// omitted too.
  Future<PrivateBalanceReport> readPrivateBalance({
    required ViewingKey viewingKey,
    required List<String> tags,
    Address? ringProgramId,
    Map<BigInt, Address> mints = const {},
    int pageLimit = 1000,
    int maxPages = 50,
    Set<SpentLeaf> spentLeaves = const {},
    NullifierKey? nullifierKey,
  }) async {
    final confidential = await _shieldedPages(
      tags: tags,
      ringProgramId: ringProgramId,
      pageLimit: pageLimit,
      maxPages: maxPages,
    );
    final deposits = await _depositPages(
      tags: tags,
      ringProgramId: ringProgramId,
      pageLimit: pageLimit,
      maxPages: maxPages,
    );
    final report = combineBalanceReports(
      await readConfidentialNotes(
        viewingKey: viewingKey,
        transactions: confidential,
        mints: mints,
        spent: spentLeaves,
      ),
      await readProoflessDeposits(deposits, spent: spentLeaves),
    );
    if (nullifierKey == null) return report;
    final spent = spentNullifiers(confidential)
        .map(
          (bytes) => bytes
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join(),
        )
        .toSet();
    final notes = <PrivateNote>[];
    for (final note in report.notes) {
      final derived = nullifierKey.nullifier(note.commitment!, note.blinding!);
      final hex = derived
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      if (!spent.contains(hex)) notes.add(note);
    }
    final kept = combineBalanceReports(
      PrivateBalanceReport(
        notes: notes,
        balances: const [],
        skipped: report.skipped,
      ),
      const PrivateBalanceReport(notes: [], balances: [], skipped: 0),
    );
    return kept;
  }

  /// Posts [witness] to the remote prover and returns a compressed proof
  /// ready for [TransactInstructionData.withProof].
  Future<TransactProof> prove({
    required String circuit,
    required Map<String, Object?> witness,
  }) {
    return prover.prove(circuit: circuit, witness: witness);
  }

  Future<List<ShieldedTransaction>> _shieldedPages({
    required List<String> tags,
    required Address? ringProgramId,
    required int pageLimit,
    required int maxPages,
  }) async {
    return collectPages((token) async {
      final response = await indexer.getShieldedTransactionsByTags(
        tags: tags,
        ringProgramId: ringProgramId,
        page: PageRequest(paginationToken: token, limit: pageLimit),
      );
      return HistoryPage(
        items: [
          for (final entry in response.data) ...entry.entries,
        ],
        paginationToken: response.paginationToken,
      );
    }, maxPages: maxPages);
  }

  Future<List<EncryptedUtxoMatch>> _depositPages({
    required List<String> tags,
    required Address? ringProgramId,
    required int pageLimit,
    required int maxPages,
  }) async {
    return collectPages((token) async {
      final response = await indexer.getEncryptedUtxosByTags(
        tags: tags,
        ringProgramId: ringProgramId,
        page: PageRequest(paginationToken: token, limit: pageLimit),
      );
      return HistoryPage(
        items: [
          for (final entry in response.data) ...entry.entries,
        ],
        paginationToken: response.paginationToken,
      );
    }, maxPages: maxPages);
  }
}
