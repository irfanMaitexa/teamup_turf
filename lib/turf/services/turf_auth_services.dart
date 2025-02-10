import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup_turf/baseurl.dart';

class AuthServivices{
Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  

  Future<String> turfRegister({
    required double lat,required double long,required String about,
    required String turfName, required String location,required String contact,required String address,required String fair,required File documentUrl,required String email,required String password})async{
    String turfRegisterUrl = "$baseUrl/api/register/turf";
    try{
            var uri = Uri.parse(turfRegisterUrl);
            var request = http.MultipartRequest('POST', uri);
             var document = await http.MultipartFile.fromPath("documentUrl", documentUrl.path);
             request.files.add(document);
             request.fields['turfName'] = turfName;
              request.fields['location'] = location;
              request.fields['contact'] = contact;
              request.fields['address'] = address;
              request.fields['fair'] = fair;
              request.fields['email'] = email;
              request.fields['password'] = password;
              request.fields['latitude'] = lat.toString();
              request.fields['longitude'] = long.toString();
              request.fields['about'] = about;

              var response = await request.send();

      if(response.statusCode == 200){
         var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> data = jsonDecode(responseBody);
        final token = data['data']['loginId'];
        saveToken(token);
        return data['message'];
    }
    else{
      return 'error occured';
    }
  }catch(e){
    rethrow;
  }
  }

}