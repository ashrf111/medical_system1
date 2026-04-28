import 'package:flutter/material.dart' hide Badge;

import '../../core/theme/theme.dart';
import '../../data/services/api.dart';
import '../../shared/widgets/layout.dart';
import '../../shared/widgets/widgets.dart';

// ════════════════════ ADMIN HOME ══════════════════════════════════════════════
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AH();
}

class _AH extends State<AdminHome> {
  Map? d;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.adminHome();
      if (mounted)
        setState(() {
          d = r;
          loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) => AdminLayout(
      cur: 0,
      title: 'Admin Overview',
      subtitle: 'Platform statistics and recent activity',
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (c, box) {
              final mob = box.maxWidth < 720;
              final recent =
                  (d?['recent_appointments'] as List?)?.cast<Map>() ?? [];
              return SingleChildScrollView(
                  padding: EdgeInsets.all(mob ? 14 : 24),
                  child: Column(children: [
                    GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: mob ? 2 : 5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: mob ? 1.4 : 1.2,
                        children: [
                          StatTile(
                              icon: Icons.medical_services_outlined,
                              value: '${d?['total_doctors'] ?? 0}',
                              label: 'Total Doctors',
                              ic: C.primary,
                              ib: C.primaryLt),
                          StatTile(
                              icon: Icons.people_outline,
                              value: '${d?['total_patients'] ?? 0}',
                              label: 'Total Patients',
                              ic: C.purple,
                              ib: C.purpleLt),
                          StatTile(
                              icon: Icons.calendar_today,
                              value: '${d?['total_appointments'] ?? 0}',
                              label: 'Total Appointments',
                              ic: C.green,
                              ib: C.greenLt),
                          StatTile(
                              icon: Icons.attach_money,
                              value:
                                  '\$${(d?['total_revenue'] ?? 0.0).toStringAsFixed(0)}',
                              label: 'Total Revenue',
                              ic: C.green,
                              ib: C.greenLt),
                          StatTile(
                              icon: Icons.hourglass_empty,
                              value: '${d?['pending_approvals'] ?? 0}',
                              label: 'Pending Approvals',
                              ic: C.amber,
                              ib: C.amberLt,
                              sub: d?['pending_approvals'] != 0
                                  ? 'Requires action'
                                  : null),
                        ]),
                    const SizedBox(height: 20),
                    SecCard(
                        title: 'Recent Appointments',
                        action: 'View all →',
                        onAction: () => Navigator.pushReplacementNamed(
                            ctx, '/admin/appointments'),
                        child: recent.isEmpty
                            ? const Empty(
                                icon: Icons.calendar_today_outlined,
                                msg: 'No recent appointments')
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(12),
                                itemCount: recent.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final a = recent[i];
                                  return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: Av(
                                          a['patient']?.toString() ?? '',
                                          r: 20),
                                      title: Text(
                                          '${a['patient']} → ${a['doctor']}',
                                          style: h5.copyWith(fontSize: 13)),
                                      subtitle: Text(
                                          '${a['date']} · ${a['time']}',
                                          style: small),
                                      trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Badge(
                                                a['status']?.toString() ?? ''),
                                            const SizedBox(width: 8),
                                            Text('\$${a['fee']}',
                                                style: h5.copyWith(
                                                    color: C.green)),
                                          ]));
                                })),
                  ]));
            }));
}

// ════════════════════ ADMIN APPOINTMENTS ═════════════════════════════════════
class AdminAppointments extends StatefulWidget {
  const AdminAppointments({super.key});
  @override
  State<AdminAppointments> createState() => _AA();
}

class _AA extends State<AdminAppointments> {
  List<Map> _all = [], _shown = [];
  bool loading = true;
  String _filter = 'All';
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.adminAppointments();
      setState(() {
        _all = (r['appointments'] as List?)?.cast<Map>() ?? [];
        _apply();
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _apply() {
    var list = _all;
    if (_filter != 'All')
      list = list.where((a) => a['status'] == _filter.toLowerCase()).toList();
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty)
      list = list
          .where((a) =>
              (a['patient']?.toString().toLowerCase().contains(q) ?? false) ||
              (a['doctor']?.toString().toLowerCase().contains(q) ?? false))
          .toList();
    setState(() => _shown = list);
  }

  @override
  Widget build(BuildContext ctx) => AdminLayout(
      cur: 1,
      title: 'All Appointments',
      subtitle: 'View and manage all platform appointments',
      body: Column(children: [
        Container(
            color: C.card,
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                  child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                          hintText: 'Search patient or doctor...',
                          prefixIcon:
                              Icon(Icons.search, size: 18, color: C.t3)),
                      onChanged: (_) => _apply())),
              const SizedBox(width: 12),
              DropdownButton<String>(
                  value: _filter,
                  items: ['All', 'Upcoming', 'Completed', 'Cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _filter = v!);
                    _apply();
                  }),
            ])),
        Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _shown.isEmpty
                    ? const Empty(
                        icon: Icons.calendar_today_outlined,
                        msg: 'No appointments found')
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _shown.length,
                        itemBuilder: (_, i) {
                          final a = _shown[i];
                          return MCard(
                              pad: const EdgeInsets.all(14),
                              child: Row(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        const Icon(Icons.person,
                                            size: 14, color: C.t3),
                                        const SizedBox(width: 4),
                                        Text(a['patient']?.toString() ?? '',
                                            style: h5.copyWith(fontSize: 13))
                                      ]),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.medical_services,
                                            size: 14, color: C.primary),
                                        const SizedBox(width: 4),
                                        Text(a['doctor']?.toString() ?? '',
                                            style: body.copyWith(fontSize: 12))
                                      ]),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${a['specialty']} · ${a['date']} ${a['time']}',
                                          style: small),
                                    ]),
                                const Spacer(),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Badge(a['status']?.toString() ?? ''),
                                      const SizedBox(height: 6),
                                      Text('\$${a['fee']}',
                                          style: h5.copyWith(color: C.green)),
                                    ]),
                              ]));
                        })),
      ]));
}

// ════════════════════ MANAGE DOCTORS ═════════════════════════════════════════
class ManageDoctors extends StatefulWidget {
  const ManageDoctors({super.key});
  @override
  State<ManageDoctors> createState() => _MD();
}

class _MD extends State<ManageDoctors> {
  List<Map> _all = [], _shown = [];
  bool loading = true;
  String _filter = 'All';
  final _search = TextEditingController();
  List<Map<String, dynamic>> _specs = [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadSpecs();
  }

  Future<void> _loadSpecs() async {
    try {
      final res = await Api.getSpecialties();
      if (mounted) setState(() => _specs = res);
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final r = await Api.getDoctors();
      setState(() {
        _all = (r['doctors'] as List?)?.cast<Map>() ?? [];
        _apply();
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _apply() {
    var list = _all;
    if (_filter != 'All')
      list = list.where((d) => d['status'] == _filter.toLowerCase()).toList();
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty)
      list = list
          .where((d) =>
              (d['name']?.toString().toLowerCase().contains(q) ?? false) ||
              (d['specialty']?.toString().toLowerCase().contains(q) ?? false))
          .toList();
    setState(() => _shown = list);
  }

  Future<void> _approve(String id) async {
    try {
      await Api.approveDoctor(id);
      _load();
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ Doctor approved')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _suspend(String id) async {
    try {
      await Api.suspendDoctor(id);
      _load();
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Doctor suspended')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _delete(String id) async {
    try {
      await Api.deleteDoctor(id);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doctor deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext ctx) => AdminLayout(
      cur: 2,
      title: 'Manage Doctors',
      subtitle: '${_all.length} total doctors registered',
      body: Column(children: [
        Container(
            color: C.card,
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                  child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                          hintText: 'Search doctors...',
                          prefixIcon:
                              Icon(Icons.search, size: 18, color: C.t3)),
                      onChanged: (_) => _apply())),
              const SizedBox(width: 12),
              Btn(label: '+ Add', width: 80, onTap: () => _addDoctorDlg(ctx)),
              const SizedBox(width: 12),
              DropdownButton<String>(
                  value: _filter,
                  items: ['All', 'Active', 'Pending', 'Suspended']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _filter = v!);
                    _apply();
                  }),
            ])),
        Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _shown.isEmpty
                    ? const Empty(
                        icon: Icons.medical_services_outlined,
                        msg: 'No doctors found')
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _shown.length,
                        itemBuilder: (_, i) {
                          final d = _shown[i];
                          final status = d['status']?.toString() ?? 'pending';
                          return MCard(
                              pad: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Av(d['name']?.toString() ?? '', r: 24),
                                      const SizedBox(width: 14),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(d['name']?.toString() ?? '',
                                                style: h5),
                                            Text(
                                                d['specialty']?.toString() ??
                                                    '',
                                                style: body.copyWith(
                                                    fontSize: 13)),
                                            Text(d['email']?.toString() ?? '',
                                                style: small),
                                          ])),
                                      Badge(status),
                                    ]),
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      _Info(Icons.people_outline,
                                          '${d['patients']} patients'),
                                      const SizedBox(width: 16),
                                      _Info(Icons.star_outline,
                                          '${d['rating']} rating'),
                                      const SizedBox(width: 16),
                                      _Info(Icons.attach_money,
                                          '\$${d['fee']}/visit'),
                                      const SizedBox(width: 16),
                                      _Info(Icons.calendar_today,
                                          'Since ${d['joined']}'),
                                    ]),
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      if (status == 'pending')
                                        Expanded(
                                            child: Btn(
                                                label: 'Approve',
                                                color: C.green,
                                                onTap: () => _approve(
                                                    d['id']?.toString() ??
                                                        ''))),
                                      if (status == 'pending')
                                        const SizedBox(width: 10),
                                      if (status == 'active')
                                        Expanded(
                                            child: Btn(
                                                label: 'Suspend',
                                                color: C.amber,
                                                onTap: () => _suspend(
                                                    d['id']?.toString() ??
                                                        ''))),
                                      if (status == 'active')
                                        const SizedBox(width: 10),
                                      Expanded(
                                          child: OutlinedButton(
                                              onPressed: () =>
                                                  _showDetail(ctx, d),
                                              style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12)),
                                              child:
                                                  const Text('View Details'))),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: C.red),
                                        onPressed: () => showDialog(context: ctx, builder: (c) => AlertDialog(
                                          title: const Text('Delete Doctor'),
                                          content: const Text('Are you sure you want to completely remove this doctor?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                                            Btn(label: 'Delete', color: C.red, width: 80, onTap: () { Navigator.pop(c); _delete(d['id'].toString()); })
                                          ]
                                        ))
                                      )
                                    ]),
                                  ]));
                        })),
      ]));
  void _showDetail(BuildContext ctx, Map d) => showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
            title: Text(d['name']?.toString() ?? ''),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row('Specialty', d['specialty']?.toString() ?? ''),
                  _Row('Email', d['email']?.toString() ?? ''),
                  _Row('Phone', d['phone']?.toString() ?? ''),
                  _Row('Experience', '${d['patients']} patients served'),
                  _Row('Rating', '${d['rating']} / 5.0'),
                  _Row('Fee', '\$${d['fee']} per visit'),
                  _Row('Joined', d['joined']?.toString() ?? ''),
                  _Row('Status', d['status']?.toString() ?? ''),
                ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'))
            ],
          ));

  void _addDoctorDlg(BuildContext ctx) {
    final fk = GlobalKey<FormState>();
    final nc = TextEditingController(), phc = TextEditingController(), ec = TextEditingController(), pc = TextEditingController(), lc = TextEditingController(), exc = TextEditingController();
    int? selSpec;
    showDialog(
      context: ctx,
      builder: (dlg) => StatefulBuilder(builder: (dlg, set) {
        bool ld = false;
        return AlertDialog(
          title: const Text('Add Doctor'),
          content: Form(
            key: fk,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Inp(label: 'Full Name', hint: 'Dr. John', ctrl: nc, validator: V.req),
                const SizedBox(height: 12),
                Inp(label: 'Email', hint: 'doc@mail.com', ctrl: ec, validator: V.req),
                const SizedBox(height: 12),
                Inp(label: 'Phone', hint: '123456', ctrl: phc, validator: V.req),
                const SizedBox(height: 12),
                Inp(label: 'Password', hint: '***', ctrl: pc, pwd: true, validator: V.req),
                const SizedBox(height: 12),
                Inp(label: 'License', hint: 'LIC-123', ctrl: lc, validator: V.req),
                const SizedBox(height: 12),
                Inp(label: 'Experience (Years)', hint: '5', ctrl: exc, kb: TextInputType.number, validator: V.req),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selSpec,
                  decoration: const InputDecoration(labelText: 'Specialty'),
                  items: _specs.map((s) => DropdownMenuItem<int>(value: s['id'], child: Text(s['name']))).toList(),
                  onChanged: (v) => set(() => selSpec = v),
                  validator: (v) => v == null ? 'Required' : null,
                )
              ])
            )
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dlg), child: const Text('Cancel')),
            Btn(label: ld ? '' : 'Create', width: 100, loading: ld, onTap: () async {
              if(!fk.currentState!.validate()) return;
              set(() => ld = true);
              try {
                await Api.createDoctor({
                  'fullName': nc.text.trim(),
                  'email': ec.text.trim(),
                  'phone': phc.text.trim(),
                  'password': pc.text.trim(),
                  'licenseNumber': lc.text.trim(),
                  'experienceYears': int.tryParse(exc.text.trim()) ?? 0,
                  'specialtyId': selSpec,
                  'status': 'active'
                });
                _load();
                if (dlg.mounted) Navigator.pop(dlg);
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Doctor created successfully!')));
              } catch(e) {
                if(ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
              }
              set(() => ld = false);
            })
          ],
        );
      })
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info(this.icon, this.text);
  @override
  Widget build(BuildContext ctx) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: C.t3),
        const SizedBox(width: 4),
        Text(text, style: small),
      ]);
}

class _Row extends StatelessWidget {
  final String k, v;
  const _Row(this.k, this.v);
  @override
  Widget build(BuildContext ctx) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
            width: 90,
            child: Text(k, style: small.copyWith(fontWeight: FontWeight.w600))),
        Expanded(child: Text(v, style: body.copyWith(fontSize: 13))),
      ]));
}

// ════════════════════ MANAGE PATIENTS ════════════════════════════════════════
class ManagePatients extends StatefulWidget {
  const ManagePatients({super.key});
  @override
  State<ManagePatients> createState() => _MP();
}

class _MP extends State<ManagePatients> {
  List<Map> _all = [], _shown = [];
  bool loading = true;
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.getPatients();
      setState(() {
        _all = (r['patients'] as List?)?.cast<Map>() ?? [];
        _shown = _all;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _apply() {
    final q = _search.text.trim().toLowerCase();
    setState(() => _shown = q.isEmpty
        ? _all
        : _all
            .where((p) =>
                (p['name']?.toString().toLowerCase().contains(q) ?? false) ||
                (p['email']?.toString().toLowerCase().contains(q) ?? false))
            .toList());
  }

  @override
  Widget build(BuildContext ctx) => AdminLayout(
      cur: 3,
      title: 'Manage Patients',
      subtitle: '${_all.length} registered patients',
      body: Column(children: [
        Container(
            color: C.card,
            padding: const EdgeInsets.all(14),
            child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                    hintText: 'Search patients...',
                    prefixIcon: Icon(Icons.search, size: 18, color: C.t3)),
                onChanged: (_) => _apply())),
        Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _shown.isEmpty
                    ? const Empty(
                        icon: Icons.people_outline, msg: 'No patients found')
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _shown.length,
                        itemBuilder: (_, i) {
                          final p = _shown[i];
                          return MCard(
                              pad: const EdgeInsets.all(14),
                              child: Row(children: [
                                Av(p['name']?.toString() ?? '', r: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(p['name']?.toString() ?? '',
                                          style: h5),
                                      Text(p['email']?.toString() ?? '',
                                          style: small),
                                      Text(
                                          'Age: ${p['age']} · Blood: ${p['blood_type']} · ${p['appointments']} appointments',
                                          style: small),
                                    ])),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Badge('active'),
                                      const SizedBox(height: 6),
                                      Text(
                                          'Since ${p['joined']?.toString().substring(0, 7) ?? ''}',
                                          style: small),
                                    ]),
                              ]));
                        })),
      ]));
}

// ════════════════════ ADMIN PAYMENTS ═════════════════════════════════════════
class AdminPayments extends StatefulWidget {
  const AdminPayments({super.key});
  @override
  State<AdminPayments> createState() => _AP();
}

class _AP extends State<AdminPayments> {
  Map? d;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.adminPayments();
      if (mounted)
        setState(() {
          d = r;
          loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final txns = (d?['transactions'] as List?)?.cast<Map>() ?? [];
    return AdminLayout(
        cur: 4,
        title: 'Payment Management',
        subtitle: 'Platform revenue and transactions',
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(builder: (c, box) {
                final mob = box.maxWidth < 720;
                return SingleChildScrollView(
                    padding: EdgeInsets.all(mob ? 14 : 24),
                    child: Column(children: [
                      GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: mob ? 2 : 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: mob ? 1.4 : 1.2,
                          children: [
                            StatTile(
                                icon: Icons.attach_money,
                                value:
                                    '\$${(d?['total_revenue'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'Total Revenue',
                                ic: C.green,
                                ib: C.greenLt),
                            StatTile(
                                icon: Icons.calendar_month,
                                value:
                                    '\$${(d?['this_month'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'This Month',
                                ic: C.primary,
                                ib: C.primaryLt),
                            StatTile(
                                icon: Icons.hourglass_empty,
                                value:
                                    '\$${(d?['pending'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'Pending',
                                ic: C.amber,
                                ib: C.amberLt),
                          ]),
                      const SizedBox(height: 16),
                      SecCard(
                          title: 'All Transactions',
                          child: txns.isEmpty
                              ? const Empty(
                                  icon: Icons.receipt_long_outlined,
                                  msg: 'No transactions')
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(12),
                                  itemCount: txns.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) {
                                    final t = txns[i];
                                    return ListTile(
                                        dense: true,
                                        leading: Av(
                                            t['patient']?.toString() ?? '',
                                            r: 20),
                                        title: Text(
                                            '${t['patient']} → Dr. ${t['doctor']}',
                                            style: h5.copyWith(fontSize: 13)),
                                        subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${t['specialty']} · ${t['date']}',
                                                  style: small),
                                              Text(
                                                  t['method']?.toString() ?? '',
                                                  style: small.copyWith(
                                                      color: C.t3)),
                                            ]),
                                        trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                  '\$${(t['amount'] ?? 0.0).toStringAsFixed(0)}',
                                                  style: h5.copyWith(
                                                      color: C.green)),
                                              Badge(t['status']?.toString() ??
                                                  'paid'),
                                            ]));
                                  })),
                    ]));
              }));
  }
}
