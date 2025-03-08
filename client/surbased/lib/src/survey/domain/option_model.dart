class Option {
  final String description;
  final bool isCorrect;
  final String? id;
  final String? questionId;

  Option({
    required this.description,
    required this.isCorrect,
    this.id,
    this.questionId,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        description: json["description"],
        isCorrect: json["is_correct"],
        id: json["id"],
        questionId: json["question_id"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "is_correct": isCorrect,
      };
}
