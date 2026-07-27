import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacky_pizza_pos/app.dart';

void main() {
  runApp(const ProviderScope(child: HackyPizzaApp()));
}
