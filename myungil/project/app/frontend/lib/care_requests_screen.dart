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
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/care-requests'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _requests = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      _showSnackBar('간병 요청을 불러오지 못했습니다.');
    }
  }

  Future<void> respondToRequest(int requestId, bool accept) async {
  final response = await http.put(
    Uri.parse('http://10.0.2.2:8000/care-requests/$requestId'),
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
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text("보호자 ID: ${request['protector_id']}"),
                        subtitle: Text("상태: ${request['status']}"),
                        trailing: request['status'] == "pending"
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => respondToRequest(request['id'], true),
                                    child: Text("수락", style: TextStyle(color: Colors.green)),
                                  ),
                                  TextButton(
                                    onPressed: () => respondToRequest(request['id'], false),
                                    child: Text("거절", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )
                            : Text(request['status'] == "accepted" ? "✅ 수락됨" : "❌ 거절됨"),
                      ),
                    );
                  },
                ),
    );
  }
}
