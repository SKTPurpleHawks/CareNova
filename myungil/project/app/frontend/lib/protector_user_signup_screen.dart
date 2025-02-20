import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'login_screen.dart';

class ProtectorUserSignupScreen extends StatefulWidget {
  @override
  _ProtectorUserSignupScreenState createState() => _ProtectorUserSignupScreenState();
}

class _ProtectorUserSignupScreenState extends State<ProtectorUserSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedGender = "남성";
  String message = "";

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          message = "비밀번호가 일치하지 않습니다.";
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/signup/protector'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text,
          'name': nameController.text,
          'phonenumber': phoneNumberController.text,
          'birthday': selectedDate.toIso8601String().split('T')[0],
          'sex': selectedGender,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("보호자 회원가입"),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(emailController, "이메일"),
                _buildTextField(passwordController, "비밀번호", isPassword: true),
                _buildTextField(confirmPasswordController, "비밀번호 확인", isPassword: true),
                _buildTextField(nameController, "이름"),
                _buildTextField(phoneNumberController, "전화번호", keyboardType: TextInputType.phone),
                
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("생년월일", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDropdownYear(),
                    _buildDropdownMonth(),
                    _buildDropdownDay(),
                  ],
                ),
                const SizedBox(height: 10),

                _buildDropdownGender(),

                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: _signup,
                    child: const Text("가입하기", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label을 입력해주세요';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownGender() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        labelText: '성별',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: ['남성', '여성'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedGender = newValue!;
        });
      },
    );
  }

  Widget _buildDropdownYear() {
    return DropdownButton<String>(
      value: selectedDate.year.toString(),
      items: List.generate(100, (index) {
        int year = DateTime.now().year - index;
        return DropdownMenuItem(
          value: year.toString(),
          child: Text("$year"),
        );
      }),
      onChanged: (String? newValue) {
        setState(() {
          selectedDate = DateTime(int.parse(newValue!), selectedDate.month, selectedDate.day);
        });
      },
    );
  }

  Widget _buildDropdownMonth() {
    return DropdownButton<String>(
      value: selectedDate.month.toString().padLeft(2, '0'),
      items: List.generate(12, (index) {
        int month = index + 1;
        return DropdownMenuItem(
          value: month.toString().padLeft(2, '0'),
          child: Text("$month"),
        );
      }),
      onChanged: (String? newValue) {
        setState(() {
          selectedDate = DateTime(selectedDate.year, int.parse(newValue!), selectedDate.day);
        });
      },
    );
  }

  Widget _buildDropdownDay() {
    return DropdownButton<String>(
      value: selectedDate.day.toString().padLeft(2, '0'),
      items: List.generate(31, (index) {
        int day = index + 1;
        return DropdownMenuItem(
          value: day.toString().padLeft(2, '0'),
          child: Text("$day"),
        );
      }),
      onChanged: (String? newValue) {
        setState(() {
          selectedDate = DateTime(selectedDate.year, selectedDate.month, int.parse(newValue!));
        });
      },
    );
  }
}
