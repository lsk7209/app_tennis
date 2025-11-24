import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 매칭 신청 다이얼로그
class MatchRequestDialog extends StatefulWidget {
  final Function(String introduction) onSubmit;

  const MatchRequestDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<MatchRequestDialog> createState() => _MatchRequestDialogState();
}

class _MatchRequestDialogState extends State<MatchRequestDialog> {
  final _introductionController = TextEditingController();
  final int _maxLength = 200;

  @override
  void dispose() {
    _introductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4CAF50);
    const backgroundColor = Color(0xFFF8F9FA);
    const textMain = Color(0xFF343A40);
    const textSecondary = Color(0xFF6C757D);
    const borderLight = Color(0xFFDEE2E6);
    const surfaceLight = Colors.white;

    return Container(
      decoration: const BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 바
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 40,
              height: 6,
              decoration: const BoxDecoration(
                color: borderLight,
                borderRadius: BorderRadius.all(Radius.circular(9999)),
              ),
            ),
          ),
          // 헤드라인
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '매칭 신청',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                  letterSpacing: -0.015,
                ),
              ),
            ),
          ),
          // 자기소개 입력
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '자기소개',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    TextField(
                      controller: _introductionController,
                      maxLines: 6,
                      maxLength: _maxLength,
                      decoration: InputDecoration(
                        hintText: '간단한 자기소개를 입력해주세요.',
                        hintStyle: const TextStyle(color: textSecondary),
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
                        contentPadding: const EdgeInsets.all(16),
                        counterText: '', // 기본 카운터 숨기기
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: textMain,
                        height: 1.5,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(_maxLength),
                      ],
                    ),
                    // 글자 수 표시
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _introductionController,
                        builder: (context, value, child) {
                          return Text(
                            '${value.text.length}/$_maxLength',
                            style: const TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 주의사항
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child:                   const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: textSecondary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '주의사항',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '본 매칭은 호스트의 승인이 필요합니다. 허위 정보 입력 시 불이익을 받을 수 있습니다.',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          ),
          // 버튼 그룹
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(
                        borderLight.red,
                        borderLight.green,
                        borderLight.blue,
                        0.5,
                      ),
                      foregroundColor: textMain,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '닫기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.015,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSubmit(_introductionController.text.trim());
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '신청 완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.015,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

