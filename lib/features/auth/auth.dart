import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/auth_utils.dart';
import '../../data/services/api.dart';
import '../../shared/widgets/widgets.dart';

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
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override Widget build(BuildContext ctx) => Scaffold(
    body: Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.g1, C.g2, Color(0xFF2563EB)])),
      child: SafeArea(child: Column(children: [
        // NAV
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('MediDash', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            Row(children: [
              _NavLink('Home', () {}), const SizedBox(width: 8),
              _NavLink('Find Doctors', () => Navigator.pushNamed(ctx, '/login')), const SizedBox(width: 16),
              OutlinedButton(onPressed: () => Navigator.pushNamed(ctx, '/login'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                child: const Text('Sign In')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => Navigator.pushNamed(ctx, '/register'),
                style: ElevatedButton.styleFrom(backgroundColor: C.primary, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                child: const Text('Get Started', style: TextStyle(color: Colors.white))),
            ]),
          ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 40),
            // Hero
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: const Text('Healthcare made simple', style: TextStyle(color: Colors.white, fontSize: 13))),
            const SizedBox(height: 20),
            const Text('Your health,\nsorted.', style: TextStyle(color: Colors.white, fontSize: 48,
                fontWeight: FontWeight.w800, height: 1.1)),
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
            // Stats
            Row(children: [
              _Stat('500+', 'Verified doctors'), const SizedBox(width: 40),
              _Stat('50K+', 'Patients'), const SizedBox(width: 40),
              _Stat('200K+', 'Appointments'),
            ]),
            const SizedBox(height: 48),
            // Search card
            Container(padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Search for a doctor', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(decoration: InputDecoration(hintText: 'e.g. Cardiologist, Dr. Ahmed Khalil...',
                    hintStyle: const TextStyle(color: C.t3, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: C.t3),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                const SizedBox(height: 10),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: () => Navigator.pushNamed(ctx, '/login'),
                    style: ElevatedButton.styleFrom(backgroundColor: C.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Search Doctors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: ['Cardiology','Neurology','Dermatology','Orthopedics','Pediatrics','Psychiatry']
                    .map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
                        child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 12)))).toList()),
                const SizedBox(height: 16),
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(10)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('HOW IT WORKS', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    _Step(1, 'Register as a patient'), _Step(2, 'Find and book a doctor'), _Step(3, 'Attend your appointment'),
                  ])),
              ])),
          ]))),
      ]))));
}
class _NavLink extends StatelessWidget {
  final String t; final VoidCallback f;
  const _NavLink(this.t, this.f);
  @override Widget build(BuildContext ctx) => TextButton(onPressed: f, child: Text(t, style: const TextStyle(color: Colors.white70, fontSize: 14)));
}
class _Stat extends StatelessWidget {
  final String v, l; const _Stat(this.v, this.l);
  @override Widget build(BuildContext ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
    Text(l, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
  ]);
}
class _Step extends StatelessWidget {
  final int n; final String t; const _Step(this.n, this.t);
  @override Widget build(BuildContext ctx) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    Container(width: 22, height: 22, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(6)),
        alignment: Alignment.center, child: Text('$n', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
    const SizedBox(width: 10), Text(t, style: const TextStyle(color: Colors.white, fontSize: 13)),
  ]));
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
    const SizedBox(height: 20),
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: C.primaryLt, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Demo accounts:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.primary)),
          SizedBox(height: 4),
          Text('Doctor  → doctor@test.com   / any password', style: TextStyle(fontSize: 11, color: C.t2)),
          Text('Patient → patient@test.com  / any password', style: TextStyle(fontSize: 11, color: C.t2)),
          Text('Admin   → admin@test.com    / any password', style: TextStyle(fontSize: 11, color: C.t2)),
        ])),
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
  static const _specs=['Cardiology','Dermatology','General Practice','Gynecology','Neurology','Oncology','Ophthalmology','Orthopedics','Pediatrics','Psychiatry','Radiology','Surgery','Urology'];
  Future<void> _pick() async {
    final r=await FilePicker.platform.pickFiles(type:FileType.custom, allowedExtensions:['jpg','jpeg','png','pdf']);
    if(r?.files.single.path!=null) setState((){_file=File(r!.files.single.path!);_fname=r.files.single.name;});
  }
  Future<void> _submit() async {
    if(!_fk.currentState!.validate()) return;
    if(_spec==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Select specialty')));return;}
    setState(()=>_loading=true);
    try {
      await Api.applyDoctor(n:widget.name,ph:widget.phone,e:widget.email,p:widget.pass,
          lic:_lic.text.trim(),exp:int.tryParse(_exp.text)??0,spec:_spec!,doc:_file);
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
    DropField(label:'Specialty',value:_spec,items:_specs,onChange:(v)=>setState(()=>_spec=v),validator:(v)=>v==null?'Required':null),
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
