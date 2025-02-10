import 'package:flutter/material.dart';

class EditPageWithFields extends StatefulWidget {
  @override
  _EditPageWithFieldsState createState() => _EditPageWithFieldsState();
}

class _EditPageWithFieldsState extends State<EditPageWithFields> {
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  TextEditingController amenitiesController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  // Sample data for amenities
  List<String> amenities = [
    'WiFi',
    'Parking',
    'Restrooms',
    'Locker Rooms',
    'Lighting',
    'Seating Area',
    'Security Camaras',
    'Food'
  ];
  List<String> selectedAmenities = [];

  // Helper to format time
  String formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> pickTime(BuildContext context, bool isStartTime) async {
    final initialTime = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTimeController.text = formatTime(pickedTime);
        } else {
          endTimeController.text = formatTime(pickedTime);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Amenities Section
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Amenities:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 10,
                        children: amenities.map((amenity) {
                          final isSelected =
                              selectedAmenities.contains(amenity);
                          return FilterChip(
                            label: Text(
                              amenity,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.green[900],
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.green, // Selected color
                            backgroundColor:
                                Colors.green[100], // Unselected color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedAmenities.add(amenity);
                                } else {
                                  selectedAmenities.remove(amenity);
                                }
                                amenitiesController.text =
                                    selectedAmenities.join(', ');
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Display Selected Amenities
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: amenitiesController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Selected Amenities',
                      hintText: 'WiFi, Parking...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.list_alt, color: Colors.green),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Time Slot Section
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Time Slots:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: startTimeController,
                              readOnly: true,
                              onTap: () => pickTime(context, true),
                              decoration: InputDecoration(
                                labelText: 'Start Time',
                                hintText: 'Select Start Time',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: Icon(Icons.access_time,
                                    color: Colors.green),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: endTimeController,
                              readOnly: true,
                              onTap: () => pickTime(context, false),
                              decoration: InputDecoration(
                                labelText: 'End Time',
                                hintText: 'Select End Time',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: Icon(Icons.access_time,
                                    color:
                                        const Color.fromARGB(255, 76, 175, 80)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Save Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Changes saved!'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
