import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';

class AdminApiServices {
  Future<List<dynamic>> getTurfs({required String status}) async {
    String getTurfsUrl =
        "$baseUrl/api/register/view-turfs";
    try {
      final response = await http.get(Uri.parse(getTurfsUrl));
      if (response.statusCode == 200) {
        final dataList = jsonDecode(response.body)['data'] as List;
        return dataList.where((turf) => turf['status'] == status).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSingleTurf({required String turfId}) async {
    String getSingleTurfUrl =
        "$baseUrl/api/register/view-single-turf/$turfId";
    try {
      final response = await http.get(Uri.parse(getSingleTurfUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        return {'message': 'No such turf found'};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> approveTurf({required String turfId}) async {
    String approveTurfUrl =
        "$baseUrl/api/register/approve-turf/$turfId";
    try {
      final response = await http.get(Uri.parse(approveTurfUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'];
      } else {
        return 'error occured';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> rejectTurf({required String turfId}) async {
    String rejectTurfUrl =
        "$baseUrl/api/register/reject-turf/$turfId";
    try {
      final response = await http.get(Uri.parse(rejectTurfUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'];
      } else {
        return 'Error occured';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addNews(
      {required String title,
      required String news,
      required File image}) async {
    String addNewsUrl = "$baseUrl/api/news/add";
    try {
      var uri = Uri.parse(addNewsUrl);
      var request = http.MultipartRequest('POST', uri);
      var imageUrl = await http.MultipartFile.fromPath("imageUrl", image.path);
      request.files.add(imageUrl);
      request.fields['title'] = title;
      request.fields['news'] = news;
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> data = jsonDecode(responseBody);
        return data['message'];
      } else {
        return 'Error occured';
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<dynamic> viewNews()async{
    String viewNewsUrl = "$baseUrl/api/news/view-news";
    try{
      final response = await http.get(Uri.parse(viewNewsUrl));
      if(response.statusCode == 200){
        final dataList = jsonDecode(response.body)['data'] as List;
        return dataList;
      }else{
        return [];
      }
    }catch(e){
      rethrow;
    }
  }
  Future<List<dynamic>> viewUsers()async{
    String viewUsersUrl = '$baseUrl/api/register/view-all-players';
    try{
      final response = await http.get(Uri.parse(viewUsersUrl));
        if (response.statusCode == 200) {
        final dataList = jsonDecode(response.body)['data'] as List;
        return dataList;
      } else {
        return [];
      }
    }catch(e){
      rethrow;
    }
  }

  Future<Map<String,dynamic>> viewSinglePlayer({required String loginId})async{
    String viewSinglePlayerUrl = '$baseUrl/api/register/view-single-player/$loginId';
    try{
      final response = await http.get(Uri.parse(viewSinglePlayerUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        return {'message': 'No such turf found'};
      }
    }catch(e){
      rethrow;

    }
  }
  Future<Map<String,dynamic>> deletePlayer({required String id})async{
  String deleteUrl = '$baseUrl/api/register/delete-player/$id';
  try{
    final response = await http.get(Uri.parse(deleteUrl));
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return {'message':data['message'],'success':data['success']};
    }else{
      
      final data = jsonDecode(response.body);
      return {'message':data['message'],'success':data['success']};
    }
  }catch(e){
    rethrow;
  }
}
}
