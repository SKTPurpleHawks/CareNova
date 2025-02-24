import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_manage_screen.dart';

class PatientAddScreen extends StatefulWidget {
  final String token;

  const PatientAddScreen({Key? key, required this.token}) : super(key: key);

  @override
  _PatientAddScreenState createState() => _PatientAddScreenState();
}

class _PatientAddScreenState extends State<PatientAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthday;
  final _ageController = TextEditingController();
  String _sex = '남성';
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  int _age = 0;
  String _canWalk = '걸을 수 있음';
  String _preferSex = '상관없음';
  String _smoking = '비흡연';
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedRegions = [];
  String _spot = '병원';
  List<String> _selectedSymptoms = [];

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

  Future<void> _addPatient() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://192.168.11.93:8000/add_patient'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'birthday': _birthday?.toIso8601String().split('T')[0] ?? '',
          'age': int.tryParse(_ageController.text) ?? 0,
          'sex': _sex,
          'height': int.tryParse(_heightController.text) ?? 0,
          'weight': int.tryParse(_weightController.text) ?? 0,
          'symptoms': _selectedSymptoms.join(','),
          'canwalk': _canWalk,
          'prefersex': _preferSex,
          'smoking': _smoking,
          'startdate': _startDate?.toIso8601String().split('T')[0] ?? '',
          'enddate': _endDate?.toIso8601String().split('T')[0] ?? '',
          'region': _selectedRegions.join(','),
          'spot': _spot,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('환자 추가에 실패했습니다. 다시 시도해주세요.')),
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
      appBar: AppBar(title: Text("환자 추가")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFieldWithLabel(_nameController, "이름"),
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
              _buildDateSelectionWithLabel("간병 시작일", _startDate, (date) {
                setState(() {
                  _startDate = date;
                });
              }),
              SizedBox(height: 10),
              _buildDateSelectionWithLabel("간병 종료일", _endDate, (date) {
                setState(() {
                  _endDate = date;
                });
              }),
              _buildGenderSelectionWithLabel(),
              SizedBox(height: 10),
              _buildTextFieldWithLabel(_heightController, "키 (cm)",
                  keyboardType: TextInputType.number),
              SizedBox(height: 10),
              _buildTextFieldWithLabel(_weightController, "몸무게 (kg)",
                  keyboardType: TextInputType.number),
              SizedBox(height: 10),
              _buildDropdownWithLabel("간병 받을 장소", _spot, ['병원', '집', '둘 다'],
                  (value) => setState(() => _spot = value)),
              SizedBox(height: 10),
              _buildMultiSelectWithLabel(
                  "간병 가능 지역", _regions, _selectedRegions),
              SizedBox(height: 10),
              _buildMultiSelectWithLabel(
                  "환자 보유 질환", _symptoms, _selectedSymptoms),
              _buildDropdownWithLabel(
                  "보행 가능 여부",
                  _canWalk,
                  ['걸을 수 있음', '걸을 수 없음', '상관없음'],
                  (value) => setState(() => _canWalk = value)),
              SizedBox(height: 10),
              _buildDropdownWithLabel(
                  "선호하는 간병인 성별",
                  _preferSex,
                  ['남성', '여성', '상관없음'],
                  (value) => setState(() => _preferSex = value)),
              SizedBox(height: 10),
              _buildDropdownWithLabel("간병인의 흡연 여부", _smoking, ['비흡연', '흡연', '상관없음'],
                  (value) => setState(() => _smoking = value)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: _addPatient,
                  child: const Text("환자 추가",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label을 입력해주세요';
          }
          return null;
        },
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                hintText: label, // 문자열만 넣기
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              items: items
                  .map((String item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) onChanged(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) onChanged(newValue);
        },
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
