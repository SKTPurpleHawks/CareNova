from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

class ForeignUserCreate(BaseModel):
    email: str
    password: str
    name: str
    phonenumber: str
    birthday: datetime
    age: int
    sex: str
    startdate: datetime
    enddate: datetime
    region: str
    spot: str
    height: int
    weight: int
    symptoms: str
    canwalkpatient: str
    prefersex: str
    smoking: str
    showyn: int

class ProtectorUserCreate(BaseModel):
    email: str
    password: str
    name: str
    phonenumber: str
    birthday: datetime
    sex: str

class UserLogin(BaseModel):
    email: str
    password: str

class UserUpdate(BaseModel):
    email: str
    new_password: Optional[str] = None
    name: str
    phonenumber: str
    birthday: datetime
    age: int
    sex: str
    startdate: datetime
    enddate: datetime
    region: str
    spot: str
    height: int
    weight: int
    symptoms: str
    canwalkpatient: str
    prefersex: str
    smoking: str

class PatientBase(BaseModel):
    name: str
    birthday: datetime
    age: int
    sex: str
    height: int
    weight: int
    symptoms: str
    canwalk: str
    prefersex: str
    smoking: str


class PatientResponse(PatientBase):
    id: str
    protector_id: str

    class Config:
        from_attributes = True


class JobInfoUpdate(BaseModel):
    showyn: int

class CareRequestCreate(BaseModel):
    caregiver_id: str 

class CareRequestUpdate(BaseModel):
    status: str  

class PatientAssignmentCreate(BaseModel):
    caregiver_id: str
    patient_id: str