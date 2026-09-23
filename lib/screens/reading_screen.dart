import 'package:flutter/material.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Língua Portuguesa', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Embora várias línguas sejam faladas no Brasil, nosso idioma oficial é o português. E você sabe qual é o idioma oficial de países como Angola, Moçambique, São Tomé e Príncipe e Portugal? Português também, ora pois! Mesmo assim, aposto que você acharia engraçado ouvir alguém falar com o sotaque típico desses lugares. Nossa pronúncia é tão distinta que há quem diga até que parece uma língua diferente. Vamos com calma. Não é. Pelo menos ainda não…\n\nPara o linguista José Simões, da Universidade de São Paulo, ainda não se pode dizer que o português falado no Brasil é autônomo – ou seja, único daqui e só entendido por falantes brasileiros. “O português brasileiro mantém um vocabulário bem próximo ao português falado na Europa”, argumenta o especialista. “Apesar de, na hora da fala, acharmos engraçado e diferente o português de Portugal, ele ainda é bem parecido com o nosso na escrita”.",
              style: TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                debugPrint("Navigate to questionnaire (RF5)");
              },
              child: const Text('PRÓXIMA QUESTÃO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}