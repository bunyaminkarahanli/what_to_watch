import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:what_to_watch/screens/car/models/question_model.dart';

class CarQuestionRepo {
  static Future<List<QuestionModel>> loadQuestions() async {
    final jsonString = await rootBundle.loadString(
      'assets/questions/youtube_questions.json',
    );

    final jsonMap = json.decode(jsonString);
    final List questions = jsonMap['questions'];

    return questions.map((e) => QuestionModel.fromJson(e)).toList();
  }
}
