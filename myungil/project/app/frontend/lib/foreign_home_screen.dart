import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'foreign_edit_profile_screen.dart'; // 프로필 수정 화면 추가

class ForeignHomeScreen extends StatefulWidget {
  final String token; // 로그인 후 전달된 토큰

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
  bool isLoading = true;
  bool showJobInfo = false; // 구인 정보 띄우기 상태 관리
  int _selectedIndex = 0; // BottomNavigationBar의 선택된 탭

  /// 🔹 사용자 정보를 가져오는 함수
  Future<void> fetchUserInfo() async {
    final url = Uri.parse('http://172.23.250.30:8000/user-info'); // 백엔드 API 엔드포인트

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}', // 토큰을 헤더에 포함
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          email = data['email'] ?? '알 수 없음';
          name = data['name'] ?? '알 수 없음';
          phonenumber = data['phonenumber'] ?? '알 수 없음';
          startdate = DateTime.tryParse(data['start_date'] ?? '') ?? DateTime.now();
          age = data['age'] ?? 0;
          sex = data['sex'] ?? '알 수 없음';
          spot = data['spot'] ?? '알 수 없음';
          height = data['height'] ?? 0;
          weight = data['weight'] ?? 0;
          isLoading = false;
        });
      } else {
        _showSnackBar('사용자 정보를 불러올 수 없습니다.');
        print('사용자 정보 로드 실패: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('서버에 연결할 수 없습니다.');
      print('서버 연결 오류: $e');
    }
  }

  /// 🔹 Snackbar 메시지 표시 함수
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 🔹 BottomNavigationBar 탭 변경 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo(); // 화면 초기화 시 사용자 정보 가져오기
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
          ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                                Text('키: $height cm'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
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
                              'spot': spot,
                            },
                          ),
                        ),
                      );

                      if (updatedData != null) {
                        setState(() {
                          name = updatedData['name'];
                          age = updatedData['age'];
                          sex = updatedData['sex'];
                          height = updatedData['height'];
                        });
                      }
                    },
                    child: Text('프로필 수정'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('구인 정보 띄우기'),
                      Switch(
                        value: showJobInfo,
                        onChanged: (value) {
                          setState(() {
                            showJobInfo = value;
                          });
                        },
                      ),
                    ],
                  ),
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
