import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'foreign_edit_profile_screen.dart';
import 'foreign_manage_patient_screen.dart';
import 'care_requests_screen.dart';

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
  DateTime birthday = DateTime.now();
  DateTime startdate = DateTime.now();
  DateTime enddate = DateTime.now();
  int age = 0;
  String sex = '';
  int height = 0;
  int weight = 0;
  String spot = '';
  String region = '';
  String symptoms = '';
  String canwalkpatient = '';
  String prefersex = '';
  String smoking = '';
  bool isLoading = true;
  int showJobInfo = 1;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  /// 사용자 정보 불러오기
  Future<void> fetchUserInfo() async {
    final url = Uri.parse('http://192.168.11.93:8000/user-info');

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
          birthday =
              DateTime.tryParse(data['birthday'] ?? '') ?? DateTime.now();
          phonenumber = data['phonenumber'] ?? '알 수 없음';
          age = data['age'] ?? 0;
          sex = data['sex'] ?? '알 수 없음';
          startdate =
              DateTime.tryParse(data['startdate'] ?? '') ?? DateTime.now();
          enddate =
              DateTime.tryParse(data['enddate'] ?? '') ?? DateTime.now();
          height = data['height'] ?? 0;
          weight = data['weight'] ?? 0;
          spot = data['spot'] ?? '알 수 없음';
          region = data['region'] ?? '알 수 없음';
          symptoms = data['symptoms'] ?? '알 수 없음';
          canwalkpatient = data['canwalkpatient'] ?? '알 수 없음';
          prefersex = data['prefersex'] ?? '알 수 없음';
          smoking = data['smoking'] ?? '알 수 없음';
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

  /// 구인 정보 업데이트
  Future<void> _updateJobInfo(bool value) async {
    final url = Uri.parse('http://192.168.11.93:8000/update-job-info');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '프로필',
          style: GoogleFonts.notoSansKr(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // 프로필 카드
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person,
                              size: 50, color: Color(0xFF43C098)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("나이: $age"),
                        Text("성별: $sex"),
                        Text("지역: $region"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 프로필 수정 버튼
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForeignEditProfileScreen(
                            token: widget.token,
                            userData: {
                              'email': email,
                              'name': name,
                              'phonenumber': phonenumber,
                              'birthday': birthday,
                              'age': age,
                              'sex': sex,
                              'startdate': startdate,
                              'enddate': enddate,
                              'region': region,
                              'spot': spot,
                              'height': height,
                              'weight': weight,
                              'symptoms': symptoms,
                              'canwalkpatient': canwalkpatient,
                              'prefersex': prefersex,
                              'smoking': smoking,
                              'showyn': showJobInfo,
                            },
                          ),
                        ),
                      );
                    },
                    child: _buildButton("프로필 수정", false),
                  ),

                  const SizedBox(height: 20),

// 기존의 GestureDetector 위젯을 다음 코드로 대체합니다.
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "구인 정보 띄우기",
                            style: GoogleFonts.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Switch(
                              value: showJobInfo == 1,
                              onChanged: (value) async {
                                await _updateJobInfo(value);
                              },
                              activeColor: const Color(0xFF43C098),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 구인 정보 관리 버튼
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CareRequestsScreen(token: widget.token),
                        ),
                      );
                    },
                    child: _buildButton("구인 관리", false),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ForeignManagePatientScreen(token: widget.token),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF43C098)),
            label: "프로필",
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            selectedIcon: Icon(Icons.list_alt, color: Color(0xFF43C098)),
            label: "환자 관리",
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, bool primary) {
    return _buildToggleButton(text, primary);
  }

  /// 토글 버튼 스타일
  Widget _buildToggleButton(String text, bool active) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF43C098) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
