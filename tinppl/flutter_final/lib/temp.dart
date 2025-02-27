import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert'; // JSON 처리
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env에서 API 키 불러오기
import 'package:audio_waveforms/audio_waveforms.dart'; // audio_waveforms 패키지 사용


class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}



class _RecorderScreenState extends State<RecorderScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  Timer? _timer;
  int _remainingTime = 30; // ⏳ 최대 30초 녹음 제한
  List<String> _messages = []; // ✅ 채팅 메시지를 저장할 리스트

  double _currentDecibel = -100.0;
  // 음성의 최대 볼륨(dB) 기록 및 최소 임계치 설정
  double _maxDecibel = -100.0;
  static const double _minDecibelThreshold = -40.0; // 예시: -40 dB 이상일 때 의미 있는 음성으로 간주

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await _requestPermissions();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();  // ✅ 플레이어 초기화 추가
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startRecording() async {
    if (_isRecording) return; // ✅ 중복 실행 방지

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

    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
    _recorder.onProgress?.listen((RecordingDisposition d) {
      setState(() {
        _currentDecibel = d.decibels ?? -100.0;
      });
      // _currentDecibel 값을 콘솔에 출력
      // debugPrint('_currentDecibel: $_currentDecibel');
    });

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
      SnackBar(content: Text('녹음 완료')),
    );

     // ✅ STT 변환 실행 (녹음 종료 후 자동 실행)
    if (_filePath != null) {
      String rawText = await _convertSpeechToTextWithWhisper(_filePath!);
      String refinedText = await _refineTextWithGPT(rawText); // ✅ GPT로 보정된 텍스트

      setState(() {
        _messages.insert(0, refinedText); // 📩 채팅 형식으로 UI에 표시
      });
      _playTTS(refinedText);  // ✅ TTS 실행
      debugPrint("📢 최종 변환 텍스트: $refinedText");
    }
  }

  Future<String> _convertSpeechToTextWithWhisper(String filePath) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final whStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty) {
      debugPrint("❌ OpenAI API Key가 설정되지 않았습니다.");
      return "입력된 내용이 없습니다.";
    }

    try {
      File audioFile = File(filePath);

      // ✅ 녹음된 파일이 존재하는지 확인
      if (!await audioFile.exists()) {
        debugPrint("❌ 녹음된 파일이 존재하지 않습니다: $filePath");
        return "입력된 내용이 없습니다.";
      }

      int fileSize = await audioFile.length();
      debugPrint("🎤 녹음된 파일 크기: $fileSize bytes");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $apiKey';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'ko';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      debugPrint("📡 Whisper API 요청 전송 중...");

      var response = await request.send();

      // ✅ 응답이 정상적으로 왔는지 확인
      if (response.statusCode != 200) {
        debugPrint("❌ Whisper API 요청 실패: ${response.reasonPhrase}");
        return "입력된 내용이 없습니다.";
      }

      String responseBody = await response.stream.bytesToString();
      whStopwatch.stop();
      debugPrint("📝 Whisper API 응답(${whStopwatch.elapsedMilliseconds}ms): $responseBody");

      // ✅ JSON 파싱 오류 방지 및 UTF-8 처리
      Map<String, dynamic> decodedResponse = jsonDecode(responseBody);

      // ✅ 변환된 텍스트 추출
      String transcribedText = decodedResponse['text']?.trim() ?? "";

      // ✅ 변환된 텍스트가 비어있는 경우 처리
      if (transcribedText.isEmpty) {
        debugPrint("❌ 변환된 텍스트 없음");
        return "입력된 내용이 없습니다.";
      }

      debugPrint("🎤 Whisper 변환 텍스트: $transcribedText");
      return transcribedText;
    } catch (e) {
      debugPrint("❌ Whisper API 오류: $e");
      return "입력된 내용이 없습니다.";
    }
  }

  Future<String> _refineTextWithGPT(String text) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final gptStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty) {
      debugPrint("❌ OpenAI API Key가 설정되지 않았습니다.");
      return text;
    }

    if (text.trim().isEmpty) {
      return "입력된 내용이 너무 짧습니다. 다시 시도해주세요.";
    }

    try {
      var response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: utf8.encode(jsonEncode({
          //"model": "gpt-4o-mini",
          "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content": "'중국어' 단어가 마지막에 포함되어 있으면 중국어로 번역해서 출력해줘. " +
                        "너는 한국어 문장 보정 전문가야. 아래 텍스트는 발음이 부정확한 사람의 음성에서 변환된 결과로, " +
                        "오타, 잘못 인식된 단어, 이름, 비자연스러운 표현들이 포함될 수 있어. " +
                        "입력된 텍스트의 원래 의미를 최대한 살리면서 자연스럽고 올바른 한국어 문장으로 보정해줘. " +
                        "보정이지, 너가 없는 말을 지어내면 안돼."
            },
            {"role": "user", "content": text}
          ],
          "temperature": 0.2
        })),
      );

      // ✅ UTF-8 디코딩 적용 (bodyBytes 사용)
      String responseBody = utf8.decode(response.bodyBytes);
      gptStopwatch.stop();
      debugPrint("📝 GPT API 응답(${gptStopwatch.elapsedMilliseconds}ms)");

      // ✅ JSON 데이터 파싱 (타입 오류 방지)
      Map<String, dynamic> decodedResponse = jsonDecode(responseBody);

      // ✅ 변환된 텍스트 가져오기
      if (decodedResponse.containsKey('choices') && decodedResponse['choices'].isNotEmpty) {
        String refinedText = decodedResponse['choices'][0]['message']['content'].trim();
        return refinedText;
      } else {
        return "GPT 응답이 올바르지 않습니다.";
      }
    } catch (e) {
      debugPrint("❌ GPT 요청 오류: $e");
      return text;
    }
  }

  Future<void> _playTTS(String text) async {
    String apiKey = dotenv.env['TYPECAST_API_KEY'] ?? '';
    String apiUrl = dotenv.env['TYPECAST_VOICE_ID'] ?? '';
    String actorId = "622964d6255364be41659078";
    //String actorId = "66d01e9dbda076835c38dcc8";
    final ttsStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty || apiUrl.isEmpty) {
      debugPrint("❌ Typecast API Key 또는 Voice ID가 설정되지 않았습니다.");
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "text": text,
          "lang": "auto",
          "actor_id": actorId,
          "xapi_hd": true,
          "model_version": "latest"
        }),
      );

      if (response.statusCode == 200) {
        var responseJson = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
        debugPrint("📝 TTS API 응답: $responseJson");

        if (responseJson.containsKey("result") &&
            responseJson["result"].containsKey("speak_v2_url")) {
          String speakUrl = responseJson["result"]["speak_v2_url"];
          ttsStopwatch.stop();
          debugPrint("✅ TTS 생성 성공(${ttsStopwatch.elapsedMilliseconds}ms): $speakUrl");
          
          // 📢 **오디오 다운로드 URL 가져오기**
          String? audioUrl = await _waitForAudio(speakUrl);
          if (audioUrl != null) {
            _downloadAndPlayTTS(audioUrl);
          } else {
            debugPrint("❌ TTS 음성 파일 URL을 가져오지 못했습니다.");
          }
        } else {
          debugPrint("❌ TTS 응답에서 speak_v2_url이 누락됨.");
        }
      } else {
        debugPrint("❌ TTS 요청 실패: ${response.reasonPhrase}");
      }
    } catch (e) {
      debugPrint("❌ Typecast API 오류: $e");
    }
  }

  Future<String?> _waitForAudio(String speakV2Url) async {
    String apiKey = dotenv.env['TYPECAST_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      debugPrint("❌ Typecast API Key가 설정되지 않았습니다.");
      return null;
    }

    try {
      for (int i = 0; i < 10; i++) { // 최대 10초 동안 대기
        var response = await http.get(
          Uri.parse(speakV2Url),
          headers: {"Authorization": "Bearer $apiKey"},
        );

        if (response.statusCode == 200) {
          var responseJson = jsonDecode(utf8.decode(response.bodyBytes));
          String status = responseJson["result"]["status"] ?? "";

          if (status == "done") {
            return responseJson["result"]["audio_download_url"];
          } else if (status == "progress") {
            debugPrint("⏳ 음성 생성 중... (1초 후 재시도)");
            await Future.delayed(Duration(seconds: 1));
          } else {
            debugPrint("❌ Unexpected status: $status");
            return null;
          }
        } else {
          debugPrint("❌ 음성 생성 상태 확인 실패: ${response.reasonPhrase}");
          return null;
        }
      }
    } catch (e) {
      debugPrint("❌ 음성 생성 대기 중 오류 발생: $e");
    }
    return null;
  }

  Future<void> _downloadAndPlayTTS(String audioUrl) async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/tts_output.wav';

    try {
      var response = await http.get(Uri.parse(audioUrl));
      if (response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint("✅ 음성 파일 다운로드 완료: $filePath");

        await _player.startPlayer(fromURI: filePath); // ✅ 즉시 재생
      } else {
        debugPrint("❌ TTS 파일 다운로드 실패 (응답 코드: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("❌ TTS 파일 다운로드 중 오류 발생: $e");
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _currentDecibel 값 (-100 ~ -40)을 0.0 ~ 1.0으로 정규화
    double normalizedAmplitude = ((_currentDecibel + 100) / 60).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('오디오 녹음기')),
      body: Column(
        children: [
          // 채팅 메시지 영역
          Expanded(
            child: ListView.builder(
              reverse: true, // 최신 메시지가 위로
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerRight, // 사용자 메시지는 우측 정렬
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43C098), // 메시지 배경색
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _messages[index],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 녹음 프로그래스 바 (채팅과 버튼 사이 중앙에 크게)
          Container(
            width: double.infinity,
            height: 80, // 원하는 높이
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 컨테이너 (회색 배경, 둥근 모서리, 그림자 효과)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                // 진행률 표시 (둥근 모서리 적용)
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: LinearProgressIndicator(
                    minHeight: 80,
                    value: _isRecording ? normalizedAmplitude : 0.0,
                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF43C098)),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // 중앙에 데시벨 텍스트 표시 (예: "-67.5 dB")
                Text(
                  _isRecording ? "${_currentDecibel.toStringAsFixed(1)} dB" : "0 dB",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          
          const SizedBox(height: 20),
          // 녹음 버튼 영역
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.grey : const Color(0xFF43C098),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(28), // 버튼 크기 조절
                elevation: 8,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

}




import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert'; // JSON 처리
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class BarDefinition {
  final double heightFactor; // 0.0 ~ 1.0 사이 값, 부모 높이의 몇 배로 표시할지 결정
  final Color? color;
  BarDefinition({required this.heightFactor, this.color});
}

// 실시간으로 변경되는 커스텀 웨이브폼 위젯
class LiveAudioWave extends StatefulWidget {
  final List<BarDefinition> bars;
  final double width;
  final double height;
  final double spacing;

  const LiveAudioWave({
    Key? key,
    required this.bars,
    required this.width,
    required this.height,
    required this.spacing,
  }) : super(key: key);

  @override
  _LiveAudioWaveState createState() => _LiveAudioWaveState();
}
class _LiveAudioWaveState extends State<LiveAudioWave> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.bars.map((bar) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100), // 부드러운 애니메이션 효과
            width: (widget.width - widget.spacing * (widget.bars.length - 1)) / widget.bars.length,
            height: widget.height * bar.heightFactor,
            margin: EdgeInsets.only(right: widget.spacing),
            decoration: BoxDecoration(
              color: bar.color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecorderScreenState extends State<RecorderScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  Timer? _timer;
  int _remainingTime = 30; // ⏳ 최대 30초 녹음 제한
  List<String> _messages = []; // ✅ 채팅 메시지를 저장할 리스트
  List<BarDefinition> _bars = [];

  double _currentDecibel = -100.0; // 음성의 최대 볼륨(dB) 기록 및 최소 임계치 설정
  double _maxDecibel = -100.0;
  static const double _minDecibelThreshold = -30.0; // 예시: -40 dB 이상일 때 의미 있는 음성으로 간주

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
    _generateInitialWaveform();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await _requestPermissions();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();  // ✅ 플레이어 초기화 추가
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startRecording() async {
    if (_isRecording) return; // ✅ 중복 실행 방지

    _generateInitialWaveform(); 

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

    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
    _recorder.onProgress?.listen((RecordingDisposition d) {
      setState(() {
        _currentDecibel = d.decibels ?? -100.0;
        _updateWaveform(_currentDecibel); // ✅ 실시간 웨이브 업데이트
      });
      // _currentDecibel 값을 콘솔에 출력
      //debugPrint('_currentDecibel: $_currentDecibel');
    });

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
      _generateInitialWaveform();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음 완료')),
    );

     // ✅ STT 변환 실행 (녹음 종료 후 자동 실행)
    if (_filePath != null) {
      String rawText = await _convertSpeechToTextWithWhisper(_filePath!);
      String refinedText = await _refineTextWithGPT(rawText); // ✅ GPT로 보정된 텍스트

      setState(() {
        _messages.insert(0, refinedText); // 📩 채팅 형식으로 UI에 표시
      });
      _playTTS(refinedText);  // ✅ TTS 실행
      debugPrint("📢 최종 변환 텍스트: $refinedText");
    }
  }

  Future<String> _convertSpeechToTextWithWhisper(String filePath) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final whStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty) {
      debugPrint("❌ OpenAI API Key가 설정되지 않았습니다.");
      return "입력된 내용이 없습니다.";
    }

    try {
      File audioFile = File(filePath);

      // ✅ 녹음된 파일이 존재하는지 확인
      if (!await audioFile.exists()) {
        debugPrint("❌ 녹음된 파일이 존재하지 않습니다: $filePath");
        return "입력된 내용이 없습니다.";
      }

      int fileSize = await audioFile.length();
      debugPrint("🎤 녹음된 파일 크기: $fileSize bytes");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $apiKey';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'ko';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      debugPrint("📡 Whisper API 요청 전송 중...");
      var response = await request.send();

      // ✅ 응답이 정상적으로 왔는지 확인
      if (response.statusCode != 200) {
        debugPrint("❌ Whisper API 요청 실패: ${response.reasonPhrase}");
        return "입력된 내용이 없습니다.";
      }

      String responseBody = await response.stream.bytesToString();
      whStopwatch.stop();
      debugPrint("📝 Whisper API 응답(${whStopwatch.elapsedMilliseconds}ms): $responseBody");

      // ✅ JSON 파싱 오류 방지 및 UTF-8 처리
      Map<String, dynamic> decodedResponse = jsonDecode(responseBody);

      // ✅ 변환된 텍스트 추출
      String transcribedText = decodedResponse['text']?.trim() ?? "";

      // ✅ 변환된 텍스트가 비어있는 경우 처리
      if (transcribedText.isEmpty) {
        debugPrint("❌ 변환된 텍스트 없음");
        return "입력된 내용이 없습니다.";
      }

      debugPrint("🎤 Whisper 변환 텍스트: $transcribedText");
      return transcribedText;
    } catch (e) {
      debugPrint("❌ Whisper API 오류: $e");
      return "입력된 내용이 없습니다.";
    }
  }

  Future<String> _refineTextWithGPT(String text) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final gptStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty) {
      debugPrint("❌ OpenAI API Key가 설정되지 않았습니다.");
      return text;
    }

    if (text.trim().isEmpty) {
      return "입력된 내용이 너무 짧습니다. 다시 시도해주세요.";
    }

    try {
      var response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: utf8.encode(jsonEncode({
          //"model": "gpt-4o-mini",
          "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content":"보정이지, 너가 없는 말을 지어내면 안돼."+ 
                        "'중국어' 단어가 마지막에 포함되어 있으면 중국어로 번역해서 출력해줘. " +
                        "너는 한국어 문장 보정 전문가야. 아래 텍스트는 발음이 부정확한 사람의 음성에서 변환된 결과로, " +
                        "오타, 잘못 인식된 단어, 이름, 비자연스러운 표현들이 포함될 수 있어. " +
                        "입력된 텍스트의 원래 의미를 최대한 살리면서 자연스럽고 올바른 한국어 문장으로 보정해줘. "
            },
            {"role": "user", "content": text}
          ],
          "temperature": 0.2
        })),
      );

      // ✅ UTF-8 디코딩 적용 (bodyBytes 사용)
      String responseBody = utf8.decode(response.bodyBytes);
      gptStopwatch.stop();
      debugPrint("📝 GPT API 응답(${gptStopwatch.elapsedMilliseconds}ms)");

      // ✅ JSON 데이터 파싱 (타입 오류 방지)
      Map<String, dynamic> decodedResponse = jsonDecode(responseBody);

      // ✅ 변환된 텍스트 가져오기
      if (decodedResponse.containsKey('choices') && decodedResponse['choices'].isNotEmpty) {
        String refinedText = decodedResponse['choices'][0]['message']['content'].trim();
        return refinedText;
      } else {
        return "GPT 응답이 올바르지 않습니다.";
      }
    } catch (e) {
      debugPrint("❌ GPT 요청 오류: $e");
      return text;
    }
  }

  Future<void> _playTTS(String text) async {
    String apiKey = dotenv.env['TYPECAST_API_KEY'] ?? '';
    String apiUrl = dotenv.env['TYPECAST_VOICE_ID'] ?? '';
    String actorId = "622964d6255364be41659078";
    //String actorId = "66d01e9dbda076835c38dcc8";
    final ttsStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty || apiUrl.isEmpty) {
      debugPrint("❌ Typecast API Key 또는 Voice ID가 설정되지 않았습니다.");
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "text": text,
          "lang": "auto",
          "actor_id": actorId,
          "xapi_hd": true,
          "model_version": "latest"
        }),
      );

      if (response.statusCode == 200) {
        var responseJson = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
        debugPrint("📝 TTS API 응답: $responseJson");

        if (responseJson.containsKey("result") &&
            responseJson["result"].containsKey("speak_v2_url")) {
          String speakUrl = responseJson["result"]["speak_v2_url"];
          ttsStopwatch.stop();
          debugPrint("✅ TTS 생성 성공(${ttsStopwatch.elapsedMilliseconds}ms): $speakUrl");
          
          // 📢 **오디오 다운로드 URL 가져오기**
          String? audioUrl = await _waitForAudio(speakUrl);
          if (audioUrl != null) {
            _downloadAndPlayTTS(audioUrl);
          } else {
            debugPrint("❌ TTS 음성 파일 URL을 가져오지 못했습니다.");
          }
        } else {
          debugPrint("❌ TTS 응답에서 speak_v2_url이 누락됨.");
        }
      } else {
        debugPrint("❌ TTS 요청 실패: ${response.reasonPhrase}");
      }
    } catch (e) {
      debugPrint("❌ Typecast API 오류: $e");
    }
  }

  Future<String?> _waitForAudio(String speakV2Url) async {
    String apiKey = dotenv.env['TYPECAST_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      debugPrint("❌ Typecast API Key가 설정되지 않았습니다.");
      return null;
    }

    try {
      for (int i = 0; i < 10; i++) { // 최대 10초 동안 대기
        var response = await http.get(
          Uri.parse(speakV2Url),
          headers: {"Authorization": "Bearer $apiKey"},
        );

        if (response.statusCode == 200) {
          var responseJson = jsonDecode(utf8.decode(response.bodyBytes));
          String status = responseJson["result"]["status"] ?? "";

          if (status == "done") {
            return responseJson["result"]["audio_download_url"];
          } else if (status == "progress") {
            debugPrint("⏳ 음성 생성 중... (1초 후 재시도)");
            await Future.delayed(Duration(seconds: 1));
          } else {
            debugPrint("❌ Unexpected status: $status");
            return null;
          }
        } else {
          debugPrint("❌ 음성 생성 상태 확인 실패: ${response.reasonPhrase}");
          return null;
        }
      }
    } catch (e) {
      debugPrint("❌ 음성 생성 대기 중 오류 발생: $e");
    }
    return null;
  }

  Future<void> _downloadAndPlayTTS(String audioUrl) async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/tts_output.wav';

    try {
      var response = await http.get(Uri.parse(audioUrl));
      if (response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint("✅ 음성 파일 다운로드 완료: $filePath");

        await _player.startPlayer(fromURI: filePath); // ✅ 즉시 재생
      } else {
        debugPrint("❌ TTS 파일 다운로드 실패 (응답 코드: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("❌ TTS 파일 다운로드 중 오류 발생: $e");
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _timer?.cancel();
    super.dispose();
  }

  void _updateWaveform(double decibel) {
    setState(() {
      _bars = List.generate(20, (index) {
        double normalizedHeight = ((decibel + 100) / 100).clamp(0.1, 1.0);
        return BarDefinition(
          heightFactor: normalizedHeight,
          color: Colors.primaries[index % Colors.primaries.length],
        );
      });
    });
  }

  void _generateInitialWaveform() {
    setState(() {
      _bars = List.generate(20, (index) {
        return BarDefinition(
          heightFactor: 0.2, // 기본 높이 (녹음 전 초기 상태)
          color: Colors.primaries[index % Colors.primaries.length],
        );
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    // _currentDecibel 값 (-100 ~ -40)을 0.0 ~ 1.0으로 정규화
    double normalizedAmplitude = ((_currentDecibel + 100) / 60).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('오디오 녹음기')),
      body: Column(
        children: [
          // 채팅 메시지 영역
          Expanded(
            child: ListView.builder(
              reverse: true, // 최신 메시지가 위로
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerRight, // 사용자 메시지는 우측 정렬
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43C098), // 메시지 배경색
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _messages[index],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 실시간 웨이브 바
          const SizedBox(height: 20),
          LiveAudioWave(
            bars: _bars,
            width: 200,
            height: 50,
            spacing: 4,
          ),
          // 녹음 프로그래스 바 (채팅과 버튼 사이 중앙에 크게)
          Container(
            width: double.infinity,
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade200,
                        Colors.blueGrey.shade400,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: FractionallySizedBox(
                      widthFactor: _isRecording ? normalizedAmplitude : 0.0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF43C098),
                              Color(0xFF2F8F7E),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _isRecording ? "${_currentDecibel.toStringAsFixed(1)} dB" : "0 dB",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // 녹음 버튼 영역
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.grey : const Color(0xFF43C098),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(28), // 버튼 크기 조절
                elevation: 8,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

}



void _updateWaveform(double decibel) {
    double normalizedHeight = ((decibel + 60) / 60).clamp(0.1, 1.0);
    setState(() {
      _bars = List.generate(18, (index) {
        return BarDefinition(
          heightFactor: normalizedHeight,
          color: Colors.green.shade700.withOpacity(0.8), // 어두운 초록 계열
        );
      });
    });
  }
