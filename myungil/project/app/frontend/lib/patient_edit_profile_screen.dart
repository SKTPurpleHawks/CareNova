import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';



/*
-----------------------------------------------------------------------------
file_name : patient_edit_profile_screen.dart

Developer
 ● Frontend : 최명일, 서민석
 ● backend : 최명일
 ● UI/UX : 서민석                                                     
                                                                  
description : 환자의 정보를 수정하는 화면
              이미 작성된 환자 정보를 DB에서 불러와 수정할 수 있도록 하는 화면
-----------------------------------------------------------------------------
*/


class PatientEditProfileScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> patientData;

  const PatientEditProfileScreen(
      {Key? key, required this.token, required this.patientData})
      : super(key: key);

  @override
  _PatientEditProfileScreenState createState() =>
      _PatientEditProfileScreenState();
}

class _PatientEditProfileScreenState extends State<PatientEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;

  late DateTime _birthday;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late int _age;

  String _sex = '남성';
  late List<String> _selectedRegions;
  String _canWalkPatient = '걸을 수 없음';
  String _preferSex = '남성';
  late List<String> _selectedSymptoms;
  String _smoking = '비흡연';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.patientData['name']?.toString() ?? '');
    _heightController = TextEditingController(
        text: widget.patientData['height']?.toString() ?? '');
    _weightController = TextEditingController(
        text: widget.patientData['weight']?.toString() ?? '');

    _birthday = _parseDate(widget.patientData['birthday']);
    _startDate = _parseDate(widget.patientData['startdate']);
    _endDate = _parseDate(widget.patientData['enddate']);
    _age = _calculateAge(_birthday);
    _ageController = TextEditingController(text: _age.toString());

    _sex = widget.patientData['sex']?.toString() ?? '남성';
    _selectedRegions = _safeSplit(widget.patientData['region']);
    _canWalkPatient =
        widget.patientData['canwalkpatient']?.toString() ?? '걸을 수 없음';
    _preferSex = widget.patientData['prefersex']?.toString() ?? '남성';
    _selectedSymptoms = _safeSplit(widget.patientData['symptoms']);
    _smoking = widget.patientData['smoking']?.toString() ?? '비흡연';
    _preferStar = widget.patientData['preferstar'];
    _selectedMessage = (_preferStar == 0)
        ? _messages[0]
        : (_preferStar == 1)
            ? _messages[1]
            : (_preferStar == 2)
                ? _messages[2]
                : null;
  }

  /// `null` 값이 들어오면 안전하게 현재 날짜 반환
  DateTime _parseDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  /// `null`이면 빈 리스트 반환, 그렇지 않으면 `,`로 분할
  List<String> _safeSplit(dynamic value) {
    return (value is String && value.isNotEmpty) ? value.split(',') : [];
  }

  /// 나이 계산 함수
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

  /// 환자 정보 업데이트 함수
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(
          'http://192.168.0.10:8000/patient-info/${widget.patientData['id']}');
      Map<String, dynamic> data = {
        "birthday": _birthday?.toIso8601String().split('T')[0] ?? '',
        "startdate": _startDate?.toIso8601String().split('T')[0] ?? '',
        "enddate": _endDate?.toIso8601String().split('T')[0] ?? '',
        "age": _age,
        "sex": _sex,
        "region": _selectedRegions.join(','),
        "height": int.tryParse(_heightController.text) ?? 0,
        "weight": int.tryParse(_weightController.text) ?? 0,
        "symptoms": _selectedSymptoms.join(','),
        "canwalkpatient": _canWalkPatient,
        "prefersex": _preferSex,
        "smoking": _smoking,
        "preferstar": _preferStar
      };

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
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('환자 정보 업데이트 실패!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버에 연결할 수 없습니다.')),
        );
      }
    }
  }

  /// 환자 정보 삭제 함수
  Future<void> _deletePatient() async {
    final url = Uri.parse(
        'http://192.168.0.10:8000/patient-info/${widget.patientData['id']}');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('환자 정보 삭제 실패!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버에 연결할 수 없습니다.')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("환자 정보 수정")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFieldWithLabel(_nameController, "이름", readOnly: true),
                _buildDateSelectionWithLabel("생년월일", _birthday, (date) {
                  setState(() {
                    _birthday = date;
                    _age = _calculateAge(date);
                    _ageController.text = _age.toString();
                  });
                }),
                _buildTextFieldWithLabel(_ageController, "나이", readOnly: true),
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
                _buildGenderSelectionWithLabel(),
                _buildTextFieldWithLabel(_heightController, "키 (cm)",
                    keyboardType: TextInputType.number),
                _buildTextFieldWithLabel(_weightController, "몸무게 (kg)",
                    keyboardType: TextInputType.number),
                _buildMultiSelectWithLabel(
                    "간병 가능 지역", _regions, _selectedRegions),
                _buildMultiSelectWithLabel(
                    "간병 가능 질환", _symptoms, _selectedSymptoms),
                _buildDropdownWithLabel(
                    "보행 가능 여부",
                    _canWalkPatient,
                    ['걸을 수 있음', '걸을 수 없음'],
                    (value) => setState(() => _canWalkPatient = value)),
                _buildDropdownWithLabel(
                    "선호하는 간병인 성별",
                    _preferSex,
                    ['남성', '여성', '상관 없음'],
                    (value) => setState(() => _preferSex = value)),
                _buildDropdownWithLabel(
                    "흡연 여부",
                    _smoking,
                    ['비흡연', '흡연', '상관 없음'],
                    (value) => setState(() => _smoking = value)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "간병인에게 전하고 싶은 말",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _deletePatient,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                          foregroundColor:
                              const Color.fromARGB(255, 212, 15, 0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 212, 15, 0))),
                        ),
                        child: Text(
                          "정보 삭제",
                          style: GoogleFonts.notoSansKr(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF43C098),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "업데이트",
                          style: GoogleFonts.notoSansKr(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
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
      String label, DateTime selectedDate, Function(DateTime) onDateChanged) {
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
      DateTime selectedDate, Function(DateTime) onDateChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedDate.year,
          items: List.generate(100, (index) {
            int year = DateTime.now().year - index;
            return DropdownMenuItem(value: year, child: Text(year.toString()));
          }),
          onChanged: (int? newValue) {
            if (newValue != null) {
              onDateChanged(
                  DateTime(newValue, selectedDate.month, selectedDate.day));
            }
          },
          isExpanded: true,
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
                hintText: label,
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
