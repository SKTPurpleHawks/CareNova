import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


/*
-----------------------------------------------------------------------------------------------------------
file_name : care_requests_screen.dart                       

Developer                                                         
 ● Frontend : 최명일, 서민석
 ● backend : 최명일
 ● UI/UX : 서민석                                                     
                                                                  
description : 보호자가 보낸 요청을 반응할 수 있는 구인관리 화면
              보호자가 보낸 간병 요청을 수락/거부를 통해 대응 할 수 있는 화면이다.
-----------------------------------------------------------------------------------------------------------
*/

class CareRequestsScreen extends StatefulWidget {
  final String token;

  const CareRequestsScreen({Key? key, required this.token}) : super(key: key);

  @override
  _CareRequestsScreenState createState() => _CareRequestsScreenState();
}

class _CareRequestsScreenState extends State<CareRequestsScreen> {
  List<dynamic> _requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCareRequests();
  }

  Future<void> fetchCareRequests() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.10:8000/care-request'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8 변환 없이 jsonDecode 직접 사용
        final decodedBody = response.bodyBytes.isNotEmpty
            ? jsonDecode(utf8.decode(response.bodyBytes))
            : [];

        setState(() {
          _requests = decodedBody;
          isLoading = false;
        });
      } else {}
    } catch (e) {
      _showSnackBar('서버 연결 중 오류가 발생했습니다.');
    }
  }

  Future<void> respondToRequest(int requestId, bool accept) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.0.10:8000/care-request/$requestId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': accept ? 'accepted' : 'rejected'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _requests.removeWhere((r) => r['id'] == requestId);
        });
        _showSnackBar('요청이 ${accept ? '수락' : '거절'}되었습니다.');
      } else {
        _showSnackBar('처리 중 오류가 발생했습니다.');
      }
    } catch (e) {
      _showSnackBar('요청 처리 중 오류가 발생했습니다.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("간병 요청 목록"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child:
                      Text("대기 중인 요청이 없습니다.", style: TextStyle(fontSize: 18)))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];

                    // protector_name 값이 없거나 null이면 기본값 설정
                    String protectorName =
                        request['protector_name'] ?? "알 수 없는 보호자";

                    return Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 🔹 둥근 모서리 조정
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            // 요청 도착 메시지
                            Text(
                              "$protectorName 님의 요청이 도착하였습니다.",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Divider(
                                thickness: 1,
                                color: Colors.black26), // 구분선 추가
                            const SizedBox(height: 8),

                            // 수락 | 거절 버튼 (가운데 정렬)
                            request['status'] == "pending"
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () => respondToRequest(
                                            request['id'], true),
                                        child: const Text("수락",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      const VerticalDivider(
                                          width: 1,
                                          color:
                                              Colors.black26), // 버튼 사이 구분선
                                      TextButton(
                                        onPressed: () => respondToRequest(
                                            request['id'], false),
                                        child: const Text("거절",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  )
                                : Text(
                                    request['status'] == "accepted"
                                        ? "수락되었습니다."
                                        : "거절되었습니다.",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
