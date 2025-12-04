class QuestionModel {
  final String id;
  final String type; 
  final String label;
  final List<String>? options;
  final bool required;
  final String? placeholder;

  QuestionModel({
    required this.id,
    required this.type,
    required this.label,
    this.options,
    this.required = false,
    this.placeholder,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      type: json['type'],
      label: json['label'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      required: json['required'] ?? false,
      placeholder: json['placeholder'],
    );
  }
}
