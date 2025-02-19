import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'foreign_edit_profile_screen.dart';

class ForeignHomeScreen extends StatefulWidget {
  final String token;

  const ForeignHomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ForeignHomeScreenState createState() => _ForeignHomeScreenState();
}

class _ForeignHomeScreenState extends State<ForeignHomeScreen> {
  String email = '';
  String name = '';
  String phonenumber = '';
  DateTime startdate = DateTime.now();
  int age = 0;
  String sex = '';
  String spot = '';
  int height = 0;
  int weight = 0;
  String symptoms = '';
  String region = '';
  bool isLoading = true;
  int showJobInfo = 1;
  int _selectedIndex = 0;

  Future<void> fetchUserInfo() async {
    final url = Uri.parse('http://192.168.91.218:8000/user-info');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          email = data['email'] ?? '알 수 없음';
          name = data['name'] ?? '알 수 없음';
          phonenumber = data['phonenumber'] ?? '알 수 없음';
          startdate =
              DateTime.tryParse(data['startdate'] ?? '') ?? DateTime.now();
          age = data['age'] ?? 0;
          sex = data['sex'] ?? '알 수 없음';
          region = data['region'] ?? '알 수 없음';
          spot = data['spot'] ?? '알 수 없음';
          height = data['height'] ?? 0;
          weight = data['weight'] ?? 0;
          symptoms = data['symptoms'] ?? '알 수 없음';
          showJobInfo =
              data.containsKey('showyn') ? (data['showyn'] == 1 ? 1 : 0) : 0;
          isLoading = false;
        });
      } else {
        _showSnackBar('사용자 정보를 불러올 수 없습니다.');
      }
    } catch (e) {
      _showSnackBar('서버에 연결할 수 없습니다.');
    }
  }

  Future<void> _updateJobInfo(bool value) async {
    final url = Uri.parse('http://192.168.91.218:8000/update-job-info');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'showyn': value ? 1 : 0}),
      );

      if (response.statusCode == 200) {
        setState(() {
          showJobInfo = value ? 1 : 0;
        });
        _showSnackBar('구인 정보가 업데이트되었습니다.');
      } else {
        _showSnackBar('업데이트 실패');
      }
    } catch (e) {
      _showSnackBar('서버에 연결할 수 없습니다.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _showSnackBar('알림 기능은 준비 중입니다.');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 로그아웃 → 로그인 화면으로 이동
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, size: 50),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('나이: $age'),
                                Text('성별: $sex'),
                                Text('지역: $region'),
                                // Text('간병 가능 증상'),
                                // Text('   - $symptoms'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 150),
                  ElevatedButton(
                    onPressed: () async {
                      final updatedData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForeignEditProfileScreen(
                            token: widget.token,
                            userData: {
                              'email': email,
                              'name': name,
                              'phonenumber': phonenumber,
                              'startdate': startdate,
                              'age': age,
                              'sex': sex,
                              'height': height,
                              'weight': weight,
                              'region': region,
                              'spot': spot,
                              'symptoms': symptoms,
                              'showyn': showJobInfo,
                            },
                          ),
                        ),
                      );

                      if (updatedData != null) {
                        setState(() {
                          showJobInfo = (updatedData['showyn'] == 1) ? 1 : 0;
                        });
                      }
                    },
                    child: Text('프로필 수정'),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('구인 정보 띄우기'),
                      Switch(
                        value: showJobInfo == 1, // ✅ showJobInfo가 1일 때만 true
                        onChanged: (value) async {
                          await _updateJobInfo(value);
                          setState(() {
                            showJobInfo = value ? 1 : 0; // ✅ UI 즉시 반영
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      _showSnackBar('구인 관리 기능은 준비 중입니다.');
                    },
                    child: Text('구인 관리'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '환자 관리'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // 탭 변경 이벤트 추가
      ),
    );
  }
}
