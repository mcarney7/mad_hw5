import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _questionCount = 5;
  String? _selectedCategory;
  String _difficulty = 'easy';
  List<Map<String, String>> _categories = [
    {'id': '9', 'name': 'General Knowledge'},
    {'id': '11', 'name': 'Movies'},
    {'id': '17', 'name': 'Science & Nature'},
    {'id': '21', 'name': 'Sports'},
    {'id': '23', 'name': 'History'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Number of Questions:', style: TextStyle(fontSize: 16)),
            DropdownButton<int>(
              value: _questionCount,
              onChanged: (value) => setState(() => _questionCount = value!),
              items: [5, 10, 15]
                  .map((count) =>
                      DropdownMenuItem(value: count, child: Text('$count')))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Category:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category['id'],
                        child: Text(category['name']!),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Difficulty:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _difficulty,
              onChanged: (value) => setState(() => _difficulty = value!),
              items: ['easy', 'medium', 'hard']
                  .map((level) =>
                      DropdownMenuItem(value: level, child: Text(level)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCategory != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          questionCount: _questionCount,
                          category: _selectedCategory,
                          difficulty: _difficulty,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Start Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
