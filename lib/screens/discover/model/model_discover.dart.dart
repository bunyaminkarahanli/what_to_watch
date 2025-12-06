import 'package:flutter/material.dart';

class DiscoverItem {
  final String title;
  final String image;
  final Color color;
  final String? subtitle;

  DiscoverItem({
    required this.title,
    required this.image,
    required this.color,
    this.subtitle,
  });
}
