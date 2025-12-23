import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider that toggles between light and dark
final themeNotifierProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);
