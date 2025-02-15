from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import schemas, crud
from security import verify_password, create_access_token, get_current_user
import models
from datetime import datetime
from fastapi.responses import JSONResponse
import logging


router = APIRouter()


# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@router.post("/signup/foreign")
def signup_foreign(user: schemas.ForeignUserCreate, db: Session = Depends(get_db)):
    db_user = crud.create_foreign_user(db, user)
    return {"message": "Foreign user created successfully"}

@router.post("/signup/protector")
def signup_protector(user: schemas.ProtectorUserCreate, db: Session = Depends(get_db)):
    db_user = crud.create_protector_user(db, user)
    return {"message": "Protector user created successfully"}



@router.post("/login")
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    logger.info(f"📌 [LOGIN ATTEMPT] Email: {user.email}")

    # 이메일로 사용자 조회
    db_user = crud.get_user_by_email(db, user.email)
    
    if not db_user:
        logger.warning(f"❌ [LOGIN FAILED] User not found: {user.email}")
        raise HTTPException(status_code=400, detail="Incorrect email or password")

    # 비밀번호 검증
    if not verify_password(user.password, db_user.password):
        logger.warning(f"❌ [LOGIN FAILED] Incorrect password for user: {user.email}")
        raise HTTPException(status_code=400, detail="Incorrect email or password")

    # 사용자 유형 확인
    user_type = "foreign" if isinstance(db_user, models.ForeignUserInfo) else "protector"
    logger.info(f"✅ [LOGIN SUCCESS] User: {user.email}, Type: {user_type}")

    # JWT 액세스 토큰 생성
    access_token = create_access_token(
        data={"sub": user.email, "user_type": user_type, "user_id": db_user.id}
    )

    return {"access_token": access_token, "token_type": "bearer", "user_type": user_type}


@router.get("/user-info")
def get_user_info(token_data=Depends(get_current_user), db=Depends(get_db)):
    user = db.query(models.ForeignUserInfo).filter(models.ForeignUserInfo.email == token_data.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {
        
        "email": user.email,
        "name": user.name.encode('utf-8').decode('utf-8'),
        "phonenumber": user.phonenumber,
        "birthday": user.birthday,
        "age": user.age,
        "sex": user.sex.encode('utf-8').decode('utf-8'),
        "startdate": user.startdate,
        "enddate": user.enddate,
        "region": user.region,
        "spot": user.spot,
        "height": user.height,
        "weight": user.weight,
        "symptoms": user.symptoms,
        "canwalkpatient": user.canwalkpatient,
        "prefersex": user.prefersex,
        "smoking": user.smoking,
    }

@router.put("/user-info")
def update_user_info(user_update: schemas.UserUpdate, db: Session = Depends(get_db)):
    user = db.query(models.ForeignUserInfo).filter(models.ForeignUserInfo.email == user_update.email).first()

    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    if user_update.new_password:
        user.password = hash_password(user_update.new_password)  # 비밀번호 암호화

    user.email = user_update.email
    user.name = user_update.name
    user.phonenumber = user_update.phonenumber
    user.birthday = user_update.birthday
    user.age = user_update.age
    user.sex = user_update.sex
    user.startdate = user_update.startdate
    user.enddate = user_update.enddate
    user.region = user_update.region
    user.spot = user_update.spot
    user.height = user_update.height
    user.weight = user_update.weight
    user.symptoms = user_update.symptoms
    user.canwalkpatient = user_update.canwalkpatient
    user.prefersex = user_update.prefersex
    user.smoking = user_update.smoking

    db.commit()
    db.refresh(user)
    
    return {"message": "프로필이 성공적으로 업데이트되었습니다.", "user": user}

