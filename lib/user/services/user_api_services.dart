import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';
import 'package:teamup_turf/login_services.dart';

class UserApiServices {

  
  Future<String> getLoginId() async {
    final loginid = await LoginServices().getLoginId();
    return loginid!;
  }
  Future<String> getId()async{
    final loginid = await LoginServices().getPlayerId();
    return loginid!;
  }

  Future<String> deletePlayer()async{
    String loginId = await getLoginId();
    String deletePlayerUrl = '$baseUrl/api/register/delete-player/$loginId';
    try{
      final response = await http.get(Uri.parse(deletePlayerUrl));
      if(response.statusCode == 200){
        return jsonDecode(response.body)['message'];
      }
      else{
        return jsonDecode(response.body)['message'];
      }
    }catch(e){
      rethrow;
    }
  }

  Future<String> createTeam({required String teamName})async{
    String createTeamUrl = '$baseUrl/api/team/create-team';
    String captainId = await getId();
    print(captainId);
    try{
      final response = await http.post(Uri.parse(createTeamUrl),body: {
        'teamName':teamName,
        'captainId':captainId,
      });
      if(response.statusCode == 201){
        final responseData =jsonDecode(response.body);
        return responseData['message'];
      }
      else{
        final responseData =jsonDecode(response.body);
        return responseData['message'];
      }
    }catch(e){
      rethrow;
    }
  }



Future<List<dynamic>> getCreatedTeams() async {
  String getCreatedTeamUrl = '$baseUrl/api/team/all-team';
  String loginId = await getId(); // Assume this function fetches the current user's ID.

  try {
    final response = await http.get(Uri.parse(getCreatedTeamUrl));
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true && responseData['data'] is List) {
        List<dynamic> teams = responseData['data'];
        
        // Filter teams where the captainId matches the loginId.
        List<dynamic> filteredTeams = teams.where((team) {
          return team['captainId']['_id'] == loginId;
        }).toList();

        return filteredTeams;
      } else {
        print('Unexpected response format or no data found.');
        return [];
      }
    } else {
      print('Failed to fetch teams: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching teams: $e');
    rethrow;
  }
}

Future<Map<String,dynamic>> singleTeam({required String id})async{

  final playerId = await LoginServices().getPlayerId();
  String getSingleTeamUrl = '$baseUrl/api/team/single-team/$id';
  try{
    final response = await http.get(Uri.parse(getSingleTeamUrl));
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      final result = {'data':jsonDecode(response.body)['data'],'message':jsonDecode(response.body)['message']};
      return result;
    }else{
      return jsonDecode(response.body)['message'];
    }
  }catch(e){
    rethrow;
  }
}

Future<String> deleteTeam({required String id})async{
  String deleteTeamUrl = '$baseUrl/api/team/delete-team/$id';
  try{
    final response = await http.get(Uri.parse(deleteTeamUrl));
    return jsonDecode(response.body)['message'];
  }catch(e){
    rethrow;
  }
}

Future<List<dynamic>> getAllTeams() async {
  String getCreatedTeamUrl = '$baseUrl/api/team/all-team';
  String loginId = await getId(); 
 

  try {
    final response = await http.get(Uri.parse(getCreatedTeamUrl));
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true && responseData['data'] is List) {
        List<dynamic> teams = responseData['data'];
        
        // Filter teams where the captainId matches the loginId.
        List<dynamic> filteredTeams = teams.where((team) {
          return team['captainId']['_id'] != loginId;
        }).toList();

        return filteredTeams;
      } else {
        print('Unexpected response format or no data found.');
        return [];
      }
    } else {
      print('Failed to fetch teams: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching teams: $e');
    rethrow;
  }
}



}