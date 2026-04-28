import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'core/utils/auth_utils.dart';
import 'data/services/api.dart';

import 'features/auth/auth.dart';
import 'features/admin/admin.dart';
import 'features/doctor/doctor.dart';
import 'features/patient/patient.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loggedIn = await Auth.restore();
  if (loggedIn && Auth.token != null) Api.setTok(Auth.token!);
  runApp(App(start: _start(loggedIn)));
}

String _start(bool ok) {
  if (!ok) return '/';
  if (Auth.isAdmin)   return '/admin/home';
  if (Auth.isDoctor)  return '/doctor/dashboard';
  return '/patient/dashboard';
}

class App extends StatelessWidget {
  final String start;
  const App({super.key, required this.start});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediDash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: start,
      routes: {
        // ── Landing & Auth ───────────────────────────────────────────────────
        '/':                      (_) => const LandingPage(),
        '/login':                 (_) => const LoginPage(),
        '/register':              (_) => const RegisterStep1(),
        '/application-received':  (_) => const ApplicationReceived(),

        // ── Admin ────────────────────────────────────────────────────────────
        '/admin/home':            (_) => const AdminHome(),
        '/admin/appointments':    (_) => const AdminAppointments(),
        '/admin/doctors':         (_) => const ManageDoctors(),
        '/admin/patients':        (_) => const ManagePatients(),
        '/admin/payments':        (_) => const AdminPayments(),

        // ── Doctor ───────────────────────────────────────────────────────────
        '/doctor/dashboard':      (_) => const DoctorDashboard(),
        '/doctor/appointments':   (_) => const DoctorAppointments(),
        '/doctor/patients':       (_) => const DoctorPatients(),
        '/doctor/prescriptions':  (_) => const DoctorPrescriptions(),
        '/doctor/messages':       (_) => const DoctorMessages(),
        '/doctor/earnings':       (_) => const DoctorEarnings(),
        '/doctor/profile':        (_) => const DoctorProfile(),

        // ── Patient ──────────────────────────────────────────────────────────
        '/patient/dashboard':     (_) => const PatientDashboard(),
        '/patient/find-doctor':   (_) => const FindDoctor(),
        '/patient/appointments':  (_) => const PatientAppointments(),
        '/patient/prescriptions': (_) => const PatientPrescriptions(),
        '/patient/messages':      (_) => const PatientMessages(),
        '/patient/payments':      (_) => const PatientPayments(),
        '/patient/profile':       (_) => const PatientProfile(),
      },
    );
  }
}
