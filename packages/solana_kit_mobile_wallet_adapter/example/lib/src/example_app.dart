import 'package:flutter/material.dart';
import 'package:solana_kit_mobile_wallet_adapter_example/src/example_controller.dart';

class SolanaKitMwaExampleApp extends StatefulWidget {
  const SolanaKitMwaExampleApp({super.key, this.controller});

  final MwaExampleController? controller;

  @override
  State<SolanaKitMwaExampleApp> createState() => _SolanaKitMwaExampleAppState();
}

class _SolanaKitMwaExampleAppState extends State<SolanaKitMwaExampleApp> {
  late final bool _ownsController = widget.controller == null;
  late final MwaExampleController _controller =
      widget.controller ?? MwaExampleController.live();
  late final TextEditingController _messageController = TextEditingController(
    text: _controller.messageDraft,
  );
  late final TextEditingController _transactionController =
      TextEditingController(text: _controller.transactionDraft);

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      _controller.setMessageDraft(_messageController.text);
    });
    _transactionController.addListener(() {
      _controller.setTransactionDraft(_transactionController.text);
    });
    _controller.initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _transactionController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _runWithFeedback(
    Future<void> Function() action, {
    required String failureMessage,
  }) async {
    try {
      await action();
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return MaterialApp(
          title: 'Solana Kit MWA Example',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7A5CFA),
            ),
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('Solana Kit MWA Example')),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _SectionCard(
                    title: 'Android-first Flutter example app',
                    child: Text(
                      'This example keeps platform support gating, wallet '
                      'session state, and transaction submission boundaries '
                      'explicit. Use it as a starting point for Android wallet '
                      'handoff flows and keep a clear fallback UX for iOS.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Platform support gate',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _StatusLine(
                          label: 'MWA supported',
                          value: _controller.isSupported ? 'Yes' : 'No',
                        ),
                        _StatusLine(
                          label: 'Wallet endpoint',
                          value: _walletEndpointLabel(),
                        ),
                        _StatusLine(
                          label: 'Authorized account',
                          value: _controller.activeAccountLabel,
                        ),
                        _StatusLine(
                          label: 'Busy',
                          value: _controller.isBusy ? 'Yes' : 'No',
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: _controller.isBusy
                              ? null
                              : () => _runWithFeedback(
                                  _controller.refreshWalletEndpointStatus,
                                  failureMessage:
                                      'Could not refresh wallet endpoint status.',
                                ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Wallet Status'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_controller.isSupported) ...<Widget>[
                    _UnsupportedPlatformCard(
                      endpointAvailable: _controller.walletEndpointAvailable,
                    ),
                  ] else ...<Widget>[
                    _SectionCard(
                      title: 'Wallet session boundary',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Keep authorization, capabilities loading, and '
                            'deauthorization inside a dedicated controller or '
                            'service instead of scattering them across widgets.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: _controller.isBusy
                                    ? null
                                    : () => _runWithFeedback(
                                        _controller.authorize,
                                        failureMessage:
                                            'Authorize failed. Check the operation log.',
                                      ),
                                child: const Text('Authorize'),
                              ),
                              ElevatedButton(
                                onPressed: _controller.isBusy ||
                                        !_controller.hasAuthorization
                                    ? null
                                    : () => _runWithFeedback(
                                        _controller.loadCapabilities,
                                        failureMessage:
                                            'Get capabilities failed. Check the operation log.',
                                      ),
                                child: const Text('Get Capabilities'),
                              ),
                              OutlinedButton(
                                onPressed: _controller.isBusy ||
                                        !_controller.hasAuthorization
                                    ? null
                                    : () => _runWithFeedback(
                                        _controller.deauthorize,
                                        failureMessage:
                                            'Deauthorize failed. Check the operation log.',
                                      ),
                                child: const Text('Deauthorize'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _StatusLine(
                            label: 'Wallet features',
                            value:
                                _controller.capabilities?.features?.join(', ') ??
                                'Not loaded',
                          ),
                          _StatusLine(
                            label: 'Max messages/request',
                            value: _controller.capabilities?.maxMessagesPerRequest
                                    ?.toString() ??
                                'Not loaded',
                          ),
                          _StatusLine(
                            label: 'Max tx/request',
                            value: _controller
                                    .capabilities
                                    ?.maxTransactionsPerRequest
                                    ?.toString() ??
                                'Not loaded',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Message signing demo',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'A signed message flow is a good first Android '
                            'integration check before you wire full '
                            'transaction submission.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _messageController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Message to sign',
                              hintText: 'Enter any text payload',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _controller.isBusy ||
                                    !_controller.hasAuthorization
                                ? null
                                : () => _runWithFeedback(
                                    _controller.signMessage,
                                    failureMessage:
                                        'Sign message failed. Check the operation log.',
                                  ),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Sign Message'),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _controller.lastSignedPayload ??
                                'No payload signed yet.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Transaction submission boundary',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Keep transaction construction and RPC submission '
                            'outside the widget tree. In a production app, '
                            'prepare or fetch the base64 payload in a separate '
                            'service and hand it to the wallet boundary here.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _transactionController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Base64 transaction payload',
                              hintText:
                                  'Paste a serialized transaction from your app service',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _controller.isBusy ||
                                    !_controller.hasAuthorization
                                ? null
                                : () => _runWithFeedback(
                                    _controller.signAndSendTransaction,
                                    failureMessage:
                                        'Sign & send failed. Check the operation log.',
                                  ),
                            icon: const Icon(Icons.send),
                            label: const Text('Sign & Send Transaction'),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _controller.lastSubmittedSignatures.isEmpty
                                ? 'No transaction signatures yet.'
                                : _controller.lastSubmittedSignatures.join('\n'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Operation log',
                    child: SelectableText(
                      _controller.logs.isEmpty
                          ? 'No operations yet.'
                          : _controller.logs.join('\n'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _walletEndpointLabel() {
    final endpointAvailable = _controller.walletEndpointAvailable;
    if (endpointAvailable == null) {
      return 'Checking...';
    }

    return endpointAvailable ? 'Available' : 'Not found';
  }
}

class _UnsupportedPlatformCard extends StatelessWidget {
  const _UnsupportedPlatformCard({required this.endpointAvailable});

  final bool? endpointAvailable;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Mobile Wallet Adapter is unavailable on this platform',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'This example is Android-first because the current Solana Mobile '
            'Wallet Adapter ecosystem does not expose an equivalent iOS '
            'wallet-handoff target.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          const Text('Recommended iOS fallback UX:'),
          const SizedBox(height: 8),
          const Text('• Explain that wallet handoff is unavailable on iOS today.'),
          const Text('• Offer a browser-wallet or desktop-wallet alternative.'),
          const Text('• Keep the rest of the Flutter app functional.'),
          const SizedBox(height: 12),
          Text(
            'Wallet endpoint: ${(endpointAvailable ?? false) ? 'Available' : 'Not available'}',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 170, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
