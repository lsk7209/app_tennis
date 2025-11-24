import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/providers/auth_providers.dart';

/// 온보딩 화면
/// 닉네임, 지역(집/직장), NTRP, 동의 입력
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedNtrp;
  bool _agreedTerms = false;
  bool _agreedPrivacy = false;
  bool _agreedMarketing = false;
  bool _isLoading = false;
  
  // 전체 동의 상태 계산
  bool get _agreedAll => _agreedTerms && _agreedPrivacy && _agreedMarketing;
  
  // 전체 동의 토글
  void _toggleAllAgreements(bool? value) {
    final allAgreed = value ?? false;
    setState(() {
      _agreedTerms = allAgreed;
      _agreedPrivacy = allAgreed;
      _agreedMarketing = allAgreed;
    });
  }
  
  // NTRP 옵션
  final List<String> _ntrpOptions = ['2.0', '2.5', '3.0', '3.5', '4.0', '4.5'];

  @override
  void initState() {
    super.initState();
    _selectedNtrp = '3.0'; // 기본값
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // 개발 단계: 폼 검증 및 이용약관 동의 체크 우회
    // TODO: 실제 저장 로직 연동 완료 후 주석 해제
    // if (!_formKey.currentState!.validate()) return;
    // if (!_agreedTerms || !_agreedPrivacy) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('필수 약관에 동의해주세요')),
    //   );
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });

    // 개발 단계: 저장 로직 우회하고 바로 다음 화면으로 이동
    await Future.delayed(const Duration(milliseconds: 300)); // 로딩 효과를 위한 짧은 딜레이

    if (mounted) {
      context.pushReplacement('/home');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // TODO: 실제 저장 로직 연동 완료 후 주석 해제
    // try {
    //   final userRepo = ref.read(userRepositoryProvider);
    //   final ntrpValue = double.tryParse(_selectedNtrp ?? '3.0') ?? 3.0;
    //   await userRepo.saveOnboarding(
    //     nickname: _nicknameController.text.trim(),
    //     region: RegionModel(
    //       home: _locationController.text.trim(),
    //       work: _locationController.text.trim(), // 주요 활동 지역을 집/직장 모두에 사용
    //     ),
    //     ntrp: ntrpValue,
    //   );

    //   if (mounted) {
    //     context.pushReplacement('/home');
    //   }
    // } on AppException catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(e.message)),
    //     );
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('저장에 실패했습니다: $e')),
    //     );
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // 개발 단계: 인증 체크 우회 - 익명 인증이 실패해도 온보딩 화면 표시
        // TODO: 실제 인증 연동 완료 후 주석 해제
        // if (user == null) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (mounted) {
        //       context.go('/auth');
        //     }
        //   });
        //   return const Scaffold(
        //     body: Center(
        //       child: CircularProgressIndicator(),
        //     ),
        //   );
        // }

        // 개발 단계: 인증 여부와 관계없이 온보딩 화면 표시
        return _buildOnboardingForm();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        // 개발 단계: 에러가 발생해도 온보딩 화면 표시
        return _buildOnboardingForm();
        // TODO: 실제 인증 연동 완료 후 주석 해제
        // return Scaffold(
        //   body: Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text('오류: $error'),
        //         const SizedBox(height: 16),
        //         ElevatedButton(
        //           onPressed: () => context.go('/auth'),
        //           child: const Text('로그인 화면으로'),
        //         ),
        //       ],
        //     ),
        //   ),
        // );
      },
    );
  }

  Widget _buildOnboardingForm() {
    const pointGreen = Color(0xFF4CAF50);
    const primaryOrange = Color(0xFFFFA726);
    const borderLight = Color(0xFFEAEAEA);
    const textMain = Color(0xFF333333);
    const textSecondary = Color(0xFFAAAAAA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textMain),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '프로필 설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 진행 표시기 (3단계 중 3단계)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: borderLight,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: borderLight,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: pointGreen,
                  ),
                ),
              ],
            ),
          ),
          
          // 메인 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 헤드라인
                    const Text(
                      '거의 다 왔어요!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '앱에서 사용할 프로필을 설정해주세요.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // 닉네임 입력
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '닉네임',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            hintText: '앱에서 사용할 이름을 입력해주세요.',
                            hintStyle: const TextStyle(color: textSecondary),
                            filled: true,
                            fillColor: Colors.white,
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
                              borderSide: const BorderSide(color: pointGreen, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
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
                    const SizedBox(height: 32),
                    
                    // NTRP 선택
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '테니스 실력 (NTRP)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textMain,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                // 도움말 표시
                              },
                              icon: const Icon(Icons.help_outline, size: 16, color: textSecondary),
                              label: const Text(
                                '모르겠어요',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // NTRP 라디오 버튼 그리드
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: _ntrpOptions.length,
                          itemBuilder: (context, index) {
                            final ntrp = _ntrpOptions[index];
                            final isSelected = _selectedNtrp == ntrp;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedNtrp = ntrp;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? pointGreen : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? pointGreen : borderLight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    ntrp,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : textMain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // 주요 활동 지역
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '주요 활동 지역',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: '자주 테니스를 치는 동네(읍/면/동) 입력',
                            hintStyle: const TextStyle(color: textSecondary),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search, color: textSecondary),
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
                              borderSide: const BorderSide(color: pointGreen, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
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
                    
                    // 체크박스들
                    Column(
                      children: [
                        // 전체 동의 체크박스
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: borderLight,
                                width: 1,
                              ),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _toggleAllAgreements(!_agreedAll),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _agreedAll,
                                  onChanged: _toggleAllAgreements,
                                  activeColor: pointGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    '전체 동의',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCheckboxTile(
                          value: _agreedTerms,
                          onChanged: (value) {
                            setState(() => _agreedTerms = value ?? false);
                            // 개별 체크박스 변경 시 전체 동의 상태도 업데이트
                          },
                          title: '(필수) 서비스 이용약관 동의',
                          pointGreen: pointGreen,
                        ),
                        const SizedBox(height: 12),
                        _buildCheckboxTile(
                          value: _agreedPrivacy,
                          onChanged: (value) {
                            setState(() => _agreedPrivacy = value ?? false);
                            // 개별 체크박스 변경 시 전체 동의 상태도 업데이트
                          },
                          title: '(필수) 개인정보 처리방침 동의',
                          pointGreen: pointGreen,
                        ),
                        const SizedBox(height: 12),
                        _buildCheckboxTile(
                          value: _agreedMarketing,
                          onChanged: (value) {
                            setState(() => _agreedMarketing = value ?? false);
                            // 개별 체크박스 변경 시 전체 동의 상태도 업데이트
                          },
                          title: '(선택) 마케팅 정보 수신 동의',
                          pointGreen: pointGreen,
                        ),
                      ],
                    ),
                    
                    // 하단 여백 (버튼 공간 확보)
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 하단 고정 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              _isLoading ? '처리 중...' : '시작하기',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required Color pointGreen,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: pointGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xFFAAAAAA),
          ),
        ],
      ),
    );
  }
}
