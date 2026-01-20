import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Tip {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color; // In real app, store as hex string

  const Tip({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class Faq {
  final String question;
  final String answer;

  const Faq({required this.question, required this.answer});
}
