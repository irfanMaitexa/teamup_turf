import 'package:flutter/material.dart';
import 'package:teamup_turf/admin/screens/admin_turf_details_screen.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminTurfManagementScreen extends StatefulWidget {
  @override
  _AdminTurfManagementScreenState createState() =>
      _AdminTurfManagementScreenState();
}

class _AdminTurfManagementScreenState extends State<AdminTurfManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Turf Management",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 4.0,
          tabs: [
            const Tab(text: "Pending"),
            const Tab(text: "Approved"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TurfListTab(status: "Pending"),
          TurfListTab(status: "Approved"),
        ],
      ),
    );
  }
}

class TurfListTab extends StatefulWidget {
  final String status;

  TurfListTab({required this.status});

  @override
  _TurfListTabState createState() => _TurfListTabState();
}

class _TurfListTabState extends State<TurfListTab> {
  late Future<List<dynamic>> turfListFuture;

  @override
  void initState() {
    super.initState();
    turfListFuture =
        AdminApiServices().getTurfs(status: widget.status.toLowerCase());
  }

  void _updateTurfList() {
    setState(() {
      turfListFuture =
          AdminApiServices().getTurfs(status: widget.status.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: turfListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading turfs"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No turfs available"));
        }

        final turfList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: turfList.length,
          itemBuilder: (context, index) {
            final turf = turfList[index];
            return TurfCard(
              name: turf['turfName'] ?? 'N/A',
              location: turf['location'] ?? 'N/A',
              contact: turf['contact'] ?? 'N/A',
              imageUrl: (turf['documentUrl'] as List?)?.isNotEmpty ?? false
                  ? turf['documentUrl'][0]
                  : 'https://5.imimg.com/data5/ANDROID/Default/2022/2/YU/YX/EV/142636168/product-jpeg-500x500.jpg',
              documentUrl: (turf['documentUrl'] as List?)?.isNotEmpty ?? false
                  ? turf['documentUrl'][0]
                  : 'https://5.imimg.com/data5/ANDROID/Default/2022/2/YU/YX/EV/142636168/product-jpeg-500x500.jpg',
              fair: turf['fair'] ?? 'N/A',
              timeSlots: [],
              status: widget.status,
              turfId: turf['loginId'],
              onTurfUpdated: _updateTurfList, // Pass the update function
            );
          },
        );
      },
    );
  }
}

class TurfCard extends StatelessWidget {
  final String name;
  final String location;
  final String contact;
  final String documentUrl;
  final String imageUrl;
  final String fair;
  final List<String> timeSlots;
  final String status;
  final String turfId;
  final Function() onTurfUpdated; // Callback to trigger UI refresh

  TurfCard({
    required this.name,
    required this.location,
    required this.contact,
    required this.documentUrl,
    required this.imageUrl,
    required this.fair,
    required this.timeSlots,
    required this.status,
    required this.turfId,
    required this.onTurfUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TurfDetailsScreen(
              turfId: turfId,
              timeSlots: timeSlots,
              amenities: ['hi'],
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      documentUrl,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Location: $location",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        Text(
                          "Contact: $contact",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 20, thickness: 1, color: Colors.grey[300]),
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(
                          documentUrl); // Ensure documentUrl is a valid URL
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Could not open the document')),
                        );
                      }
                    },
                    child: const Text(
                      "View Document",
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (status == "Pending")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          String result = await AdminApiServices()
                              .approveTurf(turfId: turfId);
                          onTurfUpdated(); // Trigger the UI update
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.green,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          String result = await AdminApiServices()
                              .rejectTurf(turfId: turfId);
                          onTurfUpdated();
                          // Handle reject action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          textStyle: const TextStyle(
                            color: Colors.red,
                          ),
                          side: const BorderSide(
                            color: Colors.red,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}


void openGoogleMaps(double latitude, double longitude) async {
  final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch Google Maps';
  }
}
