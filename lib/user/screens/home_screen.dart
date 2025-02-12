import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';
import 'package:teamup_turf/user/screens/player_turf_details_screen.dart';
import 'package:teamup_turf/user/screens/single_team_screen.dart';
import 'package:teamup_turf/user/screens/user_teams_screen.dart';
import 'package:teamup_turf/user/services/user_api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {

                                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserTeamsScreen()));

          
        },
        child: const Icon(Icons.person),

        
      ),
      
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            BannerCarousel(),
            const SizedBox(height: 30), // Increased spacing between sections
            NearbyAndRequests(),
            const SizedBox(height: 30), // Space before Quick Book section
         
            // Extra space at the bottom for better layout
          ],
        ),
      ),
    );
  }
}


class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> bannerImages = [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR86JwAGpII4DI79L0X45S1L71_mNNyJ3dC2A&s',
      'https://content.jdmagicbox.com/v2/comp/kolkata/w3/033pxx33.xx33.240126100542.p7w3/catalogue/inside-out-turf-sodepur-kolkata-sports-clubs-eskdy5lmf1.jpg',
      'https://ngpe.in/wp-content/uploads/2023/12/New-and-Unique-Sports.jpg',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 180,
        child: CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
          ),
          items: bannerImages.map((image) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                image: DecorationImage(
                  image: NetworkImage(image),

                  fit: BoxFit.fitWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


class NearbyAndRequests extends StatelessWidget {
NearbyAndRequests({super.key});
  UserApiServices userApiServices = UserApiServices();

    Future<List<dynamic>> getTeams()async{
    try{
      final result  = await userApiServices.getAllTeams();
      return result;
    }catch(e){
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Nearby Grounds',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            textAlign: TextAlign.left, // Align text to the left
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder(future: AdminApiServices().getTurfs(status: 'approved'), builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(color: Colors.lightGreen,),);
          }else if(snapshot.hasError){
            return Center(child: Text('Something went wrong'),);
          }else if(snapshot.data!.isEmpty || !snapshot.hasData){
            return Center(child: Text('No turfs found'),);
          }else{
            final data = snapshot.data;
            return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(data!.length, (index) {
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerTurfDetailsScreen(turfId: data[index]['loginId'], timeSlots: [], amenities: ['hi']),));
                },
                child: NearbyGroundCard(
                  turf: {
                    'name': data[index]['turfName'],
                    'location': data[index]['location'],
                    'image': data[index]['documentUrl'][0],
                    'sports': '⚽ +2 sports',
                  },
                ),
              );
            }),
          ),
        );
          }
        },),
        const SizedBox(height: 30),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Team Requests',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            textAlign: TextAlign.left, // Align text to the left
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder(future: getTeams(), builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(color: Colors.lightGreen,),);
          }else if(snapshot.hasError){
            return Center(child: Text('Something went wrong'),);
          }else if(snapshot.data!.isEmpty || !snapshot.hasData){
            return Center(child: Text('No Teams found'),);
          }else{
            final data = snapshot.data;
            
            return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data!.length, // Example team requests
          itemBuilder: (context, index) {
            final members = data[index]['members'];
            int noOfMembers = members.length;
            return GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SingleTeamScreen(id: data[index]['_id']),));
              },
              child: TeamRequestCard(
                request: {
                  'captain': 'Team ${data[index]['teamName']}',
                  'message': 'Looking for ${11-noOfMembers} more players for football.',
                },
              ),
            );
          },
        );
          }
        },)
      ],
    );
  }
}



class NearbyGroundCard extends StatelessWidget {
  final Map<String, String> turf;
  const NearbyGroundCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(
          color: Colors.green
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              turf['image']!,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              turf['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              turf['location']!,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              turf['sports']!,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class TeamRequestCard extends StatelessWidget {
  final Map<String, String> request;
  const TeamRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade50, // Light green background for requests
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.shade300),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.group, color: Colors.green, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request from ${request['captain']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(request['message']!),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
