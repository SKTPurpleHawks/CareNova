import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverSearchScreen extends StatefulWidget {
  const CaregiverSearchScreen({super.key});

  @override
  State<CaregiverSearchScreen> createState() => _CaregiverSearchScreenState();
}

class _CaregiverSearchScreenState extends State<CaregiverSearchScreen> {
  String _selectedOption = ''; // 선택된 옵션 저장

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF43C098); // 메인 컬러 (초록)
    final Color secondaryColor = Colors.white; // 선택되지 않은 카드 배경색
    final Color borderColor = Colors.grey; // 선택되지 않은 카드 테두리 색

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 220),

            // 제목
            Text(
              '어떤 도움을 드릴까요?',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 80),

            // 간병인 찾기 버튼
            _buildSelectionCard(
              text: '간병 일감을 찾고있어요',
              selected: _selectedOption == 'caregiver',
              onTap: () => setState(() => _selectedOption = 'caregiver'),
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              borderColor: borderColor,
            ),

            const SizedBox(height: 16),

            // 간병인을 찾고 계신가요? 버튼
            _buildSelectionCard(
              text: '간병인을 찾고있어요',
              selected: _selectedOption == 'guardian',
              onTap: () => setState(() => _selectedOption = 'guardian'),
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              borderColor: borderColor,
            ),

            const Spacer(), // 💡 하단 버튼을 아래로 밀어줌

            // 버튼 영역 (취소 & 다음)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 취소 버튼 (OutlinedButton)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context), // 이전 화면으로 이동
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                          color: Colors.grey, width: 1.5), // 테두리 추가
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16), // 버튼 간격 조정

                // 다음 버튼 (ElevatedButton)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedOption.isNotEmpty
                        ? () {
                            if (_selectedOption == 'caregiver') {
                              Navigator.pushNamed(context, '/login_caregiver');
                            } else {
                              Navigator.pushNamed(context, '/login_guardian');
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43C098), // 초록색
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '다음',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24), // 💡 버튼과 화면 하단 간격 추가
          ],
        ),
      ),
    );
  }

  /// 선택 카드 위젯 (버튼 대신 카드 스타일 적용)
  Widget _buildSelectionCard({
    required String text,
    required bool selected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color secondaryColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 100, // 박스 높이 늘리기
        padding: const EdgeInsets.symmetric(horizontal: 20), // 내부 패딩 유지
        decoration: BoxDecoration(
          color: selected ? primaryColor : secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primaryColor : borderColor, // 선택되지 않은 경우 회색 테두리
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(2, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
