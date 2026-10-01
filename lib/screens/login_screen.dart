import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/trip_scope.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final pin = _pinController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un PIN di 6 cifre.')),
      );
      return;
    }
    await TripScope.of(context).login(pin);
  }

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF6EA), Color(0xFFF3EBDD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [AppTheme.orange, AppTheme.amber],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'BCN\n26',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                height: .9,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'VIAGGIO DI GRUPPO',
                          style: TextStyle(
                            color: Color(0xFF9F6F1A),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Barcelona', style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Inserisci il tuo PIN personale',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.muted,
                              ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: _pinController,
                          enabled: !controller.loading,
                          autofocus: true,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onSubmitted: (_) => _login(),
                          decoration: const InputDecoration(
                            counterText: '',
                            hintText: '••••••',
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (controller.error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            controller.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: controller.loading ? null : _login,
                            child: controller.loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Entra'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Il PIN viene verificato sul server e non è salvato nell’app.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
