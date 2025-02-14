from sqlalchemy.orm import Session
import models, schemas
from security import get_password_hash

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
        smoking=user.smoking,
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


def get_user_by_email(db: Session, email: str):
    foreign_user = db.query(models.ForeignUserInfo).filter(models.ForeignUserInfo.email == email).first()
    if foreign_user:
        return foreign_user
    return db.query(models.ProtectorUserInfo).filter(models.ProtectorUserInfo.email == email).first()
