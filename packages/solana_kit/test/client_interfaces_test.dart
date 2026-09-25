import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

SubscribeToFn createSubscribeTo(Set<void Function()> listeners) {
  return (listener) {
    listeners.add(listener);
    return () => listeners.remove(listener);
  };
}

final class SignerClient
    implements
        ClientWithIdentity<String>,
        ClientWithPayer<String>,
        ClientWithSubscribeToIdentity,
        ClientWithSubscribeToPayer {
  SignerClient({required this.identity, required this.payer});

  @override
  final String identity;

  @override
  final String payer;

  final _identityListeners = <void Function()>{};
  final _payerListeners = <void Function()>{};

  @override
  void Function() subscribeToIdentity(void Function() listener) {
    _identityListeners.add(listener);
    return () => _identityListeners.remove(listener);
  }

  @override
  void Function() subscribeToPayer(void Function() listener) {
    _payerListeners.add(listener);
    return () => _payerListeners.remove(listener);
  }

  void notifyIdentity() {
    for (final listener in List<void Function()>.of(_identityListeners)) {
      listener();
    }
  }

  void notifyPayer() {
    for (final listener in List<void Function()>.of(_payerListeners)) {
      listener();
    }
  }
}

void main() {
  test('client identity and payer interfaces describe signer capabilities', () {
    final client = SignerClient(identity: 'owner', payer: 'fee-payer');

    expect(client.identity, 'owner');
    expect(client.payer, 'fee-payer');
  });

  test('subscribe interfaces describe reactive capability hooks', () {
    final client = SignerClient(identity: 'owner', payer: 'fee-payer');
    var identityNotifications = 0;
    var payerNotifications = 0;

    final unsubscribeIdentity = client.subscribeToIdentity(
      () => identityNotifications++,
    );
    final unsubscribePayer = client.subscribeToPayer(
      () => payerNotifications++,
    );

    client
      ..notifyIdentity()
      ..notifyPayer();
    unsubscribeIdentity();
    unsubscribePayer();
    client
      ..notifyIdentity()
      ..notifyPayer();

    expect(identityNotifications, 1);
    expect(payerNotifications, 1);
  });

  test('SubscribeToFn matches unsubscribe-returning listener registration', () {
    final listeners = <void Function()>{};

    final subscribe = createSubscribeTo(listeners);
    var notifications = 0;
    final unsubscribe = subscribe(() => notifications++);
    for (final listener in List<void Function()>.of(listeners)) {
      listener();
    }
    unsubscribe();

    expect(notifications, 1);
    expect(listeners, isEmpty);
  });

  group('transaction sending and signing interfaces', () {
    test(
      'a client can provide both sending and signing capabilities',
      () async {
        final client = _FakeTransactionClient();

        final sent = await client.sendTransaction(
          const TransactionMessage(version: TransactionVersion.v0),
        );
        final signed = await client.signTransaction(
          const TransactionMessage(version: TransactionVersion.v0),
        );

        expect(sent.context['signature'], isNotNull);
        // The signing interface makes no guarantee about the context contents;
        // the fake implementation records the signed transaction instead.
        expect(signed.context['transaction'], isNotNull);
        expect(signed.context.containsKey('signature'), isFalse);
      },
    );

    test(
      'sending accepts instruction, plan, message, and list inputs',
      () async {
        final client = _FakeTransactionClient();
        const instruction = Instruction(
          programAddress: Address('11111111111111111111111111111111'),
        );

        await client.sendTransaction(instruction);
        await client.sendTransaction(
          const SingleTransactionPlan(
            message: TransactionMessage(version: TransactionVersion.v0),
          ),
        );
        await client.sendTransaction([instruction, instruction]);
        final results = await client.sendTransactions([instruction]);

        expect(results, isA<SequentialTransactionPlanResult>());
        expect(client.receivedInputs, hasLength(5));
      },
    );

    test('forward the abort signal to the underlying capability', () async {
      final client = _FakeTransactionClient();
      final source = CancellationTokenSource();

      await client.sendTransaction(
        const TransactionMessage(version: TransactionVersion.v0),
        abortSignal: source.token,
      );

      expect(client.lastAbortSignal, same(source.token));
    });
  });
}

/// Minimal client recording the inputs and abort signals it receives.
final class _FakeTransactionClient
    implements ClientWithTransactionSending, ClientWithTransactionSigning {
  final receivedInputs = <Object>[];
  CancellationToken? lastAbortSignal;

  SuccessfulSingleTransactionPlanResult _successfulResult(
    Map<String, Object?> context,
  ) => SuccessfulSingleTransactionPlanResult(
    plannedMessage: const TransactionMessage(version: TransactionVersion.v0),
    context: context,
  );

  @override
  Future<SuccessfulSingleTransactionPlanResult> sendTransaction(
    Object input, {
    CancellationToken? abortSignal,
  }) async {
    receivedInputs.add(input);
    lastAbortSignal = abortSignal;
    return _successfulResult({
      'signature': Signature('3' * 87),
    });
  }

  @override
  Future<TransactionPlanResult> sendTransactions(
    Object input, {
    CancellationToken? abortSignal,
  }) async {
    receivedInputs.add(input);
    lastAbortSignal = abortSignal;
    return sequentialTransactionPlanResult([
      await sendTransaction(input, abortSignal: abortSignal),
    ]);
  }

  @override
  Future<SuccessfulSingleTransactionPlanResult> signTransaction(
    Object input, {
    CancellationToken? abortSignal,
  }) async {
    receivedInputs.add(input);
    lastAbortSignal = abortSignal;
    return _successfulResult({
      'transaction': Object(),
    });
  }

  @override
  Future<TransactionPlanResult> signTransactions(
    Object input, {
    CancellationToken? abortSignal,
  }) async {
    receivedInputs.add(input);
    lastAbortSignal = abortSignal;
    return sequentialTransactionPlanResult([
      await signTransaction(input, abortSignal: abortSignal),
    ]);
  }
}
