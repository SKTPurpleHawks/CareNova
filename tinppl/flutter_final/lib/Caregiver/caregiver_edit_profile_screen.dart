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

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필이 업데이트되었습니다!")),
      );
      Navigator.pop(context);
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, "이름"),
              _buildTextField(_phoneController, "전화번호",
                  keyboardType: TextInputType.phone),
              _buildTextField(_heightController, "키 (cm)",
                  keyboardType: TextInputType.number),
              _buildTextField(_weightController, "몸무게 (kg)",
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _buildDropdownField(
                "간병 가능 장소",
                value: _spot, // ✅ 현재 선택된 값을 유지하도록 추가
                options: ['병원', '집', '둘 다'],
                onChanged: (value) => setState(() => _spot = value),
              ),
              _buildDropdownField(
                "환자 보행 가능 여부",
                value: _canWalkPatient, // ✅ 선택한 값 유지
                options: ['걸을 수 있음', '걸을 수 없음', '상관없음'],
                onChanged: (value) => setState(() => _canWalkPatient = value),
              ),
              _buildDropdownField(
                "선호하는 환자 성별",
                value: _preferSex, // ✅ 선택한 값 유지
                options: ['남성', '여성', '상관없음'],
                onChanged: (value) => setState(() => _preferSex = value),
              ),
              _buildDropdownField(
                "흡연 여부",
                value: _smoking, // ✅ 선택한 값 유지
                options: ['비흡연', '흡연'],
                onChanged: (value) => setState(() => _smoking = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("프로필 업데이트",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {String hintText = '',
      TextInputType keyboardType = TextInputType.text,
      bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1.0), // 설명 텍스트 간격 최소화
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.notoSansKr(
              // 힌트 텍스트 흐리게 적용
              fontSize: 14,
              fontWeight: FontWeight.w400, // Regular 적용
              color: Colors.black45, // 흐린 회색 적용
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
        ),
        const SizedBox(height: 10), // 필드 간 간격 추가
      ],
    );
  }

  Widget _buildDropdownField(String label,
      {required List<String> options,
      required ValueChanged<String?> onChanged,
      String? value}) {
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
          value: value ?? options.first, // ✅ 기본값 설정하여 null 방지
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 16), // 내부 패딩 최소화
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          items: options.map((String value) {
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

  Widget _buildMultiSelect(
      String label, List<String> allItems, List<String> selectedItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0, // 간격 추가
            children: allItems.map((item) {
              bool isSelected = selectedItems.contains(item);
              return ChoiceChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    isSelected
                        ? selectedItems.remove(item)
                        : selectedItems.add(item);
                  });
                },
                selectedColor: Colors.blueAccent, // 선택 시 배경색 변경
                backgroundColor: Colors.grey[200], // 비선택 시 배경색
                labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.black), // 선택된 항목 텍스트 색상 변경
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
