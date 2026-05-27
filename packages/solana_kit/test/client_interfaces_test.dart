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
}
