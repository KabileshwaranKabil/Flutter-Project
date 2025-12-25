/// App color constants for the Discipline tracker app.
/// Minimalist dark theme with calm, muted colors.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2C2C2C);
  
  // Primary accent - soft teal
  static const Color primary = Color(0xFF4DB6AC);
  static const Color primaryLight = Color(0xFF80CBC4);
  static const Color primaryDark = Color(0xFF009688);
  
  // Text colors
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFF616161);
  
  // Status colors (muted versions)
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  
  // System category colors (subtle differentiation)
  static const Color learning = Color(0xFF64B5F6);
  static const Color projects = Color(0xFFBA68C8);
  static const Color academics = Color(0xFF4DD0E1);
  static const Color health = Color(0xFF81C784);
  static const Color mind = Color(0xFFFFB74D);
  
  // Divider and border
  static const Color divider = Color(0xFF424242);
  static const Color border = Color(0xFF373737);
}
