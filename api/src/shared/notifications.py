import json
import os
from firebase_admin import messaging
from google.oauth2 import service_account
import google.auth.transport.requests 
import requests
from typing import TYPE_CHECKING
from google.auth.transport.requests import Request
from schemas.NotificationSchema import NotificationRequest

def send_notification(payload: NotificationRequest):


    if not payload.token:
        print("No token provided for notification")
        return False
        
    url = f"https://fcm.googleapis.com/v1/projects/surbased-9d626/messages:send"


    message = {
        "message": {
            "token": payload.token,
            "notification": {
                "title": payload.title,
                "body": payload.body
            },
            "data": {
                "survey_id": str(payload.survey_id),
                "survey_name": payload.survey_name,
                "email": payload.email,
                "user_id": str(payload.user_id)
            }
        }
    }

    headers = {
        "Authorization": f"Bearer {get_access_token()}",
        "Content-Type": "application/json"
    }

    response = requests.post(url, headers=headers, data=json.dumps(message))

    print(payload)

    print("status code: ", response.status_code, "response: ", response.json() )
     
    return response.json()


def  get_access_token():
    api_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    credentials = service_account.Credentials.from_service_account_file(os.path.join(api_dir, 'surbased-9d626-firebase-adminsdk-fbsvc-5b498651ed.json'), scopes=['https://www.googleapis.com/auth/cloud-platform'])
    credentials.refresh(Request())
    return credentials.token
    


