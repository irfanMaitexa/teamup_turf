import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup_turf/baseurl.dart';

class LoginServices {
  Future<void> saveLoginId(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginId', token);
  }

  Future<void> savePlayerId(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerId', token);
  }
   Future<String?> getPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('playerId');
  }
  Future<String?> getLoginId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loginId');
  }

 

 

  Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    String loginUrl = "$baseUrl/api/login";
    try {
      var uri = Uri.parse(loginUrl);
      final response = await http.post(uri, body: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        var responseBody = await response.body;
        print(responseBody);
        Map<String, dynamic> data = jsonDecode(responseBody);
        if (data['Success'] == true || data['success'] == true) {
  
          final token = data['loginId'];
          final role = data['role'];
          await saveLoginId(token);
          if (role == 'player') {
            final playerId = data['playerId'];
            await savePlayerId(playerId);
          } 

           if (role == 'turf') {
            final playerId = data['playerId'];
            await savePlayerId(playerId);
          } 
          return {'message': 'Login Successfull', 'role': role};
        } else {
          return {'message': data['Message']};
        }
      } else {
        var data = await jsonDecode(response.body);
        return {'message': data['Message']};
      }
    } catch (e) {
      rethrow;
    }
  }
}
