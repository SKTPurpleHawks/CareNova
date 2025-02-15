from pydantic import BaseModel
from datetime import datetime

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