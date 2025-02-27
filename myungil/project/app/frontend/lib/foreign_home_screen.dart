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
    final url = Uri.parse('http://172.23.250.30:8000/user-info');

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
          enddate = DateTime.tryParse(data['enddate'] ?? '') ?? DateTime.now();
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
    final url = Uri.parse('http://172.23.250.30:8000/update-job-info');

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
        title: Image.asset(
          'assets/images/logo_ver2.png',
          height: 35,
          fit: BoxFit.contain,
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
                          blurRadius: 3,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          // decoration: BoxDecoration(
                          //   color: const Color.fromARGB(255, 114, 114, 114),
                          //   borderRadius: BorderRadius.circular(15),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: Colors.black.withOpacity(0.1),
                          //       blurRadius: 5,
                          //       offset: const Offset(0, 3),
                          //     ),
                          //   ],
                          // ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // 👉 중앙 정렬
                            children: [
                              Text(
                                "나이: $age",
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 20), // 👉 나이와 성별 사이 간격 조정
                              Text(
                                "성별: $sex",
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20), // 버튼과 정보 사이 간격 추가

                        // 수정 버튼
                        InkWell(
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
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF43C098),
                                  Color(0xFF2D8A76)
                                ], // 구인 관리 버튼과 동일한 색상
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "프로필 수정",
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10), // 버튼과 아래 요소 간격 추가
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

// 기존의 GestureDetector 위젯을 다음 코드로 대체합니다.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 구인 정보 토글
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "구인 정보 띄우기",
                              style: GoogleFonts.notoSansKr(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Switch(
                              value: showJobInfo == 1,
                              onChanged: (value) async {
                                await _updateJobInfo(value);
                              },
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF43C098),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

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
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF43C098), Color(0xFF2D8A76)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "구인 관리",
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
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

  Widget _buildButton2(String text, bool primary) {
    return _buildToggleButton2(text, primary);
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

  Widget _buildToggleButton2(String text, bool active) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF43C098) : Color(0xFF43C098),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Color(0xFF43C098), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
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
