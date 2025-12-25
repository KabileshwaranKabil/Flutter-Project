import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/security_provider.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _verifying = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Enter PIN',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app is locked for your privacy.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      prefixIcon: const Icon(Icons.password_outlined),
                      errorText: _error,
                    ),
                    onSubmitted: (_) => _verifyPin(),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _verifying ? null : _verifyPin,
                    child: _verifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Unlock'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPin() async {
    setState(() {
      _verifying = true;
      _error = null;
    });

    final ok = await context.read<SecurityProvider>().verifyPin(_pinController.text);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _error = 'Incorrect PIN';
        _verifying = false;
      });
      return;
    }

    setState(() {
      _verifying = false;
    });
  }
}
