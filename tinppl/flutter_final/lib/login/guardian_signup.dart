import 'package:flutter/material.dart';

class GuardianSignupScreen extends StatefulWidget {
  const GuardianSignupScreen({super.key});

  @override
  State<GuardianSignupScreen> createState() => _GuardianSignupScreenState();
}

class _GuardianSignupScreenState extends State<GuardianSignupScreen> {
  String? _selectedSex; // 성별 선택
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;

  final List<String> years = List.generate(100, (index) => (2024 - index).toString());
  final List<String> months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> days = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보호자 회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('이메일'),
              _buildTextField('비밀번호', obscureText: true),
              _buildTextField('비밀번호 확인', obscureText: true),
              _buildTextField('이름'),
              _buildTextField('전화번호', hintText: '010-0000-0000'),

              // 생년월일 필드 추가
              _buildBirthdateSelector(),

              // 성별 선택 추가
              _buildDropdownField('성별', options: ['남성', '여성'], onChanged: (value) => setState(() => _selectedSex = value)),


              const SizedBox(height: 24),

              // 가입하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('가입하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 생년월일 선택 UI (년도, 월, 일)
  Widget _buildBirthdateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('생년월일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField('년도', options: years, onChanged: (value) => setState(() => _selectedYear = value)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdownField('월', options: months, onChanged: (value) => setState(() => _selectedMonth = value)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdownField('일', options: days, onChanged: (value) => setState(() => _selectedDay = value)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, {String hintText = '', bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, {List<String>? options, ValueChanged<String?>? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: label,
          border: const OutlineInputBorder(),
        ),
        value: null,
        items: options?.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
