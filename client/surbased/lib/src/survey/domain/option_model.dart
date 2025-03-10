class Option {
  final String? description;
  final bool? isCorrect;
  final String? id;
  final String? questionId;

  Option({
    this.description,
    this.isCorrect,
    this.id,
    this.questionId,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        description: json["description"],
        isCorrect: json["is_correct"],
        id: json["id"],
        questionId: json["question_id"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (description != null) json["description"] = description;
    if (isCorrect != null) json["is_correct"] = isCorrect;
    if (id != null) json["id"] = id;
    if (questionId != null) json["question_id"] = questionId;
    return json;
  }
}
