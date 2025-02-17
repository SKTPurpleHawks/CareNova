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

  DateTime _birthday = DateTime.now();
  int _age = 0;
  DateTime _startDate = DateTime.now(); // 추가
  DateTime _endDate = DateTime.now();   // 추가
  String _sex = '남성';
  String _spot = '병원';
  List<String> _selectedRegions = [];
  String _canWalkPatient = '걸을 수 없음';
  String _preferSex = '남성';
  List<String> _selectedSymptoms = [];
  bool _canCareForImmobile = false; // 못 걷는 사람도 간병 가능 체크박스
  String _smoking = '비흡연';

  final List<String> _regions = [
    '서울',
    '부산',
    '대구',
    '인천',
    '광주',
    '대전',
    '울산',
    '세종',
    '경기남부',
    '경기북부',
    '강원영서',
    '강원영동',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주'
  ];
  final List<String> _symptoms = [
    '치매',
    '섬망',
    '욕창',
    '하반신마비',
    '상반신마비',
    '전신마비',
    '와상환자',
    '기저귀케어',
    '의식없음',
    '석션',
    '피딩',
    '소변줄',
    '장루',
    '야간집중돌봄',
    '전염성',
    '파킨슨',
    '정신질환',
    '투석',
    '재활'
  ];

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.0.12:8000/signup/foreign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'phonenumber': _phoneNumberController.text,
          'birthday': _birthday.toIso8601String().split('T')[0],
          'age': _age,
          'sex': _sex,
          'startdate': _startDate.toIso8601String().split('T')[0], // 추가
          'enddate': _endDate.toIso8601String().split('T')[0],     // 추가
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

  Future<void> _selectDate(
      BuildContext context, DateTime initialDate, Function(DateTime) onSelect) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        onSelect(picked);
        if (onSelect == (date) => _birthday = date) {
          _age = _calculateAge(picked);
        }
      });
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
      backgroundColor: Color(0xFFF8E8EE),
      appBar: AppBar(
        title: const Text("간병인 회원가입"),
        backgroundColor: Color(0xFFF8E8EE),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
              children: [
                _buildTextField(_emailController, "이메일"),
                _buildTextField(_passwordController, "비밀번호", isPassword: true),
                _buildTextField(_confirmPasswordController, "비밀번호 확인",
                    isPassword: true),
                _buildTextField(_nameController, "이름"),
                _buildTextField(_phoneNumberController, "전화번호",
                    keyboardType: TextInputType.phone),

                // 생년월일
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("생년월일", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _selectDate(context, _birthday, (date) {
                          setState(() {
                            _birthday = date;
                            _age = _calculateAge(date);
                          });
                        }),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('yyyy-MM-dd').format(_birthday),
                                  style: TextStyle(fontSize: 16)),
                              Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 나이
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text('나이(만 나이) : ${ _age}', style: TextStyle(fontSize: 16)),
                ),
                // 간병 시작일
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("간병 시작일", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _selectDate(context, _startDate, (date) {
                          setState(() {
                            _startDate = date;
                          });
                        }),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('yyyy-MM-dd').format(_startDate),
                                  style: TextStyle(fontSize: 16)),
                              Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 간병 종료일
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("간병 종료일", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _selectDate(context, _endDate, (date) {
                          setState(() {
                            _endDate = date;
                          });
                        }),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('yyyy-MM-dd').format(_endDate),
                                  style: TextStyle(fontSize: 16)),
                              Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                _buildDropdownGender(),
                _buildTextField(_heightController, "키 (cm)",
                    keyboardType: TextInputType.number),
                _buildTextField(_weightController, "몸무게 (kg)",
                    keyboardType: TextInputType.number),
                _buildDropdownSpot(),
                _buildDropdownRegions(),
                _buildDropdownSymptoms(),
                CheckboxListTile(
                  title: Text("🚶 못 걷는 사람도 간병 가능"),
                  value: _canCareForImmobile,
                  onChanged: (bool? value) {
                    setState(() {
                      _canCareForImmobile = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                _buildDropdownPreferSex(),

                // 흡연 여부
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("흡연 여부", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _smoking,
                          items: ['비흡연', '흡연'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _smoking = newValue!;
                            });
                          },
                          underline: SizedBox(), // 밑줄 제거
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: _signup,
                    child: const Text("가입하기",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
        children: [
          Text(label, style: TextStyle(fontSize: 16)), // 라벨 추가
          SizedBox(height: 5), // 라벨과 입력칸 사이 간격
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label을 입력해주세요';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownGender() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("성별", style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _sex,
              items: ['남성', '여성'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _sex = newValue!;
                });
              },
              underline: SizedBox(), // 밑줄 제거
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSpot() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("간병 가능 장소", style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _spot,
              items: ['병원', '집', '둘 다'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _spot = newValue!;
                });
              },
              underline: SizedBox(), // 밑줄 제거
            ),
          ),
        ],
      ),
    );
  }

  // 📌 간병 가능 지역 선택 (다중 선택)
  Widget _buildDropdownRegions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("간병 가능 지역", style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ExpansionTile(
              title: Text('지역 선택', style: TextStyle(fontSize: 16)),
              children: _regions.map((region) {
                return CheckboxListTile(
                  title: Text(region),
                  value: _selectedRegions.contains(region),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        _selectedRegions.add(region);
                      } else {
                        _selectedRegions.remove(region);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

// 📌 간병 가능 질환 선택 (다중 선택)
  Widget _buildDropdownSymptoms() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("간병 가능 질환", style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ExpansionTile(
              title: Text('질환 선택', style: TextStyle(fontSize: 16)),
              children: _symptoms.map((symptom) {
                return CheckboxListTile(
                  title: Text(symptom),
                  value: _selectedSymptoms.contains(symptom),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

// 📌 선호하는 환자 성별 선택 (드롭다운)
  Widget _buildDropdownPreferSex() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("선호하는 환자 성별", style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _preferSex,
              items: ['남성', '여성', '상관없음'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _preferSex = newValue!;
                });
              },
              underline: SizedBox(), // 밑줄 제거
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}
