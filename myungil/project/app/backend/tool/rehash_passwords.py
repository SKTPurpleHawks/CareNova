from sqlalchemy.orm import Session
from database import get_db  # 🔹 데이터베이스 모델과 DB 세션 가져오기
from passlib.context import CryptContext
import models

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def rehash_passwords():
    db: Session = next(get_db())  # 세션 열기
    users = db.query(models.CaregiverUserInfo).all()  # 모든 유저 가져오기

    for user in users:
        if not user.password.startswith("$2b$"):  # bcrypt 해시가 아닌 경우
            hashed_password = pwd_context.hash(user.password)
            user.password = hashed_password
            print(f"🔄 Updated password for {user.email}")

    db.commit()
    db.close()

if __name__ == "__main__":
    rehash_passwords()  # ✅ 스크립트 실행
