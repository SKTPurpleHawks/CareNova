from sqlalchemy.orm import Session
import models, schemas
from security import get_password_hash
import logging


# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_foreign_user(db: Session, user: schemas.ForeignUserCreate):

    new_id = models.ForeignUserInfo.foreign_generate_custom_id(db)

    db_user = models.ForeignUserInfo(
        id=new_id, 
        email=user.email,
        password=get_password_hash(user.password),
        name=user.name,
        phonenumber=user.phonenumber,
        birthday=user.birthday,
        age=user.age,
        sex=user.sex,
        startdate=user.startdate,
        enddate=user.enddate,
        region=user.region,
        spot=user.spot,
        height=user.height,
        weight=user.weight,
        symptoms=user.symptoms,
        canwalkpatient=user.canwalkpatient,
        prefersex=user.prefersex,
        smoking=user.smoking
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def create_protector_user(db: Session, user: schemas.ProtectorUserCreate):

    new_id = models.ProtectorUserInfo.protector_generate_custom_id(db) 

    db_user = models.ProtectorUserInfo(
        id=new_id,  
        email=user.email,
        password=get_password_hash(user.password),
        name=user.name,
        phonenumber=user.phonenumber,
        birthday=user.birthday,
        sex=user.sex,
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_patient(db: Session, patient: schemas.PatientBase):
    new_id = models.PatientUserInfo.patient_generate_custom_id(db)
    
    db_patient = models.PatientUserInfo(
        id=new_id,
        protector_id=patient.protector_id,
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
    
    db.add(db_patient)  
    db.commit()
    db.refresh(db_patient)
    
    return db_patient


def get_patients_by_protector(db: Session, protector_id: str):
    return db.query(models.PatientUserInfo).filter(models.PatientUserInfo.protector_id == protector_id).all()


def get_user_by_email(db: Session, email: str):
    logger.info(f" [SEARCH USER] Searching for email: {email}")

    # 외국인 사용자 테이블에서 검색
    foreign_user = db.query(models.ForeignUserInfo).filter(models.ForeignUserInfo.email == email).first()
    if foreign_user:
        logger.info(f" [USER FOUND] Foreign user found: {email}")
        return foreign_user

    # 보호자 사용자 테이블에서 검색
    protector_user = db.query(models.ProtectorUserInfo).filter(models.ProtectorUserInfo.email == email).first()
    if protector_user:
        logger.info(f" [USER FOUND] Protector user found: {email}")
        return protector_user

    # 사용자가 없을 경우 로그 출력
    logger.warning(f" [USER NOT FOUND] No user with email: {email}")
    return None


def update_job_info(db: Session, user_id: str, job_info_update: schemas.JobInfoUpdate):
    user = db.query(models.ForeignUserInfo).filter(models.ForeignUserInfo.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.showyn = 1 if job_info_update.showyn else 0 

    db.commit()
    db.refresh(user)

    return user

