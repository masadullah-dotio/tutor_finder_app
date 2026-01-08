import 'package:flutter/material.dart';

class AppConstants {
  static final List<Map<String, dynamic>> subjects = [
    {'name': 'Math', 'icon': Icons.calculate, 'color': Colors.blue},
    {'name': 'Physics', 'icon': Icons.science, 'color': Colors.purple},
    {'name': 'Coding', 'icon': Icons.code, 'color': Colors.black},
    {'name': 'English', 'icon': Icons.language, 'color': Colors.red},
    {'name': 'Chemistry', 'icon': Icons.biotech, 'color': Colors.green},
    {'name': 'Biology', 'icon': Icons.eco, 'color': Colors.teal},
    {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.brown},
    {'name': 'Geography', 'icon': Icons.public, 'color': Colors.indigo},
    {'name': 'Computer Science', 'icon': Icons.computer, 'color': Colors.deepPurple},
    {'name': 'Art', 'icon': Icons.palette, 'color': Colors.pink},
    {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.orange},
    {'name': 'Economics', 'icon': Icons.attach_money, 'color': Colors.green[800]},
    {'name': 'Psychology', 'icon': Icons.psychology, 'color': Colors.pinkAccent},
    {'name': 'Sociology', 'icon': Icons.groups, 'color': Colors.amber},
    {'name': 'Philosophy', 'icon': Icons.lightbulb, 'color': Colors.yellow[800]},
    {'name': 'Political Science', 'icon': Icons.gavel, 'color': Colors.blueGrey},
    {'name': 'Business', 'icon': Icons.business, 'color': Colors.cyan},
    {'name': 'Accounting', 'icon': Icons.account_balance, 'color': Colors.greenAccent},
    {'name': 'Marketing', 'icon': Icons.campaign, 'color': Colors.deepOrange},
    {'name': 'Statistics', 'icon': Icons.analytics, 'color': Colors.blueAccent},
  ];
  
  static IconData getIconForSubject(String subject) {
    final normalized = subject.toLowerCase();
    final found = subjects.firstWhere(
      (s) => (s['name'] as String).toLowerCase() == normalized, 
      orElse: () => {'icon': Icons.school},
    );
    return found['icon'] as IconData;
  }
}
