import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

const _qas = {
  'hello': 'Hello! I am ScholarBot 👋\nI can help you find scholarships, understand eligibility, and guide your application.',
  'eligibility': 'To check your eligibility:\n1. Go to Profile and fill your details\n2. Tap "Check Eligibility" on the home screen\n3. See matched schemes with reasons\n\nCategory (ST), class, and family income are the key criteria.',
  'documents': 'Required documents typically include:\n• Aadhaar Card\n• ST Caste Certificate\n• Income Certificate\n• Bank Passbook\n• Mark Sheet\n• Admission Letter\n\nUpload from camera, gallery, or fetch from DigiLocker!',
  'digilocker': 'DigiLocker is a digital document wallet by Government of India. With ScholarSetu, you can:\n• Auto-import Aadhaar\n• Fetch mark sheets from DigiLocker\n• Get digitally verified documents\n\nThis reduces rejection risk!',
  'status': 'To track your application:\n1. Go to the Track tab\n2. Select your application\n3. See the live timeline from submission to payment',
  'payment': 'Scholarship amounts are disbursed via DBT (Direct Benefit Transfer) directly to your Aadhaar-linked bank account.\n\nEnsure your bank account is:\n• In your name\n• Aadhaar-linked\n• Active',
  'deadline': 'Each scholarship has its own deadline. Check the Schemes tab to see deadlines. Alerts will be sent as deadlines approach!',
  'offline': 'ScholarSetu works offline! You can:\n• Fill and save application forms offline\n• Upload documents when connected\n• All data syncs automatically when you get internet',
  'grievance': 'To raise a grievance:\n1. Go to the Grievance section\n2. Select the issue type\n3. Describe your problem\n4. Submit\n\nOfficers respond within 7 working days.',
  'languages': 'ScholarSetu supports 12 languages including Hindi, Odia, Telugu, Tamil, Gujarati, Marathi, Bengali, Kannada, Malayalam, Santali, and Gondi!\n\nChange language in Settings.',
};

const _default = 'I can help with:\n• Scholarship eligibility\n• Required documents\n• Application status\n• Payment queries\n• Grievances\n\nType any keyword or ask your question!';

String _getBotResponse(String text) {
  final lower = text.toLowerCase();
  for (final key in _qas.keys) {
    if (lower.contains(key)) return _qas[key]!;
  }
  return _default;
}

class _Msg {
  final String text;
  final bool isBot;
  final DateTime time;
  _Msg({required this.text, required this.isBot, required this.time});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [
    _Msg(text: 'Hello! I am ScholarBot 🤖\nAsk me anything about tribal scholarships, eligibility, documents, or application status.', isBot: true, time: DateTime.now()),
  ];

  final _topics = ['Eligibility', 'Documents', 'Status', 'Payment', 'DigiLocker', 'Offline', 'Languages', 'Grievance'];

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text.trim(), isBot: false, time: DateTime.now()));
    });
    _ctrl.clear();
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(text: _getBotResponse(text), isBot: true, time: DateTime.now()));
      });
      _scrollDown();
    });
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  String _fmt(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Text('🤖 '),
          Text('ScholarBot'),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.primary.withOpacity(0.5), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Quick topics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _topics.map((t) => GestureDetector(
                  onTap: () => _send(t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
                    child: Text(t, style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ),
                )).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: m.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                    children: [
                      if (m.isBot) ...[
                        Container(width: 30, height: 30, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(15)),
                          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16)))),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: m.isBot ? Colors.white : AppTheme.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(m.isBot ? 4 : 16),
                              bottomRight: Radius.circular(m.isBot ? 16 : 4)),
                            boxShadow: m.isBot ? [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6)] : []),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(m.text, style: TextStyle(fontSize: 14, color: m.isBot ? AppTheme.textPrimary : Colors.white, height: 1.45)),
                            const SizedBox(height: 4),
                            Text(_fmt(m.time), style: TextStyle(fontSize: 10, color: m.isBot ? AppTheme.textHint : Colors.white.withOpacity(0.7))),
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            color: Colors.white,
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: _send,
                  decoration: const InputDecoration(hintText: 'Ask about scholarships...', contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(23)),
                  child: const Icon(Icons.send, color: Colors.white, size: 20)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
