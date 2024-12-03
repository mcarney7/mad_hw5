import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'summary_screen.dart';

class QuizScreen extends StatefulWidget {
  final int questionCount;
  final String? category;
  final String difficulty;
  final String type;

  const QuizScreen({
    super.key,
    required this.questionCount,
    required this.category,
    required this.difficulty,
    required this.type,
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
    final url =
        'https://opentdb.com/api.php?amount=${widget.questionCount}&category=${widget.category}&difficulty=${widget.difficulty}&type=${widget.type}';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body)['results'];
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
    setState(() {
      _isAnswered = true;
      final correctAnswer = questions[_currentQuestionIndex]['correct_answer'];
      if (selectedAnswer == correctAnswer) {
        _score++;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < widget.questionCount - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
          _startTimer();
        });
      } else {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryScreen(score: _score, totalQuestions: widget.questionCount),
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
              return const Center(child: Text('Error loading questions.'));
            }
            final questions = snapshot.data!;
            final currentQuestion = questions[_currentQuestionIndex];

            return Column(
              children: [
                Text('Score: $_score', style: const TextStyle(fontSize: 16)),
                Text('Time left: $_timeLeft', style: const TextStyle(fontSize: 16)),
                Text('Question ${_currentQuestionIndex + 1} of ${widget.questionCount}', style: const TextStyle(fontSize: 16)),
                Text(currentQuestion['question'], style: const TextStyle(fontSize: 18)),
                ...currentQuestion['incorrect_answers']
                    .map<Widget>(
                      (answer) => ElevatedButton(
                        onPressed: _isAnswered ? null : () => _handleAnswer(answer),
                        child: Text(answer),
                      ),
                    )
                    .toList(),
                ElevatedButton(
                  onPressed: _isAnswered ? null : () => _handleAnswer(currentQuestion['correct_answer']),
                  child: Text(currentQuestion['correct_answer']),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
