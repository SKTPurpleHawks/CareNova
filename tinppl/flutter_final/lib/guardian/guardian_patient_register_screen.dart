import 'package:flutter/material.dart';

class GuardianPatientRegisterScreen extends StatefulWidget {
  const GuardianPatientRegisterScreen({super.key});

  @override
  State<GuardianPatientRegisterScreen> createState() => _GuardianPatientRegisterScreenState();
}

class _GuardianPatientRegisterScreenState extends State<GuardianPatientRegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  String? selectedSpot;
  String? selectedGender;
  String? selectedPreferredGender;
  String? selectedAge;
  String? selectedHeight;
  String? selectedWeight;
  String? selectedDisease;
  bool canWalk = true;

  final List<String> spots = ['집', '병원', '둘다'];
  final List<String> symptoms = [
    '치매', '섬망', '욕창', '하반신 마비', '상반신 마비', '전신 마비',
    '와상환자', '기저귀케어', '의식X', '석션', '피딩', '소변줄', '장루',
    '야간 집중돌봄', '전염성', '파킨슨', '정신질환', '투석', '재활'
  ];
  List<String> selectedSymptoms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('환자 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('이름', controller: nameController), // ✅ 이름 입력칸 추가
              _buildTextField('간병 기간 (일 단위)', onChanged: (value) => selectedAge = value),
              _buildTextField('간병 지역', onChanged: (value) => selectedHeight = value),
              _buildDropdownField('간병 장소', spots, selectedSpot, (value) => setState(() => selectedSpot = value)),
              _buildGenderSelector('환자 성별', (value) => setState(() => selectedGender = value)),
              _buildTextField('환자 나이', onChanged: (value) => selectedAge = value),
              _buildTextField('환자 키', onChanged: (value) => selectedHeight = value),
              _buildTextField('환자 몸무게', onChanged: (value) => selectedWeight = value),
              _buildTextField('진단명', onChanged: (value) => selectedDisease = value),
              _buildMultiSelectField('증상', symptoms, selectedSymptoms),
              _buildCheckboxField('걸을 수 없는 환자입니까?', canWalk, (value) => setState(() => canWalk = value ?? false)),
              _buildGenderSelector('선호하는 간병인 성별', (value) => setState(() => selectedPreferredGender = value)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addPatient, // ✅ 버튼 동작 수정
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('환자 정보 추가하기'), // ✅ 버튼 텍스트 변경
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPatient() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('환자 이름을 입력해주세요.'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // ✅ 환자 리스트 화면으로 이동하며 새 환자 이름 전달
    Navigator.pop(context, nameController.text);
  }

  Widget _buildTextField(String label, {TextEditingController? controller, ValueChanged<String>? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: label,
          border: const OutlineInputBorder(),
        ),
        value: selectedItem ?? items.first,
        items: items.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGenderSelector(String label, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(child: _buildGenderButton('남', selectedGender, onChanged)),
            const SizedBox(width: 8),
            Expanded(child: _buildGenderButton('여', selectedGender, onChanged)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGenderButton(String gender, String? selected, ValueChanged<String?> onChanged) {
    return ElevatedButton(
      onPressed: () => onChanged(gender),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected == gender ? Colors.black : Colors.white,
        foregroundColor: selected == gender ? Colors.white : Colors.black,
        side: const BorderSide(color: Colors.black),
      ),
      child: Text(gender),
    );
  }

  Widget _buildMultiSelectField(String label, List<String> options, List<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          children: options.map((option) {
            bool isSelected = selectedOptions.contains(option);
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selected ? selectedOptions.add(option) : selectedOptions.remove(option);
                  });
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCheckboxField(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) {
              onChanged(newValue ?? false);
            },
          ),
          Text(label),
        ],
      ),
    );
  }
}
