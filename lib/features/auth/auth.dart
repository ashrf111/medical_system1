import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/auth_utils.dart';
import '../../data/services/api.dart';
import '../../shared/widgets/widgets.dart';
import '../patient/chatbot.dart';

// ─── Gradient shell ───────────────────────────────────────────────────────────
class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});
  @override Widget build(BuildContext ctx) => Scaffold(
    body: Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.g1, C.g2])),
      child: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
        child: Container(constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))]),
          child: child))))));
}

// ═══════════════════════ LANDING PAGE ════════════════════════════════════════

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override State<LandingPage> createState() => _LandingState();
}

class _LandingState extends State<LandingPage> {
  String? _statsDocs, _statsPats, _statsAppts;
  List<dynamic> _doctors = [];
  bool _loading = true;

  @override void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await Api.getAdminStats();
      final docs = await Api.getAllDoctors();
      if (mounted) {
        setState(() {
          _statsDocs = stats['total_doctors']?.toString() ?? '500+';
          _statsPats = stats['total_patients']?.toString() ?? '50K+';
          _statsAppts = stats['total_appointments']?.toString() ?? '200K+';
          _doctors = docs.where((d) => d['status'] == 'approved').toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: C.bg,
    body: SingleChildScrollView(child: Column(children: [
      // NAV & HERO SECTION (Dark Gradient)
      Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.g1, C.g2, Color(0xFF2563EB)])),
        child: SafeArea(bottom: false, child: Column(children: [
          // NAV
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('MediDash', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              Row(children: [
                OutlinedButton(onPressed: () => Navigator.pushNamed(ctx, '/login'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)),
                  child: const Text('Sign In')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => Navigator.pushNamed(ctx, '/register'),
                  style: ElevatedButton.styleFrom(backgroundColor: C.primary),
                  child: const Text('Get Started', style: TextStyle(color: Colors.white))),
              ]),
            ])),
          // HERO CONTENT
          Padding(padding: const EdgeInsets.all(24), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text('Healthcare made simple', style: TextStyle(color: Colors.white, fontSize: 13))),
              const SizedBox(height: 20),
              const Text('Your health,\nsorted.', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: 18),
              Text('Book appointments with verified doctors, get digital prescriptions, and keep your medical history in one place.',
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 16, height: 1.5)),
              const SizedBox(height: 32),
              Row(children: [
                Expanded(child: ElevatedButton(onPressed: () => Navigator.pushNamed(ctx, '/register'),
                  style: ElevatedButton.styleFrom(backgroundColor: C.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Create free account →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pushNamed(ctx, '/login'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Sign in'))),
              ]),
              const SizedBox(height: 48),
            ])),
        ])),
      ),
      
      // STATS BAR
      Container(color: Color(0xFF0F172A), padding: const EdgeInsets.symmetric(vertical: 40),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _Stat(_statsDocs ?? '...', 'Verified doctors'),
          _Stat(_statsPats ?? '...', 'Active patients'),
          _Stat(_statsAppts ?? '...', 'Appointments'),
        ]),
      ),

      // SPECIALTIES GRID
      Container(padding: const EdgeInsets.all(24), color: Colors.white, width: double.infinity,
        child: Column(children: [
          const SizedBox(height: 20),
          const Text('Browse by specialty', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          const Text('From routine check-ups to specialist consultations — we\'ve got you covered.', style: TextStyle(color: C.t2, fontSize: 15), textAlign: TextAlign.center),
          const SizedBox(height: 30),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            _SpecCard(Icons.favorite, 'Cardiology'), _SpecCard(Icons.psychology, 'Neurology'),
            _SpecCard(Icons.wb_sunny, 'Dermatology'), _SpecCard(Icons.accessibility_new, 'Orthopedics'),
            _SpecCard(Icons.child_care, 'Pediatrics'), _SpecCard(Icons.record_voice_over, 'Psychiatry'),
            _SpecCard(Icons.remove_red_eye, 'Ophthalmology'), _SpecCard(Icons.monitor_heart, 'General Practice'),
          ]),
          const SizedBox(height: 20),
        ])),

      // FEATURED DOCTORS
      if (_doctors.isNotEmpty)
        Container(padding: const EdgeInsets.all(24), color: C.bg, width: double.infinity,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            const Text('Featured specialists', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Book appointments with top-rated professionals.', style: TextStyle(color: C.t2, fontSize: 15)),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('View All →', style: TextStyle(color: C.primary, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 20),
            SizedBox(height: 200, child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _doctors.length,
              itemBuilder: (ctx, i) {
                final d = _doctors[i];
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _DoctorProfileSheet(doc: d));
                  },
                  child: Container(width: 160, margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Av(d['fullName'] ?? d['full_name'] ?? '', r: 32, img: d['avatar']),
                      const SizedBox(height: 12),
                      Text(d['fullName'] ?? d['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(d['specialty'] ?? d['specialty_name'] ?? '', style: const TextStyle(color: C.t2, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: C.greenLt, borderRadius: BorderRadius.circular(12)),
                        child: Text('\$${d['consultationFee'] ?? d['consultation_fee'] ?? 0}', style: const TextStyle(color: C.green, fontSize: 11, fontWeight: FontWeight.w700))),
                    ])),
                );
              },
            )),
          ])),

      // HOW IT WORKS
      Container(padding: const EdgeInsets.all(24), color: Colors.white, width: double.infinity,
        child: Column(children: [
          const SizedBox(height: 20),
          const Text('How it works', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 30),
          _HowStep('01', 'Create a free account', 'Sign up in under a minute. No subscription, no credit card needed to get started.'),
          _HowStep('02', 'Find a specialist', 'Browse doctors, read patient reviews, and check real-time availability.'),
          _HowStep('03', 'Book and pay', 'Pick a slot that suits you, pay online, and you\'re set.'),
          _HowStep('04', 'Attend your appointment', 'Show up in person or join a video call — whatever works best for you.'),
          const SizedBox(height: 20),
        ])),
      ],
    )),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen(isGuest: true))),
      backgroundColor: C.primary,
      child: const Icon(Icons.psychology, color: Colors.white, size: 28),
    ),
  );
}

class _SpecCard extends StatelessWidget {
  final IconData ic; final String t; const _SpecCard(this.ic, this.t);
  @override Widget build(BuildContext ctx) => GestureDetector(
    onTap: () => Navigator.pushNamed(ctx, '/register'),
    child: Container(
      width: 100, height: 100, decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(14)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(ic, color: C.primary, size: 34), const SizedBox(height: 10),
        Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: C.sidebar), textAlign: TextAlign.center),
      ])));
}

class _HowStep extends StatelessWidget {
  final String n, t, d; const _HowStep(this.n, this.t, this.d);
  @override Widget build(BuildContext ctx) => Padding(padding: const EdgeInsets.only(bottom: 24), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(n, style: const TextStyle(color: C.primary, fontSize: 32, fontWeight: FontWeight.w800)),
    const SizedBox(width: 20),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
      const SizedBox(height: 4),
      Text(d, style: const TextStyle(fontSize: 14, color: C.t2, height: 1.4)),
    ]))
  ]));
}

class _DoctorProfileSheet extends StatelessWidget {
  final Map doc; const _DoctorProfileSheet({required this.doc});
  @override Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Av(doc['fullName'] ?? doc['full_name'] ?? '', r: 36, img: doc['avatar']),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doc['fullName'] ?? doc['full_name'] ?? '', style: h3),
          Text(doc['specialty'] ?? doc['specialty_name'] ?? '', style: const TextStyle(color: C.t2, fontSize: 14)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            Text(' ${doc['averageRating'] ?? doc['average_rating'] ?? 'New'}  ·  ${doc['yearsOfExperience'] ?? doc['experience_years'] ?? 0}y exp', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ])
        ]))
      ]),
      const SizedBox(height: 24),
      if (doc['bio'] != null && doc['bio'].toString().isNotEmpty) ...[
        const Text('About', style: h5), const SizedBox(height: 8),
        Text(doc['bio'], style: body),
        const SizedBox(height: 20),
      ],
      const Text('Consultation Fee', style: h5), const SizedBox(height: 8),
      Text('\$${doc['consultationFee'] ?? doc['consultation_fee'] ?? 0} per visit', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.green)),
      const SizedBox(height: 32),
      Btn(label: 'Sign in to book', onTap: () { Navigator.pop(ctx); Navigator.pushNamed(ctx, '/login'); }),
    ])));
}

class _Stat extends StatelessWidget {
  final String v, l; const _Stat(this.v, this.l);
  @override Widget build(BuildContext ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
    Text(l, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
  ]);
}


// ═══════════════════════ LOGIN ════════════════════════════════════════════════
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginState();
}
class _LoginState extends State<LoginPage> {
  final _fk = GlobalKey<FormState>(); final _em = TextEditingController(); final _pw = TextEditingController();
  bool _obs = true, _loading = false;
  Future<void> _login() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final r = await Api.login(_em.text.trim(), _pw.text);
      final u = Map<String, dynamic>.from(r['user'] as Map);
      Api.setTok(r['token'] as String);
      Auth.set(t: r['token'] as String, r: u['role'] as String, uid: u['id']?.toString() ?? '',
          n: u['name']?.toString() ?? '', e: u['email']?.toString() ?? '', spec: u['specialty']?.toString());
      if (!mounted) return;
      final route = u['role'] == 'doctor' ? '/doctor/dashboard' : u['role'] == 'admin' ? '/admin/home' : '/patient/dashboard';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    if (mounted) setState(() => _loading = false);
  }
  @override void dispose() { _em.dispose(); _pw.dispose(); super.dispose(); }
  @override Widget build(BuildContext ctx) => _Shell(child: Form(key: _fk, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.local_hospital_outlined, color: C.primary, size: 44),
    const SizedBox(height: 14),
    const Text('Welcome back', style: h2),
    const SizedBox(height: 4), const Text('Sign in to your MediDash account', style: body),
    const SizedBox(height: 28),
    Inp(label: 'Email address', hint: 'you@example.com', ctrl: _em, kb: TextInputType.emailAddress, validator: V.email),
    const SizedBox(height: 14),
    Inp(label: 'Password', hint: 'Enter your password', ctrl: _pw, obs: _obs,
        suffix: IconButton(icon: Icon(_obs ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: C.t3),
            onPressed: () => setState(() => _obs = !_obs)), validator: V.pass),
    const SizedBox(height: 22),
    Btn(label: 'Sign In', onTap: _login, loading: _loading),
    const SizedBox(height: 14),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Don't have an account? ", style: body),
      GestureDetector(onTap: () => Navigator.pushNamed(ctx, '/register'),
          child: const Text('Create one', style: TextStyle(fontSize: 14, color: C.primary, fontWeight: FontWeight.w600))),
    ]),
    const SizedBox(height: 10),
  ])));
}

// ═══════════════════════ REGISTER STEP 1 ═════════════════════════════════════
class RegisterStep1 extends StatefulWidget {
  const RegisterStep1({super.key});
  @override State<RegisterStep1> createState() => _R1();
}
class _R1 extends State<RegisterStep1> {
  String? _role;
  @override Widget build(BuildContext ctx) => _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.person_add_alt_1_outlined, color: C.primary, size: 40),
    const SizedBox(height: 14), const Text('Create account', style: h2),
    const SizedBox(height: 4), const Text('Step 1 of 2 — Choose your role', style: body),
    const SizedBox(height: 14), StepBar(cur: 1, total: 2), const SizedBox(height: 24),
    const Text('Who are you signing up as?', style: h5), const SizedBox(height: 14),
    Row(children: [
      Expanded(child: _RCard(role:'patient', icon:Icons.person_outline, title:'Patient', sub:'Find doctors and book appointments', sel:_role=='patient', onTap:()=>setState(()=>_role='patient'))),
      const SizedBox(width: 14),
      Expanded(child: _RCard(role:'doctor', icon:Icons.medical_services_outlined, title:'Doctor', sub:'Join our verified medical network', sel:_role=='doctor', onTap:()=>setState(()=>_role='doctor'))),
    ]),
    const SizedBox(height: 22),
    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
        onPressed: _role==null?null:()=>Navigator.push(ctx, MaterialPageRoute(builder:(_)=>RegisterStep2(role:_role!))),
        style: ElevatedButton.styleFrom(backgroundColor: _role==null?C.border:C.primary),
        child: Text('Continue →', style: TextStyle(color:_role==null?C.t2:Colors.white, fontWeight:FontWeight.w600, fontSize:15)))),
    const SizedBox(height: 14),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Already have an account? ', style: body),
      GestureDetector(onTap: ()=>Navigator.pushNamed(ctx,'/login'),
          child: const Text('Sign in', style: TextStyle(fontSize:14, color:C.primary, fontWeight:FontWeight.w600))),
    ]),
  ]));
}
class _RCard extends StatelessWidget {
  final String role, title, sub; final IconData icon; final bool sel; final VoidCallback onTap;
  const _RCard({required this.role, required this.icon, required this.title, required this.sub, required this.sel, required this.onTap});
  @override Widget build(BuildContext ctx) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: sel?C.primaryLt:C.input, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel?C.primary:C.border, width: sel?2:1)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: sel?C.primary.withOpacity(0.12):C.card, shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: sel?C.primary:C.t2)),
        const SizedBox(height: 10),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sel?C.primary:C.t1)),
        const SizedBox(height: 4),
        Text(sub, textAlign: TextAlign.center, style: small.copyWith(height: 1.4)),
      ])));
}

// ═══════════════════════ REGISTER STEP 2 ═════════════════════════════════════
class RegisterStep2 extends StatefulWidget {
  final String role;
  const RegisterStep2({super.key, required this.role});
  @override State<RegisterStep2> createState() => _R2();
}
class _R2 extends State<RegisterStep2> {
  final _fk=GlobalKey<FormState>(); final _nm=TextEditingController(); final _ph=TextEditingController();
  final _em=TextEditingController(); final _pw=TextEditingController(); final _cf=TextEditingController();
  bool _oP=true, _oC=true, _loading=false;
  bool get isDoc => widget.role=='doctor';
  Future<void> _next() async {
    if (!_fk.currentState!.validate()) return;
    if (_pw.text!=_cf.text) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Passwords do not match'))); return; }
    if (isDoc) { Navigator.push(context, MaterialPageRoute(builder:(_)=>RegisterStep3Doctor(name:_nm.text.trim(),phone:_ph.text.trim(),email:_em.text.trim(),pass:_pw.text))); return; }
    setState(()=>_loading=true);
    try {
      final r=await Api.regPatient(_nm.text.trim(),_ph.text.trim(),_em.text.trim(),_pw.text);
      final u=Map<String,dynamic>.from(r['user'] as Map);
      Api.setTok(r['token'] as String);
      Auth.set(t:r['token'] as String,r:'patient',uid:u['id']?.toString()??'',n:u['name']?.toString()??'',e:u['email']?.toString()??'');
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/patient/dashboard', (_)=>false);
    } catch(e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString()))); }
    if(mounted) setState(()=>_loading=false);
  }
  @override void dispose() { _nm.dispose();_ph.dispose();_em.dispose();_pw.dispose();_cf.dispose();super.dispose(); }
  @override Widget build(BuildContext ctx) => _Shell(child: Form(key:_fk, child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
    const Icon(Icons.person_add_alt_1_outlined, color:C.primary, size:40),
    const SizedBox(height:14), const Text('Create account', style:h2),
    SizedBox(height:4), Text('Step 2 of ${isDoc?3:2} — Personal information', style:body),
    const SizedBox(height:14), StepBar(cur:2, total:isDoc?3:2), const SizedBox(height:22),
    Inp(label:'Full Name', hint:'e.g. Ahmed Khalil', ctrl:_nm, validator:V.req),
    const SizedBox(height:12),
    Inp(label:'Phone Number', hint:'+20 100 000 0000', ctrl:_ph, kb:TextInputType.phone, validator:V.phone),
    const SizedBox(height:12),
    Inp(label:'Email Address', hint:'you@example.com', ctrl:_em, kb:TextInputType.emailAddress, validator:V.email),
    const SizedBox(height:12),
    Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
      Expanded(child:Inp(label:'Password', hint:'Min 6 chars', ctrl:_pw, obs:_oP,
          suffix:IconButton(icon:Icon(_oP?Icons.visibility_off_outlined:Icons.visibility_outlined, size:18, color:C.t3), onPressed:()=>setState(()=>_oP=!_oP)),
          validator:V.pass)),
      const SizedBox(width:12),
      Expanded(child:Inp(label:'Confirm', hint:'Repeat password', ctrl:_cf, obs:_oC,
          suffix:IconButton(icon:Icon(_oC?Icons.visibility_off_outlined:Icons.visibility_outlined, size:18, color:C.t3), onPressed:()=>setState(()=>_oC=!_oC)),
          validator:(v)=>V.confirmPass(v,_pw.text))),
    ]),
    const SizedBox(height:22),
    Row(children:[
      Expanded(child:OBtn(label:'← Back', onTap:()=>Navigator.pop(ctx))),
      const SizedBox(width:12),
      Expanded(flex:2, child:Btn(label:isDoc?'Continue →':'Create Account', loading:_loading, onTap:_next)),
    ]),
  ])));
}

// ═══════════════════════ REGISTER STEP 3 (Doctor) ════════════════════════════
class RegisterStep3Doctor extends StatefulWidget {
  final String name, phone, email, pass;
  const RegisterStep3Doctor({super.key, required this.name, required this.phone, required this.email, required this.pass});
  @override State<RegisterStep3Doctor> createState() => _R3();
}
class _R3 extends State<RegisterStep3Doctor> {
  final _fk=GlobalKey<FormState>(); final _lic=TextEditingController(); final _exp=TextEditingController();
  String? _spec; File? _file; String? _fname; bool _loading=false;
  List<Map<String, dynamic>> _specialtiesList = [];
  List<String> _specs = [];
  bool _loadingSpecs = true;

  @override
  void initState() {
    super.initState();
    _loadSpecs();
  }

  Future<void> _loadSpecs() async {
    try {
      final res = await Api.getSpecialties();
      if (mounted) {
        setState(() {
          _specialtiesList = res;
          _specs = res.map((e) => e['name'].toString()).toList();
          _loadingSpecs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSpecs = false);
    }
  }
  Future<void> _pick() async {
    final r=await FilePicker.platform.pickFiles(type:FileType.custom, allowedExtensions:['jpg','jpeg','png','pdf']);
    if(r?.files.single.path!=null) setState((){_file=File(r!.files.single.path!);_fname=r.files.single.name;});
  }
  Future<void> _submit() async {
    if(!_fk.currentState!.validate()) return;
    if(_spec==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Select specialty')));return;}
    setState(()=>_loading=true);
    int specId = _specialtiesList.firstWhere((e) => e['name'] == _spec, orElse: () => {'id': 1})['id'];
    try {
      await Api.applyDoctor(n:widget.name,ph:widget.phone,e:widget.email,p:widget.pass,
          lic:_lic.text.trim(),exp:int.tryParse(_exp.text)??0,specId:specId,doc:_file);
      if(!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context,'/application-received',(_)=>false);
    } catch(e){if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
    if(mounted) setState(()=>_loading=false);
  }
  @override void dispose(){_lic.dispose();_exp.dispose();super.dispose();}
  @override Widget build(BuildContext ctx) => _Shell(child:Form(key:_fk,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Icon(Icons.verified_user_outlined,color:C.primary,size:40),
    const SizedBox(height:14),const Text('Create account',style:h2),
    const SizedBox(height:4),const Text('Step 3 of 3 — Professional credentials',style:body),
    const SizedBox(height:14),const StepBar(cur:3,total:3),const SizedBox(height:16),
    Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:C.amberLt,borderRadius:BorderRadius.circular(10),border:Border.all(color:C.amber.withOpacity(0.4))),
      child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Icon(Icons.info_outline,color:C.amber,size:18),const SizedBox(width:8),
        const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Credential verification required',style:TextStyle(fontSize:13,fontWeight:FontWeight.w700,color:Color(0xFF92400E))),
          SizedBox(height:2),
          Text('Your application will be reviewed by our admin team before you can start accepting patients.',style:TextStyle(fontSize:12,color:Color(0xFF92400E),height:1.4)),
        ])),
      ])),
    const SizedBox(height:14),
    Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Expanded(child:Inp(label:'Medical License No.*',hint:'e.g. MD-12345',ctrl:_lic,validator:V.req)),
      const SizedBox(width:12),
      Expanded(child:Inp(label:'Years of Experience',hint:'5',ctrl:_exp,kb:TextInputType.number,validator:V.req)),
    ]),
    const SizedBox(height:12),
    _loadingSpecs ? const Center(child: CircularProgressIndicator()) : DropField(label:'Specialty',value:_spec,items:_specs,onChange:(v)=>setState(()=>_spec=v),validator:(v)=>v==null?'Required':null),
    const SizedBox(height:12),
    Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('License Document',style:label_style),const SizedBox(height:6),
      GestureDetector(onTap:_pick,child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:26),
        decoration:BoxDecoration(color:C.input,borderRadius:BorderRadius.circular(10),border:Border.all(color:_file!=null?C.primary:C.border)),
        child:Column(children:[
          Icon(_file!=null?Icons.check_circle_outline:Icons.cloud_upload_outlined,size:28,color:_file!=null?C.primary:C.t3),
          const SizedBox(height:8),
          Text(_fname??'Click to upload',style:TextStyle(fontSize:13,color:_file!=null?C.primary:C.t2,fontWeight:_file!=null?FontWeight.w600:FontWeight.normal)),
          if(_file==null) const Text('JPEG, PNG or PDF • Max 3MB',style:TextStyle(fontSize:11,color:C.t3)),
        ]))),
    ]),
    const SizedBox(height:22),
    Row(children:[
      Expanded(child:OBtn(label:'← Back',onTap:()=>Navigator.pop(ctx))),
      const SizedBox(width:12),
      Expanded(flex:2,child:Btn(label:'Submit Application',loading:_loading,onTap:_submit)),
    ]),
  ])));
}

// ═══════════════════════ APPLICATION RECEIVED ═════════════════════════════════
class ApplicationReceived extends StatelessWidget {
  const ApplicationReceived({super.key});
  @override Widget build(BuildContext ctx) => _Shell(child:Column(children:[
    Container(width:72,height:72,decoration:BoxDecoration(color:C.greenLt,shape:BoxShape.circle),
        child:const Icon(Icons.check_circle_outline,color:C.green,size:40)),
    const SizedBox(height:20),
    const Text('Application Received',style:h2,textAlign:TextAlign.center),
    const SizedBox(height:12),
    const Text('Thanks for applying to join MediDash. Our team will review your credentials and get back to you within 1–2 business days.',style:body,textAlign:TextAlign.center),
    const SizedBox(height:24),
    Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:C.primaryLt,borderRadius:BorderRadius.circular(12)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('What happens next?',style:h5),const SizedBox(height:12),
        _Nx('We verify your license and credentials'),
        _Nx('Admin reviews and approves your account'),
        _Nx("You'll be able to sign in and start seeing patients"),
      ])),
    const SizedBox(height:24),
    Btn(label:'Back to Sign In',onTap:()=>Navigator.pushNamedAndRemoveUntil(ctx,'/login',(_)=>false)),
  ]));
}
class _Nx extends StatelessWidget {
  final String t; const _Nx(this.t);
  @override Widget build(BuildContext ctx)=>Padding(padding:const EdgeInsets.only(bottom:8),
    child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Icon(Icons.check_circle,color:C.primary,size:15),const SizedBox(width:8),
      Expanded(child:Text(t,style:body.copyWith(fontSize:13))),
    ]));
}
