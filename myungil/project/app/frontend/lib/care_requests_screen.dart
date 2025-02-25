import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        Uri.parse('http://172.23.250.30:8000/care-request'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        // ✅ UTF-8 변환 없이 jsonDecode 직접 사용
        final decodedBody = response.bodyBytes.isNotEmpty
            ? jsonDecode(utf8.decode(response.bodyBytes))
            : [];

        setState(() {
          _requests = decodedBody;
          isLoading = false;
        });
      } else {
        _showSnackBar('간병 요청을 불러오지 못했습니다.');
      }
    } catch (e) {
      _showSnackBar('서버 연결 중 오류가 발생했습니다.');
    }
  }

  Future<void> respondToRequest(int requestId, bool accept) async {
    try {
      final response = await http.put(
        Uri.parse('http://172.23.250.30:8000/care-request/$requestId'),
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
      appBar: AppBar(title: Text("간병 요청 목록")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(child: Text("대기 중인 요청이 없습니다."))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];

                    // ✅ protector_name 값이 없거나 null이면 기본값 설정
                    String protectorName =
                        request['protector_name'] ?? "알 수 없는 보호자";

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text("$protectorName 님의 요청이 도착하였습니다."),
                        trailing: request['status'] == "pending"
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        respondToRequest(request['id'], true),
                                    child: Text("수락",
                                        style: TextStyle(color: Colors.green)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        respondToRequest(request['id'], false),
                                    child: Text("거절",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )
                            : Text(
                                request['status'] == "accepted"
                                    ? "✅ 수락됨"
                                    : "❌ 거절됨",
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
