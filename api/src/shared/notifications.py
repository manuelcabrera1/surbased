import json
import os
from firebase_admin import messaging
from google.oauth2 import service_account
import google.auth.transport.requests 
import requests
from typing import TYPE_CHECKING
from google.auth.transport.requests import Request


def send_notification(token: str, title: str, body: str, email: str, survey_id: str, survey_name: str):


    if not token:
        print("No token provided for notification")
        return False
        
    url = f"https://fcm.googleapis.com/v1/projects/surbased-9d626/messages:send"


    message = {
        "message": {
            "token": token,
            "notification": {
                "title": title,
                "body": body
            },
            "data": {
                "survey_id": str(survey_id),
                "survey_name": survey_name,
                "email": email
            }
        }
    }

    headers = {
        "Authorization": f"Bearer {get_access_token()}",
        "Content-Type": "application/json"
    }

    response = requests.post(url, headers=headers, data=json.dumps(message))

    print("status code: ", response.status_code, "response: ", response.json() )
     
    return response.json()


def  get_access_token():
    api_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    credentials = service_account.Credentials.from_service_account_file(os.path.join(api_dir, 'surbased-9d626-firebase-adminsdk-fbsvc-5b498651ed.json'), scopes=['https://www.googleapis.com/auth/cloud-platform'])
    credentials.refresh(Request())
    print(credentials.token)
    return credentials.token
    


