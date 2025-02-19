import 'package:flutter/material.dart';
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

  late DateTime _birthday;
  late DateTime _startDate;
  late DateTime _endDate;
  late int _age;
  String? _sex;
  String? _spot;
  late List<String> _selectedRegions;
  String? _canWalkPatient;
  String? _preferSex;
  late List<String> _selectedSymptoms;
  String? _smoking;
  bool _canCareForImmobile = false;

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _phoneNumberController = TextEditingController(text: widget.userData['phonenumber'] ?? '');
    _heightController = TextEditingController(text: widget.userData['height']?.toString() ?? '');
    _weightController = TextEditingController(text: widget.userData['weight']?.toString() ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _birthday = _parseDate(widget.userData['birthday']);
    _startDate = _parseDate(widget.userData['startdate']);
    _endDate = _parseDate(widget.userData['enddate']);
    _age = _calculateAge(_birthday);
    _sex = widget.userData['sex'] ?? '남성';
    _spot = widget.userData['spot'] ?? '병원';
    _selectedRegions = (widget.userData['region'] as String?)?.split(',') ?? [];
    _canWalkPatient = widget.userData['canwalkpatient'] ?? '걸을 수 없음';
    _preferSex = widget.userData['prefersex'] ?? '남성';
    _selectedSymptoms = (widget.userData['symptoms'] as String?)?.split(',') ?? [];
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

      final url = Uri.parse('http://192.168.91.218:8000/user-info');
      Map<String, dynamic> data = {
        'email': widget.userData['email'],
        'name': _nameController.text,
        'phonenumber': _phoneNumberController.text,
        'birthday': DateFormat('yyyy-MM-dd').format(_birthday),
        'startdate': DateFormat('yyyy-MM-dd').format(_startDate),
        'enddate': DateFormat('yyyy-MM-dd').format(_endDate),
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
      appBar: AppBar(
        title: Text("프로필 수정"),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, "이름"),
                _buildTextField(_phoneNumberController, "전화번호",
                    keyboardType: TextInputType.phone),
                _buildDateSelection("생년월일", _birthday, (date) {
                  setState(() {
                    _birthday = date;
                    _age = _calculateAge(date);
                  });
                }),
                _buildTextField(
                  TextEditingController(text: _age.toString()),
                  "나이",
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
                SizedBox(height: 10),
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
                _buildTextField(_currentPasswordController, "현재 비밀번호",
                    isPassword: true),
                _buildTextField(_newPasswordController, "새 비밀번호",
                    isPassword: true),
                _buildTextField(_confirmPasswordController, "새 비밀번호 확인",
                    isPassword: true),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: _updateProfile,
                    child: Text("프로필 업데이트",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, bool readOnly = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            readOnly: readOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
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
              value: value,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
              underline: SizedBox(),
            ),
          ),
        ],
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
