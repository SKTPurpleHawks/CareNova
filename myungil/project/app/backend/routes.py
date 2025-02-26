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
import pandas as pd
from pytorch_tabnet.tab_model import TabNetRegressor
import numpy as np
import time
from schemas import ProtectorInfoSchema
from fastapi.encoders import jsonable_encoder

router = APIRouter()


MODEL_PATH = "./model/tabnet_model.zip"
ai_model = TabNetRegressor()
ai_model.load_model(MODEL_PATH)



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

@router.get("/protector-info", response_model=ProtectorInfoSchema)
def get_protector_info(
    db: Session = Depends(get_db),
    current_user: ProtectorUserInfo = Depends(get_current_user)
):
    """
    현재 로그인된 보호자의 정보를 반환하는 API
    """
    protector = db.query(ProtectorUserInfo).filter(ProtectorUserInfo.id == current_user.id).first()
    
    print(protector)

    if not protector:
        raise HTTPException(status_code=404, detail="보호자 정보를 찾을 수 없습니다.")

    return protector


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
        preferstar=patient.preferstar,
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
    logging.info(f"📥 Care request update received: {status_update.dict()}")  # 로그 추가

    care_request = db.query(models.CareRequest).filter(models.CareRequest.id == request_id).first()

    if not care_request:
        raise HTTPException(status_code=404, detail="Care request not found")

    if care_request.caregiver_id != current_user.id:
        raise HTTPException(status_code=403, detail="Unauthorized request update")

    care_request.status = status_update.status  
    db.commit()
    db.refresh(care_request)

    logging.info(f"Care request {request_id} updated to {care_request.status}")  # 로그 추가

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
                    "region": patient.region,
                    "spot": patient.spot,
                    "symptoms": patient.symptoms,
                    "canwalk": patient.canwalk,
                    "caregiver_id": caregiver_id,
                    "caregiver_name": caregiver_name,
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
                "region": patient.region,
                "height": patient.height,
                "weight": patient.weight,
                "symptoms": patient.symptoms,
                "canwalk": patient.canwalk,
                "caregiver_id": caregiver_id,
                "caregiver_name": caregiver_name,
                "caregiver_phonenumber": caregiver.phonenumber,
                "caregiver_startdate": caregiver.startdate,
                "caregiver_enddate": caregiver.enddate,
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
    """특정 환자의 간병일지를 최신순으로 조회하는 API"""
    records = db.query(models.DailyRecordInfo).filter(
        models.DailyRecordInfo.patient_id == patient_id
    ).order_by(models.DailyRecordInfo.created_at.desc()).all()

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
    update_data = patient_update.dict(exclude_unset=True)  # None인 필드는 제외
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






# AI 매칭 점수 계산 API (특정 보호자의 특정 환자 기준)
# 데이터 매핑 테이블
region_labels = {'서울': 0, '부산': 1, '대구': 2, '인천': 3, '광주': 4, '대전': 5, '울산': 6, '세종': 7, '경기남부': 8, '경기북부': 9, '강원영서': 10, '강원영동': 11, '충북': 12, '충남': 13, '전북': 14, '전남': 15, '경북': 16, '경남': 17, '제주': 18}
sex_labels = {'남성': 0, '여성': 1, '상관 없음': 2}
c_canwalk_labels = {'지원 가능': 0, '지원 불가능': 1, '둘 다 케어 가능': 2}
p_canwalk_labels = {'걸을 수 없음': 0, '걸을 수 있음': 1}
spot_label = {'병원': 0, '집': 1, '둘 다': 2}
smoking_labels = {'비흡연': 0, '흡연': 1, '상관 없음': 2}
symptom_labels = {'치매': 0, '섬망': 1, '욕창': 2, '하반신 마비': 3, '상반신 마비': 4, '전신 마비': 5, '와상 환자': 6, '기저귀 케어': 7, '의식 없음': 8, '석션': 9, '피딩': 10, '소변줄': 11, '장루': 12, '야간 집중 돌봄': 13, '전염성': 14, '파킨슨': 15, '정신질환': 16, '투석': 17, '재활': 18}

def get_patient_data(db: Session, protector_id: str, patient_id: str):
    patient = (
        db.query(models.PatientUserInfo)
        .filter(
            models.PatientUserInfo.protector_id == protector_id,
            models.PatientUserInfo.id == patient_id
        )
        .first()
    )

    if not patient:
        raise HTTPException(status_code=404, detail="해당 보호자의 해당 환자를 찾을 수 없습니다.")

    # DataFrame 변환
    patient_data = {
        "patient_id": patient.id,
        "startdate": patient.startdate.strftime('%Y-%m-%d') if patient.startdate else None,
        "enddate": patient.enddate.strftime('%Y-%m-%d') if patient.enddate else None,
        "region": patient.region,
        "spot": patient.spot,
        "sex": patient.sex,
        "age": patient.age,
        "symptoms": patient.symptoms,
        "canwalk": patient.canwalk,
        "prefersex": patient.prefersex,
        "smoking": patient.smoking,
        "preferstar": patient.preferstar
    }

    return pd.DataFrame([patient_data])


# 모든 간병인 데이터를 가져오는 함수
def get_caregiver_data(db: Session):
    caregivers = (
        db.query(models.CaregiverUserInfo, models.Review)
        .outerjoin(models.Review, models.CaregiverUserInfo.id == models.Review.caregiver_id)
        .all()
    )

    if not caregivers:
        raise HTTPException(status_code=404, detail="등록된 간병인이 없습니다.")

    caregiver_list = [
        {
            "caregiver_id": c.CaregiverUserInfo.id,
            "name": c.CaregiverUserInfo.name,
            "startdate": c.CaregiverUserInfo.startdate.strftime('%Y-%m-%d') if c.CaregiverUserInfo.startdate else None,
            "enddate": c.CaregiverUserInfo.enddate.strftime('%Y-%m-%d') if c.CaregiverUserInfo.enddate else None,
            "region": c.CaregiverUserInfo.region,
            "spot": c.CaregiverUserInfo.spot,
            "sex": c.CaregiverUserInfo.sex,
            "age": c.CaregiverUserInfo.age,
            "symptoms": c.CaregiverUserInfo.symptoms,
            "canwalk": c.CaregiverUserInfo.canwalkpatient,
            "prefersex": c.CaregiverUserInfo.prefersex,
            "smoking": c.CaregiverUserInfo.smoking,
            "star_0": c.Review.sincerity if c.Review else 0,  # 리뷰가 없으면 0
            "star_1": c.Review.communication if c.Review else 0,  # 리뷰가 없으면 0
            "star_2": c.Review.hygiene if c.Review else 0,  # 리뷰가 없으면 0
        }
        for c in caregivers
    ]

    return pd.DataFrame(caregiver_list)




# 매핑 함수들
def map_region(region):
    regions = region.split(',')  # 여러 지역이 쉼표로 구분되어 있음
    a = [str(region_labels[r]) for r in regions if r in region_labels]
    return ','.join(a)

def map_sex(sex):
    sexx = sex.split(',')  # 여러 성별이 쉼표로 구분되어 있음
    a = [str(sex_labels[r]) for r in sexx if r in sex_labels]
    return ','.join(a)

def map_spot(spot):
    spott = spot.split(',')  # 여러 장소가 쉼표로 구분되어 있음
    a = [str(spot_label[r]) for r in spott if r in spot_label]
    return ','.join(a)

def map_canwalk(canwalk):
    canwalkk = canwalk.split(',')  # 여러 지원 여부가 쉼표로 구분되어 있음
    a=[str(c_canwalk_labels[r]) for r in canwalkk if r in c_canwalk_labels]
    return ','.join(a)
    
def map_symtoms(symptom):
    symptomm = symptom.split(',')  # 여러 증상이 쉼표로 구분되어 있음
    a= [str(symptom_labels[r]) for r in symptomm if r in symptom_labels] 
    return ','.join(a)

def map_prefersex(prefersex):
    prefersexx = prefersex.split(',')  # 여러 성별 선호가 쉼표로 구분되어 있음
    a= [str(sex_labels[r]) for r in prefersexx if r in sex_labels] 
    return ','.join(a)

def map_smoking(smoking):
    smokingg = smoking.split(',')  # 여러 흡연 여부가 쉼표로 구분되어 있음
    a = [str(smoking_labels[r]) for r in smokingg if r in smoking_labels] 
    return ','.join(a)

def map_pwalk(pwalk):
    pwalkk = pwalk.split(',')  # 여러 걸을 수 있음/없음이 쉼표로 구분되어 있음
    a= [str(p_canwalk_labels[r]) for r in pwalkk if r in p_canwalk_labels]
    return ','.join(a)




# AI 매칭 점수 계산 API
@router.post("/predict/{protector_id}/{patient_id}")
def predict_matching_score(
    patient_id: str,  
    protector_id: str,
    db: Session = Depends(get_db),
    current_user: models.ProtectorUserInfo = Depends(get_current_user)
):
    # 원데이터를 가지는 caregiver_data -> flutter에서 활용하기 위함
    caregiver_data = get_caregiver_data(db)  
    
    
    #모델 학습용 dataframe으로 사용
    caregiver_df = caregiver_data.drop(labels='name',axis=1)
    patient_df = get_patient_data(db, protector_id, patient_id)

    
    # 데이터 전처리
    caregiver_df['region'] = caregiver_df['region'].apply(map_region)
    caregiver_df['sex'] = caregiver_df['sex'].apply(map_sex)
    caregiver_df['spot'] = caregiver_df['spot'].apply(map_spot)
    caregiver_df['canwalk'] = caregiver_df['canwalk'].apply(map_canwalk)
    caregiver_df['symptoms'] = caregiver_df['symptoms'].apply(map_symtoms)
    caregiver_df['prefersex'] = caregiver_df['prefersex'].apply(map_prefersex)
    caregiver_df['smoking'] = caregiver_df['smoking'].apply(map_smoking)
    patient_df['region'] = patient_df['region'].apply(map_region)
    patient_df['spot'] = patient_df['spot'].apply(map_spot)
    patient_df['sex'] = patient_df['sex'].apply(map_sex)
    patient_df['symptoms'] = patient_df['symptoms'].apply(map_symtoms)
    patient_df['canwalk'] = patient_df['canwalk'].apply(map_pwalk)
    patient_df['prefersex'] = patient_df['prefersex'].apply(map_prefersex)
    patient_df['smoking'] = patient_df['smoking'].apply(map_smoking)
    
    
    # 데이터 병합
    caregiver_df["key"] = 1
    patient_df["key"] = 1
    merged_df = pd.merge(patient_df, caregiver_df, on="key").drop(columns=["key"])

    # 지역 매칭 (One-hot Encoding)
    for i in range(19):  
        merged_df[f"region_x_{i}"] = (merged_df["region_x"] == i).astype(int)
        merged_df[f"region_y_{i}"] = merged_df["region_y"].apply(lambda x: 1 if str(i) in x.split(",") else 0)

    # 지역 매칭 여부
    merged_df["region_match"] = merged_df.apply(lambda row: 1 if row["region_x"] in map(int, row["region_y"].split(",")) else 0, axis=1)

    # Boolean Feature → 0/1 변환
    merged_df["spot_match"] = (merged_df["spot_x"] == merged_df["spot_y"]) | (merged_df["spot_y"] == 2)
    merged_df["gender_match"] = (merged_df["prefersex_x"].isin([merged_df["sex_y"], 2])) & \
                                (merged_df["prefersex_y"].isin([merged_df["sex_x"], 2]))
    merged_df["canwalk_match"] = (merged_df["canwalk_x"] == merged_df["canwalk_y"]) | (merged_df["canwalk_y"] == 2)
    merged_df["smoking_match"] = (merged_df["smoking_x"] == 2) | (merged_df["smoking_x"] == merged_df["smoking_y"])
    merged_df["date_overlap"] = (pd.to_datetime(merged_df["startdate_x"]) <= pd.to_datetime(merged_df["enddate_y"])) & \
                                (pd.to_datetime(merged_df["startdate_y"]) <= pd.to_datetime(merged_df["enddate_x"]))

    # Boolean 데이터를 0 또는 1로 변환
    for col in ["region_match", "spot_match", "gender_match", "canwalk_match", "smoking_match", "date_overlap"]:
        merged_df[col] = merged_df[col].astype(int)

    # 증상 매칭 점수 계산
    def compute_symptom_score(row):
        patient_symptoms = set(map(int, row["symptoms_x"].split(",")))
        caregiver_symptoms = set(map(int, row["symptoms_y"].split(",")))
        return len(patient_symptoms & caregiver_symptoms) / len(patient_symptoms)

    merged_df["symptom_match_score"] = merged_df.apply(compute_symptom_score, axis=1)

    # 최종 Feature 선택
    feature_cols = (
        ["patient_id", "caregiver_id"] +
        [f"region_x_{i}" for i in range(19)] +
        [f"region_y_{i}" for i in range(19)] +
        ["spot_x", "spot_y", "sex_x", "sex_y", "prefersex_x", "prefersex_y", 
            "canwalk_x", "canwalk_y", "smoking_x", "smoking_y", "region_match", 
            "spot_match", "gender_match", "canwalk_match", "smoking_match", 
            "symptom_match_score", "date_overlap", 'preferstar', "star_0", 'star_1', 'star_2']
    )

    # 최종 데이터 변환 (numpy array)
    final_data = merged_df[feature_cols].drop(columns=["patient_id", "caregiver_id"]).to_numpy()
    final_data = final_data.astype(np.float32)


    # 모델 로드
    best_model = TabNetRegressor()
    best_model.load_model("./model/gpt_1000_tabnet_model.zip")
    
    # 예측 수행
    preds = best_model.predict(final_data)
    matching_rate = (preds/max(preds)) * 100
    
    # 결과 생성
    caregiver_data['matching_rate'] = matching_rate
    sorted_result = caregiver_data.sort_values(by='matching_rate', ascending=False)
    sorted_result.rename(columns={'star_0': 'sincerity', 'star_1': 'communication', 'star_2': 'hygiene'}, inplace=True)
    
    # 결과 반환
    result = sorted_result.drop_duplicates()
    
    print(result.head(10))

    return jsonable_encoder(result.to_dict(orient="records"))
