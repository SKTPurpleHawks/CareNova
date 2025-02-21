import requests
import json
import time
import os

# Typecast API 설정
API_KEY = os.getenv("TYPECAST_API_KEY")
VOICE_ID = os.getenv("TYPECAST_VOICE_ID")

ACTOR_ID = "622964d6255364be41659078"  # 사용할 음성 ID

# TXT 파일 읽기
def read_text_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        text = f.read()
    return text.split(".")  # 마침표 기준으로 분할

# Step 1: 음성 합성 요청 (TTS 생성 요청)
def request_tts(sentence):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    data = json.dumps({
        "text": sentence.strip(),
        "lang": "auto",
        "actor_id": ACTOR_ID,
        "xapi_hd": True,
        "model_version": "latest"
    })
    
    response = requests.post(API_URL, headers=headers, data=data)
    if response.status_code == 200:
        response_json = response.json()
        if "result" in response_json and "speak_v2_url" in response_json["result"]:
            return response_json["result"]["speak_v2_url"]  # Step 2에서 사용될 URL
    print(f"Error: {response.status_code}, {response.text}")
    return None

# Step 2: 음성 상태 체크 (음성이 준비될 때까지 반복 요청)
def wait_for_audio(speak_v2_url):
    headers = {
        "Authorization": f"Bearer {API_KEY}"
    }

    while True:
        response = requests.get(speak_v2_url, headers=headers)
        if response.status_code == 200:
            response_json = response.json()
            status = response_json["result"].get("status", "")

            if status == "done":
                return response_json["result"]["audio_download_url"]  # Step 3에서 다운로드할 URL
            
            elif status == "progress":
                print("⏳ 음성 생성 중... (1초 후 재시도)")
                time.sleep(1)  # 1초 대기 후 다시 요청
                
            else:
                print(f"❌ Unexpected status: {status}")
                return None
        else:
            print(f"❌ Failed to check status: {response.status_code}")
            return None

# Step 3: 음성 파일 다운로드
def download_audio(audio_url, file_name):
    response = requests.get(audio_url)
    if response.status_code == 200:
        with open(file_name, "wb") as f:
            f.write(response.content)
        print(f"Downloaded: {file_name}")
    else:
        print(f"Failed to download {file_name} - Error {response.status_code}")

# 실행 함수 (TXT 파일 → 음성 변환)
def process_txt_to_tts(input_txt, output_folder):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    sentences = read_text_file(input_txt)
    for i, sentence in enumerate(sentences):
        if sentence.strip():
            print(f"🔄 Processing: {sentence.strip()}")
            speak_v2_url = request_tts(sentence)  # Step 1: 음성 생성 요청
            if speak_v2_url:
                audio_url = wait_for_audio(speak_v2_url)  # Step 2: 상태 확인 & 다운로드 URL 획득
                if audio_url:
                    download_audio(audio_url, f"{output_folder}/output_{i}.wav")  # Step 3: 다운로드 실행
            time.sleep(2)  # API 요청 제한 방지를 위해 딜레이 추가

# 사용 예제
f_input = "5sample.txt"
v_output = "5sample_audio"

if __name__ == "__main__":
    process_txt_to_tts(f_input, v_output)
