from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import schemas, crud, models
from security import verify_password, create_access_token, get_current_user, get_password_hash
from datetime import datetime
from fastapi.responses import JSONResponse
import logging
from typing import List

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
        "name": user.name,
        "phonenumber": user.phonenumber,
        "birthday": user.birthday,
        "age": user.age,
        "sex": user.sex,
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
        user.password = get_password_hash(user_update.new_password)

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

@router.post("/add_patient")
def add_patient(
    patient: schemas.PatientBase, 
    db: Session = Depends(get_db), 
    current_user: models.ProtectorUserInfo = Depends(get_current_user)  # ✅ 유저 인증 수정
):
    protector = db.query(models.ProtectorUserInfo).filter(models.ProtectorUserInfo.id == current_user.id).first()
    if not protector:
        raise HTTPException(status_code=404, detail="보호자를 찾을 수 없습니다.")

    new_patient_id = models.PatientUserInfo.patient_generate_custom_id(db)

    new_patient = models.PatientUserInfo(
        id=new_patient_id,
        protector_id=protector.id,  
        name=patient.name,
        birthday=patient.birthday,
        age=patient.age,
        sex=patient.sex,
        height=patient.height,
        weight=patient.weight,
        symptoms=patient.symptoms,
        canwalk=patient.canwalk,
        prefersex=patient.prefersex,
        smoking=patient.smoking,
    )

    db.add(new_patient)
    db.commit()
    db.refresh(new_patient)

    return {"message": "환자가 성공적으로 추가되었습니다.", "patient": new_patient}




@router.get("/patients", response_model=List[schemas.PatientResponse])
def get_patients(
    db: Session = Depends(get_db), 
    current_user: models.ProtectorUserInfo = Depends(get_current_user)
):

    patients = db.query(models.PatientUserInfo).filter(
        models.PatientUserInfo.protector_id == current_user.id
    ).all()

    if not patients:
        raise HTTPException(status_code=404, detail="등록된 환자가 없습니다.")

    return patients



@router.get("/caregivers")
def get_caregivers(db: Session = Depends(get_db)):
    caregivers = db.query(models.ForeignUserInfo).all()
    if not caregivers:
        raise HTTPException(status_code=404, detail="등록된 간병인이 없습니다.")

    return [
        {
            "id": c.id,
            "name": c.name,
            "age": c.age,
            "sex": c.sex,
            # "experience": c.experience,
            # "rating": c.rating,
            # "salary": c.salary,
            "region": c.region,
        }
        for c in caregivers
    ]