import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/validation_utils.dart';

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
  final _homeRegionController = TextEditingController();
  final _workRegionController = TextEditingController();
  double _ntrp = 3.0;
  bool _agreed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _homeRegionController.dispose();
    _workRegionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이용약관에 동의해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.saveOnboarding(
        nickname: _nicknameController.text.trim(),
        region: RegionModel(
          home: _homeRegionController.text.trim(),
          work: _workRegionController.text.trim(),
        ),
        ntrp: _ntrp,
      );

      if (mounted) {
        context.pushReplacement('/home');
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장에 실패했습니다: $e')),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '프로필을 설정해주세요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    hintText: '닉네임을 입력하세요',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    if (!ValidationUtils.isValidNickname(value)) {
                      return '닉네임은 2-20자여야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _homeRegionController,
                  decoration: const InputDecoration(
                    labelText: '집 지역',
                    hintText: '예: 서울시 강남구',
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: (value) {
                    if (value == null || !ValidationUtils.isValidRegion(value)) {
                      return '집 지역을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _workRegionController,
                  decoration: const InputDecoration(
                    labelText: '직장 지역',
                    hintText: '예: 서울시 서초구',
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || !ValidationUtils.isValidRegion(value)) {
                      return '직장 지역을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'NTRP 레벨',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _ntrp.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                Slider(
                  value: _ntrp,
                  min: 1.0,
                  max: 7.0,
                  divisions: 60,
                  label: _ntrp.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _ntrp = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1.0 (초보)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '7.0 (프로)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CheckboxListTile(
                  value: _agreed,
                  onChanged: (value) {
                    setState(() {
                      _agreed = value ?? false;
                    });
                  },
                  title: const Text('이용약관 및 개인정보처리방침에 동의합니다'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: Text(_isLoading ? '저장 중...' : '시작하기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
