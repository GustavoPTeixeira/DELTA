import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuestionScreen extends StatefulWidget {
  final String title;
  final List<QuestionModel>? questions;

  const QuestionScreen({
    super.key,
    this.title = 'Questionário',
    this.questions,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final List<QuestionModel> _questions;
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _score = 0;

  @override
  void initState(){
    super.initState();
    _questions = widget.questions ?? _defaultQuestions;
  }

  static const List<QuestionModel> _defaultQuestions = [
    QuestionModel(
      id: 'q1',
      statement:
          'De acordo com o texto lido, além do Brasil e de Portugal, em quais outros países o português também é idioma oficial?',
      options: [
        'México, Argentina e Chile',
        'Angola, Moçambique e São Tomé e Príncipe',
        'Espanha, Itália e França',
        'África do Sul, Egito e Nigéria',
      ],
      correctOptionIndex: 1,
      explanation:
          'O texto cita explicitamente: "E você sabe qual é o idioma oficial de países como Angola, Moçambique, São Tomé e Príncipe e Portugal? Português também, ora pois!".',
    ),
    QuestionModel(
      id: 'q2',
      statement:
          'Segundo o linguista José Simões citado no texto, o português falado no Brasil:',
      options: [
        'Já se tornou um idioma totalmente autônomo e independente do português europeu.',
        'Deixou de ser o idioma oficial devido a outras línguas faladas na região.',
        'Mantém um vocabulário bem próximo ao português falado na Europa.',
        'Não pode mais ser compreendido por pessoas naturais de Portugal.',
      ],
      correctOptionIndex: 2,
      explanation:
          'Segundo o especialista: "O português brasileiro mantém um vocabulário bem próximo ao português falado na Europa".',
    ),
    QuestionModel(
      id: 'q3',
      statement:
          'Qual é a principal constatação do texto a respeito das semelhanças e diferenças entre o português do Brasil e o de Portugal?',
      options: [
        'A pronúncia e o sotaque são distintos na fala, mas a língua escrita ainda é bastante parecida.',
        'A escrita é completamente incompatível, embora a fala soe idêntica.',
        'Não há qualquer distinção de sotaque ou vocabulário entre os dois países.',
        'O português do Brasil foi substituído por dialetos regionais exclusivos.',
      ],
      correctOptionIndex: 0,
      explanation:
          'O texto destaca que, apesar da diferença na pronúncia ao falar, na escrita os idiomas ainda são muito parecidos.',
    ),
  ];

  void _confirmAnswer(){
    if(_selectedOptionIndex == null || _isAnswered) return;

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = _selectedOptionIndex == currentQuestion.correctOptionIndex;

    setState((){
      _isAnswered = true;
      if(isCorrect){
        _score++;
      }
    });
  }

   void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      _showResultsDialog();
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isAnswered = false;
      _score = 0;
    });
  }

  void _showResultsDialog(){
    final total = _questions.length;
    final percentage = ((_score / total) * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Resultado do Questionário',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                percentage >= 60 ? Icons.check_circle_outline : Icons.help_outline,
                size: 64,
                color: percentage >= 60 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'Você acertou $_score de $total questões!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Aproveitamento: $percentage%',
                style: TextStyle(
                  fontSize: 16,
                  color: percentage >= 60 ? Colors.green[800] : Colors.orange[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                percentage >= 60
                  ? 'Excelente trabalho! Você demonstrou ótima compreensão do conteúdo.'
                  : 'Bom esforço! Que tal revisar o texto e tentar novamente?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87), 
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                _restartQuiz();
              },
              child: const Text('Refazer'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white
              ),
              onPressed: (){
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Concluir'),
            ),
          ],
        );
      },
    );
  }
    @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Nenhuma questão cadastrada.')),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. Barra de progresso linear
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
            minHeight: 6,
          ),

          // 2. Área rolável com enunciado e alternativas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Contador de questão e pontuação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questão ${_currentIndex + 1} de ${_questions.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Pontos: $_score',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Enunciado da pergunta
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      currentQuestion.statement,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                                    // Lista de alternativas (A, B, C, D) com cores dinâmicas
                  ...List.generate(currentQuestion.options.length, (index) {
                    final optionText = currentQuestion.options[index];
                    final optionLetter = index < letters.length ? letters[index] : '${index + 1}';
                    final isSelected = _selectedOptionIndex == index;
                    final isCorrect = index == currentQuestion.correctOptionIndex;

                    Color borderColor = Colors.grey[300]!;
                    Color backgroundColor = Colors.white;
                    Color textColor = Colors.black87;
                    Widget? trailingIcon;

                    if (_isAnswered) {
                      if (isCorrect) {
                        borderColor = Colors.green;
                        backgroundColor = Colors.green.withValues(alpha: 0.08);
                        trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
                      } else if (isSelected) {
                        borderColor = Colors.red;
                        backgroundColor = Colors.red.withValues(alpha: 0.08);
                        trailingIcon = const Icon(Icons.cancel, color: Colors.red);
                      }
                    } else if (isSelected) {
                      borderColor = Colors.black87;
                      backgroundColor = Colors.grey[100]!;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: _isAnswered
                            ? null
                            : () {
                                setState(() {
                                  _selectedOptionIndex = index;
                                });
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: borderColor,
                              width: isSelected || (_isAnswered && isCorrect) ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.black87 : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  optionLetter,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (trailingIcon != null) ...[
                                const SizedBox(width: 8),
                                trailingIcon,
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Caixa de explicação pedagógica (exibida apenas após responder)
                  if (_isAnswered && currentQuestion.explanation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              currentQuestion.explanation!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 3. Botão inferior com transição dinâmica de ação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_selectedOptionIndex != null || _isAnswered)
                      ? Colors.black87
                      : Colors.grey[300],
                  foregroundColor: (_selectedOptionIndex != null || _isAnswered)
                      ? Colors.white
                      : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: (_selectedOptionIndex != null || _isAnswered)
                    ? () {
                        if (!_isAnswered) {
                          _confirmAnswer();
                        } else {
                          _nextQuestion();
                        }
                      }
                    : null,
                child: Text(
                  !_isAnswered
                      ? 'CONFIRMAR RESPOSTA'
                      : (_currentIndex < _questions.length - 1
                          ? 'PRÓXIMA QUESTÃO'
                          : 'FINALIZAR QUESTIONÁRIO'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}