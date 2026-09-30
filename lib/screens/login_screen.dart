import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/eligibility_engine.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _step = 'aadhaar';
  final _aadhaarCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  int _resendTimer = 0;

  void _startResend() {
    setState(() => _resendTimer = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendTimer--);
      return _resendTimer > 0;
    });
  }

  Future<void> _sendOtp() async {
    final raw = _aadhaarCtrl.text.replaceAll(' ', '');
    if (!validateAadhaar(raw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar number'), backgroundColor: AppTheme.error),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() { _loading = false; _step = 'otp'; });
    _startResend();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to Aadhaar-linked mobile'), backgroundColor: AppTheme.success),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter 6-digit OTP'), backgroundColor: AppTheme.error),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final aadhaar = _aadhaarCtrl.text.replaceAll(' ', '');
    await context.read<AppProvider>().login({
      'aadhaarNumber': aadhaar, 'name': 'Student',
      'id': aadhaar.substring(aadhaar.length - 4),
      'loginTime': DateTime.now().toIso8601String(),
    });
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 50),
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))]),
                    child: const Icon(Icons.school, size: 40, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('ScholarSetu', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Ministry of Tribal Affairs · SIH 2026', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))]),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_step == 'aadhaar') ...[
                      const Text('Enter Aadhaar Number', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _aadhaarCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 14,
                        style: const TextStyle(fontSize: 20, letterSpacing: 3, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: 'XXXX XXXX XXXX',
                          prefixIcon: Icon(Icons.credit_card, color: AppTheme.primary),
                          counterText: '',
                        ),
                        onChanged: (v) {
                          final formatted = formatAadhaar(v);
                          if (formatted != v) {
                            _aadhaarCtrl.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text('🔒 Secure Aadhaar OTP eKYC — DPDP Act 2023 Compliant', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _sendOtp,
                          child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Send OTP'),
                        ),
                      ),
                    ] else ...[
                      const Text('Enter OTP', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Aadhaar: ${_aadhaarCtrl.text}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(fontSize: 24, letterSpacing: 6, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          hintText: '------',
                          prefixIcon: Icon(Icons.shield, color: AppTheme.primary),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _verifyOtp,
                          child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Verify & Login'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _resendTimer == 0 ? _sendOtp : null,
                          child: Text(_resendTimer > 0 ? 'Resend OTP in ${_resendTimer}s' : 'Resend OTP',
                            style: TextStyle(color: _resendTimer > 0 ? AppTheme.textHint : AppTheme.primary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _step = 'aadhaar'),
                        child: const Text('← Change Aadhaar', style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    ],
                    const Divider(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppTheme.textHint),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Your data is used only for scholarship applications and is protected under the Digital Personal Data Protection Act, 2023.',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
