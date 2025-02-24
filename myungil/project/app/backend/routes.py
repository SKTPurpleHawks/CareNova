from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import schemas, crud, models
from models import ProtectorUserInfo, CaregiverUserInfo
from security import verify_password, create_access_token, get_current_user, get_password_hash
from datetime import datetime
from fastapi.responses import JSONResponse
import logging
from typing import List
import uuid
from typing import Union


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
    user_type = "foreign" if isinstance(db_user, models.CaregiverUserInfo) else "protector"
    logger.info(f"✅ [LOGIN SUCCESS] User: {user.email}, Type: {user_type}")

    # JWT 액세스 토큰 생성
    access_token = create_access_token(
        data={"sub": user.email, "user_type": user_type, "user_id": db_user.id}
    )

    return {"access_token": access_token, "token_type": "bearer", "user_type": user_type}

@router.get("/user-info")
def get_user_info(token_data=Depends(get_current_user), db=Depends(get_db)):
    user = db.query(models.CaregiverUserInfo).filter(models.CaregiverUserInfo.email == token_data.email).first()
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
        "showyn": user.showyn
    }

@router.put("/user-info")
def update_user_info(user_update: schemas.UserUpdate, db: Session = Depends(get_db)):
    user = db.query(models.CaregiverUserInfo).filter(models.CaregiverUserInfo.email == user_update.email).first()

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


@router.put("/update-job-info")
def update_job_info(job_info_update: schemas.JobInfoUpdate, token_data=Depends(get_current_user), db: Session = Depends(get_db)):
    updated_user = crud.update_job_info(db, token_data.id, job_info_update)
    if not updated_user:
        raise HTTPException(status_code=404, detail="업데이트 실패")
    return {"message": "구인 정보 상태가 업데이트되었습니다.", "showyn": updated_user.showyn}



@router.post("/add_patient")
def add_patient(
    patient: schemas.PatientBase, 
    db: Session = Depends(get_db), 
    current_user: models.ProtectorUserInfo = Depends(get_current_user)  
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
        startdate=patient.startdate,
        enddate=patient.enddate,
        region=patient.region,
        spot=patient.spot,
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
    caregivers = db.query(models.CaregiverUserInfo).filter(models.CaregiverUserInfo.showyn == 1).all()
    if not caregivers:
        raise HTTPException(status_code=404, detail="등록된 간병인이 없습니다.")

    return [
        {
            "id": c.id,
            "name": c.name,
            "age": c.age,
            "sex": c.sex,
            "region": c.region,
        }
        for c in caregivers
    ]


@router.post("/care-request")
def send_care_request(
    request_data: schemas.CareRequestCreate, 
    db: Session = Depends(get_db), 
    current_user: models.ProtectorUserInfo = Depends(get_current_user)
):
    return crud.create_care_request(db, request_data, current_user.id)

@router.put("/care-request/{request_id}")
def update_care_request_status(
    request_id: int,
    status_update: schemas.CareRequestUpdate,
    db: Session = Depends(get_db),
    current_user: models.CaregiverUserInfo = Depends(get_current_user)
):
    logging.info(f"📥 Care request update received: {status_update.dict()}")  # ✅ 로그 추가

    care_request = db.query(models.CareRequest).filter(models.CareRequest.id == request_id).first()

    if not care_request:
        raise HTTPException(status_code=404, detail="Care request not found")

    if care_request.caregiver_id != current_user.id:
        raise HTTPException(status_code=403, detail="Unauthorized request update")

    care_request.status = status_update.status  
    db.commit()
    db.refresh(care_request)

    logging.info(f"✅ Care request {request_id} updated to {care_request.status}")  # ✅ 로그 추가

    return {"message": f"Care request {status_update.status}"}






@router.get("/care-request")
def get_care_requests(
    db: Session = Depends(get_db),
    current_user: models.CaregiverUserInfo = Depends(get_current_user)
):
    requests = db.query(models.CareRequest).filter(
        models.CareRequest.caregiver_id == current_user.id,  
        models.CareRequest.status == "pending"  
    ).all()

    return [
        {
            "id": r.id,
            "protector_name": r.protector.name if r.protector else "알 수 없는 보호자",
            "status": r.status,
            "patient_name": r.patient.name if r.patient else "알 수 없는 환자",
        }
        for r in requests
    ]





@router.get("/caregiver/patients")
def get_caregiver_patients(
    db: Session = Depends(get_db),
    current_user: Union[ProtectorUserInfo, CaregiverUserInfo] = Depends(get_current_user)  # Union 적용
):
    patients = []

    if isinstance(current_user, CaregiverUserInfo):
        # 간병인 로직
        requests = db.query(models.CareRequest).filter(
            models.CareRequest.caregiver_id == current_user.id,
            models.CareRequest.status == "accepted"
        ).all()

        for request in requests:
            patient = db.query(models.PatientUserInfo).filter(models.PatientUserInfo.id == request.patient_id).first()
            
            caregiver_id = current_user.id
            caregiver = db.query(models.CaregiverUserInfo).filter(models.CaregiverUserInfo.id == caregiver_id).first()
            caregiver_name = caregiver.name if caregiver else "알 수 없음"

            if patient:

                patients.append({
                    "id": patient.id,
                    "name": patient.name,
                    "birthday": patient.birthday,
                    "age": patient.age,
                    "sex": patient.sex,
                    "height": patient.height,
                    "weight": patient.weight,
                    "symptoms": patient.symptoms,
                    "caregiver_id": caregiver_id,
                    "caregiver_name": caregiver_name,
                    "caregiver_phonenumber": caregiver.phonenumber,
                    "caregiver_startdate": caregiver.startdate,
                    "caregiver_enddate": caregiver.enddate,
                    "protector_id": patient.protector_id
                })

    elif isinstance(current_user, ProtectorUserInfo):
        # 보호자 로직
        protector_patients = db.query(models.PatientUserInfo).filter(
            models.PatientUserInfo.protector_id == current_user.id
        ).all()

        for patient in protector_patients:
            care_request = db.query(models.CareRequest).filter(
                models.CareRequest.patient_id == patient.id,
                models.CareRequest.status == "accepted"
            ).first()

            caregiver_id = care_request.caregiver_id if care_request else None
            caregiver = db.query(models.CaregiverUserInfo).filter(models.CaregiverUserInfo.id == caregiver_id).first()
            caregiver_name = caregiver.name if caregiver else "알 수 없음"

            patients.append({
                "id": patient.id,
                "name": patient.name,
                "birthday": patient.birthday,
                "age": patient.age,
                "sex": patient.sex,
                "height": patient.height,
                "weight": patient.weight,
                "symptoms": patient.symptoms,
                "caregiver_id": caregiver_id,
                "caregiver_name": caregiver_name
            })

    return patients



@router.post("/reviews")
def submit_review(
    review_data: schemas.ReviewCreate,
    db: Session = Depends(get_db)
):
    """
    보호자가 간병인을 평가하고 리뷰를 저장한 후, 연결을 해제함
    """
    
    new_review_id = models.Review.Review_custom_id(db)
    # 리뷰 저장
    review = models.Review(
        id=new_review_id,
        caregiver_id=review_data.caregiver_id,
        protector_id=review_data.protector_id,
        sincerity=review_data.sincerity,
        hygiene=review_data.hygiene,
        communication=review_data.communication,
        total_score=review_data.total_score,
        review_content=review_data.review_content,
    )
    db.add(review)
    db.commit()

    # CareRequest에서 보호자-환자-간병인 연결 해제
    db.query(models.CareRequest).filter(
        models.CareRequest.caregiver_id == review_data.caregiver_id,
        models.CareRequest.protector_id == review_data.protector_id
    ).delete()
    db.commit()

    return {"message": "리뷰가 저장되었으며, 간병인 연결이 해제되었습니다."}


@router.post("/dailyrecord", response_model=schemas.DailyRecordResponse)
def create_daily_record(
    record: schemas.DailyRecordCreate,
    db: Session = Depends(get_db)
):
    """새로운 간병일지를 작성하는 API"""
    new_record = models.DailyRecordInfo(**record.dict())
    db.add(new_record)
    db.commit()
    db.refresh(new_record)
    return new_record


@router.get("/dailyrecord/{patient_id}", response_model=List[schemas.DailyRecordResponse])
def get_patient_records(patient_id: str, db: Session = Depends(get_db)):
    """특정 환자의 간병일지를 작성순으로 조회하는 API"""
    records = db.query(models.DailyRecordInfo).filter(
        models.DailyRecordInfo.patient_id == patient_id
    ).order_by(models.DailyRecordInfo.created_at.asc()).all()

    if not records:
        raise HTTPException(status_code=404, detail="해당 환자의 간병일지가 없습니다.")

    return records

@router.delete("/dailyrecord/{record_id}")
def delete_daily_record(record_id: int, db: Session = Depends(get_db)):
    """간병일지 삭제 API"""
    record = db.query(models.DailyRecordInfo).filter(models.DailyRecordInfo.id == record_id).first()

    if not record:
        raise HTTPException(status_code=404, detail="간병일지를 찾을 수 없습니다.")

    db.delete(record)
    db.commit()
    return {"message": "간병일지가 성공적으로 삭제되었습니다."}


@router.put("/dailyrecord/{record_id}", response_model=schemas.DailyRecordResponse)
def update_daily_record(
    record_id: int,
    updated_record: schemas.DailyRecordCreate,
    db: Session = Depends(get_db)
):
    """간병일지 수정 API"""
    record = db.query(models.DailyRecordInfo).filter(models.DailyRecordInfo.id == record_id).first()

    if not record:
        raise HTTPException(status_code=404, detail="간병일지를 찾을 수 없습니다.")

    for key, value in updated_record.dict().items():
        setattr(record, key, value)

    db.commit()
    db.refresh(record)
    return record



@router.put("/patient-info/{patient_id}")
def update_patient_info(patient_id: str, patient_update: schemas.PatientUpdate, db: Session = Depends(get_db)):
    patient = db.query(models.PatientUserInfo).filter(models.PatientUserInfo.id == patient_id).first()

    if not patient:
        raise HTTPException(status_code=404, detail="환자를 찾을 수 없습니다.")

    # 요청된 데이터만 업데이트 (None 값은 제외)
    update_data = patient_update.dict(exclude_unset=True)  # 🔹 None인 필드는 제외
    for key, value in update_data.items():
        setattr(patient, key, value)

    db.commit()
    db.refresh(patient)
    
    return {"message": "환자 정보가 성공적으로 업데이트되었습니다."}


@router.delete("/patient-info/{patient_id}")
def delete_patient_info(patient_id: str, db: Session = Depends(get_db)):
    patient_daily_records = db.query(models.DailyRecordInfo).filter(models.DailyRecordInfo.id == patient_id).all()
    patient_requests = db.query(models.CareRequest).filter(models.CareRequest.id == patient_id).all()
    patient = db.query(models.PatientUserInfo).filter(models.PatientUserInfo.id == patient_id).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="환자를 찾을 수 없습니다.")

    db.delete(patient_daily_records)
    db.delete(patient_requests)
    db.delete(patient)
    db.commit()
    return {"message": "환자 정보가 삭제되었습니다."}