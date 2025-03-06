import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SBJNMCCARE',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansKrTextTheme(),
      ),
      home: const ReviewEditScreen(),
    );
  }
}

class ReviewEditScreen extends StatefulWidget {
  const ReviewEditScreen({super.key});

  @override
  _ReviewEditScreenState createState() => _ReviewEditScreenState();
}

class _ReviewEditScreenState extends State<ReviewEditScreen> {
  final Map<String, double> ratings = {
    '간병일지 작성': 0,
    '근무 태도': 0,
    '환자 위생 관리': 0,
    '개인 위생 관리': 0,
    '요청 이해도': 0,
    '반응 정확도': 0,
  };

  double get sincerityRating => (ratings['간병일지 작성']! + ratings['근무 태도']!) / 2;
  double get hygieneRating => (ratings['환자 위생 관리']! + ratings['개인 위생 관리']!) / 2;
  double get communicationRating =>
      (ratings['요청 이해도']! + ratings['반응 정확도']!) / 2;
  double get totalRating =>
      (sincerityRating + hygieneRating + communicationRating) / 3;

  Widget buildStarRating(
      String label, double currentRating, void Function(double) onUpdate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: List.generate(5, (index) {
            double starValue = index + 1;
            return GestureDetector(
              onTap: () => onUpdate(starValue),
              child: Icon(
                currentRating >= starValue ? Icons.star : Icons.star_border,
                color: Color(0xFF43C098),
                size: 36, // 이 값을 조정하여 별 크기를 키우세요
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildCategoryBox(
      String title, List<String> items, double averageRating) {
    return Card(
      color: Colors.white,
      elevation: 2, // 그림자 강도 조절 (높을수록 강한 그림자)
      shadowColor: Colors.grey.withOpacity(0.5), // 명시적 그림자 색상 지정
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // 둥글기도 지정 가능
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title 평점: ${averageRating.toStringAsFixed(1)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...items.map((item) => buildStarRating(item, ratings[item]!,
                (val) => setState(() => ratings[item] = val))),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/textlogo.png',
          height: 25,
          fit: BoxFit.contain,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "간병인 리뷰",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    buildCategoryBox(
                        '성실도', ['간병일지 작성', '근무 태도'], sincerityRating),
                    buildCategoryBox(
                        '위생', ['환자 위생 관리', '개인 위생 관리'], hygieneRating),
                    buildCategoryBox(
                        '의사소통', ['요청 이해도', '반응 정확도'], communicationRating),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 2,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            '전체 평균 별점: ${totalRating.toStringAsFixed(1)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 29, 105, 81)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '상세 리뷰를 작성해주세요.',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 120), // 버튼과 겹치지 않도록 여유공간 확보
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: const Color(0xFF43C098),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // 리뷰 작성 완료 처리 로직
          },
          child: const Text(
            '리뷰 작성 완료하기',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
