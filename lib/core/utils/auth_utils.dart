import 'package:shared_preferences/shared_preferences.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────
class Auth {
  static String? token;
  static String? role; // doctor | patient | admin
  static String? id;
  static String? name;
  static String? email;
  static String? specialty;

  static void set({required String t, required String r, required String uid,
      required String n, required String e, String? spec}) {
    token = t; role = r; id = uid; name = n; email = e; specialty = spec;
    _save();
  }

  static Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('token', token!); await p.setString('role', role!);
    await p.setString('id', id!);       await p.setString('name', name!);
    await p.setString('email', email!);
    if (specialty != null) await p.setString('specialty', specialty!);
  }

  static Future<bool> restore() async {
    final p = await SharedPreferences.getInstance();
    final t = p.getString('token'); if (t == null) return false;
    token = t; role = p.getString('role'); id = p.getString('id');
    name = p.getString('name'); email = p.getString('email');
    specialty = p.getString('specialty');
    return true;
  }

  static Future<void> clear() async {
    token = null; role = null; id = null; name = null; email = null; specialty = null;
    final p = await SharedPreferences.getInstance(); await p.clear();
  }

  static bool get isDoctor  => role == 'doctor';
  static bool get isPatient => role == 'patient';
  static bool get isAdmin   => role == 'admin';

  static String get display => name ?? email ?? 'User';
  static String get initials {
    final parts = display.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return display.isNotEmpty ? display[0].toUpperCase() : 'U';
  }
}

// ─── Validators ──────────────────────────────────────────────────────────────
class V {
  static String? req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())
        ? null : 'Enter a valid email address';
  }

  static String? pass(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return v.length < 6 ? 'At least 6 characters required' : null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required';
    return v.replaceAll(RegExp(r'\D'), '').length < 10 ? 'Enter a valid phone' : null;
  }

  static String? confirmPass(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    return v != original ? 'Passwords do not match' : null;
  }
}
