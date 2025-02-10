import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup_turf/baseurl.dart';

class UserAuthServices {

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

   Future<void> deleteId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // Remove the token using its key
}


  
  Future<String> userRegister({
  required String playerName,
  required String gender,
  required String mobile,
  required String position,
  required String avaialabilty,
  required File imageUrl,
  required String location,
  required String email,
  required String password,
}) async {
  String userRegisterUrl = "$baseUrl/api/register/player";
  try {
    var uri = Uri.parse(userRegisterUrl);
    var request = http.MultipartRequest('POST', uri);
    var document = await http.MultipartFile.fromPath("imageUrl", imageUrl.path);
    request.files.add(document);
    request.fields['playerName'] = playerName;
    request.fields['location'] = location;
    request.fields['mobile'] = mobile;
    request.fields['gender'] = gender;
    request.fields['position'] = position;
    request.fields['availability'] = avaialabilty;
    request.fields['email'] = email;
    request.fields['password'] = password;

    var response = await request.send();

    // Read the response body once and store it
    var responseBody = await response.stream.bytesToString();

    print(responseBody);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(responseBody);
      final token = data['data']['loginId'];
      await saveToken(token); // Save the token
      return data['message']; // Return the success message
    } else {
      // Decode the response to find out the error details
      Map<String, dynamic> errorData = jsonDecode(responseBody);
      return errorData['message'] ?? 'Error occurred';
    }
  } catch (e) {
    rethrow; // Re-throw the exception to the caller
  }
}

Future<String> delete({required String id})async{
  String deleteUrl = '$baseUrl/api/register/delete-player/$id';
  try{
    final response = await http.get(Uri.parse(deleteUrl));
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return data['message'];
    }else{
      return 'Unable to delete';
    }
  }catch(e){
    rethrow;
  }
}

}