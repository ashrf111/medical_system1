import 'package:flutter/material.dart';

class C {
  static const primary     = Color(0xFF2563EB);
  static const primaryDk   = Color(0xFF1D4ED8);
  static const primaryLt   = Color(0xFFEFF6FF);
  static const sidebar     = Color(0xFF1E293B);
  static const sidebarItem = Color(0xFF334155);
  static const bg          = Color(0xFFF8FAFC);
  static const card        = Colors.white;
  static const input       = Color(0xFFF1F5F9);
  static const border      = Color(0xFFE2E8F0);
  static const t1          = Color(0xFF0F172A);
  static const t2          = Color(0xFF475569);
  static const t3          = Color(0xFF94A3B8);
  static const green       = Color(0xFF10B981);
  static const greenLt     = Color(0xFFECFDF5);
  static const amber       = Color(0xFFF59E0B);
  static const amberLt     = Color(0xFFFFFBEB);
  static const red         = Color(0xFFEF4444);
  static const redLt       = Color(0xFFFEF2F2);
  static const purple      = Color(0xFF8B5CF6);
  static const purpleLt    = Color(0xFFF5F3FF);
  static const g1          = Color(0xFF0F172A);
  static const g2          = Color(0xFF1E3A8A);
  static const visa        = Color(0xFF1A1F71);
  static const mc          = Color(0xFFEB001B);
  static const voda        = Color(0xFFE60000);
  static const fawry       = Color(0xFFF5A623);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.primary),
    scaffoldBackgroundColor: C.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: C.card, elevation: 0,
      titleTextStyle: TextStyle(color: C.t1, fontSize: 17, fontWeight: FontWeight.w600),
      iconTheme: IconThemeData(color: C.t1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: C.input,
      hintStyle: const TextStyle(color: C.t3, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.red, width: 1.5)),
      errorStyle: const TextStyle(color: C.red, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: C.primary, foregroundColor: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: C.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.t1, contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

// Text styles
const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: C.t1);
const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: C.t1);
const h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: C.t1);
const h4 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.t1);
const h5 = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.t1);
const body = TextStyle(fontSize: 14, color: C.t2, height: 1.5);
const small = TextStyle(fontSize: 12, color: C.t3);
const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: C.t1);
