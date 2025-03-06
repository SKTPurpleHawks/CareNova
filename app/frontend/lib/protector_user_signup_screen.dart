import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';


/*
-------------------------------------------------------------------------
file_name : protector_user_signup_screen.dart                       

Developer                                                         
 ● Frontend : 최명일, 서민석
 ● backend : 최명일
 ● UI/UX : 서민석                                                     
                                                                  
description : 보호자의 회원가입 화면 
              앱에서 입력받은 데이터를 백엔드 서버로 전달해 데이터베이스에 저장
-------------------------------------------------------------------------
*/

class ProtectorUserSignupScreen extends StatefulWidget {
  @override
  _ProtectorUserSignupScreenState createState() =>
      _ProtectorUserSignupScreenState();
}

class _ProtectorUserSignupScreenState extends State<ProtectorUserSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  String _sex = '남성';
  String message = "";
  bool _isPrivacyAgreed = false;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.0.10:8000/signup/protector'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text,
          'password': _passwordController.text,
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
        centerTitle: true, // 중앙 정렬 필수
        title: Image.asset(
          'assets/images/textlogo.png', // 여기에 로고 이미지 경로 입력
          height: 25, // 원하는 높이 조정 가능
          fit: BoxFit.contain,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  "보호자 회원가입",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextField(emailController, '이메일'),
                SizedBox(height: 10),

                _buildTextField(_passwordController, '비밀번호', isPassword: true),
                SizedBox(height: 10),

                _buildTextField(_confirmPasswordController, '비밀번호 확인',
                    isPassword: true),
                SizedBox(height: 10),

                _buildTextField(nameController, '이름'),
                SizedBox(height: 10),

                _buildTextField(phoneNumberController, '전화번호'),

                // 생년월일 입력 필드
                _buildBirthdateSelector(),
                const SizedBox(height: 20),

                // 성별 선택 필드
                _buildGenderSelectionWithLabel(),

                const SizedBox(height: 32),
                SizedBox(height: 20),

// 개인정보 동의서 박스
                Container(
                  padding: EdgeInsets.all(12),
                  height: 150, // 박스 크기 조정 가능
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade50,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      '''본인은 CARENOVA 서비스 이용을 위해 환자의 개인정보를 제공함에 동의합니다.

1. 수집 항목: 보호자 및 환자의 성명, 연락처, 생년월일, 건강 상태 등
2. 이용 목적: 간병인 매칭 및 서비스 제공
3. 보유 기간: 서비스 이용 종료 또는 보호자 요청 시 파기
4. 동의 거부 시 서비스 이용이 제한될 수 있음''',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ),

                SizedBox(height: 10),

// 개인정보 동의 체크박스
                CheckboxListTile(
                  title: Text(
                    '위의 개인정보 수집 및 이용에 동의합니다. (필수)',
                    style: TextStyle(
                      fontSize: 14, // 원하는 크기로 조정 가능
                      fontWeight: FontWeight.w500, // 글씨 두께 조정 가능
                      color: Colors.black87, // 글씨 색상
                    ),
                  ),
                  value: _isPrivacyAgreed,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPrivacyAgreed = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 20),

                // 가입하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_isPrivacyAgreed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('개인정보 수집 및 이용에 동의해주세요.')),
                        );
                        return;
                      }
                      _signup(); // 기존 회원가입 처리 함수
                    },
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
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),
              ],
            ),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false,
      bool readOnly = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            readOnly: readOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: const Color(0xFF43C098), width: 2.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? '$label을 입력해주세요' : null,
          ),
        ],
      ),
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
        selectedDate = DateTime(
            int.parse(newValue!), selectedDate.month, selectedDate.day);
      }),
    );
  }

  Widget _buildDropdownMonth() {
    return _buildDropdownField(
      '',
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0')),
      (newValue) => setState(() {
        selectedDate =
            DateTime(selectedDate.year, int.parse(newValue!), selectedDate.day);
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
