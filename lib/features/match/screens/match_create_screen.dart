import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _ntrpMin = 3.0;
  double _ntrpMax = 5.0;
  final Map<String, bool> _facilities = {
    'parking': false,
    'balls': false,
    'water': false,
    'racket': false,
    'etc': false,
  };
  bool _isLoading = false;

  @override
  void dispose() {
    _regionController.dispose();
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
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 2),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜와 시간을 선택해주세요')),
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
        throw ValidationException('종료 시간은 시작 시간보다 늦어야 합니다');
      }

      final matchRepo = ref.read(matchRepositoryProvider);
      await matchRepo.createMatch(
        region: _regionController.text.trim(),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('매칭이 등록되었습니다')),
        );
        context.pop();
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
          SnackBar(content: Text('등록에 실패했습니다: $e')),
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
        title: const Text('매칭 등록'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _regionController,
                  decoration: const InputDecoration(
                    labelText: '장소',
                    hintText: '예: 서울시 강남구 테니스장',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '장소를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? '날짜 선택'
                              : app_date.AppDateUtils.formatDate(_selectedDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectStartTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _startTime == null
                              ? '시작 시간'
                              : _startTime!.format(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _selectEndTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _endTime == null
                        ? '종료 시간'
                        : _endTime!.format(context),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'NTRP 범위',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '최소: ${_ntrpMin.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Slider(
                            value: _ntrpMin,
                            min: 1.0,
                            max: _ntrpMax - 0.5,
                            divisions: 60,
                            onChanged: (value) {
                              setState(() {
                                _ntrpMin = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '최대: ${_ntrpMax.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Slider(
                            value: _ntrpMax,
                            min: _ntrpMin + 0.5,
                            max: 7.0,
                            divisions: 60,
                            onChanged: (value) {
                              setState(() {
                                _ntrpMax = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  '시설',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FacilityCheckbox(
                      label: '주차 가능',
                      value: _facilities['parking']!,
                      onChanged: (value) {
                        setState(() {
                          _facilities['parking'] = value;
                        });
                      },
                    ),
                    _FacilityCheckbox(
                      label: '공 제공',
                      value: _facilities['balls']!,
                      onChanged: (value) {
                        setState(() {
                          _facilities['balls'] = value;
                        });
                      },
                    ),
                    _FacilityCheckbox(
                      label: '물 제공',
                      value: _facilities['water']!,
                      onChanged: (value) {
                        setState(() {
                          _facilities['water'] = value;
                        });
                      },
                    ),
                    _FacilityCheckbox(
                      label: '라켓 대여',
                      value: _facilities['racket']!,
                      onChanged: (value) {
                        setState(() {
                          _facilities['racket'] = value;
                        });
                      },
                    ),
                    _FacilityCheckbox(
                      label: '기타',
                      value: _facilities['etc']!,
                      onChanged: (value) {
                        setState(() {
                          _facilities['etc'] = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: Text(_isLoading ? '등록 중...' : '매칭 등록'),
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

/// 시설 체크박스 위젯
class _FacilityCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FacilityCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
    );
  }
}

