import 'package:flutter/material.dart';
import 'package:teamup_turf/user/screens/single_team_screen.dart';
import 'package:teamup_turf/user/services/user_api_services.dart';

class UserTeamsScreen extends StatefulWidget {
  const UserTeamsScreen({super.key});

  @override
  State<UserTeamsScreen> createState() => _UserTeamsScreenState();
}

class _UserTeamsScreenState extends State<UserTeamsScreen> {

  UserApiServices userApiServices = UserApiServices();

    Future<List<dynamic>> _getTeams() async {
    return await userApiServices.getCreatedTeams();
  }

  Future<void> deleteTeam({required String id})async{
    try{
      final result = await userApiServices.deleteTeam(id: id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      setState(() {
        
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Teams'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child:FutureBuilder(future:_getTeams() , builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(color: Colors.green,),);
          }else if(snapshot.hasError){
            return Center(child: Text('Something went wrong'),);
          }else if(snapshot.data!.isEmpty || !snapshot.hasData){
            return Center(child: Text('No news yet'),);
          }else{
            final data = snapshot.data;
            return  ListView.builder(
          itemCount: data!.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SingleTeamScreen(id: data[index]['_id'],),));
              },
              child: TeamCard(
                title: data[index]['teamName'],
                description: data[index]['status'],
                onDelete: () => deleteTeam(id: data[index]['_id']),
              ),
            );
          },
        );
          }
        },)
      ),
    );
  }
}

class TeamCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDelete;

  const TeamCard({
    required this.title,
    required this.description,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: 
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: $description',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(onPressed: onDelete, 
                icon: Icon(Icons.delete,color: Colors.red,))
              ],
            ),
      ),
    );
  }
}