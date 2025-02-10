import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';

class TurfApiServices {
  Future<String> updateTurf({required String id,required String turfName, required String location,required String contact,required String address,required String fair,String? imageUrl})async{    
    String updateTurfUrl = '$baseUrl/api/register/turf/$id';
    try{
     var uri = Uri.parse(updateTurfUrl);
            var request = http.MultipartRequest('PUT', uri);
            if(imageUrl != null){
             var document = await http.MultipartFile.fromPath("imageUrl", imageUrl);
             request.files.add(document);
            }
             request.fields['turfName'] = turfName;
              request.fields['location'] = location;
              request.fields['contact'] = contact;
              request.fields['address'] = address;
              request.fields['fair'] = fair;
              var response = await request.send();
      if(response.statusCode == 200){
         var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> data = jsonDecode(responseBody);
        return data['message'];
      }
      else{
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> data = jsonDecode(responseBody);
        return data['message'];
      }
    }catch(e){
      rethrow;
    }
  }
}