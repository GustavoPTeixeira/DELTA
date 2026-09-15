import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_cadastro.dart';
import 'tela_materias.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Controladores para pegar o texto digitado pelo usuário
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Espaço reservado para a Logo do Prisma desenhada pela Giovana
              Icon(
                Icons.change_history, // Ícone temporário de triângulo (Delta)
                size: 150,
                color: Colors.black87,
              ),
              const SizedBox(height: 40),

              // Campo: Nome de usuário
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nome de usuario',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Senha
              TextField(
                controller: _senhaController,
                obscureText: true, // Esconde a senha
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Botão Esqueceu a Senha
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // Futura função de recuperar senha
                  },
                  child: const Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botão LOGAR[cite: 2]
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.grey[300], // Cor baseada na Figura 5[cite: 2]
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  // Futura conexão com o Firebase para validar o RF2[cite: 2]
                  print("Botão Logar pressionado!");
                },
                child: const Text(
                  'LOGAR',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Link para ir para a tela de Cadastro (RF1)[cite: 2]
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaCadastro(),
                    ),
                  );
                },
                child: const Text('Ainda não tem conta? Registre-se aqui.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}