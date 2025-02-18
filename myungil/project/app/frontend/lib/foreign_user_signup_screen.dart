import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'login_screen.dart';

class ForeignUserSignupScreen extends StatefulWidget {
  @override
  _ForeignUserSignupScreenState createState() =>
      _ForeignUserSignupScreenState();
}

class _ForeignUserSignupScreenState extends State<ForeignUserSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController(); // 🔹 추가됨 (나이 입력)

  DateTime _birthday = DateTime.now();
  int _age = 0;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _sex = '남성';
  String _spot = '병원';
  List<String> _selectedRegions = [];
  String _canWalkPatient = '걸을 수 없음';
  String _preferSex = '남성';
  List<String> _selectedSymptoms = [];
  bool _canCareForImmobile = false;
  String _smoking = '비흡연';

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://172.30.1.53:8000/signup/foreign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'phonenumber': _phoneNumberController.text,
          'birthday': _birthday.toIso8601String().split('T')[0],
          'age': int.parse(_ageController.text), // 🔹 수정됨
          'sex': _sex,
          'startdate': _startDate.toIso8601String().split('T')[0],
          'enddate': _endDate.toIso8601String().split('T')[0],
          'region': _selectedRegions.join(','),
          'spot': _spot,
          'height': int.parse(_heightController.text),
          'weight': int.parse(_weightController.text),
          'symptoms': _selectedSymptoms.join(','),
          'canwalkpatient': _canWalkPatient,
          'prefersex': _preferSex,
          'smoking': _smoking,
          'can_care_for_immobile': _canCareForImmobile,
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

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("간병인 회원가입")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_emailController, "이메일"),
                _buildTextField(_passwordController, "비밀번호", isPassword: true),
                _buildTextField(_confirmPasswordController, "비밀번호 확인",
                    isPassword: true),
                _buildTextField(_nameController, "이름"),
                _buildTextField(_phoneNumberController, "전화번호",
                    keyboardType: TextInputType.phone),


                _buildDateSelection("생년월일", _birthday, (date) {
                  setState(() {
                    _birthday = date;
                    _age = _calculateAge(date);
                    _ageController.text = _age.toString(); // 🔹 나이 필드 자동 업데이트
                  });
                }),

                
                _buildTextField(
                  _ageController,
                  "나이",
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),

                // 📌 간병 시작일 선택
                _buildDateSelection("간병 시작일", _startDate, (date) {
                  setState(() {
                    _startDate = date;
                  });
                }),

                // 📌 간병 종료일 선택
                _buildDateSelection("간병 종료일", _endDate, (date) {
                  setState(() {
                    _endDate = date;
                  });
                }),

                _buildDropdown("성별", _sex, ['남성', '여성'],
                    (value) => setState(() => _sex = value)),
                _buildTextField(_heightController, "키 (cm)",
                    keyboardType: TextInputType.number),
                _buildTextField(_weightController, "몸무게 (kg)",
                    keyboardType: TextInputType.number),
                _buildDropdown("간병 가능 장소", _spot, ['병원', '집', '둘 다'],
                    (value) => setState(() => _spot = value)),
                _buildDropdown("흡연 여부", _smoking, ['비흡연', '흡연'],
                    (value) => setState(() => _smoking = value)),

                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: _signup,
                    child: const Text("가입하기", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelection(
      String label, DateTime selectedDate, Function(DateTime) onDateChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDropdownYear(selectedDate, onDateChanged),
              _buildDropdownMonth(selectedDate, onDateChanged),
              _buildDropdownDay(selectedDate, onDateChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownYear(
      DateTime selectedDate, Function(DateTime) onDateChanged) {
    return DropdownButton<String>(
      value: selectedDate.year.toString(),
      items: List.generate(100, (index) {
        int year = DateTime.now().year - index;
        return DropdownMenuItem(value: year.toString(), child: Text("$year"));
      }),
      onChanged: (String? newValue) {
        setState(() {
          onDateChanged(DateTime(
              int.parse(newValue!), selectedDate.month, selectedDate.day));
        });
      },
    );
  }

  Widget _buildDropdownMonth(
      DateTime selectedDate, Function(DateTime) onDateChanged) {
    return DropdownButton<String>(
      value: selectedDate.month.toString().padLeft(2, '0'),
      items: List.generate(12, (index) {
        int month = index + 1;
        return DropdownMenuItem(
            value: month.toString().padLeft(2, '0'), child: Text("$month"));
      }),
      onChanged: (String? newValue) {
        setState(() {
          onDateChanged(DateTime(
              selectedDate.year, int.parse(newValue!), selectedDate.day));
        });
      },
    );
  }

  Widget _buildDropdownDay(
      DateTime selectedDate, Function(DateTime) onDateChanged) {
    return DropdownButton<String>(
      value: selectedDate.day.toString().padLeft(2, '0'),
      items: List.generate(31, (index) {
        int day = index + 1;
        return DropdownMenuItem(
            value: day.toString().padLeft(2, '0'), child: Text("$day"));
      }),
      onChanged: (String? newValue) {
        setState(() {
          onDateChanged(DateTime(
              selectedDate.year, selectedDate.month, int.parse(newValue!)));
        });
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, bool readOnly = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? '$label을 입력해주세요' : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((String item) =>
                DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (String? newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }
}
