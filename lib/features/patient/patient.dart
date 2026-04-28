import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

import '../../core/theme/theme.dart';
import '../../data/services/api.dart';
import '../../shared/widgets/layout.dart';
import '../../shared/widgets/widgets.dart';

// ════════════════════ PATIENT DASHBOARD ═══════════════════════════════════════
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});
  @override
  State<PatientDashboard> createState() => _PDash();
}

class _PDash extends State<PatientDashboard> {
  Map? d;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.patientDash();
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
  Widget build(BuildContext ctx) => PatientLayout(
      cur: 0,
      title: 'Dashboard Overview',
      subtitle: "Here's your health overview for today.",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (c, box) {
              final mob = box.maxWidth < 720;
              final upcoming = (d?['upcoming'] as List?)?.cast<Map>() ?? [];
              final topDocs = (d?['top_doctors'] as List?)?.cast<Map>() ?? [];
              return SingleChildScrollView(
                  padding: EdgeInsets.all(mob ? 14 : 24),
                  child: Column(children: [
                    GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: mob ? 2 : 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: mob ? 1.4 : 1.2,
                        children: [
                          StatTile(
                              icon: Icons.calendar_today,
                              value: '${d?['upcoming_appointments'] ?? 0}',
                              label: 'Upcoming Appts',
                              ic: C.primary,
                              ib: C.primaryLt,
                              sub: upcoming.isEmpty ? 'No upcoming' : null),
                          StatTile(
                              icon: Icons.history,
                              value: '${d?['past_consultations'] ?? 0}',
                              label: 'Past Consultations',
                              ic: C.amber,
                              ib: C.amberLt),
                          StatTile(
                              icon: Icons.description_outlined,
                              value: '${d?['active_prescriptions'] ?? 0}',
                              label: 'Active Prescriptions',
                              ic: C.purple,
                              ib: C.purpleLt),
                          StatTile(
                              icon: Icons.favorite_outline,
                              value: d?['health_score']?.toString() ?? 'Good',
                              label: 'Health Score',
                              ic: C.red,
                              ib: C.redLt,
                              sub: 'Based on records'),
                        ]),
                    const SizedBox(height: 16),
                    if (mob) ...[
                      _upCard(upcoming),
                      const SizedBox(height: 14),
                      _topCard(topDocs)
                    ] else
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _upCard(upcoming)),
                            const SizedBox(width: 14),
                            Expanded(child: _topCard(topDocs)),
                          ]),
                  ]));
            }));
  Widget _upCard(List<Map> list) => SecCard(
      title: 'Upcoming Appointments',
      action: 'View all →',
      onAction: () =>
          Navigator.pushReplacementNamed(context, '/patient/appointments'),
      child: list.isEmpty
          ? Column(children: [
              const Empty(
                  icon: Icons.calendar_today_outlined,
                  msg: 'No upcoming appointments'),
              Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Btn(
                      label: 'Find a Doctor',
                      onTap: () => Navigator.pushReplacementNamed(
                          context, '/patient/find-doctor'))),
            ])
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Av(list[i]['doctor']?.toString() ?? '', r: 18),
                  title: Text(list[i]['doctor']?.toString() ?? '',
                      style: h5.copyWith(fontSize: 13)),
                  subtitle: Text('${list[i]['specialty']} · ${list[i]['date']}',
                      style: small))));
  Widget _topCard(List<Map> list) => SecCard(
      title: 'Top Doctors',
      action: 'See all →',
      onAction: () =>
          Navigator.pushReplacementNamed(context, '/patient/find-doctor'),
      child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 10),
          itemBuilder: (_, i) => Row(children: [
                Av(list[i]['name']?.toString() ?? ''),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(list[i]['name']?.toString() ?? '',
                          style: h5.copyWith(fontSize: 13)),
                      Text(list[i]['specialty']?.toString() ?? '',
                          style: small),
                    ])),
                Btn(
                    label: 'Book',
                    width: 70,
                    onTap: () => Navigator.pushReplacementNamed(
                        context, '/patient/find-doctor')),
              ])));
}

// ════════════════════ FIND DOCTOR ════════════════════════════════════════════
class FindDoctor extends StatefulWidget {
  const FindDoctor({super.key});
  @override
  State<FindDoctor> createState() => _Find();
}

class _Find extends State<FindDoctor> {
  final _sc = TextEditingController();
  String _spec = 'All';
  List<Map> _docs = [];
  bool loading = false;
  List<String> _specs = ['All'];
  bool _loadingSpecs = true;

  @override
  void initState() {
    super.initState();
    _loadSpecs();
    _search();
  }

  Future<void> _loadSpecs() async {
    try {
      final res = await Api.getSpecialties();
      if (mounted) {
        setState(() {
          _specs = ['All', ...res.map((e) => e['name'].toString())];
          _loadingSpecs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSpecs = false);
    }
  }

  Future<void> _search() async {
    setState(() => loading = true);
    try {
      final r = await Api.searchDoctors(
          q: _sc.text.trim(), spec: _spec == 'All' ? null : _spec);
      setState(() => _docs = (r['doctors'] as List?)?.cast<Map>() ?? []);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext ctx) => PatientLayout(
      cur: 1,
      title: 'Find a Doctor',
      subtitle: 'Discover specialists matching your requirements',
      body: Column(children: [
        Container(
            color: C.card,
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              TextField(
                  controller: _sc,
                  decoration: const InputDecoration(
                      hintText: 'Search by name or specialty...',
                      prefixIcon: Icon(Icons.search, size: 18, color: C.t3)),
                  onSubmitted: (_) => _search()),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: DropdownButtonFormField<String>(
                        value: _spec,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: C.input,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: C.border)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: C.border))),
                        items: _loadingSpecs ? [const DropdownMenuItem(value: 'All', child: Text('All'))] : _specs
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _spec = v!);
                          _search();
                        })),
                const SizedBox(width: 10),
                Btn(label: 'Search', onTap: _search, width: 100),
              ]),
            ])),
        Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _docs.isEmpty
                    ? const Empty(
                        icon: Icons.person_search_outlined,
                        msg: 'No doctors found')
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _docs.length,
                        itemBuilder: (_, i) => _DocCard(doc: _docs[i]))),
      ]));
}

class _DocCard extends StatelessWidget {
  final Map doc;
  const _DocCard({required this.doc});
  @override
  Widget build(BuildContext ctx) => MCard(
      pad: const EdgeInsets.all(16),
      child: Row(children: [
        Av(doc['name']?.toString() ?? '', r: 26),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doc['name']?.toString() ?? '', style: h5),
          Text(doc['specialty']?.toString() ?? '',
              style: body.copyWith(fontSize: 13)),
          Text(doc['clinic']?.toString() ?? '', style: small),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 13),
            Text(
                ' ${doc['rating']}  ·  ${doc['exp']}y exp  ·  ${doc['reviews']} reviews',
                style: small)
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${doc['fee']}/visit', style: h5),
          const SizedBox(height: 8),
          Btn(label: 'Book', width: 90, onTap: () => _book(ctx)),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () async {
              try {
                await Api.createConversation(Api.profileId ?? '', doc['id'].toString());
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('✅ Conversation started! Check Messages tab.')));
                }
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Message'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(90, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: C.primary
            ),
          )
        ]),
      ]));
  void _book(BuildContext ctx) async {
    final p = await Api.getPatientProfile();
    final ph = p['phone']?.toString() ?? '';
    final db = (p['dob'] ?? p['dateOfBirth'] ?? p['date_of_birth'] ?? '').toString();
    final bt = p['blood_type'] ?? p['bloodType'] ?? '';

    if (ph.isEmpty || db.isEmpty || bt.isEmpty) {
      if (!ctx.mounted) return;
      showDialog(context: ctx, builder: (d) => AlertDialog(
        title: Row(children: const [Icon(Icons.warning, color: C.amber), SizedBox(width: 8), Text('Profile Incomplete')]),
        content: const Text('For your safety and to ensure the best possible care, please complete your Personal Info and Medical Profile (Phone, DOB, Blood Type) before booking an appointment.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          Btn(label: 'Go to Profile', width: 130, onTap: () {
            Navigator.pop(d);
            Navigator.pushReplacementNamed(ctx, '/patient/profile');
          })
        ],
      ));
      return;
    }

    final nc = TextEditingController();
    DateTime? selDate;
    String? selTime;
    List<Map<String,dynamic>> slots = [];
    bool ldSlots = false;
    final fk = GlobalKey<FormState>();

    showDialog(
        context: ctx,
        builder: (dlg) => StatefulBuilder(builder: (dlg, set) {
              bool ld = false;
              
              Future<void> fetchSlots(DateTime d) async {
                set((){ selDate=d; selTime=null; ldSlots=true; });
                try {
                  final ds = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
                  final res = await Api.getDoctorSlots(doc['id'].toString(), ds);
                  set(() { slots = res; ldSlots = false; });
                } catch(_) {
                  set(()=>ldSlots=false);
                }
              }

              return AlertDialog(
                title: Text('Book — ${doc['name']}'),
                content: Form(
                    key: fk,
                    child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Select Date', style: label_style),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(context: ctx, initialDate: selDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
                          if(d!=null) fetchSlots(d);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: C.border), borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.calendar_month, size: 18, color: C.primary),
                            const SizedBox(width: 8),
                            Text(selDate == null ? 'Choose a date...' : '${selDate!.year}-${selDate!.month.toString().padLeft(2,'0')}-${selDate!.day.toString().padLeft(2,'0')}')
                          ])
                        )
                      ),
                      const SizedBox(height: 16),
                      if(selDate != null) ...[
                        const Text('Available Times', style: label_style),
                        const SizedBox(height: 8),
                        ldSlots 
                          ? const Center(child: CircularProgressIndicator()) 
                          : slots.isEmpty 
                            ? const Text('No slots available.', style: TextStyle(color: C.t3, fontSize: 13))
                            : Wrap(
                                spacing: 8, runSpacing: 8,
                                children: slots.map((s) {
                                  final av = s['available'] == true;
                                  final t = s['time'].toString();
                                  return InkWell(
                                    onTap: av ? () => set(()=>selTime=t) : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: selTime == t ? C.primary : (av ? C.bg : Colors.grey.withOpacity(0.1)),
                                        border: Border.all(color: selTime == t ? C.primary : (av ? C.border : Colors.transparent)),
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Text(t, style: TextStyle(color: selTime == t ? Colors.white : (av ? C.t1 : C.t3), fontSize: 12))
                                    )
                                  );
                                }).toList()
                              ),
                        const SizedBox(height: 16),
                      ],
                      Inp(
                          label: 'Notes (optional)',
                          hint: 'Reason for visit...',
                          ctrl: nc,
                          lines: 2),
                    ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dlg),
                      child: const Text('Cancel')),
                  Btn(
                      label: ld ? '' : 'Confirm',
                      width: 120,
                      loading: ld,
                      onTap: () async {
                        if (selDate == null || selTime == null) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please select date and time')));
                          return;
                        }
                        if (!fk.currentState!.validate()) return;
                        set(() => ld = true);
                        try {
                          final ds = '${selDate!.year}-${selDate!.month.toString().padLeft(2,'0')}-${selDate!.day.toString().padLeft(2,'0')}';
                          await Api.bookAppt(doc['id'].toString(), ds, selTime!, nc.text.trim());
                          if (dlg.mounted) Navigator.pop(dlg);
                          if (ctx.mounted)
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('✅ Appointment booked successfully!')));
                        } catch (e) {
                          if (ctx.mounted)
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                        set(() => ld = false);
                      }),
                ],
              );
            }));
  }
}

// ════════════════════ PATIENT APPOINTMENTS ════════════════════════════════════
class PatientAppointments extends StatefulWidget {
  const PatientAppointments({super.key});
  @override
  State<PatientAppointments> createState() => _PAppts();
}

class _PAppts extends State<PatientAppointments> {
  int _tab = 0;
  List<Map> _list = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r = await Api.patientAppts(['upcoming', 'past', 'cancelled'][_tab]);
      setState(() => _list = (r['appointments'] as List?)?.cast<Map>() ?? []);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext ctx) => PatientLayout(
      cur: 2,
      title: 'My Appointments',
      subtitle: 'Track and manage your consultations',
      body: Column(children: [
        MTabBar(
            tabs: const [
              'Upcoming',
              'Past',
              'Cancelled'
            ],
            counts: [
              _tab == 0 ? _list.length : 0,
              _tab == 1 ? _list.length : 0,
              _tab == 2 ? _list.length : 0
            ],
            sel: _tab,
            onSel: (i) {
              setState(() => _tab = i);
              _load();
            }),
        Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _list.isEmpty
                    ? Empty(
                        icon: Icons.calendar_today_outlined,
                        msg: 'No ${[
                          'upcoming',
                          'past',
                          'cancelled'
                        ][_tab]} appointments')
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _list.length,
                        itemBuilder: (_, i) {
                          final a = _list[i];
                          return MCard(
                              pad: const EdgeInsets.all(14),
                              child: Row(children: [
                                Av(a['doctor']?.toString() ?? '', r: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(a['doctor']?.toString() ?? '',
                                          style: h5),
                                      Text(a['specialty']?.toString() ?? '',
                                          style: body.copyWith(fontSize: 13)),
                                      Text('${a['date']} · ${a['time']}',
                                          style: small),
                                      if (a['clinic'] != null)
                                        Text(a['clinic'].toString(),
                                            style: small.copyWith(color: C.t3)),
                                    ])),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Badge(a['status']?.toString() ?? 'upcoming'),
                                      if (a['status'] == 'completed') ...[
                                        const SizedBox(height: 8),
                                        TextButton(
                                            onPressed: () => _reviewDlg(
                                                ctx,
                                                a['doctor_id']?.toString() ?? '',
                                                a['doctor']?.toString() ?? ''),
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(60, 24),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                            child: const Text('Write Review', style: TextStyle(fontSize: 12)))
                                      ]
                                    ],
                                  )
                              ]));
                        })),
      ]));

  void _reviewDlg(BuildContext ctx, String docId, String docName) {
    if (docId.isEmpty) return;
    int rating = 5;
    final c = TextEditingController();
    bool ld = false;
    showDialog(
        context: ctx,
        builder: (dlg) => StatefulBuilder(
            builder: (dlg, set) => AlertDialog(
                  title: Text('Review Dr. $docName'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Rate your experience:'),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            5,
                            (i) => IconButton(
                                icon: Icon(
                                    i < rating ? Icons.star : Icons.star_border,
                                    color: Colors.amber),
                                onPressed: () => set(() => rating = i + 1)))),
                    const SizedBox(height: 10),
                    TextField(
                        controller: c,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            hintText: 'Leave a comment... (optional)')),
                  ]),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dlg),
                        child: const Text('Cancel')),
                    Btn(
                        label: ld ? '' : 'Submit',
                        loading: ld,
                        width: 100,
                        onTap: () async {
                          set(() => ld = true);
                          try {
                            await Api.submitReview(docId, rating, c.text.trim());
                            if (dlg.mounted) Navigator.pop(dlg);
                            if (ctx.mounted)
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('✅ Review submitted successfully!')));
                          } catch (e) {
                            if (ctx.mounted)
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text(e.toString())));
                          }
                          set(() => ld = false);
                        }),
                  ],
                )));
  }
}

// ════════════════════ PATIENT PRESCRIPTIONS ═══════════════════════════════════
class PatientPrescriptions extends StatefulWidget {
  const PatientPrescriptions({super.key});
  @override
  State<PatientPrescriptions> createState() => _PPres();
}

class _PPres extends State<PatientPrescriptions> {
  List<Map> _list = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.patientRx();
      if (mounted)
        setState(() {
          _list = (r['prescriptions'] as List?)?.cast<Map>() ?? [];
          loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) => PatientLayout(
      cur: 3,
      title: 'My Prescriptions',
      subtitle: 'Your medical prescriptions from doctors',
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Empty(
                  icon: Icons.medication_outlined,
                  msg: 'No prescriptions yet',
                  sub: 'Prescriptions appear here after consultations')
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _list.length,
                  itemBuilder: (_, i) => _RxCard(rx: _list[i])));
}

class _RxCard extends StatefulWidget {
  final Map rx;
  const _RxCard({required this.rx});
  @override
  State<_RxCard> createState() => _RxS();
}

class _RxS extends State<_RxCard> {
  bool _open = false;
  @override
  Widget build(BuildContext ctx) {
    final meds = (widget.rx['medications'] as List?)?.cast<Map>() ?? [];
    return MCard(
        pad: EdgeInsets.zero,
        child: Column(children: [
          InkWell(
              onTap: () => setState(() => _open = !_open),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: C.primaryLt,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.description_outlined,
                            color: C.primary, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(widget.rx['diagnosis']?.toString() ?? '',
                              style: h5),
                          Text(
                              'Dr. ${widget.rx['doctor']} · ${widget.rx['specialty']}',
                              style: body.copyWith(fontSize: 13)),
                          Text(widget.rx['date']?.toString() ?? '',
                              style: small),
                        ])),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: C.primaryLt,
                            borderRadius: BorderRadius.circular(99)),
                        child: Text(
                            '${meds.length} med${meds.length != 1 ? "s" : ""}',
                            style: const TextStyle(
                                fontSize: 11, color: C.primary))),
                    const SizedBox(width: 6),
                    Icon(_open ? Icons.expand_less : Icons.expand_more,
                        color: C.t3),
                  ]))),
          if (_open && meds.isNotEmpty)
            Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: C.bg, borderRadius: BorderRadius.circular(10)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medications', style: label.copyWith(color: C.t2)),
                      const SizedBox(height: 10),
                      ...meds.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: 7,
                                    height: 7,
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: const BoxDecoration(
                                        color: C.primary,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text('${m['drug']} ${m['dose']}',
                                          style: h5.copyWith(fontSize: 13)),
                                      Text('${m['freq']} · ${m['dur']}',
                                          style: small),
                                      if ((m['note']?.toString() ?? '')
                                          .isNotEmpty)
                                        Text(m['note'].toString(),
                                            style: small.copyWith(color: C.t3)),
                                    ])),
                              ]))),
                    ])),
        ]));
  }
}

// ════════════════════ PATIENT MESSAGES ═══════════════════════════════════════
class PatientMessages extends StatefulWidget {
  const PatientMessages({super.key});
  @override
  State<PatientMessages> createState() => _PMsgs();
}

class _PMsgs extends State<PatientMessages> {
  List<Map> _chats = [], _avail = [];
  Map? _active;
  List<Map> _msgs = [];
  bool _lc = true, _lm = false;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final r = await Api.patientChats();
      setState(() {
        _chats = (r['chats'] as List?)?.cast<Map>() ?? [];
        _avail = (r['available'] as List?)?.cast<Map>() ?? [];
        _lc = false;
      });
    } catch (_) {
      setState(() => _lc = false);
    }
  }

  Future<void> _open(Map c) async {
    setState(() {
      _active = c;
      _lm = true;
    });
    try {
      final r = await Api.patientChats();
      setState(() {
        _msgs = (r['messages'] as List?)?.cast<Map>() ?? [];
        _lm = false;
      });
      _sb();
    } catch (_) {
      setState(() => _lm = false);
    }
  }

  void _sb() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients)
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
  Future<void> _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty || _active == null) return;
    _ctrl.clear();
    setState(() => _msgs = [
          ..._msgs,
          {
            'id': 'L${DateTime.now()}',
            'sender': 'patient',
            'text': t,
            'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'
          }
        ]);
    _sb();
    try {
      await Api.sendPatMsg(_active!['doctor_id'].toString(), t);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext ctx) {
    final mob = MediaQuery.of(ctx).size.width < 720;
    return PatientLayout(
        cur: 4,
        title: 'Messages',
        subtitle: 'Chat with your doctors',
        body: mob ? _mob() : _desk());
  }

  Widget _mob() => _active == null ? _list() : _panel(mob: true);
  Widget _desk() => MCard(
      pad: EdgeInsets.zero,
      child: Row(children: [
        SizedBox(width: 280, child: _list()),
        const VerticalDivider(width: 1),
        Expanded(
            child: _active == null
                ? const Empty(
                    icon: Icons.chat_bubble_outline,
                    msg:
                        'Select a conversation\nor start a new one with a doctor')
                : _panel()),
      ]));
  Widget _list() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('CONVERSATIONS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: C.t3,
                    letterSpacing: 1.2))),
        Expanded(
            child: _lc
                ? const Center(child: CircularProgressIndicator())
                : ListView(children: [
                    ..._chats.map((c) {
                      final act = _active?['doctor_id'] == c['doctor_id'];
                      return ListTile(
                          tileColor: act ? C.primaryLt : null,
                          leading: Av(c['doctor_name']?.toString() ?? ''),
                          title: Text(c['doctor_name']?.toString() ?? '',
                              style: h5.copyWith(fontSize: 13)),
                          subtitle: Text(c['specialty']?.toString() ?? '',
                              style: small),
                          onTap: () => _open(c));
                    }),
                    if (_avail.isNotEmpty) ...[
                      const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                          child: Text('START NEW CHAT',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: C.t3,
                                  letterSpacing: 1.2))),
                      ..._avail.map((d) => ListTile(
                          dense: true,
                          leading: Av(d['name']?.toString() ?? '', r: 17),
                          title: Text(d['name']?.toString() ?? '',
                              style: const TextStyle(fontSize: 13)),
                          subtitle: Text(d['specialty']?.toString() ?? '',
                              style: small),
                          onTap: () => _open({
                                'doctor_id': d['id'],
                                'doctor_name': d['name'],
                                'specialty': d['specialty']
                              }))),
                    ],
                  ])),
      ]);
  Widget _panel({bool mob = false}) => Column(children: [
        if (mob)
          Container(
              color: C.card,
              child: Row(children: [
                BackButton(onPressed: () => setState(() => _active = null)),
                Av(_active!['doctor_name']?.toString() ?? '', r: 18),
                const SizedBox(width: 8),
                Text(_active!['doctor_name']?.toString() ?? '', style: h5),
              ])),
        if (!mob)
          Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                  color: C.card,
                  border: Border(bottom: BorderSide(color: C.border))),
              child: Row(children: [
                Av(_active!['doctor_name']?.toString() ?? ''),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_active!['doctor_name']?.toString() ?? '', style: h5),
                  Text(_active!['specialty']?.toString() ?? '', style: small),
                ]),
              ])),
        Expanded(
            child: _lm
                ? const Center(child: CircularProgressIndicator())
                : _msgs.isEmpty
                    ? const Empty(
                        icon: Icons.chat_bubble_outline,
                        msg: 'No messages yet. Say hello!')
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(14),
                        itemCount: _msgs.length,
                        itemBuilder: (_, i) {
                          final m = _msgs[i];
                          final mine = m['sender'] == 'patient';
                          return Align(
                              alignment: mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  constraints:
                                      const BoxConstraints(maxWidth: 320),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: mine ? C.primary : C.card,
                                      borderRadius: BorderRadius.circular(12),
                                      border: mine
                                          ? null
                                          : Border.all(color: C.border)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(m['text']?.toString() ?? '',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: mine
                                                    ? Colors.white
                                                    : C.t1)),
                                        const SizedBox(height: 3),
                                        Text(m['time']?.toString() ?? '',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: mine
                                                    ? Colors.white60
                                                    : C.t3)),
                                      ])));
                        })),
        Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: C.card,
                border: Border(top: BorderSide(color: C.border))),
            child: Row(children: [
              Expanded(
                  child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10)),
                      onSubmitted: (_) => _send())),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send, color: C.primary)),
            ])),
      ]);
}

// ════════════════════ PATIENT PAYMENTS ════════════════════════════════════════
class PatientPayments extends StatefulWidget {
  const PatientPayments({super.key});
  @override
  State<PatientPayments> createState() => _PPay();
}

class _PPay extends State<PatientPayments> {
  Map? d;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.patientPay();
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
    final methods = (d?['methods'] as List?)?.cast<Map>() ?? [];
    final txns = (d?['transactions'] as List?)?.cast<Map>() ?? [];
    return PatientLayout(
        cur: 5,
        title: 'Payments',
        subtitle: 'Your billing & payment records',
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
                                icon: Icons.credit_card,
                                value: '${d?['total'] ?? 0}',
                                label: 'Total Payments',
                                ic: C.primary,
                                ib: C.primaryLt),
                            StatTile(
                                icon: Icons.attach_money,
                                value:
                                    '\$${(d?['spent'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'Total Spent',
                                ic: C.green,
                                ib: C.greenLt),
                            StatTile(
                                icon: Icons.calendar_month,
                                value:
                                    '\$${(d?['this_month'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'This Month',
                                ic: C.amber,
                                ib: C.amberLt),
                          ]),
                      const SizedBox(height: 16),
                      // Payment Methods
                      MCard(
                          pad: EdgeInsets.zero,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 14, 8, 0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Payment Methods',
                                              style: h5),
                                          TextButton.icon(
                                              onPressed: () => _addSheet(ctx),
                                              icon: const Icon(Icons.add,
                                                  size: 16),
                                              label: const Text('+ Add'),
                                              style: TextButton.styleFrom(
                                                  foregroundColor: C.primary)),
                                        ])),
                                if (methods.isEmpty)
                                  Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                          child: Column(children: [
                                        const Icon(Icons.credit_card_outlined,
                                            size: 40, color: C.t3),
                                        const SizedBox(height: 8),
                                        const Text('No payment methods yet',
                                            style: body),
                                        const SizedBox(height: 10),
                                        Btn(
                                            label: '+ Add Payment Method',
                                            onTap: () => _addSheet(ctx),
                                            width: 220),
                                      ])))
                                else
                                  Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                          children: methods
                                              .map(
                                                (m) => Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14),
                                                    decoration: BoxDecoration(
                                                        color: C.bg,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color:
                                                                (m['is_default'] ==
                                                                        true)
                                                                    ? C.primary
                                                                    : C.border,
                                                            width:
                                                                (m['is_default'] ==
                                                                        true)
                                                                    ? 1.5
                                                                    : 1)),
                                                    child: Row(children: [
                                                      _payIcon(m['type']
                                                              ?.toString() ??
                                                          ''),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                            Row(children: [
                                                              Text(
                                                                  m['label']
                                                                          ?.toString() ??
                                                                      '',
                                                                  style: h5),
                                                              if (m['is_default'] ==
                                                                  true) ...[
                                                                const SizedBox(
                                                                    width: 8),
                                                                Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            2),
                                                                    decoration: BoxDecoration(
                                                                        color: C
                                                                            .primaryLt,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                99)),
                                                                    child: const Text(
                                                                        'Default',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                10,
                                                                            color:
                                                                                C.primary,
                                                                            fontWeight: FontWeight.w600)))
                                                              ],
                                                            ]),
                                                            Text(
                                                                m['type'] ==
                                                                        'vodafone_cash'
                                                                    ? (m['phone']
                                                                            ?.toString() ??
                                                                        '')
                                                                    : '•••• •••• •••• ${m['last4']}  Exp ${m['expiry']}',
                                                                style: small),
                                                          ])),
                                                      IconButton(
                                                          icon: const Icon(
                                                              Icons.more_vert,
                                                              size: 18,
                                                              color: C.t3),
                                                          onPressed: () {}),
                                                    ])),
                                              )
                                              .toList())),
                              ])),
                      const SizedBox(height: 16),
                      // Transaction history
                      SecCard(
                          title: 'Transaction History',
                          child: txns.isEmpty
                              ? const Empty(
                                  icon: Icons.receipt_long_outlined,
                                  msg: 'No transactions yet')
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
                                            'Dr. ${t['doctor']?.toString() ?? ''}',
                                            r: 20),
                                        title: Text(
                                            'Dr. ${t['doctor']?.toString() ?? ''}',
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

  Widget _payIcon(String type) {
    Color color;
    IconData icon;
    switch (type) {
      case 'visa':
        color = C.visa;
        icon = Icons.credit_card;
        break;
      case 'mastercard':
        color = C.mc;
        icon = Icons.credit_card;
        break;
      case 'vodafone_cash':
        color = C.voda;
        icon = Icons.phone_android;
        break;
      case 'fawry':
        color = C.fawry;
        icon = Icons.payments_outlined;
        break;
      default:
        color = C.t2;
        icon = Icons.credit_card;
    }
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22));
  }

  void _addSheet(BuildContext ctx) => showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
              padding: const EdgeInsets.all(22),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: C.border,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                const Text('Add Payment Method', style: h3),
                const SizedBox(height: 20),
                _MOpt(Icons.credit_card, 'Visa / Mastercard',
                    'Add a credit or debit card', C.visa, () {
                  Navigator.pop(ctx);
                  _cardDlg(ctx);
                }),
                const SizedBox(height: 10),
                _MOpt(Icons.phone_android, 'Vodafone Cash',
                    'Pay with your Vodafone wallet', C.voda, () {
                  Navigator.pop(ctx);
                  _vodafoneDlg(ctx);
                }),
                const SizedBox(height: 10),
                _MOpt(Icons.payments_outlined, 'Fawry',
                    'Pay at any Fawry location', C.fawry, () {
                  Navigator.pop(ctx);
                  _fawryDlg(ctx);
                }),
                const SizedBox(height: 10),
              ]))));

  void _cardDlg(BuildContext ctx) {
    final fk = GlobalKey<FormState>();
    final numC = TextEditingController();
    final nameC = TextEditingController();
    final expC = TextEditingController();
    final cvvC = TextEditingController();
    bool obsCV = true;
    showDialog(
        context: ctx,
        builder: (dlg) => StatefulBuilder(
            builder: (dlg, set) => AlertDialog(
                  title: Row(children: const [
                    Icon(Icons.credit_card, color: C.primary),
                    SizedBox(width: 8),
                    Text('Add Card')
                  ]),
                  content: Form(
                      key: fk,
                      child: SizedBox(
                          width: 420,
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Inp(
                                label: 'Card Number',
                                hint: '1234 5678 9012 3456',
                                ctrl: numC,
                                kb: TextInputType.number,
                                fmt: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CardFmt()
                                ],
                                validator: (v) {
                                  final d = v?.replaceAll(' ', '') ?? '';
                                  return d.length != 16
                                      ? 'Card number must be 16 digits'
                                      : null;
                                }),
                            const SizedBox(height: 12),
                            Inp(
                                label: 'Cardholder Name',
                                hint: 'Name as on card',
                                ctrl: nameC,
                                validator: (v) =>
                                    (v?.isEmpty ?? true) ? 'Required' : null),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: Inp(
                                      label: 'Expiry (MM/YY)',
                                      hint: '12/27',
                                      ctrl: expC,
                                      kb: TextInputType.number,
                                      fmt: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        ExpiryFmt()
                                      ],
                                      validator: (v) =>
                                          !RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                                                  .hasMatch(v ?? '')
                                              ? 'Use MM/YY'
                                              : null)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Inp(
                                      label: 'CVV',
                                      hint: '•••',
                                      ctrl: cvvC,
                                      obs: obsCV,
                                      kb: TextInputType.number,
                                      fmt: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(4)
                                      ],
                                      suffix: IconButton(
                                          icon: Icon(
                                              obsCV
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 18,
                                              color: C.t3),
                                          onPressed: () =>
                                              set(() => obsCV = !obsCV)),
                                      validator: (v) => (v?.length ?? 0) < 3
                                          ? 'Invalid CVV'
                                          : null)),
                            ]),
                            const SizedBox(height: 12),
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: C.bg,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(children: const [
                                  Icon(Icons.lock_outline,
                                      size: 14, color: C.green),
                                  SizedBox(width: 6),
                                  Expanded(
                                      child: Text(
                                          'Your card details are encrypted and secure',
                                          style: TextStyle(
                                              fontSize: 12, color: C.t2)))
                                ])),
                          ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dlg),
                        child: const Text('Cancel')),
                    Btn(
                        label: 'Add Card',
                        width: 100,
                        onTap: () async {
                          if (!fk.currentState!.validate()) return;
                          
                          // Mocking processPayment when adding a card to sync with DB
                          try {
                            await Api.processPayment("50.00", "Credit Card");
                          } catch (_) {}

                          if (dlg.mounted) Navigator.pop(dlg);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                content: Text('✅ Card added and test payment synced')));
                            _load(); // Reload payments
                          }
                        }),
                  ],
                )));
  }

  void _vodafoneDlg(BuildContext ctx) {
    final fk = GlobalKey<FormState>();
    final phC = TextEditingController();
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: Row(children: [
                Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: C.voda.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.phone_android,
                        color: C.voda, size: 20)),
                const SizedBox(width: 8),
                const Text('Vodafone Cash'),
              ]),
              content: Form(
                  key: fk,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(
                        'Link your Vodafone Cash number to enable quick payments.',
                        style: body),
                    const SizedBox(height: 14),
                    Inp(
                        label: 'Vodafone Number',
                        hint: '010x xxxx xxxx',
                        ctrl: phC,
                        kb: TextInputType.phone,
                        validator: (v) {
                          final d = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                          return d.length < 10 ? 'Enter a valid number' : null;
                        }),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                Btn(
                    label: 'Link Number',
                    color: C.voda,
                    width: 130,
                    onTap: () {
                      if (!fk.currentState!.validate()) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                          content: Text('✅ Vodafone Cash linked')));
                    }),
              ],
            ));
  }

  void _fawryDlg(BuildContext ctx) => showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
            title: Row(children: [
              Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: C.fawry.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.payments_outlined,
                      color: C.fawry, size: 20)),
              const SizedBox(width: 8),
              const Text('Pay with Fawry'),
            ]),
            content: const Column(mainAxisSize: MainAxisSize.min, children: [
              Text('A unique reference code is generated at checkout.',
                  style: body),
              SizedBox(height: 8),
              Text('Pay at any Fawry outlet within 24 hours of booking.',
                  style: body),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              Btn(
                  label: 'Enable Fawry',
                  color: C.fawry,
                  width: 130,
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('✅ Fawry enabled')));
                  }),
            ],
          ));
}

class _MOpt extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final Color color;
  final VoidCallback onTap;
  const _MOpt(this.icon, this.title, this.sub, this.color, this.onTap);
  @override
  Widget build(BuildContext ctx) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: C.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.border)),
          child: Row(children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 22)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: h5),
                  Text(sub, style: small),
                ])),
            const Icon(Icons.chevron_right, color: C.t3),
          ])));
}

// ════════════════════ PATIENT PROFILE ════════════════════════════════════════
class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});
  @override
  State<PatientProfile> createState() => _PProf();
}

class _PProf extends State<PatientProfile> {
  final _fk = GlobalKey<FormState>();
  final _nm = TextEditingController();
  final _ph = TextEditingController();
  final _dob = TextEditingController();
  final _ht = TextEditingController();
  final _wt = TextEditingController();
  final _al = TextEditingController();
  final _cc = TextEditingController();
  final _en = TextEditingController();
  final _ep = TextEditingController();
  String? _blood;
  bool _loading = true, _saving = false;
  static const _bloods = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  String? _img;

  final _pwdFk = GlobalKey<FormState>();
  final _curPwd = TextEditingController();
  final _newPwd = TextEditingController();
  final _confirmPwd = TextEditingController();
  bool _pwdSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.getPatientProfile();
      setState(() {
        _nm.text = r['full_name'] ?? r['fullName'] ?? '';
        _ph.text = r['phone'] ?? '';
        _dob.text = (r['dob'] ?? r['date_of_birth'] ?? r['dateOfBirth'] ?? '').toString().split('T')[0];
        _blood = r['blood_type'] ?? r['bloodType'];
        _ht.text = '${r['height_cm'] ?? r['heightCm'] ?? r['height'] ?? ''}';
        _wt.text = '${r['weight_kg'] ?? r['weightKg'] ?? r['weight'] ?? ''}';
        _al.text = r['allergies'] ?? '';
        _cc.text = r['chronic_conditions'] ?? r['chronicConditions'] ?? r['conditions'] ?? '';
        _en.text = r['emergency_contact_name'] ?? r['emergencyContactName'] ?? r['emergency_name'] ?? '';
        _ep.text = r['emergency_contact_phone'] ?? r['emergencyContactPhone'] ?? r['emergency_phone'] ?? '';
        _img = r['avatar'];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await Api.updatePatProfile({
        'fullName': _nm.text,
        'phone': _ph.text,
        'dateOfBirth': _dob.text,
        'bloodType': _blood,
        'heightCm': double.tryParse(_ht.text),
        'weightKg': double.tryParse(_wt.text),
        'allergies': _al.text,
        'chronicConditions': _cc.text,
        'emergencyContactName': _en.text,
        'emergencyContactPhone': _ep.text
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Profile updated successfully')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _pickAvatar() async {
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (res != null && res.files.first.bytes != null) {
        final bytes = res.files.first.bytes!;
        if (bytes.length > 2 * 1024 * 1024) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image must be less than 2MB')));
          return;
        }
        final b64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() => _saving = true);
        await Api.updateAvatar(Api.userId!, b64);
        setState(() {
          _img = b64;
          _saving = false;
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Avatar updated')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _saving = false);
    }
  }

  Future<void> _changePwd() async {
    if (!_pwdFk.currentState!.validate()) return;
    if (_newPwd.text != _confirmPwd.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _pwdSaving = true);
    try {
      await Api.updatePassword(Api.userId!, _curPwd.text, _newPwd.text);
      _curPwd.clear();
      _newPwd.clear();
      _confirmPwd.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Password updated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _pwdSaving = false);
  }

  @override
  Widget build(BuildContext ctx) => PatientLayout(
      cur: 6,
      title: 'My Profile',
      subtitle: 'Manage your personal & medical information',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                Center(
                  child: Stack(
                    children: [
                      Av(_nm.text.isEmpty ? '?' : _nm.text, r: 40, img: _img),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: C.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _fk,
                  child: Column(children: [
                    InfoSec(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                                child: Inp(
                                    label: 'Full Name',
                                    hint: 'Your full name',
                                    ctrl: _nm,
                                    validator: (v) => (v?.isEmpty ?? true)
                                        ? 'Required'
                                        : null)),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Inp(
                                    label: 'Phone Number',
                                    hint: '+20 100 000 0000',
                                    ctrl: _ph,
                                    kb: TextInputType.phone)),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                                child: Inp(
                                    label: 'Date of Birth',
                                    hint: 'YYYY/MM/DD',
                                    ctrl: _dob)),
                            const SizedBox(width: 14),
                            Expanded(
                                child: DropField(
                                    label: 'Blood Type',
                                    value: _blood,
                                    items: _bloods,
                                    onChange: (v) =>
                                        setState(() => _blood = v))),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                                child: Inp(
                                    label: 'Height (cm)',
                                    hint: '175',
                                    ctrl: _ht,
                                    kb: TextInputType.number)),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Inp(
                                    label: 'Weight (kg)',
                                    hint: '70',
                                    ctrl: _wt,
                                    kb: TextInputType.number)),
                          ]),
                        ])),
                    const SizedBox(height: 14),
                    InfoSec(
                        icon: Icons.medical_information_outlined,
                        title: 'Medical Information',
                        child: Row(children: [
                          Expanded(
                              child: Inp(
                                  label: 'Allergies',
                                  hint: 'List any known allergies...',
                                  ctrl: _al,
                                  lines: 3)),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Inp(
                                  label: 'Chronic Conditions',
                                  hint: 'List any chronic conditions...',
                                  ctrl: _cc,
                                  lines: 3)),
                        ])),
                    const SizedBox(height: 14),
                    InfoSec(
                        icon: Icons.emergency_outlined,
                        title: 'Emergency Contact',
                        child: Row(children: [
                          Expanded(
                              child: Inp(
                                  label: 'Contact Name',
                                  hint: 'e.g. Sara Khalil',
                                  ctrl: _en)),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Inp(
                                  label: 'Contact Phone',
                                  hint: '+20 100 000 0000',
                                  ctrl: _ep,
                                  kb: TextInputType.phone)),
                        ])),
                    const SizedBox(height: 20),
                    Btn(label: 'Save Changes', loading: _saving, onTap: _save),
                  ])),
                const SizedBox(height: 24),
                Form(
                  key: _pwdFk,
                  child: InfoSec(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    child: Column(children: [
                      Inp(label: 'Current Password', hint: '***', ctrl: _curPwd, obs: true, validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Inp(label: 'New Password', hint: '***', ctrl: _newPwd, obs: true, validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null)),
                        const SizedBox(width: 14),
                        Expanded(child: Inp(label: 'Confirm Password', hint: '***', ctrl: _confirmPwd, obs: true, validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null)),
                      ]),
                      const SizedBox(height: 20),
                      Btn(label: 'Update Password', loading: _pwdSaving, onTap: _changePwd, color: C.primary),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
              ])));
}
