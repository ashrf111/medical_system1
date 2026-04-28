import 'package:flutter/material.dart' hide Badge;

import '../../core/theme/theme.dart';
import '../../data/services/api.dart';
import '../../shared/widgets/layout.dart';
import '../../shared/widgets/widgets.dart';

// ════════════════════ DOCTOR DASHBOARD ════════════════════════════════════════
class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});
  @override
  State<DoctorDashboard> createState() => _DDash();
}

class _DDash extends State<DoctorDashboard> {
  Map? d;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.doctorDash();
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
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return DoctorLayout(
        cur: 0,
        title: 'Dashboard Overview',
        subtitle: '${months[now.month - 1]} ${now.day}, ${now.year}',
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(builder: (c, box) {
                final mob = box.maxWidth < 720;
                final schedule = (d?['schedule'] as List?)?.cast<Map>() ?? [];
                final upcoming = (d?['upcoming'] as List?)?.cast<Map>() ?? [];
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
                                icon: Icons.calendar_today,
                                value: '${d?['today_appointments'] ?? 0}',
                                label: "Today's Appts",
                                ic: C.primary,
                                ib: C.primaryLt),
                            StatTile(
                                icon: Icons.hourglass_empty,
                                value: '${d?['pending'] ?? 0}',
                                label: 'Pending',
                                ic: C.amber,
                                ib: C.amberLt),
                            StatTile(
                                icon: Icons.check_circle_outline,
                                value: '${d?['completed'] ?? 0}',
                                label: 'Completed',
                                ic: C.green,
                                ib: C.greenLt),
                            StatTile(
                                icon: Icons.attach_money,
                                value:
                                    '\$${(d?['this_month'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'This Month',
                                ic: C.green,
                                ib: C.greenLt),
                            StatTile(
                                icon: Icons.account_balance_wallet_outlined,
                                value:
                                    '\$${(d?['total_earned'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'Total Earned',
                                ic: C.purple,
                                ib: C.purpleLt),
                          ]),
                      const SizedBox(height: 16),
                      if (mob) ...[
                        _schedCard(schedule),
                        const SizedBox(height: 14),
                        _upCard(upcoming)
                      ] else
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _schedCard(schedule)),
                              const SizedBox(width: 14),
                              Expanded(child: _upCard(upcoming)),
                            ]),
                    ]));
              }));
  }

  Widget _schedCard(List<Map> list) => SecCard(
      title: "Today's Schedule",
      action: 'View all →',
      onAction: () =>
          Navigator.pushReplacementNamed(context, '/doctor/appointments'),
      child: list.isEmpty
          ? const Empty(
              icon: Icons.calendar_today_outlined, msg: 'No appointments today')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Av(list[i]['patient']?.toString() ?? '', r: 18),
                  title: Text(list[i]['patient']?.toString() ?? '',
                      style: h5.copyWith(fontSize: 13)),
                  subtitle:
                      Text(list[i]['time']?.toString() ?? '', style: small),
                  trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: C.primaryLt,
                          borderRadius: BorderRadius.circular(99)),
                      child: Text(list[i]['type']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 11, color: C.primary))))));
  Widget _upCard(List<Map> list) => SecCard(
      title: 'Upcoming',
      child: list.isEmpty
          ? const Empty(
              icon: Icons.event_outlined, msg: 'No upcoming appointments')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(list[i]['patient']?.toString() ?? '',
                      style: h5.copyWith(fontSize: 13)),
                  subtitle: Text('${list[i]['date']} at ${list[i]['time']}',
                      style: small))));
}

// ════════════════════ DOCTOR APPOINTMENTS ════════════════════════════════════
class DoctorAppointments extends StatefulWidget {
  const DoctorAppointments({super.key});
  @override
  State<DoctorAppointments> createState() => _DAppts();
}

class _DAppts extends State<DoctorAppointments> {
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
      final r = await Api.doctorAppts(['upcoming', 'past', 'cancelled'][_tab]);
      setState(() => _list = (r['appointments'] as List?)?.cast<Map>() ?? []);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext ctx) => DoctorLayout(
      cur: 1,
      title: 'Appointments',
      subtitle: 'Manage your patient appointments',
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
                                Av(a['patient']?.toString() ?? '', r: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(a['patient']?.toString() ?? '',
                                          style: h5),
                                      Text('${a['date']} · ${a['time']}',
                                          style: small),
                                      if (a['type'] != null)
                                        Text(a['type'].toString(),
                                            style: small.copyWith(color: C.t3)),
                                    ])),
                                Badge(a['status']?.toString() ?? 'upcoming'),
                              ]));
                        })),
      ]));
}

// ════════════════════ DOCTOR MY PATIENTS ═════════════════════════════════════
class DoctorPatients extends StatefulWidget {
  const DoctorPatients({super.key});
  @override
  State<DoctorPatients> createState() => _DPats();
}

class _DPats extends State<DoctorPatients> {
  final _sc = TextEditingController();
  List<Map> _list = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load([String? q]) async {
    setState(() => loading = true);
    try {
      final r = await Api.doctorPats(q);
      setState(() => _list = (r['patients'] as List?)?.cast<Map>() ?? []);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext ctx) => DoctorLayout(
      cur: 2,
      title: 'My Patients',
      subtitle: '${_list.length} unique patients',
      body: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            SizedBox(
                width: 340,
                child: TextField(
                    controller: _sc,
                    decoration: const InputDecoration(
                        hintText: 'Search patients by name...',
                        prefixIcon: Icon(Icons.search, size: 18, color: C.t3)),
                    onChanged: (v) => _load(v.isEmpty ? null : v))),
            const SizedBox(height: 14),
            Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : _list.isEmpty
                        ? const Empty(
                            icon: Icons.people_outline,
                            msg: 'No patients found',
                            sub:
                                'Patients appear here after their first appointment')
                        : ListView.builder(
                            itemCount: _list.length,
                            itemBuilder: (_, i) => MCard(
                                pad: const EdgeInsets.all(14),
                                child: Row(children: [
                                  Av(_list[i]['name']?.toString() ?? '', r: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(_list[i]['name']?.toString() ?? '',
                                            style: h5),
                                        Text(
                                            'Last visit: ${_list[i]['last_visit']}',
                                            style: small),
                                      ])),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: C.primaryLt,
                                          borderRadius:
                                              BorderRadius.circular(99)),
                                      child: Text(
                                          _list[i]['condition']?.toString() ??
                                              '',
                                          style: const TextStyle(
                                              fontSize: 11, color: C.primary))),
                                  const SizedBox(width: 8),
                                  IconButton(
                                      icon: const Icon(Icons.chat_bubble_outline, color: C.primary),
                                      onPressed: () async {
                                        try {
                                          await Api.createConversation(_list[i]['id'].toString(), Api.profileId ?? '');
                                          if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('✅ Conversation started!')));
                                        } catch(e) {
                                          if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                                        }
                                      })
                                ])))),
          ])));
}

// ════════════════════ DOCTOR PRESCRIPTIONS ═══════════════════════════════════
class DoctorPrescriptions extends StatefulWidget {
  const DoctorPrescriptions({super.key});
  @override
  State<DoctorPrescriptions> createState() => _DPresc();
}

class _DPresc extends State<DoctorPrescriptions> {
  final _fk = GlobalKey<FormState>();
  final _dxC = TextEditingController();
  String? _apptId;
  List<Map> _appts = [];
  List<_ME> _meds = [_ME()];
  bool _loadAppts = true, _sub = false;

  @override
  void initState() {
    super.initState();
    _loadA();
  }

  Future<void> _loadA() async {
    try {
      final r = await Api.doctorAppts('upcoming');
      setState(() {
        _appts = (r['appointments'] as List?)?.cast<Map>() ?? [];
        _loadAppts = false;
      });
    } catch (_) {
      setState(() => _loadAppts = false);
    }
  }

  Future<void> _submit() async {
    if (!_fk.currentState!.validate()) return;
    if (_apptId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select an appointment')));
      return;
    }
    setState(() => _sub = true);
    try {
      await Api.createRx(
          _apptId!,
          _dxC.text.trim(),
          _meds
              .map((m) => {
                    'drug_name': m.drug.text,
                    'dosage': m.dose.text,
                    'frequency': m.freq,
                    'duration': m.dur.text,
                    'instructions': m.instr.text
                  })
              .toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Prescription saved successfully')));
        setState(() {
          _dxC.clear();
          _meds = [_ME()];
          _apptId = null;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) setState(() => _sub = false);
  }

  @override
  Widget build(BuildContext ctx) => DoctorLayout(
      cur: 3,
      title: 'Write Prescription',
      subtitle: 'Create a digital prescription for your patient',
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Form(
              key: _fk,
              child: Column(children: [
                _sec(
                    'Select Appointment',
                    _loadAppts
                        ? const Center(child: CircularProgressIndicator())
                        : _appts.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                    'No upcoming appointments. Confirm appointments first.',
                                    style: body.copyWith(color: C.t3)))
                            : DropdownButtonFormField<String>(
                                value: _apptId,
                                hint: const Text('Select an appointment...'),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: C.input,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            const BorderSide(color: C.border)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            const BorderSide(color: C.border))),
                                items: _appts
                                    .map((a) => DropdownMenuItem(
                                        value: a['id']?.toString(),
                                        child: Text(
                                            '${a['patient']} — ${a['date']} ${a['time']}')))
                                    .toList(),
                                onChanged: (v) => setState(() => _apptId = v))),
                const SizedBox(height: 14),
                _sec(
                    'Diagnosis',
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                            controller: _dxC,
                            decoration: const InputDecoration(
                                hintText:
                                    'e.g. Hypertension, Type 2 Diabetes...'),
                            validator: (v) =>
                                (v?.isEmpty ?? true) ? 'Required' : null))),
                const SizedBox(height: 14),
                MCard(
                    pad: EdgeInsets.zero,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Medications', style: h5),
                                    TextButton.icon(
                                        onPressed: () =>
                                            setState(() => _meds.add(_ME())),
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('+ Add'),
                                        style: TextButton.styleFrom(
                                            foregroundColor: C.primary)),
                                  ])),
                          ...List.generate(
                              _meds.length,
                              (i) => _MedForm(
                                  i,
                                  _meds[i],
                                  _meds.length > 1
                                      ? () => setState(() => _meds.removeAt(i))
                                      : null)),
                        ])),
                const SizedBox(height: 20),
                Btn(label: 'Save Prescription', loading: _sub, onTap: _submit),
                const SizedBox(height: 20),
              ]))));
  Widget _sec(String title, Widget child) => MCard(
      pad: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title, style: h5)),
        child,
      ]));
}

class _ME {
  final drug = TextEditingController();
  final dose = TextEditingController();
  final dur = TextEditingController();
  final instr = TextEditingController();
  String? freq;
}

class _MedForm extends StatefulWidget {
  final int i;
  final _ME e;
  final VoidCallback? rm;
  const _MedForm(this.i, this.e, this.rm);
  @override
  State<_MedForm> createState() => _MFS();
}

class _MFS extends State<_MedForm> {
  @override
  Widget build(BuildContext ctx) => Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.i > 0) const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Medication #${widget.i + 1}',
              style: label.copyWith(color: C.t2)),
          if (widget.rm != null)
            IconButton(
                onPressed: widget.rm,
                icon: const Icon(Icons.remove_circle_outline,
                    color: C.red, size: 18),
                padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: Inp(
                  label: 'Drug Name *',
                  hint: 'e.g. Amoxicillin',
                  ctrl: widget.e.drug,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null)),
          const SizedBox(width: 12),
          Expanded(
              child: Inp(
                  label: 'Dosage *',
                  hint: 'e.g. 500mg',
                  ctrl: widget.e.dose,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Frequency', style: label),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                    value: widget.e.freq,
                    hint: const Text('Select...'),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: C.input,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: C.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: C.border))),
                    items: [
                      'Once daily',
                      'Twice daily',
                      'Three times daily',
                      'Four times daily',
                      'As needed'
                    ]
                        .map((f) => DropdownMenuItem(
                            value: f,
                            child:
                                Text(f, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) => setState(() => widget.e.freq = v)),
              ])),
          const SizedBox(width: 12),
          Expanded(
              child: Inp(
                  label: 'Duration', hint: 'e.g. 7 days', ctrl: widget.e.dur)),
        ]),
        const SizedBox(height: 10),
        Inp(
            label: 'Special Instructions',
            hint: 'e.g. Take with food...',
            ctrl: widget.e.instr),
      ]));
}

// ════════════════════ DOCTOR MESSAGES ════════════════════════════════════════
class DoctorMessages extends StatefulWidget {
  const DoctorMessages({super.key});
  @override
  State<DoctorMessages> createState() => _DMsgs();
}

class _DMsgs extends State<DoctorMessages> {
  List<Map> _chats = [];
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
      final r = await Api.doctorChats();
      setState(() {
        _chats = (r['chats'] as List?)?.cast<Map>() ?? [];
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
      final r = await Api.chatMsgs(c['patient_id'].toString());
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
            'sender': 'doctor',
            'text': t,
            'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'
          }
        ]);
    _sb();
    try {
      await Api.sendDocMsg(_active!['patient_id'].toString(), t);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext ctx) {
    final mob = MediaQuery.of(ctx).size.width < 720;
    return DoctorLayout(
        cur: 4,
        title: 'Messages',
        subtitle: 'Chat with your patients',
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
                    msg: 'Select a patient to chat')
                : _panel()),
      ]));
  Widget _list() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('PATIENT CHATS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: C.t3,
                    letterSpacing: 1.2))),
        Expanded(
            child: _lc
                ? const Center(child: CircularProgressIndicator())
                : _chats.isEmpty
                    ? const Empty(
                        icon: Icons.chat_bubble_outline,
                        msg: 'No conversations yet')
                    : ListView.builder(
                        itemCount: _chats.length,
                        itemBuilder: (_, i) {
                          final c = _chats[i];
                          final act = _active?['patient_id'] == c['patient_id'];
                          return ListTile(
                              tileColor: act ? C.primaryLt : null,
                              leading: Av(c['patient_name']?.toString() ?? ''),
                              title: Text(c['patient_name']?.toString() ?? '',
                                  style: h5.copyWith(fontSize: 13)),
                              subtitle: Text(c['label']?.toString() ?? '',
                                  style: small),
                              onTap: () => _open(c));
                        })),
      ]);
  Widget _panel({bool mob = false}) => Column(children: [
        if (mob)
          Container(
              color: C.card,
              child: Row(children: [
                BackButton(onPressed: () => setState(() => _active = null)),
                Av(_active!['patient_name']?.toString() ?? '', r: 18),
                const SizedBox(width: 8),
                Text(_active!['patient_name']?.toString() ?? '', style: h5),
              ])),
        if (!mob)
          Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                  color: C.card,
                  border: Border(bottom: BorderSide(color: C.border))),
              child: Row(children: [
                Av(_active!['patient_name']?.toString() ?? ''),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_active!['patient_name']?.toString() ?? '', style: h5),
                  Text(_active!['label']?.toString() ?? '', style: small),
                ]),
              ])),
        Expanded(
            child: _lm
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(14),
                    itemCount: _msgs.length,
                    itemBuilder: (_, i) {
                      final m = _msgs[i];
                      final mine = m['sender'] == 'doctor';
                      return Align(
                          alignment: mine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              constraints: const BoxConstraints(maxWidth: 320),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                  color: mine ? C.primary : C.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: mine
                                      ? null
                                      : Border.all(color: C.border)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(m['text']?.toString() ?? '',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: mine ? Colors.white : C.t1)),
                                    const SizedBox(height: 3),
                                    Text(m['time']?.toString() ?? '',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                mine ? Colors.white60 : C.t3)),
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

// ════════════════════ DOCTOR EARNINGS ════════════════════════════════════════
class DoctorEarnings extends StatefulWidget {
  const DoctorEarnings({super.key});
  @override
  State<DoctorEarnings> createState() => _DEarn();
}

class _DEarn extends State<DoctorEarnings> {
  Map? d;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.doctorEarnings();
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
    final pmts = (d?['payments'] as List?)?.cast<Map>() ?? [];
    return DoctorLayout(
        cur: 5,
        title: 'Earnings Overview',
        subtitle: 'Track your revenue and payment history',
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
                          crossAxisCount: mob ? 2 : 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: mob ? 1.4 : 1.2,
                          children: [
                            StatTile(
                                icon: Icons.account_balance_wallet_outlined,
                                value:
                                    '\$${(d?['total'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'Total Earned',
                                ic: C.green,
                                ib: C.greenLt),
                            StatTile(
                                icon: Icons.bar_chart,
                                value:
                                    '\$${(d?['this_month'] ?? 0.0).toStringAsFixed(0)}',
                                label: 'This Month',
                                ic: C.primary,
                                ib: C.primaryLt),
                            StatTile(
                                icon: Icons.check_circle_outline,
                                value: '${d?['completed'] ?? 0}',
                                label: 'Completed',
                                ic: C.green,
                                ib: C.greenLt),
                            StatTile(
                                icon: Icons.calendar_today,
                                value: '${d?['total_appts'] ?? 0}',
                                label: 'Total Appts',
                                ic: C.amber,
                                ib: C.amberLt),
                          ]),
                      const SizedBox(height: 16),
                      SecCard(
                          title: 'Payment History',
                          child: pmts.isEmpty
                              ? const Empty(
                                  icon: Icons.receipt_long_outlined,
                                  msg: 'No payments yet')
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(12),
                                  itemCount: pmts.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) => ListTile(
                                      dense: true,
                                      leading: Av(
                                          pmts[i]['patient']?.toString() ?? '',
                                          r: 20),
                                      title: Text(
                                          pmts[i]['patient']?.toString() ?? '',
                                          style: h5.copyWith(fontSize: 13)),
                                      subtitle: Text(
                                          pmts[i]['date']?.toString() ?? '',
                                          style: small),
                                      trailing: Text(
                                          '\$${(pmts[i]['amount'] ?? 0.0).toStringAsFixed(0)}',
                                          style:
                                              h5.copyWith(color: C.green))))),
                    ]));
              }));
  }
}

// ════════════════════ DOCTOR PROFILE ═════════════════════════════════════════
class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});
  @override
  State<DoctorProfile> createState() => _DProf();
}

class _DProf extends State<DoctorProfile> {
  final _fk = GlobalKey<FormState>();
  final _fee = TextEditingController();
  final _exp = TextEditingController();
  final _lic = TextEditingController();
  final _bio = TextEditingController();
  final _edu = TextEditingController();
  final _cln = TextEditingController();
  final _cla = TextEditingController();
  String? _spec;
  bool _loading = true, _saving = false;
  static const _specs = [
    'Cardiology',
    'Dermatology',
    'General Practice',
    'Gynecology',
    'Neurology',
    'Oncology',
    'Ophthalmology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Surgery',
    'Urology'
  ];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.getDoctorProfile();
      setState(() {
        _spec = r['specialty'];
        _fee.text = '${r['consultation_fee'] ?? ''}';
        _exp.text = '${r['years_of_experience'] ?? ''}';
        _lic.text = r['license_number'] ?? '';
        _bio.text = r['bio'] ?? '';
        _edu.text = r['education'] ?? '';
        _cln.text = r['clinic_name'] ?? '';
        _cla.text = r['clinic_address'] ?? '';
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
      await Api.updateDoctorProfile({
        'specialty': _spec,
        'consultation_fee': double.tryParse(_fee.text) ?? 0,
        'years_of_experience': int.tryParse(_exp.text) ?? 0,
        'license_number': _lic.text,
        'bio': _bio.text,
        'education': _edu.text,
        'clinic_name': _cln.text,
        'clinic_address': _cla.text
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

  @override
  Widget build(BuildContext ctx) => DoctorLayout(
      cur: 6,
      title: 'Doctor Profile',
      subtitle: 'Update your professional information',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Form(
                  key: _fk,
                  child: Column(children: [
                    InfoSec(
                        icon: Icons.work_outline,
                        title: 'Professional Info',
                        child: Column(children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: DropField(
                                        label: 'Specialty',
                                        value: _spec,
                                        items: _specs,
                                        onChange: (v) =>
                                            setState(() => _spec = v),
                                        validator: (v) =>
                                            v == null ? 'Required' : null)),
                                const SizedBox(width: 14),
                                Expanded(
                                    child: Inp(
                                        label: 'Consultation Fee (\$)',
                                        hint: '60',
                                        ctrl: _fee,
                                        kb: TextInputType.number,
                                        validator: (v) => (v?.isEmpty ?? true)
                                            ? 'Required'
                                            : null)),
                              ]),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(
                                child: Inp(
                                    label: 'Years of Experience',
                                    hint: '8',
                                    ctrl: _exp,
                                    kb: TextInputType.number)),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Inp(
                                    label: 'License Number',
                                    hint: 'MD-29810',
                                    ctrl: _lic,
                                    validator: (v) => (v?.isEmpty ?? true)
                                        ? 'Required'
                                        : null)),
                          ]),
                          const SizedBox(height: 14),
                          Inp(
                              label: 'Bio / About',
                              hint: 'Tell patients about yourself...',
                              ctrl: _bio,
                              lines: 3),
                          const SizedBox(height: 14),
                          Inp(
                              label: 'Education',
                              hint:
                                  'e.g., MD from Cairo University, Board Certified',
                              ctrl: _edu),
                        ])),
                    const SizedBox(height: 14),
                    InfoSec(
                        icon: Icons.local_hospital_outlined,
                        title: 'Clinic Information',
                        child: Row(children: [
                          Expanded(
                              child: Inp(
                                  label: 'Clinic Name',
                                  hint: 'City Medical Center',
                                  ctrl: _cln)),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Inp(
                                  label: 'Clinic Address',
                                  hint: '123 Main St, City, State',
                                  ctrl: _cla)),
                        ])),
                    const SizedBox(height: 20),
                    Btn(label: 'Save Changes', loading: _saving, onTap: _save),
                    const SizedBox(height: 20),
                  ]))));
}
