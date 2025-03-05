import csv
import random

# 자주 사용되는 한국 성씨와 이름 음절 목록
surnames = ["김", "이", "박", "정", "최", "강", "조", "윤", "장", "임",
            "한", "오", "서", "신", "권", "황", "안", "송", "류", "홍"]
syllables = ["민", "서", "훈", "영", "유", "재", "준", "현", "지", "수"]

def random_name():
    # 성은 하나, 이름은 두 음절 조합
    return random.choice(surnames) + random.choice(syllables) + random.choice(syllables)

# 10,000개의 이름 생성
names = [random_name() for _ in range(8999)]

# CSV 파일 생성 (UTF-8 인코딩)
with open('names.csv', 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
    # 헤더 작성
    writer.writerow(['name'])
    # 10,000개의 이름 기록
    for name in names:
        writer.writerow([name])

print("CSV 파일(names.csv)이 생성되었습니다.")
