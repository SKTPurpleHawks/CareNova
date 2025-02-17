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
    _age = widget.userData['age'] ?? 0;
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
    return DateTime.tryParse(date.toString()) ?? DateTime.now();
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

      final url = Uri.parse('http://172.23.250.30:8000/user-info');

      try {
        final response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
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
            'current_password': _currentPasswordController.text,
            'new_password': _newPasswordController.text.isNotEmpty
                ? _newPasswordController.text
                : null,
            'can_care_for_immobile': _canCareForImmobile,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context, jsonDecode(response.body));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('프로필 업데이트 실패!')),
          );
        }
      } catch (e) {
        print('❌ 서버 연결 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버에 연결할 수 없습니다.')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onSelect) async {
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
          _age = DateTime.now().year - picked.year;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E8EE),
      appBar: AppBar(
        title: Text("프로필 수정"),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, "이름"),
                _buildTextField(_phoneNumberController, "전화번호",
                    keyboardType: TextInputType.phone),
                _buildDateField(
                    "생년월일",
                    _birthday,
                    (date) => setState(() {
                          _birthday = date;
                          _age = DateTime.now().year - date.year;
                        })),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child:
                      Text('나이(만 나이) : $_age', style: TextStyle(fontSize: 16)),
                ),
                _buildDateField("간병 시작일", _startDate,
                    (date) => setState(() => _startDate = date)),
                _buildDateField("간병 종료일", _endDate,
                    (date) => setState(() => _endDate = date)),
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
      {bool isPassword = false,
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

  Widget _buildDateField(
      String label, DateTime date, Function(DateTime) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () => _selectDate(context, date, onSelect),
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
                  Text(DateFormat('yyyy-MM-dd').format(date),
                      style: TextStyle(fontSize: 16)),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
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
