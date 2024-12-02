import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Fixed import
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
  String _type = 'multiple';
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body)['trivia_categories'];
        });
      }
    } catch (e) {
      print('Failed to fetch categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<int>(
              value: _questionCount,
              onChanged: (value) => setState(() => _questionCount = value!),
              items: [5, 10, 15].map((count) => DropdownMenuItem(value: count, child: Text('$count'))).toList(),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
              items: _categories
                  .map((category) => DropdownMenuItem(value: category['id'].toString(), child: Text(category['name'])))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      questionCount: _questionCount,
                      category: _selectedCategory,
                      difficulty: _difficulty,
                      type: _type,
                    ),
                  ),
                );
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
