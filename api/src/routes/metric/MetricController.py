from typing import Annotated
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from models.MetricModel import Metric
from auth.Auth import get_current_user, required_roles
from models.UserModel import User
from schemas.MetricSchema import *
from database import get_db


metric_router = APIRouter(tags=["Metrics"])



"""
Add metric
Get all metrics
Get metric by id
Update metric
Delete metric
"""

@metric_router.post("/metrics", status_code=200, response_model=MetricResponse)
@required_roles(["admin", "researcher"])
async def create_metric(metric: MetricCreateRequest, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if metric already exists
        result = await db.execute(select(Metric).where(Metric.name == metric.name))
        existing_metric = result.unique().scalars().first()

        if existing_metric:
            raise HTTPException(status_code=400, detail="This metric already exists")
        
        new_metric = Metric(name=metric.name, description=metric.description, formula=metric.formula)
        db.add(new_metric)
        await db.commit()
        await db.refresh(new_metric)
        
        return new_metric
 

@metric_router.get("/metrics/{id}", status_code=200, response_model=MetricResponse)
@required_roles(["admin", "researcher"])
async def get_metric_by_id(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if metric already exists
        result = await db.execute(select(Metric).where(Metric.id == id))
        existing_metric = result.unique().scalars().first()

        if not existing_metric:
            raise HTTPException(status_code=404, detail="Metric not found")
        
        return existing_metric
        
        return new_metric

@metric_router.put("/metrics/{id}", status_code=200, response_model=MetricResponse)
@required_roles(["admin", "researcher"])
async def update_metric(id: uuid.UUID, metric: MetricUpdateRequest, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if metric already exists
        result = await db.execute(select(Metric).where(Metric.id == id))
        existing_metric = result.unique().scalars().first()

        if not existing_metric:
            raise HTTPException(status_code=404, detail="Metric not found")
        
        if existing_metric.name != metric.name:
            result2 = await db.execute(select(Metric).where(Metric.name == metric.name))
            existing_metric_name = result2.scalars().first()

            if existing_metric_name:
                raise HTTPException(status_code=400, detail="Metric name already registered")
        
        await db.execute(update(Metric).where(Metric.id == id).values(metric.model_dump()))
        await db.commit()
        
        return existing_metric
    


@metric_router.delete("/metrics/{id}", status_code=204)
@required_roles(["admin", "researcher"])
async def delete_metric(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if metric already exists
        result = await db.execute(select(Metric).where(Metric.id == id))
        existing_metric = result.unique().scalars().first()

        if not existing_metric:
            raise HTTPException(status_code=404, detail="Metric not found")
        
        await db.delete(existing_metric)
        await db.commit()

        return None
    





