import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'summary_screen.dart';

class QuizScreen extends StatefulWidget {
  final int questionCount;
  final String? category;
  final String difficulty;

  const QuizScreen({
    super.key,
    required this.questionCount,
    required this.category,
    required this.difficulty,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<dynamic>> _quizQuestions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  Timer? _timer;
  int _timeLeft = 30;

  @override
  void initState() {
    super.initState();
    _quizQuestions = _fetchQuestions();
    _startTimer();
  }

  Future<List<dynamic>> _fetchQuestions() async {
    final url = Uri.parse(
        'https://opentdb.com/api.php?amount=${widget.questionCount}&category=${widget.category}&difficulty=${widget.difficulty}&type=multiple');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['response_code'] == 0) {
        return data['results'];
      } else {
        throw Exception("No questions available for the selected options.");
      }
    } else {
      throw Exception("Failed to fetch questions.");
    }
  }

  void _startTimer() {
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _handleAnswer(null);
      }
    });
  }

  void _handleAnswer(String? selectedAnswer) async {
    final questions = await _quizQuestions;
    final correctAnswer = questions[_currentQuestionIndex]['correct_answer'];
    setState(() {
      _isAnswered = true;
      if (selectedAnswer == correctAnswer) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < widget.questionCount - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
        });
        _startTimer();
      } else {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryScreen(
              score: _score,
              totalQuestions: widget.questionCount,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: FutureBuilder<List<dynamic>>(
          future: _quizQuestions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final questions = snapshot.data!;
            final currentQuestion = questions[_currentQuestionIndex];
            final allAnswers = [
              currentQuestion['correct_answer'],
              ...currentQuestion['incorrect_answers'],
            ];

            return Column(
              children: [
                Text('Score: $_score', style: const TextStyle(fontSize: 16)),
                Text('Time left: $_timeLeft seconds', style: const TextStyle(fontSize: 16)),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${widget.questionCount}',
                  style: const TextStyle(fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion['question'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                ...allAnswers.map((answer) {
                  return ElevatedButton(
                    onPressed: _isAnswered ? null : () => _handleAnswer(answer),
                    child: Text(answer),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
