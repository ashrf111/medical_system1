import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/auth_utils.dart';
import '../../data/services/api.dart';
import '../../shared/widgets/layout.dart';

class ChatbotScreen extends StatefulWidget {
  final bool isGuest;
  const ChatbotScreen({super.key, this.isGuest = false});
  @override
  State<ChatbotScreen> createState() => _ChatState();
}

class _ChatState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': 'Hello! I am your MediDash AI assistant. How can I help you today?'}
  ];
  final _ctrl = TextEditingController();
  final _sc = ScrollController();
  bool _loading = false;

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _ctrl.clear();
      _loading = true;
    });
    _scroll();

    try {
      final reply = await Api.chat(_messages);
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _loading = false;
      });
      _scroll();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _scroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_sc.hasClients) _sc.animateTo(_sc.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Widget _buildChat() => Column(children: [
    Expanded(
      child: ListView.builder(
        controller: _sc,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length + (_loading ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == _messages.length) return const _TypingIndicator();
          final m = _messages[i];
          final isUser = m['role'] == 'user';
          return Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUser ? C.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 16),
                ),
                boxShadow: [if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Text(m['content'] ?? '', style: TextStyle(color: isUser ? Colors.white : C.sidebar, fontSize: 14, height: 1.4)),
            ),
          );
        },
      ),
    ),
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.border))),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'Ask me anything...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: C.input,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (_) => _send(),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: _send,
          backgroundColor: C.primary,
          child: const Icon(Icons.send, size: 18, color: Colors.white),
        ),
      ]),
    ),
  ]);

  @override
  Widget build(BuildContext ctx) {
    if (widget.isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MediDash AI Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          backgroundColor: Colors.white,
          foregroundColor: C.sidebar,
          elevation: 0.5,
        ),
        body: _buildChat(),
      );
    }

    // Role-based layout
    if (Auth.isAdmin) return AdminLayout(cur: 5, title: 'AI Assistant', subtitle: 'Platform assistance', body: _buildChat());
    if (Auth.isDoctor) return DoctorLayout(cur: 7, title: 'AI Assistant', subtitle: 'Clinical guidance', body: _buildChat());
    return PatientLayout(cur: 7, title: 'AI Assistant', subtitle: 'Medical guidance', body: _buildChat());
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext ctx) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const SizedBox(width: 30, child: LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent)),
    ),
  );
}
