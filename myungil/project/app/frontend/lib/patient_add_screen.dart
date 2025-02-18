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
  DateTime _birthday = DateTime.now();
  final _ageController = TextEditingController();
  String _sex = '남성';
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _canWalk = '걸을 수 있음';
  String _preferSex = '상관없음';
  String _smoking = '비흡연';


  final List<String> _symptomsList = [
    '치매', '섬망', '욕창', '하반신마비', '상반신마비', '전신마비',
    '와상환자', '기저귀케어', '의식없음', '석션', '피딩', '소변줄',
    '장루', '야간집중돌봄', '전염성', '파킨슨', '정신질환', '투석', '재활'
  ];
  List<String> _selectedSymptoms = [];

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
        _ageController.text = (DateTime.now().year - picked.year).toString();
      });
    }
  }

  Future<void> _addPatient() async {
  if (_formKey.currentState!.validate()) {
    final response = await http.post(
      Uri.parse('http://172.30.1.53:8000/add_patient'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'birthday': _birthday.toIso8601String().split('T')[0],
        'age': int.tryParse(_ageController.text) ?? 0,
        'sex': _sex,
        'height': int.tryParse(_heightController.text) ?? 0,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'symptoms': _selectedSymptoms.join(','),
        'canwalk': _canWalk,
        'prefersex': _preferSex,
        'smoking': _smoking,
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
              _buildTextField(_nameController, "이름"),
              _buildDatePicker("생년월일", _birthday, _selectBirthday),
              _buildTextField(_ageController, "나이", keyboardType: TextInputType.number),
              _buildDropdown("성별", _sex, ['남성', '여성'], (value) => setState(() => _sex = value)),
              _buildTextField(_heightController, "키 (cm)", keyboardType: TextInputType.number),
              _buildTextField(_weightController, "몸무게 (kg)", keyboardType: TextInputType.number),
              _buildDropdownSymptoms(), 
              _buildDropdown("보행 가능 여부", _canWalk, ['걸을 수 있음', '걸을 수 없음'], (value) => setState(() => _canWalk = value)),
              _buildDropdown("선호하는 간병인 성별", _preferSex, ['남성', '여성', '상관없음'], (value) => setState(() => _preferSex = value)),
              _buildDropdown("흡연 여부", _smoking, ['비흡연', '흡연'], (value) => setState(() => _smoking = value)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPatient,
                child: const Text("환자 추가"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label을 입력해주세요';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(BuildContext) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text("$label: ${date.toLocal()}".split(' ')[0]),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => onSelect(context),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
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


  Widget _buildDropdownSymptoms() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("질병 이력", style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ExpansionTile(
              title: Text('질환 선택', style: TextStyle(fontSize: 16)),
              children: _symptomsList.map((symptom) {
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
}