import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class ProtectorUserSignupScreen extends StatefulWidget {
  @override
  _ProtectorUserSignupScreenState createState() =>
      _ProtectorUserSignupScreenState();
}

class _ProtectorUserSignupScreenState
    extends State<ProtectorUserSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  
  String _sex = '남성';
  String message = "";

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          message = "비밀번호가 일치하지 않습니다.";
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.11.93:8000/signup/protector'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text,
          'name': nameController.text,
          'phonenumber': phoneNumberController.text,
          'birthday': selectedDate.toIso8601String().split('T')[0],
          'sex': _sex,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF43C098); // 메인 컬러 (초록)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '보호자 회원가입',
          style: GoogleFonts.notoSansKr(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(emailController, '이메일'),
              _buildTextField(passwordController, '비밀번호', obscureText: true),
              _buildTextField(confirmPasswordController, '비밀번호 확인',
                  obscureText: true),
              _buildTextField(nameController, '이름'),
              _buildTextField(phoneNumberController, '전화번호'),

              // 생년월일 입력 필드
              _buildBirthdateSelector(),
              const SizedBox(height: 20),

              // 성별 선택 필드
              _buildGenderSelectionWithLabel(),

              const SizedBox(height: 32),

              // 가입하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '가입하기',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildGenderSelectionWithLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("성별",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _sex = '남성'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: _sex == '남성' ? Color(0xFF43C098) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF43C098)),
                    ),
                    child: Center(
                      child: Text(
                        "남성",
                        style: TextStyle(
                          color:
                              _sex == '남성' ? Colors.white : Color(0xFF43C098),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _sex = '여성'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: _sex == '여성' ? Color(0xFF43C098) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF43C098)),
                    ),
                    child: Center(
                      child: Text(
                        "여성",
                        style: TextStyle(
                          color:
                              _sex == '여성' ? Colors.white : Color(0xFF43C098),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// **입력 필드 (이메일, 비밀번호, 이름 등)**
  Widget _buildTextField(TextEditingController controller, String label,
      {String hintText = '', bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black45,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// **생년월일 선택 UI**
  Widget _buildBirthdateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '생년월일',
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDropdownYear()),
            const SizedBox(width: 6),
            Expanded(child: _buildDropdownMonth()),
            const SizedBox(width: 6),
            Expanded(child: _buildDropdownDay()),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownYear() {
    return _buildDropdownField(
      '',
      List.generate(100, (index) => (DateTime.now().year - index).toString()),
      (newValue) => setState(() {
        selectedDate = DateTime(int.parse(newValue!), selectedDate.month,
            selectedDate.day);
      }),
    );
  }

  Widget _buildDropdownMonth() {
    return _buildDropdownField(
      '',
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0')),
      (newValue) => setState(() {
        selectedDate = DateTime(
            selectedDate.year, int.parse(newValue!), selectedDate.day);
      }),
    );
  }

  Widget _buildDropdownDay() {
    return _buildDropdownField(
      '',
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0')),
      (newValue) => setState(() {
        selectedDate = DateTime(
            selectedDate.year, selectedDate.month, int.parse(newValue!));
      }),
    );
  }


  Widget _buildDropdownField(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: options.first,
      items: options.map((value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
