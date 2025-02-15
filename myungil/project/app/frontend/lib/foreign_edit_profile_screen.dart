import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ForeignEditProfileScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const ForeignEditProfileScreen({Key? key, required this.token, required this.userData}) : super(key: key);

  @override
  _ForeignEditProfileScreenState createState() => _ForeignEditProfileScreenState();
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

  final List<String> _regions = ['서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종', '경기남부', '경기북부', '강원영서', '강원영동', '충북', '충남', '전북', '전남', '경북', '경남', '제주'];
  final List<String> _symptoms = ['치매', '섬망', '욕창', '하반신마비', '상반신마비', '전신마비', '와상환자', '기저귀케어', '의식없음', '석션', '피딩', '소변줄', '장루', '야간집중돌봄', '전염성', '파킨슨', '정신질환', '투석', '재활'];

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

    _birthday = DateTime.tryParse(widget.userData['birthday'] ?? '') ?? DateTime.now();
    _startDate = DateTime.tryParse(widget.userData['startdate'] ?? '') ?? DateTime.now();
    _endDate = DateTime.tryParse(widget.userData['enddate'] ?? '') ?? DateTime.now();
    _age = widget.userData['age'] ?? 0;
    _sex = widget.userData['sex'];
    _spot = widget.userData['spot'];
    _selectedRegions = (widget.userData['region'] as String?)?.split(',') ?? [];
    _canWalkPatient = widget.userData['canwalkpatient'];
    _preferSex = widget.userData['prefersex'];
    _selectedSymptoms = (widget.userData['symptoms'] as String?)?.split(',') ?? [];
    _smoking = widget.userData['smoking'];
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

      final url = Uri.parse('http://192.168.0.10:8000/user-info');

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
            'birthday': _birthday.toIso8601String().split('T')[0],
            'startdate': _startDate.toIso8601String().split('T')[0],
            'enddate': _endDate.toIso8601String().split('T')[0],
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
            'new_password': _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
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

  Future<void> _selectDate(BuildContext context, DateTime initialDate, Function(DateTime) onSelect) async {
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
      appBar: AppBar(title: Text('프로필 수정')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: '이메일'),
              initialValue: widget.userData['email'],
              readOnly: true,
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
              validator: (value) => value!.isEmpty ? '이름을 입력해주세요' : null,
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: '전화번호'),
              validator: (value) => value!.isEmpty ? '전화번호를 입력해주세요' : null,
            ),
            ListTile(
              title: Text("생년월일: ${DateFormat('yyyy-MM-dd').format(_birthday)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, _birthday, (date) => setState(() => _birthday = date)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('나이(만나이): $_age', style: TextStyle(fontSize: 16)),
            ),
            DropdownButtonFormField<String>(
              value: _sex,
              decoration: InputDecoration(labelText: '성별'),
              items: ['남성', '여성'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _sex = newValue;
                });
              },
            ),
            ListTile(
              title: Text("간병 시작일: ${DateFormat('yyyy-MM-dd').format(_startDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, _startDate, (date) => setState(() => _startDate = date)),
            ),
            ListTile(
              title: Text("마지막 간병일: ${DateFormat('yyyy-MM-dd').format(_endDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, _endDate, (date) => setState(() => _endDate = date)),
            ),
            DropdownButtonFormField<String>(
              value: _spot,
              decoration: InputDecoration(labelText: '간병 가능 장소'),
              items: ['집', '병원', '둘 다'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _spot = newValue;
                });
              },
            ),
            TextFormField(
              controller: _heightController,
              decoration: InputDecoration(labelText: '키 (cm)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? '키를 입력해주세요' : null,
            ),
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(labelText: '몸무게 (kg)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? '몸무게를 입력해주세요' : null,
            ),
            ExpansionTile(
              title: Text('간병 가능 지역'),
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
                );
              }).toList(),
            ),
            ExpansionTile(
              title: Text('간병 가능 증상'),
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
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              value: _canWalkPatient,
              decoration: InputDecoration(labelText: '환자 보행 여부'),
              items: ['걸을 수 없음', '걸을 수 있음', '둘 다 케어 가능'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _canWalkPatient = newValue;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _preferSex,
              decoration: InputDecoration(labelText: '선호하는 환자 성별'),
              items: ['남성', '여성', '상관없음'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _preferSex = newValue;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _smoking,
              decoration: InputDecoration(labelText: '흡연 여부'),
              items: ['비흡연', '흡연'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _smoking = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _currentPasswordController,
              decoration: InputDecoration(labelText: '현재 비밀번호'),
              obscureText: true,
            ),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: '새 비밀번호'),
              obscureText: true,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: '새 비밀번호 확인'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('프로필 업데이트'),
              onPressed: _updateProfile,
            ),
          ],
        ),
      ),
    );
  }
}
