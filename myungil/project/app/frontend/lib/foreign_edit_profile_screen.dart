import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ForeignEditProfileScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const ForeignEditProfileScreen(
      {Key? key, required this.token, required this.userData})
      : super(key: key);

  @override
  _ForeignEditProfileScreenState createState() =>
      _ForeignEditProfileScreenState();
}

class _ForeignEditProfileScreenState extends State<ForeignEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _ageController;

  late DateTime _birthday;
  late DateTime _startDate;
  late DateTime _endDate;
  late int _age;
  String _sex = '남성';
  String _spot = '병원';
  late List<String> _selectedRegions;
  String _canWalkPatient = '지원불가능';
  String _preferSex = '남성';
  late List<String> _selectedSymptoms;
  String _smoking = '비흡연';
  bool _canCareForImmobile = false;

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

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userData['name'] ?? '');
    _phoneNumberController =
        TextEditingController(text: widget.userData['phonenumber'] ?? '');
    _heightController = TextEditingController(
        text: widget.userData['height']?.toString() ?? '');
    _weightController = TextEditingController(
        text: widget.userData['weight']?.toString() ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _birthday = _parseDate(widget.userData['birthday']);
    _startDate = _parseDate(widget.userData['startdate']);
    _endDate = _parseDate(widget.userData['enddate']);
    _age = _calculateAge(_birthday);
    _ageController = TextEditingController(text: _age.toString());
    _sex = widget.userData['sex'] ?? '남성';
    _spot = widget.userData['spot'] ?? '병원';
    _selectedRegions = (widget.userData['region'] as String?)?.split(',') ?? [];
    _canWalkPatient = widget.userData['canwalkpatient'] ?? '걸을 수 없음';
    _preferSex = widget.userData['prefersex'] ?? '남성';
    _selectedSymptoms =
        (widget.userData['symptoms'] as String?)?.split(',') ?? [];
    _smoking = widget.userData['smoking'] ?? '비흡연';
    _canCareForImmobile = widget.userData['can_care_for_immobile'] ?? false;
  }

  DateTime _parseDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text.isNotEmpty &&
          _newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('새 비밀번호가 일치하지 않습니다.')),
        );
        return;
      }

      final url = Uri.parse('http://192.168.11.93:8000/user-info');
      Map<String, dynamic> data = {
        'email': widget.userData['email'],
        'name': _nameController.text,
        'phonenumber': _phoneNumberController.text,
        'birthday': _birthday?.toIso8601String().split('T')[0] ?? '',
        'startdate': _startDate?.toIso8601String().split('T')[0] ?? '',
        'enddate': _endDate?.toIso8601String().split('T')[0] ?? '',
        'age': _age,
        'sex': _sex,
        'region': _selectedRegions.join(','),
        'spot': _spot,
        'height': int.tryParse(_heightController.text) ?? 0,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'symptoms': _selectedSymptoms.join(','),
        'canwalkpatient': _canWalkPatient,
        'prefersex': _preferSex,
        'smoking': _smoking,
        'can_care_for_immobile': _canCareForImmobile,
      };

      if (_currentPasswordController.text.isNotEmpty) {
        data['current_password'] = _currentPasswordController.text;
        if (_newPasswordController.text.isNotEmpty) {
          data['new_password'] = _newPasswordController.text;
        }
      }

      try {
        final response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context, jsonDecode(response.body));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('프로필 업데이트 실패!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버에 연결할 수 없습니다.')),
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
                  "프로필 수정",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextFieldWithLabel(_nameController, "이름"),
                _buildTextFieldWithLabel(_phoneNumberController, "전화번호",
                    keyboardType: TextInputType.phone),
                _buildDateSelectionWithLabel("생년월일", _birthday, (date) {
                  setState(() {
                    _birthday = date ?? DateTime.now(); // date가 null이면 현재 날짜 사용
                    _age = _calculateAge(_birthday);
                    _ageController.text = _age.toString();
                  });
                }),
                _buildTextFieldWithLabel(_ageController, "나이", readOnly: true),
                _buildDateSelectionWithLabel2("간병 시작일", _startDate,
                    (DateTime? date) {
                  setState(() {
                    _startDate = date ?? DateTime.now();
                  });
                }),
                _buildDateSelectionWithLabel2("간병 종료일", _endDate,
                    (DateTime? date) {
                  setState(() {
                    _endDate = date ?? DateTime.now();
                  });
                }),
                SizedBox(height: 10),
                _buildGenderSelectionWithLabel(),
                _buildTextFieldWithLabel(_heightController, "키 (cm)",
                    keyboardType: TextInputType.number),
                _buildTextFieldWithLabel(_weightController, "몸무게 (kg)",
                    keyboardType: TextInputType.number),
                _buildDropdownWithLabel("간병 가능 장소", _spot, ['병원', '집', '둘 다'],
                    (value) => setState(() => _spot = value)),
                _buildMultiSelectWithLabel(
                    "간병 가능 지역", _regions, _selectedRegions),
                _buildMultiSelectWithLabel(
                    "간병 가능 질환", _symptoms, _selectedSymptoms),
                _buildDropdownWithLabel(
                    "환자의 보행 지원 여부",
                    _canWalkPatient,
                    ['지원 가능', '지원 불가능', '상관 없음'],
                    (value) => setState(() => _canWalkPatient = value)),
                _buildDropdownWithLabel(
                    "선호하는 환자 성별",
                    _preferSex,
                    ['남성', '여성', '상관 없음'],
                    (value) => setState(() => _preferSex = value)),
                _buildDropdownWithLabel("흡연 여부", _smoking, ['비흡연', '흡연'],
                    (value) => setState(() => _smoking = value)),
                SizedBox(height: 20),
                _buildTextFieldWithLabel(_currentPasswordController, "현재 비밀번호",
                    isPassword: true),
                _buildTextFieldWithLabel(_newPasswordController, "새 비밀번호",
                    isPassword: true),
                _buildTextFieldWithLabel(
                    _confirmPasswordController, "새 비밀번호 확인",
                    isPassword: true),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color(0xFF43C098),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: _updateProfile,
                    child: Text("프로필 업데이트",
                        style: GoogleFonts.notoSansKr(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
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

  Widget _buildDropdownYear2(
      DateTime? selectedDate, Function(DateTime?) onDateChanged) {
    int currentYear = DateTime.now().year;

    return _buildDropdown<int>(
      selectedValue: selectedDate?.year,
      hintText: "년도",
      items: List.generate(100, (index) => currentYear + index),
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
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdownMonth(
      DateTime? selectedDate, Function(DateTime) onDateChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
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
                value: items.contains(value) ? value : null,
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                dropdownColor: Colors.white,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ExpansionTile(
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
        ],
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
              _buildGenderButton("남성"),
              SizedBox(width: 10),
              _buildGenderButton("여성"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sex = gender),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _sex == gender ? Color(0xFF43C098) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xFF43C098)),
          ),
          child: Center(
            child: Text(
              gender,
              style: TextStyle(
                color: _sex == gender ? Colors.white : Color(0xFF43C098),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
