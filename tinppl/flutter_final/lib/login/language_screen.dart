import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts 패키지 사용

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';
  final Color primaryColor = const Color(0xFF43C098); // 버튼 색상

  void _goToCaregiverSearchScreen() {
    Navigator.pushReplacementNamed(context, '/caregiver_search');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logoplain.png', // ✅ 로고 추가됨
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                'Select Your Language',
                style: GoogleFonts.notoSansKr(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _buildLanguageCard('English'),
              _buildLanguageCard('Korean'),
              _buildLanguageCard('Chinese'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _goToCaregiverSearchScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Next',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // TextButton(
              //   onPressed: () {
              //     Navigator.pushReplacementNamed(context, '/recorder_screen');
              //   },
              //   style: TextButton.styleFrom(
              //     foregroundColor: primaryColor,
              //   ),
              //   child: Text(
              //     'Record',
              //     style: GoogleFonts.notoSansKr(
              //       fontSize: 16,
              //       fontWeight: FontWeight.bold,
              //   ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(String language) {
    bool isSelected = _selectedLanguage == language;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor, width: 1.5),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(2, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.white : primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
