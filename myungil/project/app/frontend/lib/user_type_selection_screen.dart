import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'foreign_user_signup_screen.dart';
import 'protector_user_signup_screen.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  @override
  _UserTypeSelectionScreenState createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String _selectedOption = ''; // 선택된 옵션 저장

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF43C098); // 초록색
    final Color secondaryColor = Colors.white; // 기본 배경색
    final Color borderColor = Colors.grey; // 선택되지 않은 카드 테두리 색

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 160),

            // 타이틀
            Text(
              '어떤 도움을 드릴까요?',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 120),

            // "간병 일감을 찾고 있어요" 카드
            _buildSelectionCard(
              text: '간병 일감을 찾고 있어요',
              selected: _selectedOption == 'foreign',
              onTap: () => setState(() => _selectedOption = 'foreign'),
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              borderColor: borderColor,
            ),

            const SizedBox(height: 16),

            // "간병인을 찾고 있어요" 카드
            _buildSelectionCard(
              text: '간병인을 찾고 있어요',
              selected: _selectedOption == 'protector',
              onTap: () => setState(() => _selectedOption = 'protector'),
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              borderColor: borderColor,
            ),

            const Spacer(), // 하단 버튼을 밀어줌

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
                          color: Color.fromARGB(255, 113, 113, 113),
                          width: 1.5), // 테두리 추가
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

                // 다음 버튼 (선택해야 활성화됨)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedOption.isNotEmpty
                        ? () {
                            if (_selectedOption == 'foreign') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForeignUserSignupScreen()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProtectorUserSignupScreen()),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
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

            const SizedBox(height: 24), // 버튼과 화면 하단 간격 추가
          ],
        ),
      ),
    );
  }

  /// **선택 카드 UI (버튼 대신 카드 스타일 적용)**
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
        height: 100, // 카드 높이
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: selected ? primaryColor : secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(
                  color: primaryColor,
                  width: 2,
                )
              : null, // 선택되지 않았을 때 border 제거
          boxShadow: [
            BoxShadow(
              color: selected
                  ? primaryColor.withOpacity(0.4)
                  : borderColor.withOpacity(0.4), // 선택되지 않았을 때 약한 그림자
              blurRadius: selected ? 8 : 6, // 선택되었을 때 더 뚜렷한 블러
              spreadRadius: selected ? 1 : 0, // 선택되지 않았을 때 퍼짐 줄이기
              offset: selected
                  ? const Offset(2, 4)
                  : const Offset(1, 2), // 선택 여부에 따라 그림자 위치 조정
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
