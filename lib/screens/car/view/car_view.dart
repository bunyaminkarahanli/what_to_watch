import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:what_to_watch/screens/car/view/result_car_view.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';

class CarView extends StatefulWidget {
  const CarView({super.key});

  @override
  State<CarView> createState() => _CarViewState();
}

class _CarViewState extends State<CarView> {
  List<QuestionModel> questions = [];
  final PageController _pageController = PageController();
  final Map<String, dynamic> answers = {};

  bool loading = true;
  int index = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    questions = await CarQuestionRepo.loadQuestions();
    if (!mounted) return;
    setState(() => loading = false);
  }

  Widget buildInput(QuestionModel q) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (q.type == "select") {
      final String? selected = answers[q.id] as String?;

      return Column(
        children: q.options!.map((option) {
          final bool isSelected = option == selected;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  answers[q.id] = option;
                });
                next();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: 1.5,
                  ),
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : (isDark ? theme.colorScheme.surface : Colors.white),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      size: 22,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return TextField(
      decoration: InputDecoration(
        hintText: q.placeholder ?? "",
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (v) => answers[q.id] = v,
    );
  }

  void next() {
    final q = questions[index];

    if (q.required &&
        (answers[q.id] == null || answers[q.id].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${q.label} gerekli")),
      );
      return;
    }

    if (index < questions.length - 1) {
      setState(() => index++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        answers['userId'] = uid;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CarResultView(answers: answers),
        ),
      );
    }
  }

  void back() {
    if (index > 0) {
      setState(() => index--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/car.json',
                width: 220,
                repeat: true,
              ),
              const SizedBox(height: 12),
              const Text("Sorular yükleniyor..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Araba Bul")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questions[index].label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (_, i) => SingleChildScrollView(
                  child: buildInput(questions[index]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: back,
                      child: const Text("Geri"),
                    ),
                  ),
                if (index > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: next,
                    child: Text(
                        index == questions.length - 1 ? "Araba Bul" : "İleri"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
