import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final input = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(
        identifier: input,
        password: password,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPasswordResetDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    final resetFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Recuperar Senha'),
          content: Form(
            key: resetFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Digite seu e-mail cadastrado para receber o link de redefinição de senha:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  validator: (text) {
                    if (text == null || text.trim().isEmpty) {
                      return 'O e-mail é obrigatório';
                    }
                    if (!text.contains('@')) {
                      return 'Por favor, digite um e-mail válido.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!resetFormKey.currentState!.validate()) return;

                final email = resetEmailController.text.trim().toLowerCase();
                Navigator.pop(dialogContext);
                try {
                  await _authService.sendPasswordResetEmail(email);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'E-mail de recuperação enviado! Verifique sua caixa de entrada.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } on AuthException catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao enviar e-mail: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('ENVIAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.change_history,
                  size: 150,
                  color: Colors.black87,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _identifierController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário ou E-mail',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (text) {
                    if (text == null || text.trim().isEmpty) {
                      return 'Informe seu usuário ou e-mail';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      tooltip: _obscurePassword
                          ? 'Mostrar senha'
                          : 'Ocultar senha',
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (text) {
                    if (text == null || text.trim().isEmpty) {
                      return 'Informe sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _showPasswordResetDialog,
                    child: const Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'LOGAR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Ainda não tem conta? Registre-se aqui.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}