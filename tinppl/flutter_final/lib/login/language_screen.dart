import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  void _goToCaregiverSearchScreen() {
    Navigator.pushReplacementNamed(context, '/caregiver_search'); // 간병인 찾기 화면 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // 가로축 중앙 정렬
        children: [
      const SizedBox(height: 10), // 👈 위쪽 여백 추가
      const Text(
        'Language',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
          const SizedBox(height: 100), // 버튼 간격 추가
          _buildRadioTile('English'),
          _buildRadioTile('Korean'),
          _buildRadioTile('Chinese'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _goToCaregiverSearchScreen,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String language) {
    return ListTile(
      title: Text(language),
      leading: Radio<String>(
        value: language,
        groupValue: _selectedLanguage,
        onChanged: (String? value) {
          setState(() {
            _selectedLanguage = value!;
          });
        },
      ),
    );
  }
}

