import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        name: _nameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        )
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        )
      );
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Cadastro', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) return 'O nome é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nome de Usuário'),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) return 'O nome de usuário é obrigatório';
                  if (text.contains(' ')) return 'Não use espaços no nome de usuário';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (text) {
                  if (text == null || text.trim().isEmpty) return 'O email é obrigatório';
                  if (!text.contains('@')) return 'Digite um email válido com @';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) return 'A senha é obrigatória';
                  if (text.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('REGISTRAR', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}