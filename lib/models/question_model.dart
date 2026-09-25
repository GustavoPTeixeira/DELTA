class QuestionModel {
  final String id;
  final String statement;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  const QuestionModel({
    required this.id,
    required this.statement,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'statement': statement,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map, String documentId){
    return QuestionModel(
      id: documentId,
      statement: map['statement'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? []),
      correctOptionIndex: map['correctOptionIndex'] as int? ?? 0,
      explanation: map['explanation'] as String?,
    );
  }
}