import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class ForeignUserSignupScreen extends StatefulWidget {
  const ForeignUserSignupScreen({super.key});

  @override
  State<ForeignUserSignupScreen> createState() =>
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
  final _ageController = TextEditingController();

  bool _isPrivacyAgreed = false;
  DateTime? _birthday;
  int _age = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  String _sex = '남성';
  String _spot = '병원';
  List<String> _selectedRegions = [];
  String _canWalkPatient = '지원 불가능';
  String _preferSex = '남성';
  List<String> _selectedSymptoms = [];
  bool _canCareForImmobile = false;
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
    '하반신 마비',
    '상반신 마비',
    '전신 마비',
    '와상 환자',
    '기저귀 케어',
    '의식 없음',
    '석션',
    '피딩',
    '소변줄',
    '장루',
    '야간 집중 돌봄',
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
        Uri.parse('http://172.23.250.30:8000/signup/foreign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'phonenumber': _phoneNumberController.text,
          'birthday': _birthday?.toIso8601String().split('T')[0] ?? '',
          'age': int.parse(_ageController.text),
          'sex': _sex,
          'startdate': _startDate?.toIso8601String().split('T')[0] ?? '',
          'enddate': _endDate?.toIso8601String().split('T')[0] ?? '',
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

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // 중앙 정렬 필수
        // title: Image.asset(
        //   'assets/images/textlogo.png', // 여기에 로고 이미지 경로 입력
        //   height: 25, // 원하는 높이 조정 가능
        //   fit: BoxFit.contain,
        // ),
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
                  "간병인 회원가입",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextFieldWithLabel(_emailController, "이메일"),
                SizedBox(height: 10),
                _buildTextFieldWithLabel(_passwordController, "비밀번호",
                    isPassword: true),
                SizedBox(height: 10),
                _buildTextFieldWithLabel(_confirmPasswordController, "비밀번호 확인",
                    isPassword: true),
                SizedBox(height: 10),
                _buildTextFieldWithLabel(_nameController, "이름"),
                SizedBox(height: 10),
                _buildTextFieldWithLabel(_phoneNumberController, "전화번호",
                    keyboardType: TextInputType.phone),
                SizedBox(height: 10),
                _buildDateSelectionWithLabel("생년월일", _birthday, (date) {
                  setState(() {
                    _birthday = date;
                    _age = _calculateAge(date ?? DateTime.now());
                    _ageController.text = _age.toString(); // 🔹 나이 필드 자동 업데이트
                  });
                }),
                SizedBox(height: 10),
                _buildTextFieldWithLabel(
                  _ageController,
                  "나이",
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                _buildDateSelectionWithLabel2("간병 시작일", _startDate, (date) {
                  setState(() {
                    _startDate = date;
                  });
                }),
                SizedBox(height: 10),
                _buildDateSelectionWithLabel2("간병 종료일", _endDate, (date) {
                  setState(() {
                    _endDate = date;
                  });
                }),
                SizedBox(height: 10),
                _buildGenderSelectionWithLabel(),
                SizedBox(height: 10),
                _buildTextFieldWithLabel(_heightController, "키 (cm)",
                    keyboardType: TextInputType.number),
                SizedBox(height: 10),
                _buildTextFieldWithLabel(_weightController, "몸무게 (kg)",
                    keyboardType: TextInputType.number),
                SizedBox(height: 10),
                _buildDropdownWithLabel("간병 가능 장소", _spot, ['병원', '집', '둘 다'],
                    (value) => setState(() => _spot = value)),
                SizedBox(height: 10),
                _buildMultiSelectWithLabel(
                    "간병 가능 지역", _regions, _selectedRegions),
                SizedBox(height: 10),
                _buildMultiSelectWithLabel(
                    "간병 가능 질환", _symptoms, _selectedSymptoms),
                SizedBox(height: 10),
                _buildDropdownWithLabel(
                    "환자의 보행 지원 여부",
                    _canWalkPatient,
                    ['지원 가능', '지원 불가능', '상관 없음'],
                    (value) => setState(() => _canWalkPatient = value)),
                SizedBox(height: 10),
                _buildDropdownWithLabel(
                    "선호하는 환자 성별",
                    _preferSex,
                    ['남성', '여성', '상관 없음'],
                    (value) => setState(() => _preferSex = value)),
                SizedBox(height: 10),
                _buildDropdownWithLabel("흡연 여부", _smoking, ['비흡연', '흡연'],
                    (value) => setState(() => _smoking = value)),
                SizedBox(height: 30),
                SizedBox(height: 20),
// 개인정보 동의 박스
                Container(
                  padding: EdgeInsets.all(12),
                  height: 150, // 적절한 높이 설정
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade50,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      '''본인은 CARENOVA 서비스 이용을 위하여 아래와 같은 개인정보를 수집 및 이용하는 것에 동의합니다.

1. 수집하는 개인정보 항목
   - 필수정보: 성명, 생년월일, 성별, 연락처(전화번호, 이메일 주소), 신체 정보(키, 몸무게), 경력, 간병 가능 지역 및 장소, 간병 가능 질환 정보

2. 개인정보 수집 및 이용 목적
   - 회원 가입 및 관리
   - 간병 서비스 매칭 및 관련 정보 제공
   - 서비스 품질 향상 및 고객 응대

3. 개인정보 보유 및 이용 기간
   - 회원 탈퇴 시까지 또는 법령에 따른 보관 기간 동안 보관 후 즉시 파기됩니다.

※ 귀하는 위와 같은 개인정보 수집 및 이용에 대한 동의를 거부할 권리가 있으나, 동의 거부 시 회원 가입이 제한됩니다.''',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ),

                SizedBox(height: 10),
// 체크박스
                CheckboxListTile(
                  title: Text('위의 개인정보 수집 및 이용에 동의합니다. (필수)',
                      style: TextStyle(fontSize: 12, color: Colors.black87)),
                  value: _isPrivacyAgreed,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPrivacyAgreed = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF43C098),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (!_isPrivacyAgreed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('개인정보 수집 및 이용에 동의해주세요.')),
                        );
                        return;
                      }
                      _signup();
                    },
                    child: const Text("가입하기",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(height: 30),
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

  Widget _buildDateSelectionWithLabel(
      String label, DateTime? selectedDate, Function(DateTime?) onDateChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildDropdownYear(selectedDate, onDateChanged)),
              SizedBox(width: 10),
              Expanded(child: _buildDropdownMonth(selectedDate, onDateChanged)),
              SizedBox(width: 10),
              Expanded(child: _buildDropdownDay(selectedDate, onDateChanged)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionWithLabel2(
      String label, DateTime? selectedDate, Function(DateTime?) onDateChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildDropdownYear2(selectedDate, onDateChanged)),
              SizedBox(width: 10),
              Expanded(child: _buildDropdownMonth(selectedDate, onDateChanged)),
              SizedBox(width: 10),
              Expanded(child: _buildDropdownDay(selectedDate, onDateChanged)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownYear2(
      DateTime? selectedDate, Function(DateTime?) onDateChanged) {
    int currentYear = DateTime.now().year;

    return _buildDropdown<int>(
      selectedValue: selectedDate?.year,
      hintText: "년도",
      items: List.generate(
          100, (index) => currentYear + index), // 현재 연도부터 100년 뒤까지
      onChanged: (int? newValue) {
        if (newValue != null) {
          onDateChanged(DateTime(
              newValue, selectedDate?.month ?? 1, selectedDate?.day ?? 1));
        }
      },
    );
  }

  Widget _buildDropdown<T>(
      {T? selectedValue,
      required String hintText,
      required List<T> items,
      required Function(T?) onChanged}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          hint: Text(hintText, style: TextStyle(color: Colors.grey)),
          items: items
              .map((T item) =>
                  DropdownMenuItem(value: item, child: Text(item.toString())))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: Colors.white, // ✅ 펼쳤을 때 배경을 하얀색으로 설정
        ),
      ),
    );
  }

  Widget _buildDropdownYear(
      DateTime? selectedDate, Function(DateTime?) onDateChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedDate?.year != null ? selectedDate!.year : null, //
          hint: Text("년도", style: TextStyle(color: Colors.grey)),
          items: List.generate(100, (index) {
            int year = DateTime.now().year - index;
            return DropdownMenuItem(value: year, child: Text(year.toString()));
          }),
          onChanged: (int? newValue) {
            if (newValue != null) {
              onDateChanged(DateTime(
                  newValue, selectedDate?.month ?? 1, selectedDate?.day ?? 1));
            }
          },
          isExpanded: true,
          dropdownColor: Colors.white, // ✅ 펼쳤을 때 배경을 하얀색으로 설정
        ),
      ),
    );
  }

  Widget _buildDropdownMonth(
      DateTime? selectedDate, Function(DateTime?) onDateChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedDate?.month,
          hint: Text('월', style: TextStyle(color: Colors.grey)),
          items: List.generate(12, (index) {
            int month = index + 1;
            return DropdownMenuItem(
                value: month, child: Text(month.toString()));
          }),
          onChanged: (int? newValue) {
            if (newValue != null) {
              onDateChanged(DateTime(selectedDate?.year ?? DateTime.now().year,
                  newValue, selectedDate?.day ?? 1));
            }
          },
          isExpanded: true,
          dropdownColor: Colors.white, // ✅ 펼쳤을 때 배경을 하얀색으로 설정
        ),
      ),
    );
  }

  Widget _buildDropdownDay(
      DateTime? selectedDate, Function(DateTime?) onDateChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedDate?.day,
          hint: Text('일', style: TextStyle(color: Colors.grey)),
          items: List.generate(31, (index) {
            int day = index + 1;
            return DropdownMenuItem(value: day, child: Text(day.toString()));
          }),
          onChanged: (int? newValue) {
            if (newValue != null) {
              onDateChanged(DateTime(selectedDate?.year ?? DateTime.now().year,
                  selectedDate?.month ?? 1, newValue));
            }
          },
          isExpanded: true,
          dropdownColor: Colors.white, // ✅ 펼쳤을 때 배경을 하얀색으로 설정
        ),
      ),
    );
  }

  Widget _buildTextFieldWithLabel(
      TextEditingController controller, String label,
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

  Widget _buildDropdownWithLabel(String label, String value, List<String> items,
      void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10), // 둥근 모서리
              border: Border.all(color: Colors.grey.shade300), // 테두리 추가
            ),
            child: SizedBox(
              height: 55, // 높이 조정 ✅
              child: DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // 둥근 모서리 유지
                    borderSide: BorderSide.none, // 기본 테두리 제거
                  ),
                  filled: true,
                  fillColor: Colors.white, // 배경색 설정
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 15, vertical: 15), // ✅ 높이 증가
                ),
                dropdownColor: Colors.white,
                // 펼쳤을 때 배경 흰색 유지
                icon:
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey), // 아이콘
                items: items
                    .map((String item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) onChanged(newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectWithLabel(
      String label, List<String> allItems, List<String> selectedItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // 둥근 모서리 유지
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent, // 구분선 제거
                ),
                child: ExpansionTile(
                  backgroundColor: Colors.white, // 펼쳤을 때 배경 흰색
                  collapsedBackgroundColor: Colors.white, // 닫혔을 때 배경 흰색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Text('${selectedItems.length}개 선택됨',
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
            ),
          ),
        ],
      ),
    );
  }
}
