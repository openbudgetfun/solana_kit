import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ManualMwaExampleApp());
}

class ManualMwaExampleApp extends StatelessWidget {
  const ManualMwaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solana Kit MWA Manual Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF161627)),
        useMaterial3: true,
      ),
      home: const ManualMwaHomePage(),
    );
  }
}

class ManualMwaHomePage extends StatefulWidget {
  const ManualMwaHomePage({super.key});

  @override
  State<ManualMwaHomePage> createState() => _ManualMwaHomePageState();
}

class _ManualMwaHomePageState extends State<ManualMwaHomePage> {
  final MwaClientHostApi _hostApi = MwaClientHostApi();
  final TextEditingController _messageController = TextEditingController(
    text: 'Hello from solana_kit_mobile_wallet_adapter example',
  );

  final List<String> _logs = <String>[];

  final bool _isMwaSupported = isMwaSupported();

  bool _isBusy = false;
  bool? _walletEndpointAvailable;
  AuthorizationResult? _authorization;
  WalletCapabilities? _capabilities;
  String? _lastSignedPayload;

  @override
  void initState() {
    super.initState();
    _refreshWalletEndpointStatus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _runOperation(
    String label,
    Future<void> Function() operation,
  ) async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    _appendLog('$label started.');

    try {
      await operation();
      _appendLog('$label succeeded.');
    } on Object catch (error) {
      _appendLog('$label failed: $error');
      _showSnackBar('$label failed. Check log for details.');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _refreshWalletEndpointStatus() async {
    if (!_isMwaSupported) {
      setState(() {
        _walletEndpointAvailable = false;
      });
      return;
    }

    final isAvailable = await _hostApi.isWalletEndpointAvailable();

    if (!mounted) {
      return;
    }

    setState(() {
      _walletEndpointAvailable = isAvailable;
    });

    _appendLog(
      isAvailable
          ? 'Wallet endpoint detected on device.'
          : 'No wallet endpoint detected. Install a mock or compatible wallet.',
    );
  }

  Future<void> _authorize() async {
    await _runOperation('Authorize', () async {
      final auth = await transact(
        (wallet) => wallet.authorize(
          chain: 'solana:devnet',
          features: const ['solana:signMessages'],
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _authorization = auth;
      });

      final accountCount = auth.accounts.length;
      final accountPreview = accountCount > 0
          ? (auth.accounts.first.displayAddress ?? auth.accounts.first.address)
          : 'No accounts returned';

      _appendLog(
        'Authorized $accountCount account(s). First account: $accountPreview',
      );
    });
  }

  Future<void> _loadCapabilities() async {
    final auth = _authorization;
    if (auth == null) {
      _appendLog('Get capabilities skipped: authorize first.');
      _showSnackBar('Authorize first.');
      return;
    }

    await _runOperation('Get capabilities', () async {
      final capabilities = await transact((wallet) async {
        final refreshedAuth = await wallet.reauthorize(
          authToken: auth.authToken,
        );
        final fetchedCapabilities = await wallet.getCapabilities();
        return (refreshedAuth, fetchedCapabilities);
      });

      if (!mounted) {
        return;
      }

      final (refreshedAuth, fetchedCapabilities) = capabilities;

      setState(() {
        _authorization = refreshedAuth;
        _capabilities = fetchedCapabilities;
      });

      final features = fetchedCapabilities.features?.join(', ') ?? 'none';
      _appendLog('Capabilities loaded. Features: $features');
    });
  }

  Future<void> _signMessage() async {
    final auth = _authorization;
    if (auth == null || auth.accounts.isEmpty) {
      _appendLog('Sign message skipped: authorize first.');
      _showSnackBar('Authorize first.');
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _appendLog('Sign message skipped: message is empty.');
      _showSnackBar('Enter a message to sign.');
      return;
    }

    await _runOperation('Sign message', () async {
      final encodedMessage = base64Encode(utf8.encode(message));

      final signed = await transact((wallet) async {
        final refreshedAuth = await wallet.reauthorize(
          authToken: auth.authToken,
        );

        if (refreshedAuth.accounts.isEmpty) {
          throw StateError('Wallet returned no accounts after reauthorize.');
        }

        final signedPayloads = await wallet.signMessages(
          addresses: <String>[refreshedAuth.accounts.first.address],
          payloads: <String>[encodedMessage],
        );

        return (refreshedAuth, signedPayloads);
      });

      final (refreshedAuth, signedPayloads) = signed;

      if (signedPayloads.isEmpty) {
        throw StateError('Wallet returned no signed payloads.');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _authorization = refreshedAuth;
        _lastSignedPayload = signedPayloads.first;
      });

      _appendLog(
        'Message signed. Returned ${signedPayloads.length} signed payload(s).',
      );
    });
  }

  Future<void> _deauthorize() async {
    final auth = _authorization;
    if (auth == null) {
      _appendLog('Deauthorize skipped: no active authorization.');
      _showSnackBar('No active authorization.');
      return;
    }

    await _runOperation('Deauthorize', () async {
      await transact((wallet) => wallet.deauthorize(authToken: auth.authToken));

      if (!mounted) {
        return;
      }

      setState(() {
        _authorization = null;
        _capabilities = null;
        _lastSignedPayload = null;
      });

      _appendLog('Authorization revoked.');
    });
  }

  void _appendLog(String message) {
    if (!mounted) {
      return;
    }

    final now = DateTime.now();
    final timestamp =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    setState(() {
      _logs.insert(0, '[$timestamp] $message');
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _walletEndpointLabel() {
    final isAvailable = _walletEndpointAvailable;
    if (isAvailable == null) {
      return 'Checking...';
    }
    return isAvailable ? 'Available' : 'Not found';
  }

  String _truncate(String value, {int max = 72}) {
    if (value.length <= max) {
      return value;
    }

    return '${value.substring(0, max)}...';
  }

  @override
  Widget build(BuildContext context) {
    final auth = _authorization;
    final activeAccount = auth != null && auth.accounts.isNotEmpty
        ? (auth.accounts.first.displayAddress ?? auth.accounts.first.address)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Solana Kit MWA Manual Test')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              'Use this app to manually test authorize, capabilities, signing, and deauthorize flows on Android wallets supporting Mobile Wallet Adapter.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _StatusLine(
                      label: 'MWA supported',
                      value: _isMwaSupported ? 'Yes' : 'No',
                    ),
                    _StatusLine(
                      label: 'Wallet endpoint',
                      value: _walletEndpointLabel(),
                    ),
                    _StatusLine(
                      label: 'Authorized account',
                      value: activeAccount ?? 'Not authorized',
                    ),
                    _StatusLine(label: 'Busy', value: _isBusy ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _isBusy
                      ? null
                      : () {
                          _runOperation(
                            'Refresh wallet endpoint',
                            _refreshWalletEndpointStatus,
                          );
                        },
                  child: const Text('Refresh Wallet Status'),
                ),
                ElevatedButton(
                  onPressed: !_isBusy && _isMwaSupported ? _authorize : null,
                  child: const Text('Authorize'),
                ),
                ElevatedButton(
                  onPressed: !_isBusy && auth != null
                      ? _loadCapabilities
                      : null,
                  child: const Text('Get Capabilities'),
                ),
                ElevatedButton(
                  onPressed: !_isBusy && auth != null ? _signMessage : null,
                  child: const Text('Sign Message'),
                ),
                OutlinedButton(
                  onPressed: !_isBusy && auth != null ? _deauthorize : null,
                  child: const Text('Deauthorize'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Capabilities',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _StatusLine(
                      label: 'Features',
                      value:
                          _capabilities?.features?.join(', ') ?? 'Not loaded',
                    ),
                    _StatusLine(
                      label: 'Max messages/request',
                      value:
                          _capabilities?.maxMessagesPerRequest?.toString() ??
                          'Not loaded',
                    ),
                    _StatusLine(
                      label: 'Max tx/request',
                      value:
                          _capabilities?.maxTransactionsPerRequest
                              ?.toString() ??
                          'Not loaded',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Last signed payload (base64)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _lastSignedPayload == null
                          ? 'No payload signed yet.'
                          : _truncate(_lastSignedPayload!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Operation log',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _logs.isEmpty ? 'No operations yet.' : _logs.join('\n'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
