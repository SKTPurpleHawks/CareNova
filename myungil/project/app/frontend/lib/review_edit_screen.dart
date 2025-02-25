import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'protector_home_screen.dart'; // 보호자 홈 화면 import
import 'patient_detail_screen.dart'; // 환자 상세 화면 import

class ReviewScreen extends StatefulWidget {
  final String token;
  final String caregiverId;
  final String protectorId;

  const ReviewScreen({
    Key? key,
    required this.token,
    required this.caregiverId,
    required this.protectorId,
  }) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double diaryWriting = 0;
  double workAttitude = 0;
  double patientHygiene = 0;
  double personalHygiene = 0;
  double understandingRequests = 0;
  double responseAccuracy = 0;
  TextEditingController reviewController = TextEditingController();

  /// 별점 업데이트 함수 (드래그하여 변경 가능)
  void updateRating(Function(double) updateFunc, double value) {
    setState(() {
      updateFunc(value);
    });
  }

  /// 리뷰 제출 함수
  Future<void> submitReview() async {
    // 평균 점수 계산
    double sincerity = (diaryWriting + workAttitude) / 2;
    double hygiene = (patientHygiene + personalHygiene) / 2;
    double communication = (understandingRequests + responseAccuracy) / 2;
    double totalScore = (sincerity + hygiene + communication) / 3;

    final url = Uri.parse('http://192.168.11.93:8000/reviews');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'caregiver_id': widget.caregiverId,
        'protector_id': widget.protectorId,
        'sincerity': sincerity,
        'hygiene': hygiene,
        'communication': communication,
        'total_score': totalScore,
        'review_content': reviewController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰가 저장되었습니다.')),
      );

      // 보호자 홈 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ProtectorUserHomeScreen(token: widget.token),
        ),
        (route) => false, // 이전 화면을 모두 제거
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 저장 실패!')),
      );
    }
  }

  Widget buildStarRating(
      String label, double currentRating, Function(double) onRatingUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            // 슬라이드 거리 기반으로 별점 조정 (0~5 사이)
            double dx = details.localPosition.dx;
            double newRating = (dx / 40).clamp(0, 5); // 40px 당 1점
            updateRating(onRatingUpdate, newRating);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              double starValue = index + 1.0;
              bool isHalfFilled =
                  currentRating >= starValue - 0.5 && currentRating < starValue;
              return GestureDetector(
                onTap: () => updateRating(
                    onRatingUpdate, isHalfFilled ? starValue - 0.5 : starValue),
                child: Icon(
                  isHalfFilled
                      ? Icons.star_half
                      : (currentRating >= starValue
                          ? Icons.star
                          : Icons.star_border),
                  color: Colors.amber,
                  size: 40,
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("간병인 평가하기")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildStarRating("간병일지 작성", diaryWriting,
                (rating) => setState(() => diaryWriting = rating)),
            buildStarRating("근무 태도", workAttitude,
                (rating) => setState(() => workAttitude = rating)),
            buildStarRating("환자 위생 관리", patientHygiene,
                (rating) => setState(() => patientHygiene = rating)),
            buildStarRating("개인 위생 관리", personalHygiene,
                (rating) => setState(() => personalHygiene = rating)),
            buildStarRating("요청 이해도", understandingRequests,
                (rating) => setState(() => understandingRequests = rating)),
            buildStarRating("반응 정확도", responseAccuracy,
                (rating) => setState(() => responseAccuracy = rating)),

            SizedBox(height: 10),

            // 리뷰 입력 필드
            TextField(
              controller: reviewController,
              decoration: InputDecoration(
                labelText: "리뷰 작성",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            SizedBox(height: 20),

            // 버튼 그룹 (확인 / 취소)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: submitReview,
                  child: Text("확인"),
                ),
                TextButton(
                  onPressed: () {
                    // 이전 화면으로 돌아가기
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text("취소"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
