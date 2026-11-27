import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PendingApprovalScreen extends StatelessWidget {
  final AuthService? authService;
  const PendingApprovalScreen({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_top, size: 72, color: Colors.blueGrey),
                const SizedBox(height: 20),
                const Text(
                  'Aguardando aprovação',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Seu cadastro como professor foi recebido. Um administrador precisa confirmar seu acesso antes de você usar a área do professor.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const _Step(number: '✓', label: 'Conta criada', done: true),
                const _Step(number: '2', label: 'Aprovação do administrador', current: true),
                const _Step(number: '3', label: 'Acesso à área do professor'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => (authService ?? AuthService()).logout(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String label;
  final bool done;
  final bool current;

  const _Step({
    required this.number,
    required this.label,
    this.done = false,
    this.current = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor = done
        ? Colors.green
        : current
            ? Theme.of(context).primaryColor
            : Colors.grey[300]!;
    final Color numberColor = done || current ? Colors.white : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: circleColor,
            child: Text(
              number,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: numberColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: current ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
