import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_manage_screen.dart';
import 'package:google_fonts/google_fonts.dart';



/*
---------------------------------------------------------------
file_name : patient_add_screen.dart

Developer
 ● Frontend : 최명일, 서민석
 ● backend : 최명일
 ● UI/UX : 서민석                                                     
                                                                  
description : 환자를 등록하기 위해 환자 정보를 입력하는 화면
              입력된 정보는 백엔드 서버로 전달되어 DB에 저장됨
---------------------------------------------------------------
*/

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
  String _preferSex = '상관 없음';
  String _smoking = '비흡연';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRegion = null;
  String _spot = '병원';
  List<String> _selectedSymptoms = [];
  int? _preferStar;

  final List<String> _messages = [
    "성실하게 환자를 돌봐주세요.",
    "의사소통을 중요하게 생각해요.",
    "위생/청결 관리에 신경 써주세요."
  ];
  String? _selectedMessage;

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

  Future<void> _addPatient() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://192.168.232.218:8000/add_patient'),
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
          'region': _selectedRegion,
          'spot': _spot,
          'preferstar': _preferStar,
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

  void _updatePreferStar() {
    setState(() {
      _preferStar = _selectedMessage == _messages[0]
          ? 0
          : _selectedMessage == _messages[1]
              ? 1
              : _selectedMessage == _messages[2]
                  ? 2
                  : null;
    });
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "환자 추가",
            style: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: Colors.black,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFieldWithLabel(_nameController, "이름"),
              SizedBox(height: 10),
              _buildDateSelectionWithLabel("생년월일", _birthday, (date) {
                setState(() {
                  _birthday = date;
                  _age = _calculateAge(date ?? DateTime.now());
                  _ageController.text = _age.toString(); // 나이 필드 자동 업데이트
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
              _buildDropdownWithLabel("간병 받을 장소", _spot, ['병원', '집', '둘 다'],
                  (value) => setState(() => _spot = value)),
              SizedBox(height: 10),
              _buildSingleSelectWithLabel(
                "간병 받을 지역",
                _regions,
                _selectedRegion,
                (value) {
                  setState(() {
                    _selectedRegion = value; // 선택된 값 업데이트
                  });
                },
              ),
              SizedBox(height: 10),
              _buildMultiSelectWithLabel(
                  "환자 보유 질환", _symptoms, _selectedSymptoms),
              SizedBox(height: 10),
              _buildDropdownWithLabel(
                  "보행 가능 여부",
                  _canWalk,
                  ['걸을 수 있음', '걸을 수 없음'],
                  (value) => setState(() => _canWalk = value)),
              SizedBox(height: 10),
              _buildDropdownWithLabel(
                  "선호하는 간병인 성별",
                  _preferSex,
                  ['남성', '여성', '상관 없음'],
                  (value) => setState(() => _preferSex = value)),
              SizedBox(height: 10),
              _buildDropdownWithLabel(
                  "간병인의 흡연 여부",
                  _smoking,
                  ['비흡연', '흡연', '상관 없음'],
                  (value) => setState(() => _smoking = value)),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "간병인에게 전하고 싶은 말",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return RadioListTile<String>(
                          title: Text(message),
                          value: message,
                          groupValue: _selectedMessage,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedMessage = value;
                              _updatePreferStar(); // 선택 시 preferstar 업데이트
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF43C098),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "환자 추가",
                    style: GoogleFonts.notoSansKr(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
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
                  child: SizedBox(
                    height: 60, // 원하는 높이로 조정
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20), // 위아래 패딩 증가
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
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
          dropdownColor: Colors.white, // 펼쳤을 때 배경을 하얀색으로 설정
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
          dropdownColor: Colors.white,
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
          dropdownColor: Colors.white,
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
          dropdownColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // 둥근 모서리 유지
                  borderSide: BorderSide.none, // 기본 테두리 제거
                ),
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              dropdownColor: Colors.white,
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

  Widget _buildSingleSelectWithLabel(String label, List<String> allItems,
      String? selectedItem, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedItem, // 현재 선택된 값
              hint: Text('선택하세요', style: TextStyle(color: Colors.grey)),
              decoration: InputDecoration(
                border: InputBorder.none, // 드롭다운 테두리 제거
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              dropdownColor: Colors.white,
              items: allItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              isExpanded: true,
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
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
}
