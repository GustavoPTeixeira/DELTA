import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reading_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  final List<String> subjects = const [
    'Artes',
    'Ciências',
    'Educação Física',
    'Geografia',
    'História',
    'Língua inglesa',
    'Língua Portuguesa',
    'Matemática'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matérias', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da conta',
            onPressed: () async {
              // Sign out from Firebase Auth.
              // StreamBuilder in main.dart automatically reverts to LoginScreen.
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(subjects[index], style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  // Currently redirecting all subjects to the sample science reading text
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReadingScreen()),
                  );
                },
              ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}