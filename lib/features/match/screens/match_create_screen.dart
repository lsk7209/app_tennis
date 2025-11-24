import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/utils/date_utils.dart' as app_date;

/// 매칭 등록 화면
class MatchCreateScreen extends ConsumerStatefulWidget {
  const MatchCreateScreen({super.key});

  @override
  ConsumerState<MatchCreateScreen> createState() => _MatchCreateScreenState();
}

class _MatchCreateScreenState extends ConsumerState<MatchCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _matchType = '복식'; // 단식, 복식
  int _headcount = 4; // 2, 3, 4
  double _ntrpMin = 2.5;
  double _ntrpMax = 4.0;
  final Map<String, bool> _facilities = {
    'parking': false,
    'balls': true, // 기본값
    'water': false,
    'racket': false,
    'etc': false,
  };
  bool _isLoading = false;

  @override
  void dispose() {
    _regionController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // 시작 시간이 변경되면 종료 시간이 없거나 시작 시간보다 이전이면 자동으로 설정
        if (_endTime == null || 
            _endTime!.hour < picked.hour || 
            (_endTime!.hour == picked.hour && _endTime!.minute <= picked.minute)) {
          _endTime = TimeOfDay(
            hour: (picked.hour + 2) % 24,
            minute: picked.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 시작 시간을 선택해주세요')),
      );
      return;
    }
    
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay(
        hour: (_startTime!.hour + 2) % 24,
        minute: _startTime!.minute,
      ),
    );
    if (picked != null) {
      // 종료 시간이 시작 시간보다 늦은지 확인
      if (picked.hour < _startTime!.hour || 
          (picked.hour == _startTime!.hour && picked.minute <= _startTime!.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('종료 시간은 시작 시간보다 늦어야 합니다')),
        );
        return;
      }
      
      setState(() {
        _endTime = picked;
      });
    }
  }


  Future<void> _handleSubmit() async {
    // 개발 단계: 로그인 체크 우회
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('개발 모드: 로그인 없이 매칭 등록 진행');
    } else {
      print('현재 로그인 사용자: ${currentUser.uid}');
    }

    // 폼 검증 (null 안전성 체크)
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      print('폼 검증 실패');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('입력 정보를 확인해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // 필수 필드 확인
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜를 선택해주세요')),
      );
      return;
    }
    
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작 시간을 선택해주세요')),
      );
      return;
    }
    
    if (_endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료 시간을 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('종료 시간은 시작 시간보다 늦어야 합니다')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final region = _regionController.text.trim();
      if (region.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치를 입력해주세요')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('매칭 등록 시작:');
      print('  - region: $region');
      print('  - startTime: $startDateTime');
      print('  - endTime: $endDateTime');
      print('  - ntrpMin: $_ntrpMin');
      print('  - ntrpMax: $_ntrpMax');
      print('  - facilities: ${_facilities}');
      
      final matchRepo = ref.read(matchRepositoryProvider);
      print('MatchRepository 인스턴스 생성 완료');
      
      print('createMatch 호출 시작...');
      final matchId = await matchRepo.createMatch(
        region: region,
        startTime: startDateTime,
        endTime: endDateTime,
        ntrpMin: _ntrpMin,
        ntrpMax: _ntrpMax,
        facilities: FacilitiesModel(
          parking: _facilities['parking']!,
          balls: _facilities['balls']!,
          water: _facilities['water']!,
          racket: _facilities['racket']!,
          etc: _facilities['etc']!,
        ),
      );

      print('매칭 등록 성공: matchId=$matchId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('매칭이 등록되었습니다'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // 잠시 대기 후 화면 닫기
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.pop();
        }
      }
    } on FirestoreException catch (e) {
      print('매칭 등록 실패 (FirestoreException): ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firestore 오류: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      print('매칭 등록 실패 (AuthException): ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증 오류: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '로그인',
              textColor: Colors.white,
              onPressed: () {
                context.go('/auth');
              },
            ),
          ),
        );
      }
    } on AppException catch (e) {
      print('매칭 등록 실패 (AppException): ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('등록 실패: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('매칭 등록 실패 (예외): $e');
      print('예외 타입: ${e.runtimeType}');
      print('스택 트레이스: $stackTrace');
      if (mounted) {
        final errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('등록에 실패했습니다: ${errorMessage.length > 100 ? errorMessage.substring(0, 100) + "..." : errorMessage}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
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
    const backgroundColor = Color(0xFFF8F7F5);
    const primaryOrange = Color(0xFFFFA726);
    const activeGreen = Color(0xFF4CAF50);
    const textMain = Color(0xFF333333);
    const textSecondary = Color(0xFF9CA3AF);
    const borderLight = Color(0xFFE0E0E0);
    const componentBg = Colors.white;
    const componentInactive = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(
          backgroundColor.red,
          backgroundColor.green,
          backgroundColor.blue,
          0.8,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textMain),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '매칭 등록하기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            const SizedBox(height: 16),
            // 날짜/시간 입력
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '날짜/시간',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 8),
                // 날짜 선택
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: componentBg,
                            border: Border.all(color: borderLight),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedDate != null
                                      ? app_date.AppDateUtils.formatDate(_selectedDate!)
                                      : '날짜를 선택하세요',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedDate != null
                                        ? textMain
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: componentBg,
                        border: Border(
                          top: BorderSide(color: borderLight),
                          right: BorderSide(color: borderLight),
                          bottom: BorderSide(color: borderLight),
                          left: BorderSide.none,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 시작 시간 선택
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectStartTime,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: componentBg,
                            border: Border.all(color: borderLight),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _startTime != null
                                      ? '시작: ${_startTime!.format(context)}'
                                      : '시작 시간을 선택하세요',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _startTime != null
                                        ? textMain
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: componentBg,
                        border: Border(
                          top: BorderSide(color: borderLight),
                          right: BorderSide(color: borderLight),
                          bottom: BorderSide(color: borderLight),
                          left: BorderSide.none,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 종료 시간 선택
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectEndTime,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: componentBg,
                            border: Border.all(color: borderLight),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _endTime != null
                                      ? '종료: ${_endTime!.format(context)}'
                                      : '종료 시간을 선택하세요',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _endTime != null
                                        ? textMain
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: componentBg,
                        border: Border(
                          top: BorderSide(color: borderLight),
                          right: BorderSide(color: borderLight),
                          bottom: BorderSide(color: borderLight),
                          left: BorderSide.none,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 위치 입력
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '위치',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _regionController,
                        decoration: InputDecoration(
                          hintText: '장소를 검색하거나 선택하세요',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: componentBg,
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            borderSide: const BorderSide(color: borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            borderSide: const BorderSide(color: borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            borderSide: const BorderSide(color: primaryOrange, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16, color: textMain),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '장소를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: componentBg,
                            border: Border(
                              top: BorderSide(color: borderLight),
                              right: BorderSide(color: borderLight),
                              bottom: BorderSide(color: borderLight),
                              left: BorderSide.none,
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: const Icon(
                            Icons.map,
                            color: textSecondary,
                          ),
                        ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 유형 및 인원 선택 (카드 형태)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: componentBg,
                borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 유형
                  const Text(
                    '유형',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: componentInactive,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ToggleOption(
                            label: '단식',
                            isSelected: _matchType == '단식',
                            onTap: () => setState(() => _matchType = '단식'),
                          ),
                        ),
                        Expanded(
                          child: _ToggleOption(
                            label: '복식',
                            isSelected: _matchType == '복식',
                            onTap: () => setState(() => _matchType = '복식'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 인원
                  const Text(
                    '인원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: componentInactive,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ToggleOption(
                            label: '2명',
                            isSelected: _headcount == 2,
                            onTap: () => setState(() => _headcount = 2),
                          ),
                        ),
                        Expanded(
                          child: _ToggleOption(
                            label: '3명',
                            isSelected: _headcount == 3,
                            onTap: () => setState(() => _headcount = 3),
                          ),
                        ),
                        Expanded(
                          child: _ToggleOption(
                            label: '4명',
                            isSelected: _headcount == 4,
                            onTap: () => setState(() => _headcount = 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // NTRP 범위
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: componentBg,
                borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NTRP 범위',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textMain,
                        ),
                      ),
                      Text(
                        '${_ntrpMin.toStringAsFixed(1)} - ${_ntrpMax.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // RangeSlider를 사용한 직관적인 범위 선택 (0.5 단위)
                  RangeSlider(
                    values: RangeValues(_ntrpMin, _ntrpMax),
                    min: 1.0,
                    max: 7.0,
                    divisions: 12, // 0.5 단위로 선택 (6.0 / 0.5 = 12)
                    activeColor: primaryOrange,
                    inactiveColor: componentInactive,
                    labels: RangeLabels(
                      _ntrpMin.toStringAsFixed(1),
                      _ntrpMax.toStringAsFixed(1),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        // 0.5 단위로 반올림
                        _ntrpMin = (values.start * 2).round() / 2.0;
                        _ntrpMax = (values.end * 2).round() / 2.0;
                      });
                    },
                  ),
                  // NTRP 레벨 표시 (1.0 ~ 7.0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                        Text(
                          '7.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 편의시설
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: componentBg,
                borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '편의시설',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                    children: [
                      _FacilityGridItem(
                        emoji: '🅿️',
                        label: '주차',
                        isSelected: _facilities['parking']!,
                        onTap: () => setState(() => _facilities['parking'] = !_facilities['parking']!),
                        activeGreen: activeGreen,
                        componentInactive: componentInactive,
                      ),
                      _FacilityGridItem(
                        emoji: '🎾',
                        label: '공',
                        isSelected: _facilities['balls']!,
                        onTap: () => setState(() => _facilities['balls'] = !_facilities['balls']!),
                        activeGreen: activeGreen,
                        componentInactive: componentInactive,
                      ),
                      _FacilityGridItem(
                        emoji: '💧',
                        label: '물',
                        isSelected: _facilities['water']!,
                        onTap: () => setState(() => _facilities['water'] = !_facilities['water']!),
                        activeGreen: activeGreen,
                        componentInactive: componentInactive,
                      ),
                      _FacilityGridItem(
                        emoji: '🪶',
                        label: '라켓',
                        isSelected: _facilities['racket']!,
                        onTap: () => setState(() => _facilities['racket'] = !_facilities['racket']!),
                        activeGreen: activeGreen,
                        componentInactive: componentInactive,
                      ),
                      _FacilityGridItem(
                        emoji: '✳',
                        label: '기타',
                        isSelected: _facilities['etc']!,
                        onTap: () => setState(() => _facilities['etc'] = !_facilities['etc']!),
                        activeGreen: activeGreen,
                        componentInactive: componentInactive,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 메모
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '메모',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _memoController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: '매치에 대한 추가 정보를 입력하세요. (예: 참가비, 준비물 등)',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: componentBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: primaryOrange, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(fontSize: 16, color: textMain),
                ),
              ],
            ),
            
            // 하단 여백 (버튼 공간)
            const SizedBox(height: 100),
          ],
        ),
      ),
      ),
      // 하단 고정 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              elevation: 8,
            ),
            child: Text(
              _isLoading ? '등록 중...' : '등록 완료',
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
}

/// 토글 옵션 버튼
class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const componentBg = Colors.white;
    const textMain = Color(0xFF333333);
    const textSecondary = Color(0xFF9CA3AF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? componentBg : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? textMain : textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 편의시설 그리드 아이템
class _FacilityGridItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeGreen;
  final Color componentInactive;

  const _FacilityGridItem({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeGreen,
    required this.componentInactive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: isSelected
                ? Color.fromRGBO(
                    activeGreen.red,
                    activeGreen.green,
                    activeGreen.blue,
                    0.1,
                  )
                : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? activeGreen : componentInactive,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? activeGreen : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

