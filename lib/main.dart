import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';

void main() {
  runApp(const ProviderScope(child: MacroAdvisorApp()));
}
