import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:convert'; // JSON 처리
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/*
---------------------------------------------------------------------------------------------
file_name : recorder_screen.dart

Developer
 ● Frontend : 나지영, 서민석
 ● AI : 나지영
 ● UI : 나지영

description : 간병인과 환자 간 음성 대화를 STT -> GPT -> TTS 과정을 거쳐 음성 보정 및 번역 기능 구현
              Flutter 내 API 호출로 기능 구현
---------------------------------------------------------------------------------------------
*/

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class BarDefinition {
  final double heightFactor; // 부모 높이의 몇 배로 표시할지 결정
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
            width: (widget.width / widget.bars.length)
                .clamp(6.0, 15.0), // 🔺 바 너비를 제한
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
  int _remainingTime = 30; // 최대 30초 녹음 제한
  List<String> _messages = []; // 채팅 메시지를 저장
  List<BarDefinition> _bars = [];

  double _currentDecibel = -50.0;
  double _maxDecibel = -30.0; // 의미 있는 최소 감지 음량

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
    await _player.openPlayer(); // 플레이어 초기화
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startRecording() async {
    if (_isRecording) return; // 중복 실행 방지

    _generateInitialWaveform();

    Directory? extDir = await getExternalStorageDirectory();
    if (extDir == null) {
      debugPrint("외부 저장소 접근 불가");
      return;
    }

    String path = '${extDir.path}/recording.wav';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV, // WAV 포맷 사용
      sampleRate: 16000, // 16kHz 설정
      numChannels: 1, // 모노(1채널)
    );

    _recorder.setSubscriptionDuration(const Duration(milliseconds: 250));
    _recorder.onProgress?.listen((RecordingDisposition d) {
      setState(() {
        _currentDecibel = d.decibels ?? -50.0; // 최소값 -50.0 dB 유지

        // 최대 감지된 dB 업데이트 (너무 낮으면 제외)
        if (_currentDecibel > _maxDecibel) {
          _maxDecibel = _currentDecibel;
        }

        // 웨이브 업데이트
        _updateWaveform(_currentDecibel);
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

    // 30초 타이머 시작
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
    _timer?.cancel(); // 타이머 정지

    setState(() {
      _isRecording = false;
      _generateInitialWaveform();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('녹음 완료')),
    );

    // STT 변환 실행 (녹음 종료 후 자동 실행)
    if (_filePath != null) {
      String rawText = await _convertSpeechToTextWithWhisper(_filePath!);
      if (_isInvalidShortText(rawText)) {
        debugPrint("뉴스 관련 음성이 감지되어 실행 중단: $rawText");
        return;
      }
      String refinedText = await _refineTextWithGPT(rawText); // GPT로 보정된 텍스트

      setState(() {
        _messages.insert(0, refinedText); // 채팅 형식으로 UI에 표시
      });
      _playTTS(refinedText); // TTS 실행
      debugPrint("최종 변환 텍스트: $refinedText");
    }
  }

  Future<String> _convertSpeechToTextWithWhisper(String filePath) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final whStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty) {
      debugPrint("OpenAI API Key가 설정되지 않았습니다.");
      return "입력된 내용이 없습니다.";
    }

    try {
      File audioFile = File(filePath);

      // 녹음된 파일이 존재하는지 확인
      if (!await audioFile.exists()) {
        debugPrint("녹음된 파일이 존재하지 않습니다: $filePath");
        return "입력된 내용이 없습니다.";
      }

      int fileSize = await audioFile.length();
      debugPrint("녹음된 파일 크기: $fileSize bytes");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $apiKey';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'ko';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      debugPrint("Whisper API 요청 전송 중...");
      var response = await request.send();

      // 응답이 정상적으로 왔는지 확인
      if (response.statusCode != 200) {
        debugPrint("Whisper API 요청 실패: ${response.reasonPhrase}");
        return "입력된 내용이 없습니다.";
      }

      String responseBody = await response.stream.bytesToString();
      whStopwatch.stop();
      debugPrint(
          "Whisper API 응답(${whStopwatch.elapsedMilliseconds}ms): $responseBody");

      // JSON 파싱 오류 방지 및 UTF-8 처리
      Map<String, dynamic> decodedResponse = jsonDecode(responseBody);

      // 변환된 텍스트 추출
      String transcribedText = decodedResponse['text']?.trim() ?? "";

      // 변환된 텍스트가 비어있는 경우 처리
      if (transcribedText.isEmpty) {
        debugPrint("변환된 텍스트 없음");
        return "입력된 내용이 없습니다.";
      }

      if (_isInvalidShortText(transcribedText)) {
      debugPrint("뉴스 오류 감지: $transcribedText");

      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("잘못된 음성이 감지되었습니다"),
            backgroundColor: Colors.red,
          ),
        );
      });

      return transcribedText; // 감지된 뉴스 문장을 그대로 반환 (GPT/TTS 실행 안 함)
    }

    debugPrint("Whisper 변환 텍스트: $transcribedText");
    return transcribedText;
  } catch (e) {
    debugPrint("Whisper API 오류: $e");
    return "입력된 내용이 없습니다.";
  }
}

/// 특정 뉴스 문장이 감지되었는지 확인하는 함수
bool _isInvalidShortText(String text) {
  List<String> invalidShortTexts = [
    "MBC 뉴스 이덕영입니다.",
    "기상캐스터 배혜지",
    "MBC 뉴스 김재경입니다",
    "시청해 주셔서 감사합니다."
  ];
  return invalidShortTexts.contains(text);
  }

  Future<String> _refineTextWithGPT(String text) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final gptStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty) {
      debugPrint("OpenAI API Key가 설정되지 않았습니다.");
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
          "model": "gpt-4o-mini",
          // "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content":
                  "The following text is the result of transcribing speech from a person with inaccurate pronunciation and may contain typos, misinterpreted words, names, and unnatural expressions. Do not add any extra explanation; output only the sentence.  It is a correction, so do not make up words that weren't there. Also, remove as many punctuation marks as possible." +
                  "If the word '중국어' is included at the end, translate the sentence into Chinese and output only that sentence at that time. "
            },
            {"role": "user", "content": text}
          ],
          "temperature": 0.2
        })),
      );

      // UTF-8 디코딩 적용 (bodyBytes 사용)
      String responseBody = utf8.decode(response.bodyBytes);
      gptStopwatch.stop();
      debugPrint("📝 GPT API 응답(${gptStopwatch.elapsedMilliseconds}ms)");

      // JSON 데이터 파싱 (타입 오류 방지)
      Map<String, dynamic> decodedResponse = jsonDecode(responseBody);

      // 변환된 텍스트 가져오기
      if (decodedResponse.containsKey('choices') &&
          decodedResponse['choices'].isNotEmpty) {
        String refinedText =
            decodedResponse['choices'][0]['message']['content'].trim();
        return refinedText;
      } else {
        return "GPT 응답이 올바르지 않습니다.";
      }
    } catch (e) {
      debugPrint("GPT 요청 오류: $e");
      return text;
    }
  }

  Future<void> _playTTS(String text) async {
    String apiKey = dotenv.env['TYPECAST_API_KEY'] ?? '';
    String apiUrl = "https://typecast.ai/api/speak"; // Typecast API 엔드포인트 적용
    String actorId = "60ad0841061ee28740ec2e1c"; // 최신 Typecast Voice ID 확인 필요
    final ttsStopwatch = Stopwatch()..start();

    if (apiKey.isEmpty) {
      debugPrint("Typecast API Key가 설정되지 않았습니다.");
      return;
    }

    if (text.trim().isEmpty) {
      debugPrint("TTS 요청이 중단됨: 변환된 텍스트가 없음.");
      return;
    }

    try {
      Map<String, dynamic> requestBody = {
        "actor_id": actorId,
        "text": text.trim(),
        "lang": "auto",
        "tempo": 1, // 추가
        "volume": 100, // 추가
        "pitch": 0, // 추가
        "xapi_hd": true,
        "max_seconds": 30, // 추가
        "model_version": "latest",
        "xapi_audio_format": "wav" // 추가
      };

      debugPrint("TTS 요청 데이터: ${jsonEncode(requestBody)}"); // JSON 데이터 출력

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("TTS API 응답: $responseJson");

        if (responseJson.containsKey("result") &&
            responseJson["result"].containsKey("speak_v2_url")) {
          String speakUrl = responseJson["result"]["speak_v2_url"];
          ttsStopwatch.stop();
          debugPrint(
              "TTS 생성 성공(${ttsStopwatch.elapsedMilliseconds}ms): $speakUrl");

          // **오디오 다운로드 URL 가져오기**
          String? audioUrl = await _waitForAudio(speakUrl);
          if (audioUrl != null) {
            _downloadAndPlayTTS(audioUrl);
          } else {
            debugPrint("TTS 음성 파일 URL을 가져오지 못했습니다.");
          }
        } else {
          debugPrint("TTS 응답에서 speak_v2_url이 누락됨.");
        }
      } else {
        debugPrint(
            "TTS 요청 실패: ${response.statusCode} - ${response.reasonPhrase}");
        debugPrint("응답 본문: ${response.body}"); // 응답 본문 출력
      }
    } catch (e) {
      debugPrint("Typecast API 오류: $e");
    }
  }

  Future<String?> _waitForAudio(String speakV2Url) async {
    String apiKey = dotenv.env['TYPECAST_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      debugPrint("Typecast API Key가 설정되지 않았습니다.");
      return null;
    }

    try {
      for (int i = 0; i < 10; i++) {
        // 최대 10초 동안 대기
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
            debugPrint("음성 생성 중... (1초 후 재시도)");
            await Future.delayed(Duration(seconds: 1));
          } else {
            debugPrint("Unexpected status: $status");
            return null;
          }
        } else {
          debugPrint(" 음성 생성 상태 확인 실패: ${response.reasonPhrase}");
          return null;
        }
      }
    } catch (e) {
      debugPrint("음성 생성 대기 중 오류 발생: $e");
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
        debugPrint("음성 파일 다운로드 완료: $filePath");

        await _player.startPlayer(fromURI: filePath); // 즉시 재생
      } else {
        debugPrint("TTS 파일 다운로드 실패 (응답 코드: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("TTS 파일 다운로드 중 오류 발생: $e");
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
    double base = ((decibel + 60) / 60).clamp(0.1, 1.0);
    final time = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _bars = List.generate(18, (index) {
        double phase = index / 18 * 2 * pi;
        double variation = 0.2 * sin(2 * pi * (time % 1000) / 1000 + phase);
        double newHeight = (base + variation).clamp(0.1, 1.0);
        return BarDefinition(
          heightFactor: newHeight,
          color: Colors.green.shade700.withOpacity(0.8),
        );
      });
    });
  }

  void _generateInitialWaveform() {
    setState(() {
      _bars = List.generate(18, (index) {
        return BarDefinition(
          heightFactor: 0.2, // 기본 초기 높이 설정 (줄어든 상태)
          color: Colors.green.shade600.withOpacity(0.8), // 연한 초록 계열
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 기기 화면 너비 가져오기
    double waveWidth = screenWidth * 0.9; // 좌우 패딩을 고려한 웨이브바 크기

    return Scaffold(
      appBar: AppBar(title: const Text('대화하기')),
      body: Column(
        children: [
          // 채팅 메시지 영역
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43C098),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _messages[index],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 웨이브 바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: waveWidth, // 부모 너비 설정
              height: 100,
              child: Row(
                mainAxisSize: MainAxisSize.max, // 부모 너비에 맞춤
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: LiveAudioWave(
                      bars: _bars,
                      width: waveWidth,
                      height: 100,
                      spacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 녹음 버튼
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isRecording ? Colors.grey : const Color(0xFF43C098),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(28),
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
