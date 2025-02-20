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


  final List<String> _regions = [
    '서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종',
    '경기남부', '경기북부', '강원영서', '강원영동', '충북', '충남', 
    '전북', '전남', '경북', '경남', '제주'
  ];
  
  final List<String> _symptoms = [
    '치매', '섬망', '욕창', '하반신마비', '상반신마비', '전신마비',
    '와상환자', '기저귀케어', '의식없음', '석션', '피딩', '소변줄', 
    '장루', '야간집중돌봄', '전염성', '파킨슨', '정신질환', '투석', '재활'
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
        Uri.parse('http://10.0.2.2:8000/signup/foreign'),
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

                _buildDateSelection("간병 시작일", _startDate, (date) {
                  setState(() {
                    _startDate = date;
                  });
                }),

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
                _buildMultiSelect("간병 가능 지역", _regions, _selectedRegions),
                _buildMultiSelect("간병 가능 질환", _symptoms, _selectedSymptoms),
                _buildDropdown("환자의 보행 가능 여부", _canWalkPatient, ['걸을 수 있음', '걸을 수 없음', '상관없음'],
                    (value) => setState(() => _canWalkPatient = value)),
                _buildDropdown("선호하는 환자 성별", _preferSex, ['남성', '여성', '상관없음'],
                    (value) => setState(() => _preferSex = value)),
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


  Widget _buildMultiSelect(
      String label, List<String> allItems, List<String> selectedItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ExpansionTile(
              title: Text('${selectedItems.length} 선택됨',
                  style: TextStyle(fontSize: 16)),
              children: allItems.map((item) {
                return CheckboxListTile(
                  title: Text(item),
                  value: selectedItems.contains(item),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        selectedItems.add(item);
                      } else {
                        selectedItems.remove(item);
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
}
