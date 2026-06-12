class GameSession {
  final int? id;
  final String month; // e.g. "June 2026"
  final int correctAnswers;
  final int totalQuestions;
  final String difficulty;
  final double rate; // points per correct answer
  final double basePoints;
  final double bonus; // rebate
  final double finalScore;
  final String dateCreated;

  GameSession({
    this.id,
    required this.month,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.difficulty,
    required this.rate,
    required this.basePoints,
    required this.bonus,
    required this.finalScore,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'rate': rate,
      'basePoints': basePoints,
      'bonus': bonus,
      'finalScore': finalScore,
      'dateCreated': dateCreated,
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] as int?,
      month: map['month'] as String,
      correctAnswers: map['correctAnswers'] as int,
      totalQuestions: map['totalQuestions'] as int,
      difficulty: map['difficulty'] as String,
      rate: (map['rate'] as num).toDouble(),
      basePoints: (map['basePoints'] as num).toDouble(),
      bonus: (map['bonus'] as num).toDouble(),
      finalScore: (map['finalScore'] as num).toDouble(),
      dateCreated: map['dateCreated'] as String,
    );
  }

  GameSession copyWith({
    int? id,
    String? month,
    int? correctAnswers,
    int? totalQuestions,
    String? difficulty,
    double? rate,
    double? basePoints,
    double? bonus,
    double? finalScore,
    String? dateCreated,
  }) {
    return GameSession(
      id: id ?? this.id,
      month: month ?? this.month,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      difficulty: difficulty ?? this.difficulty,
      rate: rate ?? this.rate,
      basePoints: basePoints ?? this.basePoints,
      bonus: bonus ?? this.bonus,
      finalScore: finalScore ?? this.finalScore,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
