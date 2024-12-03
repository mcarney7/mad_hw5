import 'package:flutter/material.dart';
import 'quiz_setup_screen.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const SummaryScreen({super.key, required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const QuizSetupScreen()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: $score/$totalQuestions', style: const TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizSetupScreen()),
                );
              },
              child: const Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
