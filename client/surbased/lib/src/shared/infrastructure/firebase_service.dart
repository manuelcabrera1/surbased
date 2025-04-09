import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:surbased/src/app.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:http/http.dart' as http;
import 'package:surbased/src/survey/application/pages/survey_invitation_dialog.dart';

class FirebaseService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final String _baseUrl = 'http://192.168.1.69:8000/fcm-token';


  Future<String?> initNotifications() async {
    
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();

    print('Firebase token: $token');

    FirebaseMessaging.onMessage.listen(_handleMessage);  

    await initPushNotifications(); 

    return token;
  }

  Future<void> _handleMessage(RemoteMessage? message) async {


    if (message == null) return;

    _showSurveyInvitationDialog(message);
 
  }

  void _showSurveyInvitationDialog(RemoteMessage message) {
    if (navigatorKey.currentContext == null) return;
    
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => Dialog(
        child: SurveyInvitationDialog(
          surveyId: message.data['survey_id'],
          surveyName: message.data['survey_name'],
          inviterName: message.data['email'],
        ),
      ),
    );
  }

  Future<void> initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }
  
  Future<Map<String, dynamic>> sendFcmToken(String jwtToken, String userId, String fcmToken) async {
    try {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({
          'fcm_token': fcmToken,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Token sent successfully'};
      } else {
        return {'success': false, 'message': 'Failed to send token'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to send token: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteFcmToken(String jwtToken, String userId, String fcmToken) async {
    try {
        final response = await http.delete(
          Uri.parse(_baseUrl),
          headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({
          'fcm_token': fcmToken,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 204) {
        return {'success': true, 'message': 'Token deleted successfully'};
      } else {
        return {'success': false, 'message': 'Failed to delete token'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete token: $e'};
    }
  }
}
