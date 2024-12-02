import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const SummaryScreen({super.key, required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Summary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: $score/$totalQuestions'),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
