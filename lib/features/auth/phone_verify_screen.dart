import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/format_utils.dart';

/// 전화번호 인증 화면
class PhoneVerifyScreen extends ConsumerStatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final _nameController = TextEditingController(text: '김테니');
  final _emailController = TextEditingController(text: 'tennis_friend@kakao.com');
  final _phoneController = TextEditingController(text: '010-1234-5678');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 개발 단계: 정보 확인 없이 익명 인증으로 로그인 후 온보딩 화면으로 이동
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 개발 단계: 익명 인증으로 임시 사용자 생성
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        if (userCredential.user != null) {
          // 온보딩 화면으로 이동
          if (mounted) {
            context.pushReplacement('/onboarding');
            return;
          }
        }
      } catch (e) {
        // 익명 인증 실패 시에도 온보딩으로 이동 (개발 단계)
        if (mounted) {
          context.pushReplacement('/onboarding');
          return;
        }
      }
      
      // 익명 인증이 완료되지 않았어도 온보딩으로 이동 (개발 단계)
      if (mounted) {
        context.pushReplacement('/onboarding');
      }
    } catch (e) {
      // 개발 단계: 에러가 발생해도 온보딩으로 이동
      if (mounted) {
        context.pushReplacement('/onboarding');
      }
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
    const backgroundColor = Color(0xFFFDFDFD);
    const primaryGreen = Color(0xFF6A994E);
    const textMain = Color(0xFF333333);
    const textSecondary = Color(0xFFCCCCCC);
    const borderLight = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    // 진행 표시기 (4단계 중 2단계)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 헤드라인
                    const Text(
                      '회원 정보 확인',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        height: 1.2,
                        letterSpacing: -0.015,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '카카오 계정의 정보가 정확한지 확인하고, 필요하다면 수정해주세요.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(
                          textMain.red,
                          textMain.green,
                          textMain.blue,
                          0.8,
                        ),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 입력 필드들
                    Column(
                      children: [
                        // 이름
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '이름',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: backgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderLight),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: primaryGreen, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: textMain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // 이메일
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '이메일',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: backgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderLight),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: primaryGreen, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: textMain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // 휴대폰 번호
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '휴대폰 번호',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                                // 전화번호 포맷팅 (010-1234-5678)
                                TextInputFormatter.withFunction((oldValue, newValue) {
                                  final text = newValue.text;
                                  if (text.isEmpty) return newValue;
                                  
                                  final formatted = FormatUtils.formatPhoneNumber(text);
                                  return TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(offset: formatted.length),
                                  );
                                }),
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: backgroundColor,
                                hintText: '010-1234-5678',
                                hintStyle: const TextStyle(color: textSecondary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderLight),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: primaryGreen, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: textMain,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 100), // 하단 버튼 공간
                  ],
                ),
              ),
            ),
            // 하단 고정 버튼
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Color.fromRGBO(
                      borderLight.red,
                      borderLight.green,
                      borderLight.blue,
                      0.5,
                    ),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '다음',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

