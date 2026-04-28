import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/auth_utils.dart';
import '../../data/services/api.dart';

class NavItem {
  final IconData icon, activeIcon;
  final String label, route;
  const NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.route});
}

class AppLayout extends StatelessWidget {
  final List<NavItem> nav;
  final List<int> bottomIdx;
  final int cur;
  final Widget body;
  final String title, subtitle, portal;

  const AppLayout(
      {super.key,
      required this.nav,
      required this.bottomIdx,
      required this.cur,
      required this.body,
      required this.title,
      this.subtitle = '',
      required this.portal});

  bool _mob(BuildContext ctx) => MediaQuery.of(ctx).size.width < 720;

  @override
  Widget build(BuildContext ctx) => _mob(ctx) ? _m(ctx) : _d(ctx);

  // ── MOBILE ──────────────────────────────────────────────────────────────────
  Widget _m(BuildContext ctx) {
    final sel = bottomIdx.contains(cur) ? bottomIdx.indexOf(cur) : 0;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.card,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 14,
        title: Row(children: [
          const Text('MediDash',
              style: TextStyle(
                  color: C.primary, fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(title,
                  style: const TextStyle(color: C.t2, fontSize: 13),
                  overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: C.t1),
            onSelected: (v) {
              if (v == 'out') _logout(ctx);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'out',
                  child: Row(children: const [
                    Icon(Icons.logout, color: C.red, size: 16),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: C.red))
                  ]))
            ],
          )
        ],
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            color: C.card, border: Border(top: BorderSide(color: C.border))),
        child: SafeArea(
            child: SizedBox(
                height: 64,
                child: Row(
                    children: List.generate(bottomIdx.length, (i) {
                  final it = nav[bottomIdx[i]];
                  final act = i == sel;
                  return Expanded(
                      child: InkWell(
                          onTap: () => _go(ctx, bottomIdx[i]),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(act ? it.activeIcon : it.icon,
                                    color: act ? C.primary : C.t3, size: 22),
                                const SizedBox(height: 3),
                                Text(it.label,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: act ? C.primary : C.t3,
                                        fontWeight: act
                                            ? FontWeight.w600
                                            : FontWeight.normal)),
                              ])));
                })))),
      ),
    );
  }

  // ── DESKTOP ─────────────────────────────────────────────────────────────────
  Widget _d(BuildContext ctx) => Scaffold(
          body: Row(children: [
        _sidebar(ctx),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              color: C.card,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: C.border))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: h2),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(color: C.t3, fontSize: 13))
                    ],
                  ])),
          Expanded(child: Container(color: C.bg, child: body)),
        ])),
      ]));

  Widget _sidebar(BuildContext ctx) {
    final nm = Auth.display;
    final ini = Auth.initials;
    return Container(
        width: 240,
        color: C.sidebar,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 6),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MediDash',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    Text(portal,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ])),
          const SizedBox(height: 10),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: nav.length,
                  itemBuilder: (c, i) => _NavTile(
                      item: nav[i], active: i == cur, onTap: () => _go(c, i)))),
          Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                CircleAvatar(
                    radius: 18,
                    backgroundColor: C.primary.withOpacity(0.4),
                    child: Text(ini,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13))),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(nm,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                      Text(portal.split(' ').first,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10)),
                    ])),
              ])),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
              child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                      onPressed: () => _logout(ctx),
                      icon: const Icon(Icons.logout, size: 14, color: C.red),
                      label: const Text('Sign Out',
                          style: TextStyle(fontSize: 13, color: C.red)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: C.red),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)))))),
        ]));
  }

  void _go(BuildContext ctx, int i) {
    if (i == cur) return;
    Navigator.pushReplacementNamed(ctx, nav[i].route);
  }

  void _logout(BuildContext ctx) async {
    await Api.logout();
    await Auth.clear();
    Api.clearTok();
    if (ctx.mounted)
      Navigator.pushNamedAndRemoveUntil(ctx, '/login', (_) => false);
  }
}

class _NavTile extends StatelessWidget {
  final NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavTile(
      {required this.item, required this.active, required this.onTap});
  @override
  Widget build(BuildContext ctx) => Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
          onTap: onTap,
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: active ? C.primary : Colors.transparent,
          hoverColor: Colors.white.withOpacity(0.06),
          leading: Icon(active ? item.activeIcon : item.icon,
              color: active ? Colors.white : Colors.white60, size: 18),
          title: Text(item.label,
              style: TextStyle(
                  color: active ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal))));
}

// ─── Concrete Layouts ────────────────────────────────────────────────────────
class DoctorLayout extends StatelessWidget {
  final int cur;
  final Widget body;
  final String title;
  final String subtitle;
  const DoctorLayout(
      {super.key,
      required this.cur,
      required this.body,
      required this.title,
      this.subtitle = ''});

  static const _nav = [
    NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        route: '/doctor/dashboard'),
    NavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Appointments',
        route: '/doctor/appointments'),
    NavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'My Patients',
        route: '/doctor/patients'),
    NavItem(
        icon: Icons.description_outlined,
        activeIcon: Icons.description,
        label: 'Prescriptions',
        route: '/doctor/prescriptions'),
    NavItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Messages',
        route: '/doctor/messages'),
    NavItem(
        icon: Icons.attach_money_outlined,
        activeIcon: Icons.attach_money,
        label: 'Earnings',
        route: '/doctor/earnings'),
    NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        route: '/doctor/profile'),
    NavItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        label: 'AI Assistant',
        route: '/doctor/chatbot'),
  ];

  @override
  Widget build(BuildContext ctx) => AppLayout(
      nav: _nav,
      bottomIdx: const [0, 1, 2, 4, 6],
      cur: cur,
      body: body,
      title: title,
      subtitle: subtitle,
      portal: 'Doctor Portal');
}

class PatientLayout extends StatelessWidget {
  final int cur;
  final Widget body;
  final String title;
  final String subtitle;
  const PatientLayout(
      {super.key,
      required this.cur,
      required this.body,
      required this.title,
      this.subtitle = ''});

  static const _nav = [
    NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        route: '/patient/dashboard'),
    NavItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: 'Find Doctor',
        route: '/patient/find-doctor'),
    NavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Appointments',
        route: '/patient/appointments'),
    NavItem(
        icon: Icons.description_outlined,
        activeIcon: Icons.description,
        label: 'Prescriptions',
        route: '/patient/prescriptions'),
    NavItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Messages',
        route: '/patient/messages'),
    NavItem(
        icon: Icons.credit_card_outlined,
        activeIcon: Icons.credit_card,
        label: 'Payments',
        route: '/patient/payments'),
    NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'My Profile',
        route: '/patient/profile'),
    NavItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        label: 'AI Assistant',
        route: '/patient/chatbot'),
  ];

  @override
  Widget build(BuildContext ctx) => AppLayout(
      nav: _nav,
      bottomIdx: const [0, 1, 2, 4, 6],
      cur: cur,
      body: body,
      title: title,
      subtitle: subtitle,
      portal: 'Patient Portal');
}

class AdminLayout extends StatelessWidget {
  final int cur;
  final Widget body;
  final String title;
  final String subtitle;
  const AdminLayout(
      {super.key,
      required this.cur,
      required this.body,
      required this.title,
      this.subtitle = ''});

  static const _nav = [
    NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Overview',
        route: '/admin/home'),
    NavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Appointments',
        route: '/admin/appointments'),
    NavItem(
        icon: Icons.medical_services_outlined,
        activeIcon: Icons.medical_services,
        label: 'Doctors',
        route: '/admin/doctors'),
    NavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Patients',
        route: '/admin/patients'),
    NavItem(
        icon: Icons.payments_outlined,
        activeIcon: Icons.payments,
        label: 'Payments',
        route: '/admin/payments'),
    NavItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        label: 'AI Assistant',
        route: '/admin/chatbot'),
  ];

  @override
  Widget build(BuildContext ctx) => AppLayout(
      nav: _nav,
      bottomIdx: const [0, 1, 2, 3, 4],
      cur: cur,
      body: body,
      title: title,
      subtitle: subtitle,
      portal: 'Admin Panel');
}
