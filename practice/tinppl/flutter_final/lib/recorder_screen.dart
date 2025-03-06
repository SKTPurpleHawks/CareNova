import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;
  Timer? _timer;
  int _remainingTime = 30; // ⏳ 최대 30초 녹음 제한

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startRecording() async {
    Directory? extDir = await getExternalStorageDirectory();
    if (extDir == null) {
      debugPrint("외부 저장소 접근 불가");
      return;
    }

    String path = '${extDir.path}/recording.wav';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV, // 🎤 WAV 포맷 사용
      sampleRate: 16000, // 🎼 16kHz 설정
      numChannels: 1, // 🔊 모노(1채널)
    );

    setState(() {
      _isRecording = true;
      _filePath = path;
      _remainingTime = 30;
    });

    debugPrint("녹음된 파일 저장 위치: $path");

    // ⏳ 30초 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _stopRecording(); // 30초 초과 시 자동 중지
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return; // 중복 실행 방지

    await _recorder.stopRecorder();
    _timer?.cancel(); // ⏳ 타이머 정지

    setState(() {
      _isRecording = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음 완료: $_filePath')),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오디오 녹음기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? '녹음 중지' : '녹음 시작'),
            ),
          ],
        ),
      ),
    );
  }
}
