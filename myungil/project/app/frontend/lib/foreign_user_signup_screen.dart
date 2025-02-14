import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'login_screen.dart';

class ForeignUserSignupScreen extends StatefulWidget {
  @override
  _ForeignUserSignupScreenState createState() => _ForeignUserSignupScreenState();
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
  String _smoking = '비흡연';

  final List<String> _regions = ['서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종', '경기남부', '경기북부', '강원영서', '강원영동', '충북', '충남', '전북', '전남', '경북', '경남', '제주'];
  final List<String> _symptoms = ['치매', '섬망', '욕창', '하반신마비', '상반신마비', '전신마비', '와상환자', '기저귀케어', '의식없음', '석션', '피딩', '소변줄', '장루', '야간집중돌봄', '전염성', '파킨슨', '정신질환', '투석', '재활'];

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
          'age': _age,
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


  Future<void> _selectDate(BuildContext context, DateTime initialDate, Function(DateTime) onSelect) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        onSelect(picked);
        if (onSelect == (date) => _birthday = date) {
          _age = _calculateAge(picked);
        }
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
              validator: (value) {
                if (value!.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: '비밀번호 확인'),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return '비밀번호를 다시 입력해주세요';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
              validator: (value) {
                if (value!.isEmpty) {
                  return '이름을 입력해주세요';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: '전화번호'),
              validator: (value) {
                if (value!.isEmpty) {
                  return '전화번호를 입력해주세요';
                }
                return null;
              },
            ),
            ListTile(
              title: Text("생년월일: ${DateFormat('yyyy-MM-dd').format(_birthday)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, _birthday, (date) {
                setState(() {
                  _birthday = date;
                  _age = _calculateAge(date);
                });
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '나이(만나이): $_age',
                style: TextStyle(fontSize: 16),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _sex,
              decoration: InputDecoration(labelText: '성별'),
              items: ['남성', '여성'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _sex = newValue!;
                });
              },
            ),
            ListTile(
              title: Text("간병 시작일: ${DateFormat('yyyy-MM-dd').format(_startDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, _startDate, (date) => _startDate = date),
            ),
            ListTile(
              title: Text("마지막 간병일: ${DateFormat('yyyy-MM-dd').format(_endDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, _endDate, (date) => _endDate = date),
            ),
            DropdownButtonFormField<String>(
              value: _spot,
              decoration: InputDecoration(labelText: '간병 가능 장소'),
              items: ['집', '병원', '둘 다'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _spot = newValue!;
                });
              },
            ),
            TextFormField(
              controller: _heightController,
              decoration: InputDecoration(labelText: '키 (cm)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return '키를 입력해주세요';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(labelText: '몸무게 (kg)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return '몸무게를 입력해주세요';
                }
                return null;
              },
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
            /*
            ExpansionTile(
              title: Text('질병 간병 경력'),
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
            */
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
              decoration: InputDecoration(labelText: '환자 보행 여부'), /* text 수정 필요 */ 
              items: ['걸을 수 없음', '걸을 수 있음', '둘 다 케어 가능'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _canWalkPatient = newValue!;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _preferSex,
              decoration: InputDecoration(labelText: '선호하는 환자 성별'),
              items: ['남성', '여성', '상관없음'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _preferSex = newValue!;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _smoking,
              decoration: InputDecoration(labelText: '흡연 여부'),
              items: ['비흡연', '흡연'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _smoking = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('회원가입'),
              onPressed: _signup,
            ),
          ],
        ),
      ),
    );
  }
}
