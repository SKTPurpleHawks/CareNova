from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import schemas, crud, models
from security import verify_password, create_access_token, get_current_user, get_password_hash
from datetime import datetime
from fastapi.responses import JSONResponse
import logging
from typing import List
import uuid


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
        "showyn": user.showyn
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
    caregivers = db.query(models.ForeignUserInfo).filter(models.ForeignUserInfo.showyn == 1).all()
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


@router.post("/care-request")
def send_care_request(
    request_data: schemas.CareRequestCreate, 
    db: Session = Depends(get_db), 
    current_user: models.ProtectorUserInfo = Depends(get_current_user)
):
    
    caregiver = db.query(models.ForeignUserInfo).filter(models.ForeignUserInfo.id == request_data.caregiver_id).first()
    
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")

    new_request = models.CareRequest(
        protector_id=current_user.id,
        caregiver_id=request_data.caregiver_id,
        status="pending"
    )

    db.add(new_request)
    db.commit()
    db.refresh(new_request)

    return {"message": "Care request sent successfully"}




@router.put("/care-request/{request_id}")
def update_care_request_status(
    request_id: int,
    status_update: schemas.CareRequestUpdate,
    db: Session = Depends(get_db),
    current_user: models.ForeignUserInfo = Depends(get_current_user)
):
    # 간병 요청 조회
    care_request = db.query(models.CareRequest).filter(models.CareRequest.id == request_id).first()

    # 존재하지 않는 간병 요청 예외 처리
    if not care_request:
        raise HTTPException(status_code=404, detail="Care request not found")

    # 요청된 caregiver_id가 None일 경우 예외 처리
    if care_request.caregiver_id is None:
        raise HTTPException(status_code=400, detail="This care request has no assigned caregiver.")

    # 현재 로그인한 사용자가 해당 요청을 처리할 권한이 있는지 확인
    if care_request.caregiver_id != current_user.id:
        raise HTTPException(status_code=403, detail="You are not authorized to update this request")

    # 요청 상태 변경
    care_request.status = status_update.status  
    db.commit()
    db.refresh(care_request)

    # 'accepted' 상태일 경우만 환자 추가 로직 실행
    if status_update.status == "accepted":
        # 보호자가 등록한 환자 조회
        patient = db.query(models.PatientUserInfo).filter(
            models.PatientUserInfo.protector_id == care_request.protector_id
        ).first()

        # 환자가 없을 경우 404 오류 반환
        if not patient:
            raise HTTPException(status_code=404, detail="No patient found for this protector.")

        # caregiver_id와 patient_id 중복 검사
        existing_assignment = db.query(models.CaregiverPatient).filter(
            models.CaregiverPatient.patient_id == patient.id
        ).first()

        if existing_assignment:
            db.delete(care_request)
            db.commit()
            raise {"message" : "Patient already assigned to caregiver.Request deleted."}

        # 환자-간병인 연결 추가
        new_assignment = models.CaregiverPatient(
            caregiver_id=care_request.caregiver_id,
            patient_id=patient.id
        )

        db.add(new_assignment)
        db.commit()
        db.refresh(new_assignment)

    return {"message": f"Care request {status_update.status}"}






@router.get("/care-requests")
def get_care_requests(
    db: Session = Depends(get_db),
    current_user: models.ForeignUserInfo = Depends(get_current_user)
):
    
    requests = db.query(models.CareRequest).filter(
        models.CareRequest.caregiver_id == current_user.id,  
        models.CareRequest.status == "pending"  
    ).all()

    return [
        {
            "id": r.id,
            "protector_name": r.protector.name if r.protector else "알 수 없는 보호자",
            "status": r.status
        }
        for r in requests
    ]




@router.get("/caregiver/patients")
def get_caregiver_patients(
    db: Session = Depends(get_db),
    current_user: models.ForeignUserInfo = Depends(get_current_user)
):
    assignments = db.query(models.CaregiverPatient).filter(models.CaregiverPatient.caregiver_id == current_user.id).all()

    patients = []
    for assignment in assignments:
        patient = db.query(models.PatientUserInfo).filter(models.PatientUserInfo.id == assignment.patient_id).first()
        if patient:
            patients.append({
                "id": patient.id,
                "name": patient.name,
                "birthday": patient.birthday,
                "age": patient.age
            })

    return patients
