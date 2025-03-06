import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'protector_home_screen.dart';
import 'patient_detail_screen.dart';


/*
------------------------------------------------------------------
file_name : review_edit_screen.dart                       

Developer                                                         
 ● Frontend : 최명일, 서민석
 ● backend : 최명일
 ● UI/UX : 서민석                                                     
                                                                  
description : 보호자가 간병인을 평가하는 별점 및 리뷰 작성 화면
              리뷰 작성 항목을 백엔드 서버로 전달 후 데이터베이스에 저장
------------------------------------------------------------------
*/

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

  double get sincerityRating => (diaryWriting + workAttitude) / 2;
  double get hygieneRating => (patientHygiene + personalHygiene) / 2;
  double get communicationRating =>
      (understandingRequests + responseAccuracy) / 2;
  double get totalRating =>
      (sincerityRating + hygieneRating + communicationRating) / 3;

  Future<void> submitReview() async {
    final url = Uri.parse('http://192.168.0.10:8000/reviews');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'caregiver_id': widget.caregiverId,
        'protector_id': widget.protectorId,
        'sincerity': sincerityRating,
        'hygiene': hygieneRating,
        'communication': communicationRating,
        'total_score': totalRating,
        'review_content': reviewController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰가 저장되었습니다.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ProtectorUserHomeScreen(token: widget.token),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 저장 실패!')),
      );
    }
  }

  Widget buildStarRating(
      String label, double rating, Function(double) onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.notoSansKr(fontSize: 16)),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            double dx = details.localPosition.dx;
            double newRating = (dx / 40).clamp(0, 5); // 40px 당 1점
            setState(() => onUpdate(newRating));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              double starValue = index + 1.0;
              bool isHalfFilled =
                  rating >= starValue - 0.5 && rating < starValue;
              return GestureDetector(
                onTap: () => setState(
                    () => onUpdate(isHalfFilled ? starValue - 0.5 : starValue)),
                child: Icon(
                  isHalfFilled
                      ? Icons.star_half
                      : (rating >= starValue ? Icons.star : Icons.star_border),
                  color: Color(0xFF43C098),
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

  Widget buildCategoryBox(
      String title, List<Map<String, dynamic>> items, double averageRating) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title 평점: ${averageRating.toStringAsFixed(1)}',
                style: GoogleFonts.notoSansKr(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            ...items.map((item) => buildStarRating(
                item['label'], item['rating'], item['updateFunc'])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("간병인 리뷰 작성",
            style: GoogleFonts.notoSansKr(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            buildCategoryBox(
                '성실도',
                [
                  {
                    'label': '간병일지 작성',
                    'rating': diaryWriting,
                    'updateFunc': (val) => diaryWriting = val
                  },
                  {
                    'label': '근무 태도',
                    'rating': workAttitude,
                    'updateFunc': (val) => workAttitude = val
                  },
                ],
                sincerityRating),
            buildCategoryBox(
                '위생',
                [
                  {
                    'label': '환자 위생 관리',
                    'rating': patientHygiene,
                    'updateFunc': (val) => patientHygiene = val
                  },
                  {
                    'label': '개인 위생 관리',
                    'rating': personalHygiene,
                    'updateFunc': (val) => personalHygiene = val
                  },
                ],
                hygieneRating),
            buildCategoryBox(
                '의사소통',
                [
                  {
                    'label': '요청 이해도',
                    'rating': understandingRequests,
                    'updateFunc': (val) => understandingRequests = val
                  },
                  {
                    'label': '반응 정확도',
                    'rating': responseAccuracy,
                    'updateFunc': (val) => responseAccuracy = val
                  },
                ],
                communicationRating),
            SizedBox(height: 10),
            Text("상세 리뷰 작성",
                style: GoogleFonts.notoSansKr(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text('전체 별점: ${totalRating.toStringAsFixed(1)}',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: reviewController,
              decoration: InputDecoration(
                hintText: '상세 리뷰를 작성해주세요.',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 250, 94, 47),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text("취소", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF43C098),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text("확인", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
