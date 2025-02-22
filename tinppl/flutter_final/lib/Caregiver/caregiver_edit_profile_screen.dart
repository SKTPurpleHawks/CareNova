import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverEditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CaregiverEditProfileScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  _CaregiverEditProfileScreenState createState() =>
      _CaregiverEditProfileScreenState();
}

class _CaregiverEditProfileScreenState
    extends State<CaregiverEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String? _spot;
  List<String> _selectedRegions = [];
  List<String> _selectedSymptoms = [];
  String? _canWalkPatient;
  String? _preferSex;
  String? _smoking;
  bool _canWalk = false; // 못 걷는 사람 간병 가능 여부
  String? _selectedSpot = '집'; // 간병 가능 장소 기본값
  String? _selectedSex;
  String? _preferredSex;

  // 생년월일 관련 변수
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;

  final List<String> _regions = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원도',
    '충청북도',
    '충청남도',
    '전라북도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도'
  ];

  final List<String> _symptoms = [
    '치매',
    '섬망',
    '욕창',
    '하반신 마비',
    '상반신 마비',
    '전신 마비',
    '와상환자',
    '기저귀케어',
    '의식X',
    '석션',
    '피딩',
    '소변줄',
    '장루',
    '야간 집중돌봄',
    '전염성',
    '파킨슨',
    '정신질환',
    '투석',
    '재활'
  ];

  final List<String> years =
      List.generate(100, (index) => (2024 - index).toString());
  final List<String> months =
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userData['name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.userData['phonenumber'] ?? '');
    _heightController = TextEditingController(
        text: widget.userData['height']?.toString() ?? '');
    _weightController = TextEditingController(
        text: widget.userData['weight']?.toString() ?? '');

    _spot = widget.userData['spot'] ?? '병원';
    _selectedRegions = (widget.userData['region'] as String?)?.split(',') ?? [];
    _selectedSymptoms =
        (widget.userData['symptoms'] as String?)?.split(',') ?? [];
    _canWalkPatient = widget.userData['canwalkpatient'] ?? '걸을 수 없음';
    _preferSex = widget.userData['prefersex'] ?? '남성';
    _smoking = widget.userData['smoking'] ?? '비흡연';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("프로필 수정"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey, // ✅ Form과 _formKey 연결
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('이메일 수정', hintText: '0000@flyai.com'),
              const SizedBox(height: 25),
              _buildTextField('비밀번호 수정', obscureText: true),
              const SizedBox(height: 25),

              _buildTextField('이름'),
              _buildTextField('나이'),
              _buildTextField('키'),
              _buildTextField('몸무게'),
              _buildTextField('전화번호', hintText: '010-0000-0000'),
              const SizedBox(height: 25),

              _buildDropdownField('성별',
                  options: ['남성', '여성'],
                  onChanged: (value) => setState(() => _selectedSex = value)),
              const SizedBox(height: 25),

              _buildBirthdateSelector(),
              const SizedBox(height: 25),

              _buildTextField('간병 가능 지역'),
              _buildTextField('간병 가능한 질환'),

              _buildDropdownField('간병 가능 장소',
                  options: ['집', '병원', '둘다'],
                  onChanged: (value) => setState(() => _selectedSpot = value)),
              const SizedBox(height: 15),

              _buildTextField('간병해본 진단명(경력)'),
              _buildTextField('간병 가능한 증상'),

              // 못 걷는 사람 간병 가능 여부 체크박스
              Row(
                children: [
                  Checkbox(
                    value: _canWalk,
                    onChanged: (bool? value) {
                      setState(() {
                        _canWalk = value!;
                      });
                    },
                  ),
                  Text(
                    '못 걷는 사람도 간병 가능',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              _buildDropdownField(
                '선호하는 환자 성별',
                options: ['남성', '여성'],
                onChanged: (value) => setState(() => _preferredSex = value),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile, // ✅ 버튼 클릭 시 _updateProfile 실행
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43C098),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "프로필 업데이트",
                    style: GoogleFonts.notoSansKr(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

// ✅ TextField 대신 TextFormField 사용
  Widget _buildTextField(String label,
      {String hintText = '', bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1.0),
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black45,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label을 입력하세요.';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

// ✅ 수정된 _updateProfile 함수
  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      // ✅ Form이 연결되어야 정상 작동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("프로필이 업데이트되었습니다!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildBirthdateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '생년월일',
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4), // 제목과 드롭다운 사이 간격 최소화
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 2.0), // **년도 라벨과 드롭다운 간격 최소화**
                    child: Text(
                      '년도',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _buildDropdownField2(
                    '',
                    options: years,
                    onChanged: (value) => setState(() => _selectedYear = value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6), // 간격 최소화
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 2.0), // **월 라벨과 드롭다운 간격 최소화**
                    child: Text(
                      '월',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _buildDropdownField2(
                    '',
                    options: months,
                    onChanged: (value) =>
                        setState(() => _selectedMonth = value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6), // 간격 최소화
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 2.0), // **일 라벨과 드롭다운 간격 최소화**
                    child: Text(
                      '일',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _buildDropdownField2(
                    '',
                    options: days,
                    onChanged: (value) => setState(() => _selectedDay = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField2(String label,
      {List<String>? options, ValueChanged<String?>? onChanged}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // 박스 둥글기 줄임
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 2, horizontal: 8), // 내부 패딩 최대한 줄이기
      ),
      value: null,
      items: options?.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField(String label,
      {List<String>? options, ValueChanged<String?>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0), // 설명 텍스트 간격 추가
          child: Text(
            label, // 💡 라벨 표시 유지
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label, // 💡 라벨이 드롭다운 내부에도 유지되도록 추가
            labelStyle: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          value: null,
          items: options?.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16), // 필드 간 간격 추가
      ],
    );
  }
}
