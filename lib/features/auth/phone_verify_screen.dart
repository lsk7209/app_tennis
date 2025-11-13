import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_service_providers.dart';
import 'services/phone_auth_service.dart';
import '../../../core/errors/app_exceptions.dart';

/// 전화번호 인증 화면
class PhoneVerifyScreen extends ConsumerStatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isCodeSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _countdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = '전화번호를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneAuth = ref.read(phoneAuthServiceProvider);
      await phoneAuth.sendVerificationCode(phone);
      
      setState(() {
        _isCodeSent = true;
        _countdown = 60;
      });

      // 카운트다운 시작
      _startCountdown();
    } on AppException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '인증 코드 전송에 실패했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = '인증 코드를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneAuth = ref.read(phoneAuthServiceProvider);
      await phoneAuth.verifyCode(code);
      
      // 인증 성공 후 온보딩으로
      if (mounted) {
        context.pushReplacement('/onboarding');
      }
    } on AppException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '인증에 실패했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_countdown > 0) return;

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneAuth = ref.read(phoneAuthServiceProvider);
      await phoneAuth.resendCode(phone);
      
      setState(() {
        _countdown = 60;
      });
      _startCountdown();
    } catch (e) {
      setState(() {
        _errorMessage = '재전송에 실패했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전화번호 인증'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '전화번호를 인증해주세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '안전한 매칭을 위해 본인인증이 필요합니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              TextField(
                controller: _phoneController,
                enabled: !_isCodeSent,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '010-1234-5678',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              if (_isCodeSent) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: '인증 코드',
                    hintText: '6자리 코드',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_countdown > 0)
                      Text(
                        '${_countdown}초 후 재전송 가능',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _isLoading ? null : _resendCode,
                        child: const Text('인증 코드 재전송'),
                      ),
                  ],
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_isCodeSent ? _verifyCode : _sendCode),
                child: Text(_isLoading
                    ? '처리 중...'
                    : (_isCodeSent ? '인증 완료' : '인증 코드 전송')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

