import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Api {
  // ════════════════════════════════════════════════
  static const String base = 'https://la-phi.vercel.app/api';
  // ════════════════════════════════════════════════

  static String? _tok;
  static String? _currentUserId;
  static String? _currentProfileId; // Maps to patient_id or doctor_id

  static String? get userId => _currentUserId;
  static String? get profileId => _currentProfileId;

  static void setTok(String t) {
    _tok = t;
    if (int.tryParse(t) != null) {
      _currentUserId = t;
    }
  }

  static void clearTok() {
    _tok = null;
    _currentUserId = null;
    _currentProfileId = null;
  }

  static Map<String, String> get _h => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_tok != null) 'Authorization': 'Bearer $_tok',
      };

  // AUTH
  static Future<Map<String, dynamic>> login(String e, String p) async {
    final res = _r(await http.post(Uri.parse('$base/auth/signin'),
        headers: _h, body: jsonEncode({'email': e, 'password': p})));
    
    if (res['user'] != null) {
      res['token'] = res['user']['id'].toString();
      _currentUserId = res['user']['id'].toString();
      _currentProfileId = res['user']['profileId']?.toString();
      res['user']['name'] = res['user']['fullName'];
    }
    return res;
  }

  static Future<Map<String, dynamic>> regPatient(
      String n, String ph, String e, String p) async {
    final res = _r(await http.post(Uri.parse('$base/auth/signup'),
        headers: _h,
        body: jsonEncode({
          'fullName': n,
          'phone': ph,
          'email': e,
          'password': p,
          'role': 'patient'
        })));
    
    if (res['user'] != null) {
      res['token'] = res['user']['id'].toString();
      _currentUserId = res['user']['id'].toString();
      _currentProfileId = res['user']['profileId']?.toString();
      res['user']['name'] = res['user']['fullName'];
    }
    return res;
  }

  static Future<Map<String, dynamic>> applyDoctor(
      {required String n,
      required String ph,
      required String e,
      required String p,
      required String lic,
      required int exp,
      required int specId,
      File? doc}) async {
    final res = _r(await http.post(Uri.parse('$base/auth/signup'),
        headers: _h,
        body: jsonEncode({
          'fullName': n,
          'phone': ph,
          'email': e,
          'password': p,
          'role': 'doctor',
          'licenseNumber': lic,
          'experienceYears': exp,
          'specialtyId': specId, 
        })));
    return res;
  }

  static Future<void> logout() async {
    clearTok();
  }

  // ADMIN
  static Future<Map<String, dynamic>> adminHome() async {
    final d = DateTime.now().toString().substring(0, 10);
    final res = _r(await http.get(Uri.parse('$base/admin/stats?date=$d'), headers: _h));
    return res;
  }

  static Future<Map<String, dynamic>> adminAppointments() async {
    final res = _r(await http.get(Uri.parse('$base/appointments/all'), headers: _h));
    return {'appointments': res is List ? res : (res['appointments'] ?? [])};
  }

  static Future<Map<String, dynamic>> adminPayments() async {
    final res = _r(await http.get(Uri.parse('$base/payments'), headers: _h));
    return {'payments': res is List ? res : (res['payments'] ?? [])};
  }

  static Future<String> chat(List<Map<String, String>> messages) async {
    final res = _r(await http.post(
      Uri.parse('$base/chat'),
      headers: _h,
      body: jsonEncode({"messages": messages}),
    ));
    return res['reply'];
  }

  static Future<Map<String, dynamic>> getDoctors() async {
    final res = _r(await http.get(Uri.parse('$base/doctors/all'), headers: _h));
    return {'doctors': res is List ? res : (res['doctors'] ?? [])};
  }

  static Future<Map<String, dynamic>> getPatients() async {
    final res = _r(await http.get(Uri.parse('$base/patients/all'), headers: _h));
    return {'patients': res is List ? res : (res['patients'] ?? [])};
  }

  static Future<Map<String, dynamic>> approveDoctor(String id) async {
    return _r(await http.put(Uri.parse('$base/doctors/$id/status'),
        headers: _h, body: jsonEncode({'status': 'approved'})));
  }

  static Future<Map<String, dynamic>> suspendDoctor(String id) async {
    return _r(await http.put(Uri.parse('$base/doctors/$id/status'),
        headers: _h, body: jsonEncode({'status': 'suspended'})));
  }

  static Future<Map<String, dynamic>> deletePatient(String id) async {
    return _r(await http.put(Uri.parse('$base/admin/users/$id/toggle'), headers: _h));
  }

  // DOCTOR
  static Future<Map<String, dynamic>> doctorDash() async {
    if (_currentProfileId == null) return {};
    try {
      final appts = await http.get(Uri.parse('$base/doctors/$_currentProfileId/appointments'), headers: _h);
      final earn = await http.get(Uri.parse('$base/doctors/$_currentProfileId/earnings'), headers: _h);
      
      List aList = [];
      if (appts.statusCode == 200) aList = jsonDecode(appts.body) as List;
      Map eMap = {};
      if (earn.statusCode == 200) eMap = jsonDecode(earn.body) as Map;

      return {
        'today_appointments': aList.where((a) => a['appointment_date'] == DateTime.now().toString().substring(0, 10)).length,
        'pending': aList.where((a) => a['status'] == 'pending').length,
        'completed': aList.where((a) => a['status'] == 'completed').length,
        'this_month': eMap['this_month'] ?? 0,
        'total_earned': eMap['total_earned'] ?? 0,
        'schedule': aList.where((a) => a['appointment_date'] == DateTime.now().toString().substring(0, 10)).map((a) => {
          'id': a['id'],
          'patient': a['patient_name'],
          'time': a['appointment_time'],
          'type': a['type']
        }).toList(),
        'upcoming': aList.where((a) => a['status'] == 'confirmed').map((a) => {
          'id': a['id'],
          'patient': a['patient_name'],
          'date': a['appointment_date'],
          'time': a['appointment_time']
        }).toList()
      };
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> doctorAppts(String s) async {
    if (_currentProfileId == null) return {'appointments': []};
    final res = _r(await http.get(Uri.parse('$base/doctors/$_currentProfileId/appointments'), headers: _h));
    List appts = res is List ? res : (res['appointments'] ?? []);
    
    if (s == 'upcoming') {
      appts = appts.where((a) => a['status'] == 'confirmed' || a['status'] == 'pending').toList();
    } else if (s == 'past') {
      appts = appts.where((a) => a['status'] == 'completed').toList();
    } else if (s == 'cancelled') {
      appts = appts.where((a) => a['status'] == 'cancelled').toList();
    }
    
    return {'appointments': appts.map((a) {
      a['patient'] = a['patient_name'];
      a['date'] = a['appointment_date'];
      a['time'] = a['appointment_time'];
      return a;
    }).toList()};
  }

  static Future<Map<String, dynamic>> updateAppt(String id, String s) async {
    return _r(await http.put(Uri.parse('$base/appointments/$id/status'),
        headers: _h, body: jsonEncode({'status': s})));
  }

  static Future<Map<String, dynamic>> doctorPats([String? q]) async {
    if (_currentProfileId == null) return {'patients': []};
    final res = _r(await http.get(Uri.parse('$base/doctors/$_currentProfileId/appointments'), headers: _h));
    List appts = res is List ? res : [];
    
    Map<String, Map> uniquePats = {};
    for (var a in appts) {
      if (a['patient_name'] != null) {
        if (q != null && q.isNotEmpty && !a['patient_name'].toString().toLowerCase().contains(q.toLowerCase())) continue;
        uniquePats[a['patient_name']] = {
          'id': a['patient_id'],
          'name': a['patient_name'],
          'last_visit': a['appointment_date'],
          'condition': a['reason'] ?? 'Routine'
        };
      }
    }
    return {'patients': uniquePats.values.toList()};
  }

  static Future<Map<String, dynamic>> createRx(
      String aid, String dx, List meds) async {
    return _r(await http.post(Uri.parse('$base/prescriptions'),
        headers: _h,
        body: jsonEncode(
            {'appointmentId': aid, 'doctorId': _currentProfileId, 'diagnosis': dx, 'medications': meds})));
  }

  static Future<Map<String, dynamic>> doctorChats() async {
    if (_currentUserId == null) return {'chats': []};
    final res = _r(await http.get(Uri.parse('$base/conversations?userId=$_currentUserId&role=doctor'), headers: _h));
    List chats = res is List ? res : [];
    return {'chats': chats.map((c) => {
      'id': c['id'],
      'patient_id': c['id'], 
      'patient_name': c['other_name'] ?? 'Unknown',
      'label': c['last_message'] ?? 'New conversation'
    }).toList()};
  }

  static Future<Map<String, dynamic>> chatMsgs(String id) async {
    final res = _r(await http.get(Uri.parse('$base/conversations/$id/messages'), headers: _h));
    List msgs = res is List ? res : [];
    return {'messages': msgs.map((m) => {
      'id': m['id'],
      'sender': m['sender_role'] == 'doctor' ? 'doctor' : 'patient',
      'text': m['content'],
      'time': m['created_at']?.toString().substring(11, 16) ?? ''
    }).toList()};
  }

  static Future<Map<String, dynamic>> sendDocMsg(String id, String m) async {
    return _r(await http.post(Uri.parse('$base/conversations/$id/messages'),
        headers: _h, body: jsonEncode({'senderId': _currentUserId, 'content': m})));
  }

  static Future<Map<String, dynamic>> doctorEarnings() async {
    if (_currentProfileId == null) return {};
    return _r(await http.get(Uri.parse('$base/doctors/$_currentProfileId/earnings'), headers: _h));
  }

  static Future<Map<String, dynamic>> getDoctorProfile() async {
    if (_currentProfileId == null) return {};
    return _r(await http.get(Uri.parse('$base/doctors/$_currentProfileId'), headers: _h));
  }

  static Future<Map<String, dynamic>> updateDoctorProfile(Map d) async {
    if (_currentProfileId == null) return {};
    return _r(await http.put(Uri.parse('$base/doctors/$_currentProfileId'),
        headers: _h, body: jsonEncode(d)));
  }

  // PATIENT
  static Future<Map<String, dynamic>> patientDash() async {
    if (_currentProfileId == null) return {};
    try {
      final appts = await http.get(Uri.parse('$base/patients/$_currentProfileId/appointments'), headers: _h);
      final stats = await http.get(Uri.parse('$base/patients/$_currentProfileId/stats'), headers: _h);
      
      List aList = [];
      if (appts.statusCode == 200) aList = jsonDecode(appts.body) as List;
      
      Map res = {};
      if (stats.statusCode == 200) res = jsonDecode(stats.body);

      final upcoming = aList.where((a) => a['status'] == 'confirmed' || a['status'] == 'pending').toList();
      final recentDocs = []; 

      return {
        'upcoming_appointments': res['upcoming_appointments'] ?? 0,
        'past_consultations': res['past_consultations'] ?? 0,
        'active_prescriptions': res['active_prescriptions'] ?? 0,
        'health_score': res['health_score'] ?? 92,
        'upcoming': upcoming.map((a) => {
          'id': a['id'],
          'doctor': a['doctor_name'] ?? 'Doctor',
          'specialty': a['specialty'] ?? '',
          'date': a['appointment_date'],
          'time': a['appointment_time'],
        }).toList(),
        'top_doctors': recentDocs.map((d) => {
          'id': d['doctor_id'],
          'name': d['doctor_name'] ?? 'Doctor',
          'specialty': d['specialty'] ?? '',
        }).toList(),
      };
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> searchDoctors(
      {String? q, String? spec}) async {
    final p = <String, String>{};
    if (q?.isNotEmpty ?? false) p['search'] = q!;
    if (spec != null && spec != 'All') p['specialty'] = spec;
    
    final res = _r(await http.get(
        Uri.parse('$base/doctors').replace(queryParameters: p),
        headers: _h));
    
    List docs = res is List ? res : [];
    return {'doctors': docs.map((d) {
      d['name'] = d['full_name'];
      d['specialty'] = d['specialty_name'];
      d['fee'] = d['consultation_fee'];
      d['rating'] = d['rating'] ?? 0;
      return d;
    }).toList()};
  }

  static Future<Map<String, dynamic>> bookAppt(
      String did, String date, String time,
      [String? notes]) async {
    return _r(await http.post(Uri.parse('$base/appointments'),
        headers: _h,
        body: jsonEncode({
          'patientId': _currentProfileId,
          'doctorId': did,
          'date': date,
          'time': time,
          if (notes != null) 'reason': notes
        })));
  }

  static Future<Map<String, dynamic>> patientAppts(String s) async {
    if (_currentProfileId == null) return {'appointments': []};
    
    final res = _r(await http.get(Uri.parse('$base/patients/$_currentProfileId/appointments'), headers: _h));
    List appts = res is List ? res : [];
    
    if (s == 'upcoming') {
      appts = appts.where((a) => a['status'] == 'confirmed' || a['status'] == 'pending').toList();
    } else if (s == 'past') {
      appts = appts.where((a) => a['status'] == 'completed').toList();
    } else if (s == 'cancelled') {
      appts = appts.where((a) => a['status'] == 'cancelled').toList();
    }
    
    return {'appointments': appts.map((a) {
      a['doctor'] = a['doctor_name'];
      a['date'] = a['appointment_date'];
      a['time'] = a['appointment_time'];
      return a;
    }).toList()};
  }

  static Future<Map<String, dynamic>> patientRx() async {
    if (_currentProfileId == null) return {'prescriptions': []};
    final res = _r(await http.get(Uri.parse('$base/patients/$_currentProfileId/prescriptions'), headers: _h));
    return {'prescriptions': res is List ? res : []};
  }

  static Future<Map<String, dynamic>> patientChats() async {
    if (_currentUserId == null) return {'chats': []};
    final res = _r(await http.get(Uri.parse('$base/conversations?userId=$_currentUserId&role=patient'), headers: _h));
    List chats = res is List ? res : [];
    return {'chats': chats.map((c) => {
      'id': c['id'],
      'doctor_id': c['id'], 
      'doctor_name': c['other_name'] ?? 'Unknown',
      'label': c['last_message'] ?? 'New conversation'
    }).toList()};
  }

  static Future<Map<String, dynamic>> sendPatMsg(String id, String m) async {
    return _r(await http.post(Uri.parse('$base/conversations/$id/messages'),
        headers: _h, body: jsonEncode({'senderId': _currentUserId, 'content': m})));
  }

  static Future<Map<String, dynamic>> patientPay() async {
    if (_currentProfileId == null) return {'payments': []};
    final res = _r(await http.get(Uri.parse('$base/patients/$_currentProfileId/payments'), headers: _h));
    return {'payments': res is List ? res : []};
  }

  static Future<Map<String, dynamic>> submitReview(String docId, int rating, String comment) async {
    return _r(await http.post(Uri.parse('$base/reviews'),
        headers: _h, body: jsonEncode({
          'patientId': _currentProfileId,
          'doctorId': docId,
          'rating': rating,
          'comment': comment
        })));
  }

  static Future<Map<String, dynamic>> processPayment(String amount, String method) async {
    return _r(await http.post(Uri.parse('$base/payments'),
        headers: _h, body: jsonEncode({
          'patientId': _currentProfileId,
          'amount': amount,
          'paymentMethod': method,
          'status': 'completed'
        })));
  }

  static Future<Map<String, dynamic>> getPatientProfile() async {
    if (_currentProfileId == null) return {};
    return _r(await http.get(Uri.parse('$base/patients/$_currentProfileId'), headers: _h));
  }

  static Future<Map<String, dynamic>> updatePatProfile(Map d) async {
    if (_currentProfileId == null) return {};
    return _r(await http.put(Uri.parse('$base/patients/$_currentProfileId'),
        headers: _h, body: jsonEncode(d)));
  }

  static Future<List<Map<String, dynamic>>> getSpecialties() async {
    final res = _r(await http.get(Uri.parse('$base/specialties'), headers: _h));
    return res is List ? res.cast<Map<String, dynamic>>() : [];
  }

  static Future<List<Map<String, dynamic>>> getDoctorSlots(String id, String date) async {
    final res = _r(await http.get(Uri.parse('$base/doctors/$id/slots?date=$date'), headers: _h));
    return res is List ? res.cast<Map<String, dynamic>>() : [];
  }

  static Future<Map<String, dynamic>> createDoctor(Map d) async {
    return _r(await http.post(Uri.parse('$base/admin/doctors'), headers: _h, body: jsonEncode(d)));
  }

  static Future<Map<String, dynamic>> deleteDoctor(String id) async {
    return _r(await http.delete(Uri.parse('$base/doctors/$id'), headers: _h));
  }

  static Future<Map<String, dynamic>> createConversation(String patId, String docId) async {
    return _r(await http.post(Uri.parse('$base/conversations'), headers: _h, body: jsonEncode({'patientId': patId, 'doctorId': docId})));
  }

  static Future<Map<String, dynamic>> updateAvatar(String userId, String base64Data) async {
    return _r(await http.put(Uri.parse('$base/users/$userId/avatar'),
        headers: _h, body: jsonEncode({'avatar': base64Data})));
  }

  static Future<Map<String, dynamic>> updatePassword(String userId, String currentPwd, String newPwd) async {
    return _r(await http.put(Uri.parse('$base/users/$userId/password'),
        headers: _h, body: jsonEncode({'currentPassword': currentPwd, 'newPassword': newPwd})));
  }

  static Future<List<dynamic>> getAllDoctors() async {
    try {
      final res = _r(await http.get(Uri.parse('$base/doctors/all'), headers: _h));
      return res is List ? res : (res['doctors'] ?? []);
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    final d = DateTime.now().toString().substring(0, 10);
    try {
      return _r(await http.get(Uri.parse('$base/admin/stats?date=$d'), headers: _h));
    } catch (_) {
      return {};
    }
  }

  static dynamic _r(http.Response res) {
    var body;
    try {
      body = jsonDecode(res.body);
    } catch (_) {
      throw 'Invalid JSON response from server';
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw body['message'] ?? 'Error ${res.statusCode}';
  }
}
