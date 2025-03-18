class Option {
  final String? description;
  final int? points;
  final String? id;
  final String? questionId;

  Option({
    this.description,
    this.points,
    this.id,
    this.questionId,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        description: json["description"],
        points: json["points"],
        id: json["id"],
        questionId: json["question_id"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (description != null) json["description"] = description;
    if (points != null) json["points"] = points;
    if (id != null) json["id"] = id;
    if (questionId != null) json["question_id"] = questionId;
    return json;
  }
}
