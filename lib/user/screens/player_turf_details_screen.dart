import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:teamup_turf/admin/screens/admin_turf_mangement_screen.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/user/screens/review_dialoge.dart';
import 'package:teamup_turf/user/screens/user_booking_screen.dart';
import 'package:teamup_turf/user/screens/user_chat_screenns.dart';

class PlayerTurfDetailsScreen extends StatefulWidget {
  final String turfId;
  final List<String> timeSlots;
  final List<String> amenities;

  PlayerTurfDetailsScreen({
    required this.turfId,
    required this.timeSlots,
    required this.amenities,
  });

  @override
  State<PlayerTurfDetailsScreen> createState() => _PlayerTurfDetailsScreenState();
}

class _PlayerTurfDetailsScreenState extends State<PlayerTurfDetailsScreen> {
  Future<Map<String, dynamic>> fetchTurfDetails() async {
    try {
      final values = await AdminApiServices().getSingleTurf(turfId: widget.turfId);
      print(values);
      return values;
    } catch (e) {
      throw Exception("Failed to fetch turf details: $e");
    }
  }

  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: 1,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered,
                  );
                },
                scrollPhysics: BouncingScrollPhysics(),
                backgroundDecoration: BoxDecoration(color: Colors.black),
                pageController: PageController(),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  //review add 

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTurfDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No data found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final turfDetails = snapshot.data!;
          return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Turf Image with Gradient Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: GestureDetector(
                    onTap: () => _showImage(context, (turfDetails['documentUrl'] != null && turfDetails['documentUrl'].isNotEmpty)
      ? turfDetails['documentUrl'][0]
      : 'https://via.placeholder.com/150',), // Show image when tapped
                    child: Image.network(
                       (turfDetails['documentUrl'] != null && turfDetails['documentUrl'].isNotEmpty)
      ? turfDetails['documentUrl'][0]
      : 'https://via.placeholder.com/150',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Turf Name, Distance, and Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turfDetails['turfName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              turfDetails['location'],
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                          
                         
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Contact Info with Divider
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        // Contact Info Row
                        Row(
                          children: [
                            Text(
                              turfDetails['contact'],
                              style: TextStyle(fontSize: 16),
                            ),
                            Spacer(),
                            Icon(Icons.phone, color: Colors.green),
                          ],
                        ),
                        Divider(color: const Color.fromARGB(255, 220, 219, 219)),
                        SizedBox(height: 10),

                        // Fair Info Row
                        Row(
                          children: [
                            Text(
                              turfDetails['fair'],
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.attach_money, color: Colors.green),
                          ],
                        ),
                        Divider(color: const Color.fromARGB(255, 220, 219, 219)),
                        SizedBox(height: 10),

                        // Time Slots Title

                        if (turfDetails.containsKey('latitude') && turfDetails.containsKey('longitude')) 
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          double latitude = double.tryParse(turfDetails['latitude'].toString()) ?? 0.0;
          double longitude = double.tryParse(turfDetails['longitude'].toString()) ?? 0.0;
          openGoogleMaps(latitude, longitude);
        },
        icon: Icon(Icons.map, color: Colors.white),
        label: Text("View on Google Maps" ,style: TextStyle(color: Colors.white),),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
  ),



                        
                      

                        // Time Slots in Bubble-like Arrangement
                       
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),


            // About Turf Section
if (turfDetails.containsKey('about') && turfDetails['about'] != null) 
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Turf",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                turfDetails['about'],
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    ),
  ),


   



            

            // Document Link Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: GestureDetector(
                    onTap: () {
                      _showImage(context, turfDetails['documentUrl']?[0] ?? 'https://via.placeholder.com/150');
                    },
                    child: Text(
                      "View image",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),



  

              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chat Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Navigate to Chat Screen (Replace with actual screen)

                        final turfId = await FirebaseFirestore.instance.collection('turf').where('email',isEqualTo: turfDetails['email']).limit(1).get();

                        print(turfId.docs.first.id);

                      

                       Navigator.push(context, MaterialPageRoute(builder: (context) => UserChatScreen(turfId: turfId.docs.first.id, turfName: turfDetails['turfName']),));
                       
                      },
                      icon: Icon(Icons.chat, color: Colors.white),
                      label: Text("Chat", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Space between buttons

                  // Review & Feedback Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async{
                        final playerId = await LoginServices().getPlayerId();
                        final  turfId = widget.turfId;
                        // Navigate to Review & Feedback Screen (Replace with actual screen)
                      showReviewDialog(context,playerId!, turfDetails['_id']);
                        
                      },
                      icon: Icon(Icons.rate_review, color: Colors.white),
                      label: Text("Review", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),


            
             Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {

          Navigator.push(context, MaterialPageRoute(builder: (context) => TurfBookingScreen(turfName: turfDetails['turfName']??'', turfId: turfDetails['_id']??'', hourlyPrice: double.tryParse(turfDetails['fair'].toString())??0,),));
         
        },
        icon: Icon(Icons.map, color: Colors.white),
        label: Text("Book now" ,style: TextStyle(color: Colors.white),),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
  ),

  SizedBox(height: 20),



          ],
        ),
      );
        },
      ),
    );
  }
}
